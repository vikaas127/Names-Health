import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

import '../../constants/app_color.dart';
import '../../constants/firebaseKey.dart';
import '../../custom_widget/custom_widget.dart';
import '../../helper/AppHelper.dart';
import '../../helper/ProgressDialog.dart';
import '../../main.dart';
import '../../model/GroupDataModel.dart';
import '../../model/UsersModel.dart';
import 'GroupAddMember.dart';

class GroupDetailsPage extends StatefulWidget {
  GroupDataModel groupDataModel;
  GroupDetailsPage(this.groupDataModel);
  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  ScrollController scrollController = ScrollController();
  Stream<DocumentSnapshot<Map<String, dynamic>>> groupUserStream;
  List<UsersModel> lstGroupUsers = [];
  int userCount;
  @override
  void initState() {
    super.initState();
    userCount = widget.groupDataModel.groupCount;
    getGroupUsers();
  }

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
              Navigator.of(context).pop(true);
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
                      maxLines: 2,
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
                userCount.toString() + " users",
                style: TextStyle(fontSize: 13, color: Colors.white),
              ),
            ],
          ),
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
              backgroundColor: AppColor.skyBlueColor,
              body: SafeArea(
                  child: GestureDetector(
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                            stream: groupUserStream,
                            builder: (BuildContext context,
                                AsyncSnapshot<
                                        DocumentSnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasError)
                                return Center(
                                    child:
                                        new Text('Error: ${snapshot.error}'));
                              switch (snapshot.connectionState) {
                                case ConnectionState.waiting:
                                  return ProgressDialog
                                      .getCircularProgressIndicator();
                                default:
                                  if (snapshot.data.data() == null) {
                                    return Center(
                                      child: Text("No users found"),
                                    );
                                  }

                                  Map data = snapshot.data.data();
                                  // dynamic jsn = json.encode(data);
                                  lstGroupUsers.clear();
                                  lstGroupUsers.add(new UsersModel(
                                      id: -1)); //for show add participants
                                  GroupDataModel groupDataModel =
                                      GroupDataModel.fromJson(data);

                                  for (int i = 0;
                                      i < groupDataModel.usersData.length;
                                      i++) {
                                    UsersModel usersModel = UsersModel.fromJson(
                                        groupDataModel.usersData[i].toJson());

                                    if (groupDataModel.deleted_user.contains(
                                        int.parse(usersModel.id.toString()))) {
                                      continue;
                                    }

                                    lstGroupUsers.add(usersModel);
                                  }
                                  if (groupDataModel.deleted_user
                                      .contains(appUserSession.value.id)) {
                                    Future.delayed(Duration(seconds: 1), () {
                                      // setState(() {});
                                      Navigator.pop(context, true);
                                    });
                                    return Container();
                                  }

                                  Future.delayed(Duration(seconds: 1), () {
                                    setState(() {
                                      userCount = groupDataModel.groupCount;
                                    });
                                  });
                                  return ListView.separated(
                                    itemBuilder: (ctx, index) {
                                      UsersModel groupUser =
                                          lstGroupUsers[index];

                                      if (groupUser.id == -1) {
                                        return Visibility(
                                            visible: widget.groupDataModel
                                                    .groupAdminID ==
                                                appUserSession.value.id
                                                    .toString(),
                                            child: GestureDetector(
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
                                                    children: [
                                                      Expanded(
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
                                                              margin: EdgeInsets
                                                                  .all(5),
                                                              child: ClipRRect(
                                                                  borderRadius:
                                                                      BorderRadius.all(
                                                                          Radius.circular(
                                                                              30.0)),
                                                                  child: Container(
                                                                      color: AppColor.blueColor,
                                                                      padding: EdgeInsets.all(5),
                                                                      child: Icon(
                                                                        Icons
                                                                            .group_add,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30,
                                                                      ))),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                height: 50,
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Text(
                                                                  "Add User",
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          "Lato_Bold",
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
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
                                                      GroupAddMember(
                                                          groupDataModel) /*widget.groupDataModel)*/,
                                                  transitionDuration:
                                                      Duration(seconds: 0),
                                                ))
                                                    .then((value) {
                                                  if (value != null && value) {
                                                    Navigator.pop(
                                                        context, true);
                                                  }
                                                });
                                              },
                                            ));
                                      }
                                      return GestureDetector(
                                        child: Container(
                                          width:
                                              AppHelper.getDeviceWidth(context),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.all(5),
                                          child: Container(
                                            child: Row(
                                              children: [
                                                Expanded(
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
                                                              CustomWidget.imageView(
                                                                  groupUser
                                                                      .profilePicture,
                                                                  backgroundColor:
                                                                      AppColor
                                                                          .profileBackColor,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  forProfileImage:
                                                                      true,
                                                                  width: 50,
                                                                  height: 50),
                                                              AppHelper
                                                                  .professtionWidget(
                                                                      groupUser
                                                                          .profession_symbol)
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
                                                                            groupUser.name == appUserSession.value.name
                                                                                ? "You"
                                                                                : groupUser.name,
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
                                                                            groupUser.licenseExpiryDate,
                                                                            16,
                                                                            16)
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                      height: 5,
                                                                    ),
                                                                    Text(
                                                                      AppHelper.setText(
                                                                          groupUser
                                                                              .profession),
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style: TextStyle(
                                                                          color:
                                                                              AppColor.textGrayColor),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Visibility(
                                                                  visible: widget
                                                                          .groupDataModel
                                                                          .groupAdminID ==
                                                                      groupUser
                                                                          .id
                                                                          .toString(),
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                100),
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                AppColor.textGrayColor)),
                                                                    child: Text(
                                                                      "Admin",
                                                                      style: TextStyle(
                                                                          color:
                                                                              AppColor.textGrayColor),
                                                                    ),
                                                                  )),
                                                              Visibility(
                                                                visible: widget
                                                                            .groupDataModel
                                                                            .groupAdminID ==
                                                                        appUserSession
                                                                            .value
                                                                            .id
                                                                            .toString() &&
                                                                    widget.groupDataModel
                                                                            .groupAdminID !=
                                                                        groupUser
                                                                            .id
                                                                            .toString() &&
                                                                    groupUser
                                                                            .id !=
                                                                        appUserSession
                                                                            .value
                                                                            .id,
                                                                child:
                                                                    GestureDetector(
                                                                  onTap: () {
                                                                    callDialog(
                                                                        false,
                                                                        groupUser
                                                                            .id,
                                                                        'Remove ${groupUser.name} from "${widget.groupDataModel.groupName}" group?');
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .all(5),
                                                                    decoration: BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                                100),
                                                                        border: Border.all(
                                                                            width:
                                                                                1,
                                                                            color:
                                                                                Colors.redAccent)),
                                                                    child: Text(
                                                                      "Remove",
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.redAccent),
                                                                    ),
                                                                  ),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        onTap: () {},
                                      );
                                    },
                                    shrinkWrap: true,
                                    itemCount: lstGroupUsers.length,
                                    controller: scrollController,
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Container(
                                        height: 2,
                                        margin:
                                            EdgeInsets.only(top: 5, bottom: 5),
                                      );
                                    },
                                  );
                              }
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          child: AppHelper.button(context, "DELETE",
                              backColor: Colors.redAccent,
                              iconData: Icons.logout),
                          onTap: () {
                            // add exit code
                            callDialog(true, appUserSession.value.id,
                                'Do you want to delete "${widget.groupDataModel.groupName}" group?');
                            // callDialog(true,appUserSession.value.id,'Exit "${widget.groupDataModel.groupName}" group?');
                          },
                        ),
                      ],
                    ),
                  ),
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

  void callDialog(bool isExit, int id, String msg) {
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
                                isExit ? "Delete" : "OK",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              removeFromGroup(isExit, id);
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

  void getGroupUsers() {
    lstGroupUsers.clear();
    groupUserStream = FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .doc(widget.groupDataModel.groupID)
        .snapshots();
  }

  Future<void> removeFromGroup(isExit, id) async {
    print("lstGroupUsers=" + lstGroupUsers.length.toString());
    print("id=" + id.toString());
    print("widget.groupDataModel.groupAdminID=" +
        widget.groupDataModel.groupAdminID.toString());
    bool isAdminGroup = false;
    String groupName = widget.groupDataModel.groupName;
    lstGroupUsers.removeWhere((element) => element.id == -1);
    if (widget.groupDataModel.groupAdminID.toString() == id.toString()) {
      print("group delete =" + lstGroupUsers.length.toString());
      isAdminGroup = true;
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(FirebaseKey.groupRoom)
          .doc(widget.groupDataModel.groupID);

      await FirebaseFirestore.instance
          .runTransaction((Transaction myTransaction) async {
        myTransaction.delete(documentReference);
      });
      documentReference.delete().then((value) {
        AppHelper.showToastMessage("$groupName removed");
        Navigator.pop(context, true);
      });
    } else {
      print("2 lstGroupUsers=" + lstGroupUsers.length.toString());
      lstGroupUsers.removeWhere((element) => element.id == id);

      /*Map<String, dynamic> usersCountMap = Map();
    lstGroupUsers.forEach((user) {
      print("user.toJson()"+user.toString());
      users.add(user.id.toString());
      usersData.add(user.toJson());
      print("usersData.length()"+usersData.length.toString());
      usersCountMap[user.id.toString()] = FieldValue.increment(0);
    });*/
      var users = [
        id,
      ];
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(FirebaseKey.groupRoom)
          .doc(widget.groupDataModel.groupID);

      documentReference.update({
        FirebaseKey.deleted_user: FieldValue.arrayUnion(users),
        FirebaseKey.groupCount: lstGroupUsers.length,
        // FirebaseKey.unreadCount: usersCountMap,
      }).then((value) {
        AppHelper.showToastMessage("Removed successfully");
        getGroupUsers();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}
