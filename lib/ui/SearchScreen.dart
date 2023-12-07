import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/MessageModel.dart';
import 'package:names/model/SearchUserModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

import '../main.dart';
import 'chat/ChatScreen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  GlobalKey globalKey = GlobalKey();
  String searchText = "";
  Future<List<SearchUserModel>> futureSearchUsers;
  List<SearchUserModel> searchUserList = [];
  List<SearchUserModel> tempSearchUserList = [];
  _appBarWidget(BuildContext context) {
    return Row(
      children: [
        Container(
          child: IconButton(
            icon: Image.asset(
              "assets/icons/back_arrow.png",
              height: 20,
              width: 20,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: Text(
            "Search User",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
/*            IconButton(
              icon: Container(
                child: Image.asset(
                  "assets/icons/menu.png",
                  height: 16,
                  width: 16,
                  color: Colors.black,
                ),
              ),
              onPressed: () {},
            ),*/
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
              body: SafeArea(
                  child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        child: TextFormField(
                            style: TextStyle(color: AppColor.textGrayColor),
                            onChanged: (value) {
                              searchText = value;
                              if (value.isEmpty) {
                                searchUserList.clear();
                                searchUserList.addAll(tempSearchUserList);
                              } else {
                                searchUserList.clear();

                                for (int i = 0;
                                    i < tempSearchUserList.length;
                                    i++) {
                                  tempSearchUserList[i].usersModel.name =
                                      _getName(
                                          tempSearchUserList[i].usersModel);
                                  if (tempSearchUserList[i]
                                      .usersModel
                                      .name
                                      .toString()
                                      .toLowerCase()
                                      .contains(
                                          value.toString().toLowerCase())) {
                                    searchUserList.add(tempSearchUserList[i]);
                                  }
                                }
                              }
                              setState(() {});
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Search",
                              prefixIcon: Icon(
                                Icons.search,
                                color: AppColor.textGrayColor,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              labelStyle: TextStyle(
                                  color: AppColor.textGrayColor, fontSize: 14),
                              hintStyle: TextStyle(
                                  color: AppColor.textGrayColor, fontSize: 14),
                            )),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                          child: FutureBuilder<List<SearchUserModel>>(
                              future: futureSearchUsers, // async work
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<SearchUserModel>>
                                      snapshot) {
                                if (snapshot.hasData) {
                                  return searchUserList.length > 0
                                      ? ListView.separated(
                                          itemCount: searchUserList.length,
                                          shrinkWrap: true,
                                          physics: ClampingScrollPhysics(),
                                          itemBuilder: (ctx, index) {
                                            SearchUserModel searchUserModel =
                                                searchUserList[index];
                                            print("profilephoto" +
                                                searchUserModel
                                                    .usersModel.profilePicture
                                                    .toString());
                                            return GestureDetector(
                                              child: Container(
                                                width: AppHelper.getDeviceWidth(
                                                    context),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
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
                                                        height: 50,
                                                        width: 50,
                                                        margin:
                                                            EdgeInsets.all(5),
                                                        child: ClipRRect(
                                                          child: Stack(
                                                            children: [
                                                              CustomWidget
                                                                  .imageView(
                                                                searchUserModel
                                                                    .usersModel
                                                                    .profilePicture,
                                                                width: 50,
                                                                fit: BoxFit
                                                                    .cover,
                                                                forProfileImage:
                                                                    true,
                                                              ),
                                                              !searchUserModel
                                                                      .isGroup
                                                                  ? AppHelper.professtionWidget(
                                                                      searchUserModel
                                                                          .usersModel
                                                                          .profession_symbol)
                                                                  : SizedBox()
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
                                                          // height: 50,
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
                                                                      children: [
                                                                        Flexible(
                                                                          child:
                                                                              Text(
                                                                            _getName(searchUserModel.usersModel),
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
                                                                            searchUserModel.usersModel.licenseExpiryDate,
                                                                            16,
                                                                            16),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      searchUserModel
                                                                          .messageModel
                                                                          .message
                                                                          .toString(),
                                                                      style: TextStyle(
                                                                          color:
                                                                              AppColor.textGrayColor),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.of(context)
                                                    .push(PageRouteBuilder(
                                                  pageBuilder: (BuildContext
                                                              context,
                                                          Animation<double>
                                                              animation,
                                                          Animation<double>
                                                              secondaryAnimation) =>
                                                      ChatScreen(searchUserModel
                                                          .usersModel),
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
                                        )
                                      : Center(
                                          child: Text(getText()),
                                        );
                                }
                                return ProgressDialog
                                    .getCircularProgressIndicator();
                              })),
                    ],
                  ),
                ),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              )),
            );
          } else {
            return Container(
              color: AppColor.skyBlueColor,
            );
          }
        }));
  }

  @override
  void initState() {
    if (mounted) {
      getConnectedChatUser();
    }
    super.initState();
  }

  getConnectedChatUser() {
    FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .where(FirebaseKey.users,
            arrayContains: appUserSession.value.id.toString())
        .orderBy(
          FirebaseKey.lastMessage + "." + FirebaseKey.sentAt,
          descending: true,
        )
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((QueryDocumentSnapshot queryDocumentSnapshot) {
        Map data = queryDocumentSnapshot.data();
        MessageModel messageModel =
            MessageModel.fromJson(data[FirebaseKey.lastMessage]);
        String receiverID =
            messageModel.receiver == appUserSession.value.id.toString()
                ? messageModel.sender.toString()
                : messageModel.receiver.toString();
        UsersModel usersModel;
        for (int i = 0; i < data[FirebaseKey.usersData].length; i++) {
          usersModel = UsersModel.fromJson(data[FirebaseKey.usersData][i]);
          if (receiverID == usersModel.id.toString()) {
            break;
          }
        }
        searchUserList.add(new SearchUserModel(messageModel, usersModel));
        tempSearchUserList.add(new SearchUserModel(messageModel, usersModel));
      });

      futureSearchUsers = Future.delayed(Duration(seconds: 0), () {
        setState(() {});
        return searchUserList;
      });
    });
  }

  String getText() {
    if (searchText != null && searchText.isNotEmpty) {
      return "No chat found";
    }
    return "No record found";
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
}
