import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ImageHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/ConnectionModel.dart';
import 'package:names/model/GroupModel.dart';
import 'package:names/model/ImageResponseModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

import '../../main.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({Key key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> implements ApiCallBackListener {
  TextEditingController groupNameController = TextEditingController();
  GlobalKey globalKey = GlobalKey();
  ConnectionModel connectionModel;
  bool isSearching = false;
  TextEditingController controller = TextEditingController();

  // List<SearchModel> searchList = [];
  // List<SearchModel> selectedSearchList = [];

  File file;

  String groupImageURL;

  Future<List<UsersModel>> futureConnectedUsers;
  List<UsersModel> connectedUsersList = [];
  List<UsersModel> selectedConnectedUsersList = [];
  ScrollController _scrollController = ScrollController();

  bool isPaging = false;

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
                      border: InputBorder.none,
                      filled: true,
                      fillColor: Colors.white,
                      labelStyle: TextStyle(color: AppColor.textGrayColor),
                      hintStyle: TextStyle(color: AppColor.textGrayColor),
                      hintText: "Search",
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12)),
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
                    Icons.search,
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
                              child: GestureDetector(
                                child: Container(
                                  height: 50,
                                  width: 50,
                                  child: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: AppHelper.isEmpty(groupImageURL)
                                            ? Image.asset(
                                                "assets/images/doctor_def_circle.jpeg",
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              )
                                            : CustomWidget.imageView(
                                                groupImageURL,
                                                height: 50,
                                                width: 50,
                                                forGroupImage: true,
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: Colors.white),
                                          alignment: Alignment.center,
                                          child: Icon(
                                            Icons.camera_alt,
                                            size: 18,
                                            color: AppColor.blueColor,
                                          ),
                                          padding: EdgeInsets.all(3),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  ImageHelper().showPhotoBottomDialog(
                                      context, Platform.isIOS, (file) {
                                    if (file != null) {
                                      this.file = file;
                                      uploadImageAPI();
                                    }
                                  });
                                },
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Container(
                                height: 50,
                                child: TextFormField(
                                    controller: groupNameController,
                                    style: TextStyle(
                                        color: AppColor.textGrayColor),
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
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              height: 60,
                                                                              width: 60,
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
                                                                                height: 60,
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
                                                                                                  style: TextStyle(fontSize: 16, fontFamily: "Lato_Bold", color: Colors.black),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                width: 5,
                                                                                              ),
                                                                                              AppHelper.ShildWidget(userModel.licenseExpiryDate, 18, 18)
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
                                                                            20,
                                                                        width:
                                                                            20,
                                                                        decoration: BoxDecoration(
                                                                            color: userModel.isSelected
                                                                                ? AppColor.lightSkyBlueColor
                                                                                : AppColor.skyBlueBoxColor,
                                                                            borderRadius: BorderRadius.circular(100)),
                                                                        child: userModel.isSelected
                                                                            ? Icon(
                                                                                Icons.done,
                                                                                size: 14,
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
                            "CREATE NOW",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          createGroup();
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
    if (mounted) {
      getConnectedUsersAPI();
    }
    super.initState();
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
    if (action == ApiAction.networkList) {
      connectionModel = ConnectionModel.fromJson(result);
      if (connectionModel.success) {
        connectedUsersList.clear();

        connectionModel.data.list.forEach((element) {
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

          for (var element in pagination.data.list) {
            if (!connectionModel.data.list.contains(element)) {
              connectionModel.data.list.add(element);
              connectedUsersList.add(UsersModel.fromJson(element.toJson()));
            }
          }
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
    } else if (action == ApiAction.chatImageUpload) {
      ImageResponseModel imageResponseModel =
          ImageResponseModel.fromJson(result);
      if (imageResponseModel.success) {
        groupImageURL = imageResponseModel.data;
        if (mounted) {
          setState(() {});
        }
      } else {
        groupImageURL = null;
        AppHelper.showToastMessage(imageResponseModel.message);
      }
    }
  }

  void createGroup() {
    String groupName = groupNameController.text.trim();
    if (groupImageURL == null || groupImageURL.isEmpty) {
      AppHelper.showToastMessage("Please select group image.");
    } else if (groupName == null || groupName.isEmpty) {
      AppHelper.showToastMessage("Please enter group name.");
    } else if (selectedConnectedUsersList.length == 0) {
      AppHelper.showToastMessage("Please select group users.");
    } else {
      UsersModel groupAdminUser =
          UsersModel.fromJson(appUserSession.value.toJson());
      selectedConnectedUsersList.insert(0, groupAdminUser);

      List<String> users = [];
      List<dynamic> usersData = [];

      Map<String, dynamic> usersCountMap = Map();
      selectedConnectedUsersList.forEach((user) {
        users.add(user.id.toString());
        usersData.add(user.toJson());
        usersCountMap[user.id.toString()] = FieldValue.increment(0);
      });

      DocumentReference documentReference =
          FirebaseFirestore.instance.collection(FirebaseKey.groupRoom).doc();

      documentReference.set({
        FirebaseKey.groupAdminID: groupAdminUser.id.toString(),
        FirebaseKey.groupID: documentReference.id,
        FirebaseKey.groupName: groupName,
        FirebaseKey.groupImage: groupImageURL,
        FirebaseKey.groupCreatedTime: FieldValue.serverTimestamp(),
        FirebaseKey.isGroup: true,
        FirebaseKey.lastMessage: GroupModel(
                null,
                "",
                null,
                groupAdminUser.id.toString(),
                FieldValue.serverTimestamp(),
                FirebaseKey.TEXT)
            .toJson(),
        FirebaseKey.users: users,
        FirebaseKey.usersData: usersData,
        FirebaseKey.unreadCount: usersCountMap,
        FirebaseKey.groupCount: selectedConnectedUsersList.length,
        FirebaseKey.groupCount: selectedConnectedUsersList.length,
      }, SetOptions(merge: true)).then((value) {
        AppHelper.showToastMessage(groupName + " group created successfully.");
        Navigator.pop(context);
      });
    }
  }
}
