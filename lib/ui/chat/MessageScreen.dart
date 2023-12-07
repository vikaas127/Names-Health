import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/custom_widget/group_menu_dialog.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/GroupDataModel.dart';
import 'package:names/model/MessageModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:names/ui/chat/ChatScreen.dart';
import 'package:names/ui/chat/ConnectedUserScreen.dart';
import 'package:names/ui/chat/GroupChatScreen.dart';
import 'package:names/ui/chat/GroupScreen.dart';
import 'package:names/ui/SearchScreen.dart';

import '../../main.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({Key key}) : super(key: key);

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  List<MessageModel> messageList = [];
  GlobalKey globalKey = GlobalKey();
  Stream<QuerySnapshot> stream;
  Stream<QuerySnapshot> groupStream;
  bool isStreamEmpty = false, isGroupStream = false;

  _appBarWidget(BuildContext context) {
    return Row(
      children: [
        Container(
          child: IconButton(
            icon: Image.asset(
              "assets/icons/message_black.png",
              height: 20,
              width: 20,
            ),
            onPressed: () {},
          ),
        ),
        Expanded(
          child: Text(
            "Consults",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: Container(
            child: Image.asset(
              "assets/icons/search.png",
              height: 16,
              width: 16,
            ),
          ),
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  SearchScreen(),
              transitionDuration: Duration(seconds: 0),
            ));
          },
        ),
        IconButton(
          key: globalKey,
          icon: Container(
            child: Image.asset(
              "assets/icons/menu.png",
              height: 16,
              width: 16,
            ),
          ),
          onPressed: () {
            GroupMenuDialog().show(context, globalKey, (menuValue) {
              if (menuValue.toString() == "message") {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) =>
                      ConnectedUserScreen(),
                  transitionDuration: Duration(seconds: 0),
                ));
              } else if (menuValue.toString() == "group") {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) =>
                      GroupScreen(),
                  transitionDuration: Duration(seconds: 0),
                ));
              }
            });
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
          if (snapshot.hasData && snapshot.data != null && snapshot.data.data() != null) {
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
                                    AppColor.skyBlueColor,
                                    AppColor.skyBlueColor
                                  ])),
                            ],
                          ),
                        )
                      : AppHelper.appBar(
                          context,
                          _appBarWidget(context),
                          LinearGradient(colors: [
                            AppColor.skyBlueColor,
                            AppColor.skyBlueColor
                          ])),
              backgroundColor: AppColor.skyBlueColor,
              body: Container(
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        StreamBuilder<QuerySnapshot>(
                            stream: groupStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError)
                                return Center(
                                    child:
                                        new Text('Error: ${snapshot.error}'));
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Center();
                                default:
                                  isGroupStream =
                                      snapshot.data.docs.length == 0;
                                  if (isStreamEmpty && isGroupStream) {
                                    Future.delayed(Duration.zero, () async {
                                      setState(() {});
                                    });
                                  }
                                  return snapshot.data.docs.length > 0
                                      ? Column(
                                          children: [
                                            ListView.separated(
                                              itemCount:
                                                  snapshot.data.docs.length,
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              padding: EdgeInsets.zero,
                                              itemBuilder: (ctx, index) {
                                                Map data = snapshot
                                                    .data.docs[index].data();
                                                // dynamic jsn = json.encode(data);

                                                GroupDataModel groupDataModel =
                                                    GroupDataModel.fromJson(
                                                        data);

                                                Map<String, dynamic> map =
                                                    groupDataModel.unreadCount;
                                                int unreadCount = map[
                                                            appUserSession
                                                                .value.id
                                                                .toString()] !=
                                                        null
                                                    ? map[appUserSession
                                                        .value.id
                                                        .toString()]
                                                    : 0;

                                                if (groupDataModel.deleted_user.contains(appUserSession
                                                        .value.id)) {
                                                  return Container();
                                                }
                                                return GestureDetector(
                                                  child: Container(
                                                    width: AppHelper
                                                        .getDeviceWidth(
                                                            context),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.white,
                                                    ),
                                                    padding: EdgeInsets.all(5),
                                                    child: Container(
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Container(
                                                            height: 60,
                                                            width: 60,
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child: ClipRRect(
                                                              child: Stack(
                                                                children: [
                                                                  CustomWidget
                                                                      .imageView(
                                                                    groupDataModel
                                                                        .groupImage,
                                                                    backgroundColor:
                                                                        AppColor
                                                                            .profileBackColor,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    width: double
                                                                        .infinity,
                                                                    height: double
                                                                        .infinity,
                                                                    forGroupImage:
                                                                        true,
                                                                  ),
                                                                ],
                                                              ),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child: Container(
                                                              height: 70,
                                                              margin: EdgeInsets
                                                                  .all(5),
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .max,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Flexible(
                                                                              child: Text(
                                                                                groupDataModel.groupName.toString(),
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(fontSize: 16, fontFamily: "Lato_Bold", color: Colors.black),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 5,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        SizedBox(
                                                                          height:
                                                                              5,
                                                                        ),
                                                                        groupDataModel.lastMessage !=
                                                                                null
                                                                            ? Text(
                                                                                groupDataModel.lastMessage.delete_from.contains(appUserSession.value.id.toString()) ? "" : getLastMessagetext(groupDataModel.lastMessage.message, groupDataModel.lastMessage.messageType, groupDataModel.lastMessage.file),
                                                                                maxLines: 1,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(color: AppColor.textGrayColor),
                                                                              )
                                                                            : SizedBox(),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .end,
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      Text(
                                                                        groupDataModel.lastMessage.delete_from.contains(appUserSession.value.id.toString())
                                                                            ? ""
                                                                            : AppHelper.timeAgoSinceDate(groupDataModel.lastMessage.sentAt),
                                                                        style: TextStyle(
                                                                            color:
                                                                                AppColor.textGrayColor),
                                                                      ),
                                                                      unreadCount >
                                                                              0
                                                                          ? Container(
                                                                              constraints: BoxConstraints(minHeight: 20, minWidth: 20),
                                                                              alignment: Alignment.center,
                                                                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(5)),
                                                                              padding: EdgeInsets.all(5),
                                                                              child: Text(
                                                                                unreadCount.toString(),
                                                                                style: TextStyle(color: Colors.white),
                                                                              ),
                                                                            )
                                                                          : SizedBox(),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    Navigator.of(context)
                                                        .push(PageRouteBuilder(
                                                      pageBuilder: (BuildContext
                                                                  context,
                                                              Animation<double>
                                                                  animation,
                                                              Animation<double>
                                                                  secondaryAnimation) =>
                                                          GroupChatScreen(
                                                              groupDataModel),
                                                      transitionDuration:
                                                          Duration(seconds: 0),
                                                    ));
                                                  },
                                                );
                                              },
                                              separatorBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                return SizedBox(
                                                  height: 20,
                                                );
                                              },
                                            ),
                                            SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        )
                                      : Center();
                              }
                            }),
                        StreamBuilder<QuerySnapshot>(
                            stream: stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError)
                                return Center(
                                    child:
                                        new Text('Error: ${snapshot.error}'));
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return Container(
                                    height:
                                        MediaQuery.of(context).size.height / 2,
                                    width: MediaQuery.of(context).size.width,
                                    alignment: Alignment.bottomCenter,
                                    child: ProgressDialog
                                        .getCircularProgressIndicator(),
                                  );
                                default:
                                  isStreamEmpty =
                                      snapshot.data.docs.length == 0;
                                  if (isStreamEmpty && isGroupStream) {
                                    Future.delayed(Duration.zero, () async {
                                      setState(() {});
                                    });
                                  }
                                  return snapshot.data.docs.length > 0
                                      ? ListView.separated(
                                          itemCount: snapshot.data.docs.length,
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemBuilder: (ctx, index) {
                                            Map data = snapshot.data.docs[index].data();
                                            MessageModel messageModel = MessageModel.fromJson(data[FirebaseKey.lastMessage]);

                                            String receiverID = messageModel
                                                        .receiver ==
                                                    appUserSession.value.id.toString()
                                                ? messageModel.sender.toString()
                                                : messageModel.receiver
                                                    .toString();
                                            UsersModel usersModel;
                                            for (int i = 0;
                                                i <
                                                    data[FirebaseKey.usersData]
                                                        .length;
                                                i++) {
                                              usersModel = UsersModel.fromJson(
                                                  data[FirebaseKey.usersData]
                                                      [i]);
                                              if (receiverID ==
                                                  usersModel.id.toString()) {
                                                break;
                                              }
                                            }

                                            Map<String, dynamic> map =
                                                data[FirebaseKey.unreadCount];
                                            int unreadCount = map[appUserSession
                                                        .value.id
                                                        .toString()] !=
                                                    null
                                                ? map[appUserSession.value.id
                                                    .toString()]
                                                : 0;

                                            return GestureDetector(
                                              child: Container(
                                                width: AppHelper.getDeviceWidth(
                                                    context),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: messageModel.isSelected
                                                      ? AppColor.skyBlueBoxColor
                                                      : Colors.white,
                                                ),
                                                padding: EdgeInsets.all(5),
                                                child: Container(
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Container(
                                                        height: 60,
                                                        width: 60,
                                                        margin:
                                                            EdgeInsets.all(5),
                                                        child: ClipRRect(
                                                          child: Stack(
                                                            children: [
                                                              CustomWidget.imageView(
                                                                usersModel.profilePicture,
                                                                backgroundColor: AppColor.profileBackColor,
                                                                fit: BoxFit.cover,
                                                                width: double.infinity,
                                                                height: double.infinity,
                                                                forProfileImage: true,
                                                              ),
                                                              AppHelper.professtionWidget(
                                                                      usersModel.profession_symbol),
                                                            ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          height: 70,
                                                          margin:
                                                              EdgeInsets.all(5),
                                                          alignment: Alignment
                                                              .centerLeft,
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .center,
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .max,
                                                                  children: [
                                                                    Row(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            _getName(usersModel),
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontSize: 16,
                                                                                fontFamily: "Lato_Bold",
                                                                                color: Colors.black),
                                                                          ),
                                                                        ),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                        AppHelper.ShildWidget(
                                                                            usersModel.licenseExpiryDate,
                                                                            16,
                                                                            16),
                                                                        SizedBox(
                                                                          width:
                                                                              5,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    messageModel !=
                                                                            null
                                                                        ? Text(
                                                                            messageModel.delete_from.contains(appUserSession.value.id.toString())
                                                                                ? ""
                                                                                : getLastMessagetext(messageModel.message, messageModel.messageType, messageModel.file),
                                                                            maxLines: 1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(color: AppColor.textGrayColor),
                                                                          )
                                                                        : SizedBox(),
                                                                  ],
                                                                ),
                                                              ),
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .end,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    messageModel.delete_from.contains(appUserSession
                                                                            .value
                                                                            .id
                                                                            .toString())
                                                                        ? ""
                                                                        : AppHelper.timeAgoSinceDate(
                                                                            messageModel.sentAt),
                                                                    style: TextStyle(
                                                                        color: AppColor
                                                                            .textGrayColor),
                                                                  ),
                                                                  unreadCount >
                                                                          0
                                                                      ? Container(
                                                                          constraints: BoxConstraints(
                                                                              minHeight: 20,
                                                                              minWidth: 20),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          decoration: BoxDecoration(
                                                                              color: Colors.red,
                                                                              borderRadius: BorderRadius.circular(5)),
                                                                          padding:
                                                                              EdgeInsets.all(5),
                                                                          child:
                                                                              Text(
                                                                            unreadCount.toString(),
                                                                            style:
                                                                                TextStyle(color: Colors.white),
                                                                          ),
                                                                        )
                                                                      : SizedBox(),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              onTap: () async {
                                                bool multiSelected = false;
                                                messageList.forEach(
                                                    (MessageModel data) {
                                                  if (data.isSelected) {
                                                    multiSelected = true;
                                                    return;
                                                  }
                                                });
                                                if (multiSelected) {
                                                  setState(() {
                                                    messageModel.isSelected =
                                                        !messageModel
                                                            .isSelected;
                                                  });
                                                } else {
                                                  Navigator.of(context)
                                                      .push(PageRouteBuilder(
                                                    pageBuilder: (BuildContext
                                                                context,
                                                            Animation<double>
                                                                animation,
                                                            Animation<double>
                                                                secondaryAnimation) =>
                                                        ChatScreen(usersModel),
                                                    transitionDuration:
                                                        Duration(seconds: 0),
                                                  ));
                                                }
                                              },
                                              onLongPress: () {
                                                setState(() {
                                                  messageModel.isSelected =
                                                      !messageModel.isSelected;
                                                });
                                              },
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return SizedBox(
                                              height: 20,
                                            );
                                          },
                                        )
                                      : Center();
                              }
                            }),
                        isStreamEmpty && isGroupStream
                            ? _noRecordsWidget(context)
                            : Container()
                      ],
                    ),
                  )),
            );
          }
          return Container(
            color: AppColor.skyBlueColor,
          );
        })
    );
  }

  @override
  void initState() {
    if (mounted) {
      getChatMessages();
    }
    super.initState();
  }

  void getChatMessages() {
    stream = FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .where(FirebaseKey.users,
            arrayContains: appUserSession.value.id.toString())
        .orderBy(
          FirebaseKey.lastMessage + "." + FirebaseKey.sentAt,
          descending: true,
        )
        .snapshots();

    groupStream = FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .where(FirebaseKey.users,
            arrayContains: appUserSession.value.id.toString())
        .orderBy(
          FirebaseKey.lastMessage + "." + FirebaseKey.sentAt,
          descending: true,
        )
        .snapshots();
  }

  _noRecordsWidget(context) {
    return Container(
        height: MediaQuery.of(context).size.height / 2.5,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /*Image.asset(
              "assets/icons/message.png",
              height: 30,
              width: 30,
              // color: AppColor.lightSkyBlueColor,
            ),*/
            Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(FirebaseKey.noChatsYet)),
          ],
        ));
  }

  String _getName(UsersModel usersModel) {
    if (usersModel.name != null) {
      return usersModel.name;
    } else if (usersModel.firstName != null && usersModel.lastName != null) {
      return usersModel.firstName + " " + usersModel.lastName.toString();
    } else {
      return "";
    }
  }

  getLastMessagetext(String message, String messageType, String file) {
    if (messageType != null && messageType == "IMAGE") {
      if (file != null && file.isNotEmpty) {
        return "Image";
      } else {
        return "";
      }
    }
    return message ?? "";
  }
}
