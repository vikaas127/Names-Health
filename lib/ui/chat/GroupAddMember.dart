import 'package:flutter/material.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import '../../model/GroupDataModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/ConnectionModel.dart';
import 'package:names/model/UsersModel.dart';
import '../../main.dart';

class GroupAddMember extends StatefulWidget {
  GroupDataModel groupDataModel;
  GroupAddMember(this.groupDataModel);
  @override
  State<GroupAddMember> createState() => _GroupAddMemberState();
}

class _GroupAddMemberState extends State<GroupAddMember>
    implements ApiCallBackListener {
  TextEditingController groupNameController = TextEditingController();
  GlobalKey globalKey = GlobalKey();

  Future<List<UsersModel>> futureConnectedUsers;
  List<UsersModel> connectedUsersList = [];
  List<UsersModel> selectedConnectedUsersList = [];
  // List<UsersModel> tempConnectedUsersList = [];
  bool isSearching = false;
  TextEditingController controller = TextEditingController();
  List<UsersModel> lstGroupUsers = [];
  ConnectionModel connectionModel;
  bool isPaging = false;
  ScrollController _scrollController = ScrollController();

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
          child: Container(
            height: 50,
            margin: EdgeInsets.only(
              right: 5,
            ),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(
                child: TextFormField(
                  style: TextStyle(color: AppColor.textGrayColor),
                  controller: controller,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    labelStyle: TextStyle(color: AppColor.textGrayColor),
                    hintStyle: TextStyle(color: AppColor.textGrayColor),
                    hintText: "Search",
                  ),
                  textAlignVertical: TextAlignVertical.center,
                ),
              ),
              IconButton(
                onPressed: () {
                  String name = controller.text.trim();
                  if (name.isNotEmpty) {
                    setState(
                      () {
                        isSearching = true;
                      },
                    );
                    getConnectedUsersAPI();
                  }
                },
                icon: Container(
                  child: const Icon(
                    Icons.search_outlined,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(5),
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                      color: AppColor.blueColor, shape: BoxShape.circle),
                ),
                color: Colors.white,
              ),
              if (isSearching)
                IconButton(
                  onPressed: () {
                    setState(
                      () {
                        isSearching = false;
                      },
                    );

                    controller.clear();
                    getConnectedUsersAPI();
                  },
                  icon: Container(
                    child: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                    padding: const EdgeInsets.all(5),
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                        color: AppColor.blueColor, shape: BoxShape.circle),
                  ),
                  color: Colors.white,
                ),
            ]),
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
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          children: [
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 50,
                                width: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: CustomWidget.imageView(
                                    widget.groupDataModel.groupImage,
                                    height: 50,
                                    width: 50,
                                    forGroupImage: true,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                height: 50,
                                child: TextFormField(
                                    enabled: false,
                                    controller: groupNameController,
                                    style: TextStyle(color: AppColor.blueColor),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15.0),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: "Group Name",
                                      filled: true,
                                      fillColor: Colors.white,
                                      labelStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                      hintStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                    )),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: AppColor.fileBoxColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "Participants : " +
                              selectedConnectedUsersList.length.toString() +
                              " of " +
                              connectedUsersList.length.toString(),
                          style: TextStyle(fontFamily: "Lato_Bold"),
                        ),
                      ),
                      selectedConnectedUsersList.length > 0
                          ? Container(
                              height: 100,
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerLeft,
                              child: ListView.separated(
                                itemBuilder: (ctx, index) {
                                  UsersModel userModel =
                                      selectedConnectedUsersList[index];
                                  return Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 65,
                                          width: 55,
                                          child: Stack(
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 5),
                                                height: 50,
                                                width: 50,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  child: CustomWidget.imageView(
                                                    userModel.profilePicture,
                                                    fit: BoxFit.cover,
                                                    height: 50,
                                                    width: 50,
                                                    forProfileImage: true,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                child: Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    width: 15,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: AppColor
                                                            .textGrayColor),
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  setState(() {
                                                    for (int i = 0;
                                                        i <
                                                            connectedUsersList
                                                                .length;
                                                        i++) {
                                                      if (connectedUsersList[i]
                                                              .id ==
                                                          userModel.id) {
                                                        selectedConnectedUsersList
                                                            .removeAt(index);
                                                        connectedUsersList[i]
                                                            .isSelected = false;
                                                        break;
                                                      }
                                                    }
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          userModel.name.toString(),
                                          style: TextStyle(
                                              fontFamily: "Lato_Bold"),
                                        )
                                      ],
                                    ),
                                  );
                                },
                                itemCount: selectedConnectedUsersList.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return SizedBox(
                                    width: 10,
                                  );
                                },
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        width: MediaQuery.of(context).size.width,
                        child: Text(
                          "Suggestions :",
                          style:
                              TextStyle(fontSize: 16, fontFamily: "Lato_Bold"),
                        ),
                      ),
                      Expanded(
                          child: FutureBuilder<List<UsersModel>>(
                              future: futureConnectedUsers, // async work
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<UsersModel>> snapshot) {
                                if (snapshot.hasData) {
                                  return connectedUsersList.length > 0
                                      ? Column(children: [
                                          Expanded(
                                              child:
                                                  NotificationListener<
                                                          ScrollNotification>(
                                                      onNotification:
                                                          (ScrollNotification
                                                              scroll) {
                                                        if (scroll
                                                                is ScrollEndNotification &&
                                                            _scrollController
                                                                    .position
                                                                    .maxScrollExtent ==
                                                                _scrollController
                                                                    .position
                                                                    .pixels) {
                                                          if (connectionModel
                                                                      .data
                                                                      .nextPageUrl !=
                                                                  null &&
                                                              !isPaging) {
                                                            setState(() {
                                                              isPaging = true;
                                                            });
                                                            getConnectedUsersNextAPI(
                                                                connectionModel
                                                                    .data
                                                                    .nextPageUrl);
                                                          }
                                                        }
                                                        return false;
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(20),
                                                        child:
                                                            ListView.separated(
                                                          controller:
                                                              _scrollController,
                                                          physics:
                                                              ClampingScrollPhysics(),
                                                          itemBuilder:
                                                              (ctx, index) {
                                                            UsersModel
                                                                userModel =
                                                                connectedUsersList[
                                                                    index];
                                                            return GestureDetector(
                                                              child: Container(
                                                                width: AppHelper
                                                                    .getDeviceWidth(
                                                                        context),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              10),
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                child:
                                                                    Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            Row(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.start,
                                                                          children: [
                                                                            Container(
                                                                              height: 50,
                                                                              width: 50,
                                                                              margin: EdgeInsets.all(5),
                                                                              child: ClipRRect(
                                                                                child: Stack(
                                                                                  children: [
                                                                                    CustomWidget.imageView(userModel.profilePicture, backgroundColor: AppColor.profileBackColor, fit: BoxFit.cover, forProfileImage: true, width: 50, height: 50),
                                                                                    AppHelper.professtionWidget(userModel.profession_symbol),
                                                                                  ],
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                            ),
                                                                            SizedBox(
                                                                              width: 10,
                                                                            ),
                                                                            Expanded(
                                                                              child: Container(
                                                                                height: 70,
                                                                                margin: EdgeInsets.all(5),
                                                                                alignment: Alignment.centerLeft,
                                                                                child: Row(
                                                                                  children: [
                                                                                    Expanded(
                                                                                      child: Column(
                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        mainAxisSize: MainAxisSize.max,
                                                                                        children: [
                                                                                          Row(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              Flexible(
                                                                                                child: Text(
                                                                                                  userModel.name,
                                                                                                  maxLines: 2,
                                                                                                  overflow: TextOverflow.ellipsis,
                                                                                                  style: TextStyle(fontSize: 16, fontFamily: "Lato_Bold", color: Colors.black),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: 5,
                                                                                              ),
                                                                                              AppHelper.ShildWidget(userModel.licenseExpiryDate, 16, 16)
                                                                                            ],
                                                                                          ),
                                                                                          SizedBox(
                                                                                            height: 5,
                                                                                          ),
                                                                                          Text(
                                                                                            AppHelper.setText(userModel.profession),
                                                                                            maxLines: 1,
                                                                                            overflow: TextOverflow.ellipsis,
                                                                                            style: TextStyle(color: AppColor.textGrayColor),
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
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      Container(
                                                                        height:
                                                                            15,
                                                                        width:
                                                                            15,
                                                                        decoration: BoxDecoration(
                                                                            color: userModel.isSelected
                                                                                ? AppColor.lightSkyBlueColor
                                                                                : AppColor.skyBlueBoxColor,
                                                                            borderRadius: BorderRadius.circular(100)),
                                                                        child: userModel.isSelected
                                                                            ? Icon(
                                                                                Icons.done,
                                                                                size: 10,
                                                                                color: Colors.white,
                                                                              )
                                                                            : null,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              onTap: () {
                                                                setState(() {
                                                                  if (userModel
                                                                      .isSelected) {
                                                                    for (int i =
                                                                            0;
                                                                        i < selectedConnectedUsersList.length;
                                                                        i++) {
                                                                      if (selectedConnectedUsersList[i]
                                                                              .id ==
                                                                          connectedUsersList[index]
                                                                              .id) {
                                                                        selectedConnectedUsersList
                                                                            .removeAt(i);
                                                                        userModel.isSelected =
                                                                            false;
                                                                        break;
                                                                      }
                                                                    }
                                                                  } else {
                                                                    userModel
                                                                            .isSelected =
                                                                        true;
                                                                    selectedConnectedUsersList.add(
                                                                        connectedUsersList[
                                                                            index]);
                                                                  }
                                                                });
                                                              },
                                                            );
                                                          },
                                                          itemCount:
                                                              connectedUsersList
                                                                  .length,
                                                          shrinkWrap: true,
                                                          separatorBuilder:
                                                              (BuildContext
                                                                      context,
                                                                  int index) {
                                                            return SizedBox(
                                                              height: 10,
                                                            );
                                                          },
                                                        ),
                                                      ))),
                                          if (isPaging &&
                                              connectionModel
                                                      .data.nextPageUrl !=
                                                  null)
                                            Container(
                                              height: 50,
                                              child: ProgressDialog
                                                  .getCircularProgressIndicator(),
                                            ),
                                        ])
                                      : Center(
                                          child: AppHelper.getNoRecordWidget(
                                              context,
                                              "assets/icons/connection.png",
                                              "No connections yet",
                                              MainAxisAlignment.center),
                                        );
                                }
                                return ProgressDialog
                                    .getCircularProgressIndicator();
                              })),
                      GestureDetector(
                        child: Container(
                          width: AppHelper.getDeviceWidth(context),
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: AppColor.lightSkyBlueColor),
                          alignment: Alignment.center,
                          child: Text(
                            "ADD",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          addInGroup();
                        },
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
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

  getConnectedUsersAPI() {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: true,
          httpType: HttpMethods.POST,
          url: Url.networkList,
          apiAction: ApiAction.networkList,
          body: body);
    } else {
      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.networkList,
        apiAction: ApiAction.networkList,
      );
    }
  }

  getConnectedUsersNextAPI(String url) {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
    }
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: url,
        apiAction: ApiAction.pagination,
        body: body);
  }

  @override
  void initState() {
    groupNameController.text = widget.groupDataModel.groupName;
    List<int> deleted_user = widget.groupDataModel.deleted_user;
    for (int i = 0; i < widget.groupDataModel.usersData.length; i++) {
      UsersModel usersModel =
          UsersModel.fromJson(widget.groupDataModel.usersData[i].toJson());
      if (deleted_user.contains(int.parse(usersModel.id.toString()))) {
        continue;
      }
      lstGroupUsers.add(usersModel);
    }
    if (mounted) {
      getConnectedUsersAPI();
    }
    super.initState();
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.networkList) {
      connectionModel = ConnectionModel.fromJson(result);
      if (connectionModel.success) {
        connectedUsersList.clear();
        List<Data> rmconnectionLst = [];

        for (int i = 0; i < connectionModel.data.list.length; i++) {
          bool found = false;
          for (int j = 0; j < lstGroupUsers.length; j++) {
            if (lstGroupUsers[j].id == connectionModel.data.list[i].id) {
              found = true;
              break;
            }
          }
          if (!found) {
            rmconnectionLst.add(connectionModel.data.list[i]);
          }
        }
        rmconnectionLst.forEach((element) {
          connectedUsersList.add(UsersModel.fromJson(element.toJson()));
        });

        futureConnectedUsers = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return connectedUsersList;
        });
      } else {
        AppHelper.showToastMessage(connectionModel.message);
      }
    } else if (action == ApiAction.pagination) {
      ConnectionModel pagination = ConnectionModel.fromJson(result);
      if (pagination.success) {
        if (connectionModel != null) {
          connectionModel.data.nextPageUrl = pagination.data.nextPageUrl;

          List<Data> rmconnectionLst = [];

          for (int i = 0; i < pagination.data.list.length; i++) {
            bool found = false;
            for (int j = 0; j < lstGroupUsers.length; j++) {
              if (lstGroupUsers[j].id == pagination.data.list[i].id) {
                found = true;
                break;
              }
            }
            if (!found) {
              rmconnectionLst.add(pagination.data.list[i]);
            }
          }
          rmconnectionLst.forEach((element) {
            connectedUsersList.add(UsersModel.fromJson(element.toJson()));
          });
        }

        isPaging = false;
        if (mounted) {
          setState(() {});
        }
      } else {
        isPaging = false;
        if (mounted) {
          setState(() {});
        }

        AppHelper.showToastMessage(pagination.message);
      }
    }
  }

  void addInGroup() {
    String groupName = groupNameController.text.trim();
    if (selectedConnectedUsersList.length == 0) {
      AppHelper.showToastMessage("Please select group users.");
    } else {
      lstGroupUsers.addAll(selectedConnectedUsersList);
      List<String> users = [];
      List<dynamic> usersData = [];

      Map<String, dynamic> usersCountMap = Map();
      lstGroupUsers.forEach((user) {
        users.add(user.id.toString());
        usersData.add(user.toJson());
        usersCountMap[user.id.toString()] = FieldValue.increment(0);
      });

      DocumentReference documentReference = FirebaseFirestore.instance
          .collection(FirebaseKey.groupRoom)
          .doc(widget.groupDataModel.groupID);

      documentReference.get().then((value) {
        Map data = value.data();

        List<dynamic> delete_users = data[FirebaseKey.deleted_user] != null
            ? data[FirebaseKey.deleted_user].toList()
            : [];
        List<dynamic> temp_delete_users = [];
        selectedConnectedUsersList.forEach((element) {
          if (delete_users.contains(element.id)) {
            temp_delete_users.add(element.id);
          }
        });
        delete_users
            .removeWhere((element) => temp_delete_users.contains(element));
        documentReference.update({
          FirebaseKey.deleted_user: delete_users,
          FirebaseKey.users: users,
          FirebaseKey.usersData: usersData,
          FirebaseKey.unreadCount: usersCountMap,
          FirebaseKey.groupCount: lstGroupUsers.length,
        }).then((value) {
          AppHelper.showToastMessage("Added in " + groupName + " group .");
          Navigator.pop(context, true);
        });
      });
    }
  }
}
