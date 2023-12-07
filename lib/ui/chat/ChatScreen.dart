import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:names/Providers/ChatProvider.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ImageHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/ImageResponseModel.dart';

import 'package:names/model/UserStatusModel.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:names/custom_widget/chat_pop_menu.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/model/ChatModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

import 'package:names/ui/Calling/AudioPreviewScreen.dart';
import 'package:names/ui/Calling/PreviewWidget.dart';

import 'package:provider/provider.dart';

import 'package:visibility_detector/visibility_detector.dart';

import '../../app/FirebasePushNotification.dart';
import '../../custom_widget/ChatDeletePopup.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget   {
  UsersModel usersModel;
  ChatScreen(this.usersModel);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen>  with WidgetsBindingObserver implements ApiCallBackListener {
  ChatProvider _chatProvider;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  File file;
  String imageURL;
  GlobalKey globalKey = GlobalKey();
  GlobalKey globalKeyMENU = GlobalKey();
  bool sendingMessage = false;
  bool showEmoji = false;
  KeyboardVisibilityController keyboardVisibilityController;

  String notmessage = '';
  String userStatus = "";
  List<ChatModel> listChatModel = [];
  List<int> blockedBy = [];

  String storeDeviceToken;
  _appBarWidget(BuildContext context) {
    return Row(
      children: [
        Container(
          child: IconButton(
            icon: Image.asset(
              "assets/icons/back_arrow.png",
              height: 20,
              width: 20,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Container(
          height: 40,
          width: 40,
          child: CustomWidget.imageView(
            widget.usersModel.profilePicture,
            fit: BoxFit.cover,
            height: 40,
            width: 40,
            circle: true,
            forProfileImage: true,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      _getName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: "Lato_Bold",
                          color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  AppHelper.ShildWidget(
                      widget.usersModel.licenseExpiryDate, 13, 13),
                ],
              ),
              Text(
                userStatus,
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 5,
        ),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection(FirebaseKey.chatroom)
                .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
                    widget.usersModel.id.toString()))
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                blockedBy = [];
                if (snapshot.data.data() != null) {
                  for (var element
                      in snapshot.data.data()['blocked_by'] ?? []) {
                    blockedBy.add(element);
                  }
                }
                return blockedBy.isNotEmpty &&
                        (blockedBy.contains(appUserSession.value.id) ||
                            !blockedBy.contains(appUserSession.value.id))
                    ? Row(children: [
                        Icon(Icons.videocam),
                        SizedBox(
                          width: 15,
                        ),
                        Icon(
                          Icons.call,
                          size: 20,
                        )
                      ])
                    : checkBlockUnblockWidget();
              } else {
                return checkBlockUnblockWidget();
              }
            }),
        IconButton(
          key: globalKeyMENU,
          icon: Container(
            child: Image.asset(
              "assets/icons/menu.png",
              height: 16,
              width: 16,
              color: Colors.white,
            ),
          ),
          onPressed: () {
            ChatDeletePopup().show(blockedBy.contains(appUserSession.value.id),
                context, globalKeyMENU, (menuValue) async {
              if (menuValue.toString() == "clearAll") {
                callDialog(null, FirebaseKey.delete_message_all, 'Delete', 1,
                    deleteMessage);
              } else if (menuValue.toString() == "block") {
                callDialog(null, "Do you want to block this user?", 'Block', 2,
                    getBlockUnblockAPI);
              } else if (menuValue.toString() == "unblock") {
                callDialog(null, "Do you want to unblock this user?", 'Unblock',
                    3, getBlockUnblockAPI);
              }
            }, false);
          },
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseHelper.getuserCallStatus(
            appUserSession.value.id.toString()),
        builder: ((context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.data() != null) {
            final data = CallStatusModel.fromMap(snapshot.data.data());
            if (data.stopRinging) {
              AppHelper.stopRingtone();
            }
            if (data.callStatus == "ringing") {
              AppHelper.callRingtone();
              AppHelper.playRingtone();
            }

            return Scaffold(
              appBar: data.callStatus == "ringing"
                  ? PreferredSize(
                      child: CallNotificationPopup(),
                      preferredSize: Size(200, 140))
                  : data.onCall
                      ? PreferredSize(
                          preferredSize: Size(200, 140),
                          child: Column(
                            children: [
                              Flexible(child: CallNotificationPopup()),
                              AppHelper.appBar(
                                  context,
                                  _appBarWidget(context),
                                  LinearGradient(colors: [
                                    AppColor.blueColor,
                                    AppColor.blueColor
                                  ])),
                            ],
                          ),
                        )
                      : AppHelper.appBar(
                          context,
                          _appBarWidget(context),
                          LinearGradient(colors: [
                            AppColor.blueColor,
                            AppColor.blueColor
                          ])),
              body: body(),
            );
          }
          return Container(
            color: AppColor.skyBlueColor,
          );
        }));
  }
  Widget body() {
    return SafeArea(
        child: GestureDetector(
      child: Column(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(child: Consumer<ChatProvider>(
                      builder: (BuildContext context, value, child) {
                    if (value.chats != null) {
                      listChatModel.clear();
                      int lastchangedIndex = -1;
                      bool noOneIsVisible = false;
                      List<ChatModel> tempList = [];
                      for (var element in value.chats) {
                        if (element.delete_from
                            .contains(appUserSession.value.id.toString())) {
                          continue; //does not add deleted user
                        }

                        tempList.add(element);
                      }

                      for (int i = 0; i < tempList.length; i++) {
                        ChatModel chatModel = tempList[i];
                        chatModel.strDate =
                            AppHelper.getDatesNumeric(chatModel.sentAt);

                        if (i != 0 &&
                            listChatModel[i - 1].strDate.isNotEmpty &&
                            listChatModel[i - 1].strDate !=
                                AppHelper.getDatesNumeric(chatModel.sentAt)) {
                          lastchangedIndex = i - 1;
                          listChatModel[i - 1].visible = true;
                          noOneIsVisible = true;

                          if (i == tempList.length - 1 &&
                              lastchangedIndex != -1 &&
                              listChatModel[lastchangedIndex].strDate !=
                                  AppHelper.getDatesNumeric(chatModel.sentAt)) {
                            chatModel.visible = true;
                            noOneIsVisible = true;
                          }
                        } else if (i == tempList.length - 1 &&
                            lastchangedIndex != -1 &&
                            listChatModel[lastchangedIndex].strDate !=
                                AppHelper.getDatesNumeric(chatModel.sentAt)) {
                          chatModel.visible = true;
                          noOneIsVisible = true;
                        }

                        listChatModel.add(chatModel);
                      }

                      if (listChatModel.length == 0) {
                        return Center(
                          child: Text("Please initiate the massage!"),
                        );
                      }

                      return RefreshIndicator(
                          displacement: 0,
                          edgeOffset: 10,
                          color: AppColor.darkBlueColor,
                          onRefresh: () async {
                            return value.fetchPreviousChats();
                          },
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: ListView.separated(
                              itemBuilder: (ctx, index) {
                                ChatModel chatModel = listChatModel[index];
                                print(chatModel.messageType);

                                if (!noOneIsVisible &&
                                    index == listChatModel.length - 1) {
                                  listChatModel[index].visible = true;
                                }
                                if (chatModel.sender ==
                                    appUserSession.value.id.toString()) {
                                  return Container(
                                      child: Column(
                                    children: [
                                      _dateWidget(
                                          chatModel, index, value.chats.length),
                                      GestureDetector(
                                        onLongPress: () {
                                          callDialog(
                                              chatModel.messageID,
                                              FirebaseKey.delete_message_single,
                                              'Delete',
                                              1,
                                              deleteMessage);
                                        },
                                        child: chatModel.messageType == 'Call'
                                            ? Container(
                                                height: 30,
                                                padding: EdgeInsets.all(5),
                                                decoration: BoxDecoration(
                                                    color:
                                                        AppColor.skyBlueBoxColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Text(
                                                  chatModel.message +
                                                      " at ${AppHelper.timeOnly(chatModel.sentAt)}",
                                                  style: TextStyle(
                                                      color: Colors.black),
                                                ))
                                            : Container(
                                                margin:
                                                    EdgeInsets.only(left: 100),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      child: Column(
                                                        children: [
                                                          chatModel.file != null
                                                              ? Container(
                                                                  constraints:
                                                                      BoxConstraints(
                                                                          minWidth:
                                                                              120,
                                                                          maxWidth:
                                                                              120),
                                                                  child:
                                                                      FullScreenWidget(
                                                                          child:
                                                                              Hero(
                                                                    tag: "customTag" +
                                                                        index
                                                                            .toString(),
                                                                    child: CustomWidget
                                                                        .imageView(
                                                                      chatModel
                                                                          .file,
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      // height: 120,
                                                                      // width: 120,
                                                                    ),
                                                                  )),
                                                                )
                                                              : SizedBox(),
                                                          AppHelper.isNotEmpty(
                                                                  chatModel
                                                                      .message)
                                                              ? Text(
                                                                  chatModel
                                                                      .message,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                )
                                                              : SizedBox(),
                                                        ],
                                                      ),
                                                      padding: EdgeInsets.all(10),
                                                      decoration: BoxDecoration(
                                                          color: AppColor
                                                              .skyBlueBoxColor,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          AppHelper.timeOnly(
                                                              chatModel.sentAt),
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: AppColor
                                                                  .textGrayColor),
                                                        ),
                                                        SizedBox(
                                                          width: 2,
                                                        ),
                                                        Icon(
                                                          Icons.done_all,
                                                          size: 10,
                                                          color: chatModel
                                                                  .receiverRead
                                                              ? Colors.blue
                                                              : Colors.grey,
                                                        ),
                                                      ],
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                    ],
                                  ));
                                }
                                return VisibilityDetector(
                                  key: Key(value.chats[index].messageID),
                                  onVisibilityChanged:
                                      (VisibilityInfo visibilityInfo) {
                                    double visiblePercentage =
                                        visibilityInfo.visibleFraction * 100;

                                    if (visiblePercentage == 100.0 &&
                                        !chatModel.receiverRead) {
                                      // updating message read status
                                      DocumentReference documentReference =
                                          value.chats[index].ref;
                                      documentReference.update(
                                          {FirebaseKey.receiverRead: true});

                                      // updating unread message count
                                      FirebaseFirestore.instance
                                          .collection(FirebaseKey.chatroom)
                                          .doc(AppHelper.getChatID(
                                              appUserSession.value.id.toString(),
                                              widget.usersModel.id.toString()))
                                          .update({
                                            FirebaseKey.unreadCount +
                                                    "." +
                                                    appUserSession.value.id
                                                        .toString():
                                                FieldValue.increment(-1)
                                          })
                                          .then((value) {})
                                          .catchError((onError) {});
                                    }
                                  },
                                  child: Container(
                                    // margin: EdgeInsets.onlyy(right: 100),
                                    child: Column(
                                      children: [
                                        _dateWidget(
                                            chatModel, index, value.chats.length),
                                        GestureDetector(
                                          onLongPress: () {
                                            callDialog(
                                                chatModel.messageID,
                                                FirebaseKey.delete_message_single,
                                                'Delete',
                                                1,
                                                deleteMessage);
                                          },
                                          child: chatModel.messageType == "Call"
                                              ? Container(
                                                  height: 30,
                                                  padding: EdgeInsets.all(5),
                                                  decoration: BoxDecoration(
                                                      color: AppColor
                                                          .skyBlueBoxColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  child: Text(
                                                    chatModel.message +
                                                        " at ${AppHelper.timeOnly(chatModel.sentAt)}",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ))
                                              : Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      height: 30,
                                                      width: 30,
                                                      child:
                                                          CustomWidget.imageView(
                                                        widget.usersModel
                                                            .profilePicture,
                                                        fit: BoxFit.cover,
                                                        height: 30,
                                                        width: 30,
                                                        circle: true,
                                                        forProfileImage: true,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Container(
                                                            child: Column(
                                                              children: [
                                                                chatModel.file !=
                                                                        null
                                                                    ? Container(
                                                                        constraints: BoxConstraints(
                                                                            minWidth:
                                                                                120,
                                                                            maxWidth:
                                                                                120),
                                                                        child: FullScreenWidget(
                                                                            child: Hero(
                                                                          tag: "customTag" +
                                                                              index.toString(),
                                                                          child: CustomWidget
                                                                              .imageView(
                                                                            chatModel
                                                                                .file,
                                                                            fit: BoxFit
                                                                                .scaleDown,
                                                                            // height: 120,
                                                                            // width: 120,
                                                                          ),
                                                                        )),
                                                                      )
                                                                    : SizedBox(),
                                                                AppHelper.isNotEmpty(
                                                                        chatModel
                                                                            .message)
                                                                    ? Text(
                                                                        chatModel
                                                                            .message,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16),
                                                                      )
                                                                    : SizedBox(),
                                                              ],
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    10),
                                                            decoration:
                                                                BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      topLeft: Radius
                                                                          .circular(
                                                                              10),
                                                                      topRight: Radius
                                                                          .circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                    )),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text(
                                                            AppHelper.timeOnly(
                                                                chatModel.sentAt),
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: AppColor
                                                                    .textGrayColor),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              shrinkWrap: true,
                              itemCount: listChatModel.length,
                              controller: scrollController,
                              reverse: true,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  height: 2,
                                  margin: EdgeInsets.only(top: 5, bottom: 5),
                                );
                              },
                            ),
                          ));
                    } else {
                      return ProgressDialog.getCircularProgressIndicator();
                    }
                  })),
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection(FirebaseKey.chatroom)
                          .doc(AppHelper.getChatID(
                              appUserSession.value.id.toString(),
                              widget.usersModel.id.toString()))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          blockedBy = [];
                          if (snapshot.data.data() != null) {
                            for (var element
                                in snapshot.data.data()['blocked_by'] ?? []) {
                              blockedBy.add(element);
                            }
                          }
                          return Column(children: [
                            blockedBy.isNotEmpty &&
                                    blockedBy.contains(appUserSession.value.id)
                                ? GestureDetector(
                                    onTap: () {
                                      getBlockUnblockAPI('2');
                                    },
                                    child: Container(
                                        margin: EdgeInsets.only(top: 5),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: AppColor.skyBlueBoxColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(
                                          "You blocked this user. Tap to unblock.",
                                          style: TextStyle(fontSize: 16),
                                        )),
                                  )
                                : blockedBy.isNotEmpty &&
                                        !blockedBy
                                            .contains(appUserSession.value.id)
                                    ? Container(
                                        margin: EdgeInsets.only(top: 5),
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            color: AppColor.skyBlueBoxColor,
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Text(
                                          "You are blocked by this user.",
                                          style: TextStyle(fontSize: 16),
                                        ))
                                    : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            if (blockedBy.isEmpty ||
                                !blockedBy.contains(appUserSession.value.id))
                              Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    border: Border.all(
                                        width: 1,
                                        color: AppColor.textGrayColor)),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        showEmoji
                                            ? Icons.keyboard
                                            : Icons.emoji_emotions,
                                        color: AppColor.textGrayColor,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          showEmoji = !showEmoji;
                                          if (showEmoji) {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                          }
                                        });
                                      },
                                    ),
                                    Expanded(
                                        child: TextFormField(
                                            style: TextStyle(
                                                color: AppColor.textGrayColor),
                                            textInputAction:
                                                TextInputAction.newline,
                                            keyboardType:
                                                TextInputType.multiline,
                                            maxLines: 3,
                                            minLines: 1,
                                            controller: messageController,
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Type your text here",
                                              labelStyle: TextStyle(
                                                  color: AppColor.textGrayColor,
                                                  fontSize: 16),
                                              hintStyle: TextStyle(
                                                  color: AppColor.textGrayColor,
                                                  fontSize: 16),
                                            ))),
                                    IconButton(
                                      key: globalKey,
                                      icon: file != null
                                          ? Image.file(
                                              file,
                                              height: 50,
                                              width: 50,
                                            )
                                          : Icon(
                                              Icons.attach_file,
                                              color: AppColor.lightSkyBlueColor,
                                            ),
                                      onPressed: () {
                                        ChatMenuDialog().show(
                                            context, globalKey, (menuValue) {
                                          if (menuValue == "gallery") {
                                            ImageHelper()
                                                .pickFile(
                                                    FileType.image, context)
                                                .then((value) {
                                              file = value;
                                              if (file != null) {
                                                uploadImageAPI();
                                              }
                                            });
                                          } else if (menuValue == "camera") {
                                            ImageHelper()
                                                .pickCameraPhoto(
                                              context,
                                            )
                                                .then((value) {
                                              file = value;
                                              if (file != null) {
                                                uploadImageAPI();
                                              }
                                            });
                                          }
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        sendingMessage
                                            ? Icons.schedule_send
                                            : Icons.send,
                                        color: AppColor.lightSkyBlueColor,
                                      ),
                                      onPressed: () async {
                                        sendTextMessage();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ]);
                        }

                        return Container();
                      }),
                ],
              ),
            ),
          ),
          Offstage(
            offstage: !showEmoji,
            child: Container(
              height: AppHelper.getDeviceWidth(context) / 2,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  messageController
                    ..text += emoji.emoji
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: messageController.text.length));
                },
                onBackspacePressed: () {
                  messageController
                    ..text =
                        messageController.text.characters.skipLast(1).toString()
                    ..selection = TextSelection.fromPosition(
                        TextPosition(offset: messageController.text.length));
                },
                config: Config(
                    columns: 7,
                    emojiSizeMax: 25.0,
                    verticalSpacing: 0,
                    horizontalSpacing: 0,
                    initCategory: Category.RECENT,
                    bgColor: AppColor.skyBlueColor,
                    indicatorColor: Colors.blue,
                    iconColor: Colors.grey,
                    iconColorSelected: Colors.blue,
                    // progressIndicatorColor: Colors.blue,
                    showRecentsTab: true,
                    recentsLimit: 28,
                    // noRecentsText: "No Recent",
                    // noRecentsStyle:
                    //     const TextStyle(fontSize: 20, color: Colors.black26),
                    categoryIcons: const CategoryIcons(),
                    buttonMode: ButtonMode.MATERIAL),
              ),
            ),
          )
        ],
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    ));
  }
  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);
    UpdateusersDataInChatRoom();
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    _chatProvider = Provider.of<ChatProvider>(context, listen: false);
    _chatProvider.userId = widget.usersModel.id.toString();
    _chatProvider.getChats();
    if (mounted) {
      getUserOnlineStatus();
      keyboardVisibilityController = KeyboardVisibilityController();
      keyboardVisibilityController.onChange.listen((bool visible) {
        if (visible && mounted) {
          setState(() {
            showEmoji = false;
          });
        }
      });
    }

    messaging.requestPermission();
    messaging.getToken().then((token) {
      String deviceToken = token;
      storeDeviceToken = token;
      // Use the deviceToken as needed (e.g., send it to the server)
      print('-------------------------------Device Token: $deviceToken');
    });
    super.initState();
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _chatProvider.chats = [];
    super.dispose();
  }
  getBlockUnblockAPI(String isBlock) {
    Map<String, String> body = Map();
    body['is_block'] = isBlock;
    body['block_unblock_user_id'] = widget.usersModel.id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.userBlockUnblock,
        apiAction: ApiAction.userBlockUnblock,
        body: body);
  }
  Future<void> blockUnblockUserFirebase() async {
    if (blockedBy.contains(appUserSession.value.id)) {
      await FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
              widget.usersModel.id.toString()))
          .set({
        "blocked_by": FieldValue.arrayRemove([appUserSession.value.id]),
      }, SetOptions(merge: true));
    } else {
      await FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
              widget.usersModel.id.toString()))
          .set({
        "blocked_by": FieldValue.arrayUnion([appUserSession.value.id]),
      }, SetOptions(merge: true));
    }
  }
  Future<void> sendTextMessage() {
    notmessage = messageController.text;
    if (messageController.text.trim().isNotEmpty) {
      sendMessagetoFirebase();
        sendPushNotification(notmessage);
    } else if (AppHelper.isNotEmpty(imageURL)) {
      sendMessagetoFirebase();
        sendPushNotification(notmessage);
    } else {
      AppHelper.showToastMessage("Please enter message.");
    }
  }
  void uploadImageAPI() {
    Map<String, String> body = Map();
    Map<String, File> mapOfFilesAndKey = Map();
    mapOfFilesAndKey["file"] = file;

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.chatImageUpload,
        apiAction: ApiAction.chatImageUpload,
        body: body,
        mapOfFilesAndKey: mapOfFilesAndKey,
        isMultiPart: true);
  }
  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.chatImageUpload) {
      ImageResponseModel imageResponseModel =
          ImageResponseModel.fromJson(result);
      if (imageResponseModel.success) {
        imageURL = imageResponseModel.data;
        setState(() {});
      } else {
        imageURL = null;
        AppHelper.showToastMessage(imageResponseModel.message);
      }
    } else if (action == ApiAction.userBlockUnblock) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        blockUnblockUserFirebase();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }
  Future<void>UpdateusersDataInChatRoom() async {
   final  OtheruserData= await FirebaseFirestore.instance.collection(FirebaseKey.users)
       .doc(widget.usersModel.id.toString()).get();
   UsersModel usersModel = UsersModel.fromJson(OtheruserData.data());
     widget.usersModel = usersModel;
   var users = [ appUserSession.value.id.toString(), widget.usersModel.id.toString() ];
   var usersData = [
     UsersModel.fromJson(appUserSession.value.toJson()).toJson(),
     usersModel.toJson()
   ];
   FirebaseFirestore.instance
       .collection(FirebaseKey.chatroom)
       .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
       widget.usersModel.id.toString()))
       .set({
     FirebaseKey.users: users,
     FirebaseKey.usersData: usersData,

   }, SetOptions(merge: true));

  }
  Future<void> sendMessagetoFirebase() async {
    ChatModel chatModel;
    if (blockedBy.contains(appUserSession.value.id)) {
      chatModel = ChatModel(
          null,
          messageController.text,
          imageURL != null ? imageURL : null,
          appUserSession.value.id.toString(),
          widget.usersModel.id.toString(),
          FieldValue.serverTimestamp(),
          imageURL != null ? FirebaseKey.IMAGE : FirebaseKey.TEXT,
          true,
          false,
          [appUserSession.value.id.toString()]);
    }
    else if (blockedBy.contains(widget.usersModel.id)) {
      chatModel = ChatModel(
          null,
          messageController.text,
          imageURL != null ? imageURL : null,
          appUserSession.value.id.toString(),
          widget.usersModel.id.toString(),
          FieldValue.serverTimestamp(),
          imageURL != null ? FirebaseKey.IMAGE : FirebaseKey.TEXT,
          true,
          false,
          [widget.usersModel.id.toString()]);
    }
    else {
      chatModel = ChatModel(
          null,
          messageController.text,
          imageURL != null ? imageURL : null,
          appUserSession.value.id.toString(),
          widget.usersModel.id.toString(),
          FieldValue.serverTimestamp(),
          imageURL != null ? FirebaseKey.IMAGE : FirebaseKey.TEXT,
          true,
          false, []);
    }

    setState(() {
      messageController.clear();
      file = null;
      imageURL = null;
    });

    var users = [
      appUserSession.value.id.toString(),
      widget.usersModel.id.toString()
    ];
    var usersData = [
      UsersModel.fromJson(appUserSession.value.toJson()).toJson(),
      widget.usersModel.toJson()
    ];

    // int unreadCount = await getUnreadCount();

    Map<String, dynamic> usersCountMap = Map();
    usersCountMap[widget.usersModel.id.toString()] = FieldValue.increment(1);

    FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
            widget.usersModel.id.toString()))
        .collection(FirebaseKey.messages)
        .add(chatModel.toJson())
        .then((value) {
      FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
              widget.usersModel.id.toString()))
          .collection(FirebaseKey.messages)
          .doc(value.id)
          .update({
        FirebaseKey.messageID: value.id,
      }).then((valuess) {
        // AppHelper.showToastMessage( "id added in db");
        FirebaseFirestore.instance
            .collection(FirebaseKey.chatroom)
            .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
                widget.usersModel.id.toString()))
            .set({
          FirebaseKey.lastMessage: chatModel.toJsonAddId(value.id),
          FirebaseKey.users: users,
          FirebaseKey.usersData: usersData,
          FirebaseKey.unreadCount: usersCountMap,
        }, SetOptions(merge: true));
      });
    }).whenComplete(() {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        scrollController.animateTo(
          scrollController.position.minScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      });
    });
  }
  void getUserOnlineStatus() {
    FirebaseFirestore.instance
        .collection(FirebaseKey.usersStatus)
        .doc(widget.usersModel.id.toString())
        .snapshots()
        .listen((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        UserStatusModel userStatusModel =
            UserStatusModel.fromJson(documentSnapshot.data());
        if (userStatusModel.isOnline) {
          userStatus = "Online";
        } else {
          userStatus = "Offline " +
              AppHelper.timeAgoSinceDate(userStatusModel.offlineTime);
        }
        if (mounted) {
          setState(() {});
        }
      }
    });
  }

  _dateWidget(ChatModel chatModel, int index, int length) {
    return Visibility(
        visible: chatModel.visible
            ? (chatModel.strDate != null && chatModel.strDate.isNotEmpty)
            : false,
        // visible:index1==-1?index==length-1:index==index1,
        child: Container(
          margin: EdgeInsets.all(10),
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: AppColor.skyBlueBoxColor,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                )),
            child: Text(
              chatModel.strDate != null ? chatModel.strDate : "",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ));
  }
  String _getName() {
    if (widget.usersModel.firstName != null &&
        widget.usersModel.lastName != null) {
      return widget.usersModel.firstName +
          " " +
          widget.usersModel.lastName.toString();
    } else if (widget.usersModel.name != null) {
      return widget.usersModel.name;
    } else {
      return "";
    }
  }

  void callDialog(String id, String msg, String btn1, int type, Function function) {
    showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Wrap(
              children: [
                Container(
                  child: Column(
                    children: [
                      Text(
                        msg,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.red,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                btn1,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              if (type == 1) {
                                deleteMessage(id);
                              } else if (type == 2) {
                                getBlockUnblockAPI('1');
                              } else if (type == 3) {
                                getBlockUnblockAPI('2');
                              }
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            child: Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColor.lightSkyBlueColor,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "Cancel",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
  String userId;
  var hasPushedToCall = false;
  AppLifecycleState state;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    this.state = state;
    print("didChangeAppLifecycleState");
    if (state == AppLifecycleState.resumed) {

    }
  }
  Future<void> deleteMessage(String id) async {
    var users = [
      appUserSession.value.id.toString(),
    ];

    ChatModel lastMessageModule = null;
    await FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
            widget.usersModel.id.toString()))
        .get()
        .then((value) {
      Map data = value.data();
      if (data['lastMessage'] != null) {
        lastMessageModule = ChatModel.fromJson(data['lastMessage']);
      }
    });

    if (id != null) {
      if (lastMessageModule != null && lastMessageModule.messageID == id) {
        lastMessageModule.delete_from.addAll(users);
        FirebaseFirestore.instance
            .collection(FirebaseKey.chatroom)
            .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
                widget.usersModel.id.toString()))
            .update({FirebaseKey.lastMessage: lastMessageModule.toJson()});
      }
      FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
              widget.usersModel.id.toString()))
          .collection(FirebaseKey.messages)
          .doc(id)
          .update({
        FirebaseKey.delete_from: FieldValue.arrayUnion(users),
      }).then((value) {
        AppHelper.showToastMessage(FirebaseKey.delete_message_show_single);
        // getGroupUsers();
      });
    } else {
      Map<String, dynamic> usersCountMap = Map();
      usersCountMap[appUserSession.value.id.toString()] = 0;
      await FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
              widget.usersModel.id.toString()))
          .set({
        FirebaseKey.unreadCount: usersCountMap,
      }, SetOptions(merge: true));

      lastMessageModule.delete_from.addAll(users);
      FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
              widget.usersModel.id.toString()))
          .update({FirebaseKey.lastMessage: lastMessageModule.toJson()});

      FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
              widget.usersModel.id.toString()))
          .collection(FirebaseKey.messages)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs
            .forEach((QueryDocumentSnapshot queryDocumentSnapshot) async {
          await queryDocumentSnapshot.reference.update({
            FirebaseKey.delete_from: FieldValue.arrayUnion(users),
          });
        });
      }).then((value) {
        AppHelper.showToastMessage(FirebaseKey.delete_message_show_all);
        // getGroupUsers();
      });
    }
  }
  Widget checkBlockUnblockWidget() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseHelper.getuserCallStatus(
            appUserSession.value.id.toString()),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final data = CallStatusModel.fromMap(snapshot.data.data());
            return data.onCall ||
                    (blockedBy.isNotEmpty &&
                        (blockedBy.contains(appUserSession.value.id) ||
                            !blockedBy.contains(appUserSession.value.id)))
                ? Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(Icons.videocam),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.call,
                        size: 20,
                      ),
                    )
                  ])
                : Row(children: [
                    GestureDetector(
                        onTap: () async {
                          UpdateusersDataInChatRoom();
                          final per =
                              await AppHelper.photoPermissionCheck(context);
                          if (per) {
                          /*  if (!await (TwilioVoice.instance.hasMicAccess())) {
                              print("request mic access");
                              TwilioVoice.instance.requestMicAccess();
                              return;
                            }*/
                            print(widget.usersModel.apntoken);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => PreviewScreen(
                                  apntoken:  widget.usersModel.apntoken ??
                                      widget.usersModel.apntoken,
                                  devicetype:widget.usersModel.devicetype ??
                                      widget.usersModel.devicetype ,
                                  username: appUserSession.value.name??appUserSession.value.firstName,
                                      otherUserId: widget.usersModel.id.toString(),
                                  otherUserName:widget.usersModel.name.toString() ,
                                    )));
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(Icons.videocam),
                        )),
                    SizedBox(
                      width: 15,
                    ),
                    GestureDetector(
                      onTap: () async {
                        UpdateusersDataInChatRoom();
                        final per =
                        await AppHelper.photoPermissionCheck(context);
                        if (per) {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AudioPreviewScreen(
                                apntoken:  widget.usersModel.apntoken ?? widget.usersModel.apntoken,
                                devicetype:widget.usersModel.devicetype ?? widget.usersModel.devicetype,
                                profilePicture: widget.usersModel.profilePicture,
                                username: appUserSession.value.firstName ?? appUserSession.value.name,
                                otherUserName:
                                widget.usersModel.firstName ??
                                    widget.usersModel.name,
                                otherUserId:
                                widget.usersModel.id.toString(),
                              )));

                        }

                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.call,
                          size: 20,
                        ),
                      ),
                    )
                  ]);
          } else {
            return Icon(Icons.videocam);
          }
        });
  }


  void sendPushNotification(String message) async {
    final serverKey = 'AAAAAvcxV_A:APA91bEA72IU695WhvNIYA6o9Dpj0fbxnbU4Ay3Mot1Mwn5viMx6oLI6IeWAB0z-ugQCXgHwyYCSiJgKL7EXLhD7lxSaUHDBUDRHRdITjTDVv4HJalbGgoogF4LKQ2vfNtT5Wh3GKV-M'; // Replace with your FCM server key

    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };
    print("-----------------------" +widget.usersModel.id.toString());
    final body = {
      'notification': {
        'senderId': appUserSession.value.id,
        'title':  appUserSession.value.name,
        'body': message,
        "sound": "Tri-tone",
        'smallIcon' : "assets/icons/launcher_icon.jpg",
         'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      },
      'to': widget.usersModel.apntoken,
        //'condition': "'!${storeDeviceToken}' in topics", // Replace with the topic or device token to send the notification to
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 ) {
      print('Push notification sent successfully');
    } else {
      print('Failed to send push notification');
    }
  }
}
