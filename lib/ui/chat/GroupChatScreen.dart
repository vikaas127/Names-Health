import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:names/Providers/ChatProvider.dart';
import 'package:names/Providers/GroupChatProvider.dart';
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
import 'package:names/main.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/GroupDataModel.dart';
import 'package:names/model/GroupModel.dart';
import 'package:names/model/ImageResponseModel.dart';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/scheduler.dart';

import 'package:names/custom_widget/chat_pop_menu.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:names/ui/chat/GroupDetailsPage.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../custom_widget/ChatDeletePopup.dart';
import 'package:http/http.dart' as http;

class GroupChatScreen extends StatefulWidget {
  GroupDataModel groupDataModel;
  GroupChatScreen(this.groupDataModel);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen>
    implements ApiCallBackListener {
  GroupChatProvider _groupChatProvider;
  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  File file;
  String imageURL;
  Stream<DocumentSnapshot> groupStream;
  GlobalKey globalKey = GlobalKey();
  GlobalKey globalKeyMENU = GlobalKey();
  bool sendingMessage = false;
  String storeDeviceapnToken;
  bool showEmoji = false;
  String notmessage = '';
  String groupId;
  List<GroupModel> listChatModel = [];

  _appBarWidget(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.of(context)
            .push(PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              GroupDetailsPage(widget.groupDataModel),
          transitionDuration: Duration(seconds: 0),
        ))
            .then((value) {
          if (value != null && value) {
            Navigator.pop(context);
            // Navigator.popUntil(context, (route) => false)
          }
        });
      },
      child: Row(
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
              widget.groupDataModel.groupImage,
              fit: BoxFit.cover,
              height: 40,
              width: 40,
              circle: true,
              forGroupImage: true,
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
                        widget.groupDataModel.groupName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Lato_Bold",
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Text(
                  widget.groupDataModel.groupCount.toString() + " users",
                  style: TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          ),
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
              ChatDeletePopup().show(false, context, globalKeyMENU,
                  (menuValue) {
                if (menuValue.toString() == "clearAll") {
                  callDialog(null, FirebaseKey.delete_message_all);
                }
              }, true);
            },
          ),
        ],
      ),
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
              backgroundColor: AppColor.skyBlueColor,
              body: SafeArea(
                  child: GestureDetector(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Container(
                              height: 10,
                              width: AppHelper.getDeviceWidth(context),
                              child: StreamBuilder<DocumentSnapshot>(
                                  stream: groupStream,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<DocumentSnapshot>
                                          snapshot) {
                                    if (snapshot.hasError)
                                      return Center(
                                          child: new Text(
                                              'Error: ${snapshot.error}'));
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return ProgressDialog
                                            .getCircularProgressIndicator();
                                      default:
                                        print("group data=" +
                                            snapshot.data.toString());
                                        if (snapshot.data != null) {
                                          print("group data2=" +
                                              snapshot.data.data().toString());
                                          if (snapshot.data.data() == null) {
                                            Future.delayed(Duration(seconds: 1),
                                                () {
                                              Navigator.pop(context);
                                            });
                                          } else {
                                            Map data = snapshot.data.data();
                                            List<dynamic> deleted_user = data[
                                                        FirebaseKey
                                                            .deleted_user] !=
                                                    null
                                                ? data[FirebaseKey.deleted_user]
                                                    .toList()
                                                : [];
                                            if (deleted_user.contains(
                                                appUserSession.value.id)) {
                                              Future.delayed(
                                                  Duration(seconds: 1), () {
                                                Navigator.pop(context);
                                              });
                                            }
                                            print("delete_from===" +
                                                data[FirebaseKey.deleted_user]
                                                    .toString());
                                          }
                                        }
                                        return Container();
                                    }
                                  }),
                            ),
                            Expanded(
                                child: Consumer<GroupChatProvider>(
                                builder: (BuildContext context, value, child) {
                              if (value.chats != null) {
                                listChatModel.clear();
                                int lastchangedIndex = -1;
                                bool noOneIsVisible = false;

                                List<GroupModel> tempList = [];

                                for (int i = 0; i < value.chats.length; i++) {
                                  GroupModel chatModel =
                                      GroupModel.fromJsonDate(
                                          value.chats[i].toJson(),
                                          AppHelper.getDatesNumeric(
                                              value.chats[i].sentAt));

                                  if (chatModel.delete_from.contains(
                                      appUserSession.value.id.toString())) {
                                    continue; //does not add deleted user
                                  }

                                  tempList.add(chatModel);
                                }

                                for (int i = 0; i < tempList.length; i++) {
                                  GroupModel groupModel = tempList[i];

                                  if (i != 0 &&
                                      listChatModel[i - 1].strDate.isNotEmpty &&
                                      listChatModel[i - 1].strDate !=
                                          AppHelper.getDatesNumeric(
                                              groupModel.sentAt)) {
                                    //set last one is visible
                                    lastchangedIndex = i - 1;
                                    listChatModel[i - 1].visible = true;
                                    noOneIsVisible = true;
                                  } else if (i == tempList.length - 1 &&
                                      lastchangedIndex != -1 &&
                                      listChatModel[lastchangedIndex].strDate !=
                                          AppHelper.getDatesNumeric(
                                              groupModel.sentAt)) {
                                    groupModel.visible = true;
                                    noOneIsVisible = true;
                                  }

                                  listChatModel.add(groupModel);
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
                                          GroupModel groupModel =
                                              listChatModel[index];
                                          if (!noOneIsVisible &&
                                              index == listChatModel.length - 1) {
                                            listChatModel[index].visible = true;
                                          }
                                          UsersModel usersModel;
                                          for (int i = 0;
                                              i <
                                                  widget.groupDataModel.usersData
                                                      .length;
                                              i++) {
                                            usersModel = UsersModel.fromJson(
                                                widget.groupDataModel.usersData[i]
                                                    .toJson());
                                            if (usersModel.id.toString() ==
                                                groupModel.sender.toString()) {
                                              break;
                                            }
                                          }

                                          if (groupModel.sender ==
                                              appUserSession.value.id
                                                  .toString()) {
                                            return Container(
                                                child: Column(children: [
                                              _dateWidget(groupModel, index),
                                              GestureDetector(
                                                onLongPress: () {
                                                  callDialog(
                                                      groupModel.messageID,
                                                      FirebaseKey
                                                          .delete_message_single);
                                                },
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 100),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        child: Column(
                                                          children: [
                                                            groupModel.file !=
                                                                    null
                                                                ? Container(
                                                                    constraints: BoxConstraints(
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
                                                                        groupModel
                                                                            .file,
                                                                        forGroupImage:
                                                                            true,
                                                                        fit: BoxFit
                                                                            .scaleDown,
                                                                        // height: 120,
                                                                        // width: 120,
                                                                      ),
                                                                    )),
                                                                  )
                                                                : SizedBox(),
                                                            AppHelper.isNotEmpty(
                                                                    groupModel
                                                                        .message)
                                                                ? Text(
                                                                    groupModel
                                                                        .message,
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  )
                                                                : SizedBox(),
                                                          ],
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(10),
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
                                                                groupModel
                                                                    .sentAt),
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
                                                            color: groupModel
                                                                        .users
                                                                        .length ==
                                                                    widget
                                                                            .groupDataModel
                                                                            .usersData
                                                                            .length -
                                                                        1
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
                                              )
                                            ]));
                                          }
                                          return VisibilityDetector(
                                            key: Key(value.chats[index].messageID
                                                // tempList[index].messageID
                                                .toString()),
                                            onVisibilityChanged:
                                                (VisibilityInfo visibilityInfo) {
                                              double visiblePercentage =
                                                  visibilityInfo.visibleFraction *
                                                      100;

                                              if (visiblePercentage == 100.0 &&
                                                  !groupModel.users.contains(
                                                      appUserSession.value.id
                                                          .toString())) {
                                                groupModel.users.add(
                                                    appUserSession.value.id
                                                        .toString());
                                                DocumentReference
                                                    documentReference =
                                                    value.chats[index].ref;

                                                documentReference.update({
                                                  FirebaseKey.seen_by:
                                                      groupModel.users
                                                });

                                                // updating unread message count
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        FirebaseKey.groupRoom)
                                                    .doc(widget
                                                        .groupDataModel.groupID)
                                                    .update({
                                                  FirebaseKey.unreadCount +
                                                          "." +
                                                          appUserSession.value.id
                                                              .toString():
                                                      FieldValue.increment(-1)
                                                });
                                              }
                                            },
                                            child: Container(
                                              // margin: EdgeInsets.only(right: 100),
                                              child: Column(children: [
                                                _dateWidget(groupModel, index),
                                                GestureDetector(
                                                  onLongPress: () {
                                                    callDialog(
                                                        groupModel.messageID,
                                                        FirebaseKey
                                                            .delete_message_single);
                                                  },
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        height: 30,
                                                        width: 30,
                                                        child: CustomWidget
                                                            .imageView(
                                                          usersModel
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
                                                                  groupModel.file !=
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
                                                                            child:
                                                                                CustomWidget.imageView(
                                                                              groupModel.file,
                                                                              forGroupImage:
                                                                                  true,
                                                                              fit:
                                                                                  BoxFit.scaleDown,
                                                                              // height: 120,
                                                                              // width: 120,
                                                                            ),
                                                                          )),
                                                                        )
                                                                      : SizedBox(),
                                                                  AppHelper.isNotEmpty(
                                                                          groupModel
                                                                              .message)
                                                                      ? Text(
                                                                          groupModel
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
                                                                        topRight:
                                                                            Radius.circular(
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
                                                                  groupModel
                                                                      .sentAt),
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
                                                )
                                              ]),
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
                                            margin: EdgeInsets.only(
                                                top: 5, bottom: 5),
                                          );
                                        },
                                      ),
                                    ));
                              } else {
                                return ProgressDialog
                                    .getCircularProgressIndicator();
                              }
                            })),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 1, color: AppColor.textGrayColor)),
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
                                          keyboardType: TextInputType.multiline,
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
                                      ChatMenuDialog().show(context, globalKey,
                                          (menuValue) {
                                        if (menuValue == "gallery") {
                                          ImageHelper()
                                              .pickFile(FileType.image, context)
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
                                    onPressed: () {
                                      sendTextMessage();
                                    },
                                  ),
                                ],
                              ),
                            ),
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
                                  TextPosition(
                                      offset: messageController.text.length));
                          },
                          onBackspacePressed: () {
                            messageController
                              ..text = messageController.text.characters
                                  .skipLast(1)
                                  .toString()
                              ..selection = TextSelection.fromPosition(
                                  TextPosition(
                                      offset: messageController.text.length));
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
              )),
            );
          }
          return Container(
            color: AppColor.skyBlueColor,
          );
        }));
  }

  @override
  void initState() {
    if (mounted) {
      getGroupModel();
      _groupChatProvider =
          Provider.of<GroupChatProvider>(context, listen: false);
      _groupChatProvider.groupId = widget.groupDataModel.groupID.toString();
      _groupChatProvider.getChats();
    }
    super.initState();
  }

  @override
  void dispose() {
    groupStream = null;
    super.dispose();
  }

  // void getChatMessages() {
  //   stream = FirebaseFirestore.instance
  //       .collection(FirebaseKey.groupRoom)
  //       .doc(widget.groupDataModel.groupID)
  //       .collection(FirebaseKey.messages)
  //       .orderBy(
  //         FirebaseKey.sentAt,
  //         descending: true,
  //       )
  //       .snapshots();
  // }

  void getGroupModel() {
    groupStream = FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .doc(widget.groupDataModel.groupID)
        .snapshots();
  }

  Future<void> sendTextMessage() {
    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    messaging.getToken().then((token) {
      String deviceToken = token;
      storeDeviceapnToken = token??"";
      print('-------------------------------Device Token: $deviceToken');
    });
    notmessage = messageController.text;
    if (messageController.text.isNotEmpty) {
      sendMessagetoFirebase()
          .whenComplete(() =>
          updateApnToken())
          .whenComplete(() => sendPushNotification(notmessage));
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
    }
  }

  Future<void> sendMessagetoFirebase() async {
    GroupModel groupModel = GroupModel(
      null,
      messageController.text,
      imageURL != null ? imageURL : null,
      appUserSession.value.id.toString(),
      FieldValue.serverTimestamp(),
      imageURL != null ? FirebaseKey.IMAGE : FirebaseKey.TEXT,
    );

    setState(() {
      messageController.clear();
      file = null;
      imageURL = null;
    });

    // int unreadCount = await getUnreadCount();

    Map<String, dynamic> usersCountMap = Map();

    Map map = widget.groupDataModel.unreadCount;
    map.keys.forEach((userID) {
      if (userID.toString() != appUserSession.value.id.toString()) {
        usersCountMap[userID.toString()] = FieldValue.increment(1);
      }
    });

    FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .doc(widget.groupDataModel.groupID)
        .set({
      FirebaseKey.lastMessage: groupModel.toJson(),
      FirebaseKey.unreadCount: usersCountMap,
    }, SetOptions(merge: true));

    FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .doc(widget.groupDataModel.groupID)
        .collection(FirebaseKey.messages)
        .add(groupModel.toJson())
        .then((value) {
      FirebaseFirestore.instance
          .collection(FirebaseKey.groupRoom)
          .doc(widget.groupDataModel.groupID)
          .collection(FirebaseKey.messages)
          .doc(value.id)
          .update({
        FirebaseKey.messageID: value.id,
      }).then((values) {
        // AppHelper.showToastMessage( "id added in db");
        // getGroupUsers();
        print("groupModel.toJsonAddId(value.id)====" +
            groupModel.toJsonAddId(value.id).toString());
        FirebaseFirestore.instance
            .collection(FirebaseKey.groupRoom)
            .doc(widget.groupDataModel.groupID)
            .update({
          FirebaseKey.lastMessage: groupModel.toJsonAddId(value.id),
        });
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

  _dateWidget(GroupModel groupModel, int index) {
    print("_dateWidget " +
        index.toString() +
        " " +
        groupModel.message.toString());
    print(groupModel.visible.toString());
    return Visibility(
        visible: groupModel.visible
            ? (groupModel.strDate != null && groupModel.strDate.isNotEmpty)
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
              groupModel.strDate != null ? groupModel.strDate : "",
              style: TextStyle(fontSize: 16),
            ),
          ),
        ));
  }

  void callDialog(String id, String msg) {
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
                                "Delete",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              deleteMessage(id);
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

  Future<void> deleteMessage(String id) async {
    var users = [
      appUserSession.value.id.toString(),
    ];

    /*Map<String, dynamic> usersCountMap = Map();
    usersCountMap[widget.usersModel.id.toString()] = FieldValue.increment(1);*/

    GroupModel lastMessageModule = null;
    await FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .doc(widget.groupDataModel.groupID)
        .get()
        .then((value) {
      Map data = value.data();
      if (data['lastMessage'] != null) {
        lastMessageModule = GroupModel.fromJson(data['lastMessage']);
      }
    });
    if (id != null) {
      if (lastMessageModule != null && lastMessageModule.messageID == id) {
        lastMessageModule.delete_from.addAll(users);
        FirebaseFirestore.instance
            .collection(FirebaseKey.groupRoom)
            .doc(widget.groupDataModel.groupID)
            .update({FirebaseKey.lastMessage: lastMessageModule.toJson()});
      }

      FirebaseFirestore.instance
          .collection(FirebaseKey.groupRoom)
          .doc(widget.groupDataModel.groupID)
          .collection(FirebaseKey.messages)
          .doc(id)
          .update({
        FirebaseKey.delete_from: FieldValue.arrayUnion(users),
      }).then((value) {
        AppHelper.showToastMessage(FirebaseKey.delete_message_show_single);
        // getGroupUsers();
      });
    } else {
      lastMessageModule.delete_from.addAll(users);
      FirebaseFirestore.instance
          .collection(FirebaseKey.groupRoom)
          .doc(widget.groupDataModel.groupID)
          .update({FirebaseKey.lastMessage: lastMessageModule.toJson()});

      FirebaseFirestore.instance
          .collection(FirebaseKey.groupRoom)
          .doc(widget.groupDataModel.groupID)
          .collection(FirebaseKey.messages)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs
            .forEach((QueryDocumentSnapshot queryDocumentSnapshot) async {
          Map data = queryDocumentSnapshot.data();
          print("data[FirebaseKey.sender]==" +
              data[FirebaseKey.sender].toString());
          print(
              "appUserSession.value.id==" + appUserSession.value.id.toString());

          await queryDocumentSnapshot.reference.update({
            FirebaseKey.delete_from: FieldValue.arrayUnion(users),
          });

          /*if(data[FirebaseKey.sender].toString() == appUserSession.value.id.toString()){
            print("user added==");
          }*/
        });
      }).then((value) {
        AppHelper.showToastMessage(FirebaseKey.delete_message_show_all);
        // getGroupUsers();
      });
    }
  }

  void sendPushNotification(String message) async {
    final serverKey = 'AAAAAvcxV_A:APA91bEA72IU695WhvNIYA6o9Dpj0fbxnbU4Ay3Mot1Mwn5viMx6oLI6IeWAB0z-ugQCXgHwyYCSiJgKL7EXLhD7lxSaUHDBUDRHRdITjTDVv4HJalbGgoogF4LKQ2vfNtT5Wh3GKV-M'; // Replace with your FCM server key

    final url = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };
   // print("-----------------------" +widget.usersModel.id.toString());
    List<UsersData> groupMembers = widget.groupDataModel.usersData;
    for (UsersData member in groupMembers) {
      final body = {
        'notification': {
          'senderId': appUserSession.value.id,
          'title': appUserSession.value.name,
          'body': message,
          "sound": "Tri-tone",
          'smallIcon': "assets/icons/launcher_icon.jpg",
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
        'to': member.apntoken,
        // Assuming deviceToken is the property holding the token
      };

      // final body = {
      //   'notification': {
      //     'senderId': appUserSession.value.id,
      //     'title':  appUserSession.value.name,
      //     'body': message,
      //     "sound": "Tri-tone",
      //     'smallIcon' : "assets/icons/launcher_icon.jpg",
      //     'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      //   },
      //   'to': widget.groupDataModel.usersData.,
      //   //'condition': "'!${storeDeviceToken}' in topics", // Replace with the topic or device token to send the notification to
      // };

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Push notification sent successfully');
      } else {
        print('Failed to send push notification');
      }
    }}

  void updateApnToken() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the groupRoom document and usersData subcollection
    DocumentReference groupRoomRef = firestore.collection('groupRoom').doc(widget.groupDataModel.groupID);
    CollectionReference usersDataRef = groupRoomRef.collection('usersData');

    // Query users with null APN token
    QuerySnapshot usersSnapshot = await usersDataRef.where('apn_token', isEqualTo: "").get();

    // Iterate through users with null APN token and update them
    usersSnapshot.docs.forEach((userDoc) async {
      String userId = userDoc.id;

      // Update the APN token
      await usersDataRef.doc(userId).update({'apn_token': storeDeviceapnToken});
      print('APN token updated for user: $userId');
    });
  }
}
