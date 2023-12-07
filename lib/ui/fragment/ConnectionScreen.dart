import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/ConnectionModel.dart';
import 'package:names/model/InvitationModel.dart';
import 'package:names/model/UsersModel.dart';

import '../UserProfileScreen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({Key key}) : super(key: key);

  @override
  _ConnectionScreenState createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen>
    with ApiCallBackListener {
  bool connectionSelected = true;
  bool invitationSelected = false;
  TextEditingController controller = TextEditingController();
  ScrollController _scrollController = ScrollController();
  ScrollController _invitationController = ScrollController();

  bool isPaging = false;
  bool isSearching = false;
  ConnectionModel connectionModel;
  InvitationModel invitationModel;

  Future<List<UsersModel>> futureConnection;
  Future<List<UsersModel>> futureInvitation;

  List<UsersModel> connectionUsersList = [];
  List<UsersModel> invitationUsersList = [];

  int connectionSelectedIndex = 0;
  int invitationSelectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 50,
              // decoration: BoxDecoration(
              //     color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            color: connectionSelected
                                ? AppColor.blueColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          "CONNECTIONS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: connectionSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          connectionSelected = true;
                          invitationSelected = false;
                          // connectedSelected = false;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: invitationSelected
                                ? AppColor.blueColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "INVITATIONS",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: invitationSelected
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          connectionSelected = false;
                          invitationSelected = true;
                          // connectedSelected = false;
                        });
                      },
                    ),
                  ),
                  /*SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: GestureDetector(
                      child: Container(
                        height: double.maxFinite,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                            color: connectedSelected
                                ? AppColor.blueColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          "CONNECTED",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                connectedSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          connectionSelected = false;
                          invitationSelected = false;
                          connectedSelected = true;
                        });
                      },
                    ),
                  ),*/
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: TextFormField(
                    style: TextStyle(color: AppColor.textGrayColor),
                    controller: controller,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Connection",
                        labelStyle: TextStyle(color: AppColor.textGrayColor),
                        hintStyle: TextStyle(color: AppColor.textGrayColor),
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
                      if (connectionSelected) {
                        getConnectionAPI();
                      } else if (invitationSelected) {
                        getInvitationAPI();
                      }
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
                      if (connectionSelected) {
                        getConnectionAPI();
                      } else if (invitationSelected) {
                        getInvitationAPI();
                      }
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
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Builder(builder: (ctx) {
                if (connectionSelected) {
                  return FutureBuilder<List<UsersModel>>(
                      future: futureConnection, // async work
                      builder: (BuildContext context,
                          AsyncSnapshot<List<UsersModel>> snapshot) {
                        if (snapshot.hasData) {
                          return connectionUsersList.length > 0
                              ? Column(children: [
                                  Expanded(
                                      child: NotificationListener<
                                              ScrollNotification>(
                                          onNotification:
                                              (ScrollNotification scroll) {
                                            if (scroll
                                                    is ScrollEndNotification &&
                                                _scrollController.position
                                                        .maxScrollExtent ==
                                                    _scrollController
                                                        .position.pixels) {
                                              if (connectionModel
                                                          .data.nextPageUrl !=
                                                      null &&
                                                  !isPaging) {
                                                setState(() {
                                                  isPaging = true;
                                                });
                                                getConnectionNextAPI(
                                                    connectionModel
                                                        .data.nextPageUrl);
                                              }
                                            }
                                            return false;
                                          },
                                          child: ListView.separated(
                                            itemCount:
                                                connectionUsersList.length,
                                            shrinkWrap: true,
                                            controller: _scrollController,
                                            physics: ClampingScrollPhysics(),
                                            itemBuilder: (ctx, index) {
                                              UsersModel usersModel =
                                                  connectionUsersList[index];
                                              return GestureDetector(
                                                child: Container(
                                                  width:
                                                      AppHelper.getDeviceWidth(
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
                                                          height: 80,
                                                          width: 80,
                                                          margin:
                                                              EdgeInsets.all(5),
                                                          child: ClipRRect(
                                                            child: Stack(
                                                              children: [
                                                                CustomWidget.imageView(
                                                                    usersModel
                                                                        .profilePicture,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    forProfileImage:
                                                                        true,
                                                                    backgroundColor:
                                                                        AppColor
                                                                            .profileBackColor,
                                                                    height: 80,
                                                                    width: 80),
                                                                AppHelper.professtionWidget(
                                                                    usersModel
                                                                        .profession_symbol),
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
                                                            height: 80,
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5),
                                                            alignment: Alignment
                                                                .centerLeft,
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
                                                                Text(
                                                                  AppHelper.setText(
                                                                      usersModel
                                                                          .name),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          "Lato_Bold",
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  AppHelper.setText(
                                                                      usersModel
                                                                          .profession),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: AppColor
                                                                          .textGrayColor),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          GestureDetector(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              100,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(100),
                                                                              color: AppColor.lightSkyBlueColor),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            "CONNECT",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          sendRequestAPI(
                                                                              index);
                                                                        },
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            30,
                                                                        width:
                                                                            100,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        AppHelper.ShildWidget(
                                                            usersModel
                                                                .licenseExpiryDate,
                                                            16,
                                                            16),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  _navigateToUserProfile(
                                                      context, usersModel);
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
                                          ))),
                                  if (isPaging &&
                                      connectionModel.data.nextPageUrl != null)
                                    Container(
                                      height: 50,
                                      child: ProgressDialog
                                          .getCircularProgressIndicator(),
                                    ),
                                ])
                              : AppHelper.getNoRecordWidget(
                                  context,
                                  "assets/icons/connection.png",
                                  "No connections yet",
                                  MainAxisAlignment.center);
                        }
                        return ProgressDialog.getCircularProgressIndicator();
                      });
                } else if (invitationSelected) {
                  return FutureBuilder<List<UsersModel>>(
                      future: futureInvitation, // async work
                      builder: (BuildContext context,
                          AsyncSnapshot<List<UsersModel>> snapshot) {
                        if (snapshot.hasData) {
                          return invitationUsersList.length > 0
                              ? Column(children: [
                                  Expanded(
                                      child: NotificationListener<
                                              ScrollNotification>(
                                          onNotification:
                                              (ScrollNotification scroll) {
                                            if (scroll
                                                    is ScrollEndNotification &&
                                                _invitationController.position
                                                        .maxScrollExtent ==
                                                    _invitationController
                                                        .position.pixels) {
                                              if (invitationModel
                                                          .data.nextPageUrl !=
                                                      null &&
                                                  !isPaging) {
                                                setState(() {
                                                  isPaging = true;
                                                });
                                                getInvitationNextAPI(
                                                    invitationModel
                                                        .data.nextPageUrl);
                                              }
                                            }
                                            return false;
                                          },
                                          child: ListView.separated(
                                            controller: _invitationController,
                                            itemCount:
                                                invitationUsersList.length,
                                            shrinkWrap: true,
                                            physics: ClampingScrollPhysics(),
                                            itemBuilder: (ctx, index) {
                                              UsersModel usersModel =
                                                  invitationUsersList[index];
                                              return GestureDetector(
                                                child: Container(
                                                  width:
                                                      AppHelper.getDeviceWidth(
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
                                                          height: 80,
                                                          width: 80,
                                                          margin:
                                                              EdgeInsets.all(5),
                                                          child: ClipRRect(
                                                            child: Stack(
                                                              children: [
                                                                CustomWidget.imageView(
                                                                    usersModel
                                                                        .profilePicture,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                    forProfileImage:
                                                                        true,
                                                                    backgroundColor:
                                                                        AppColor
                                                                            .profileBackColor,
                                                                    height: 80,
                                                                    width: 80),
                                                                AppHelper.professtionWidget(
                                                                    usersModel
                                                                        .profession_symbol),
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
                                                            height: 80,
                                                            margin:
                                                                EdgeInsets.all(
                                                                    5),
                                                            alignment: Alignment
                                                                .centerLeft,
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
                                                                Text(
                                                                  AppHelper.setText(
                                                                      usersModel
                                                                          .name),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          "Lato_Bold",
                                                                      color: Colors
                                                                          .black),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text(
                                                                  AppHelper.setText(
                                                                      usersModel
                                                                          .profession),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  style: TextStyle(
                                                                      color: AppColor
                                                                          .textGrayColor),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Row(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .center,
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          GestureDetector(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              100,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(100),
                                                                              color: AppColor.lightSkyBlueColor),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            "ACCEPT",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          acceptRequestAPI(
                                                                              index);
                                                                        },
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          GestureDetector(
                                                                        child:
                                                                            Container(
                                                                          height:
                                                                              30,
                                                                          width:
                                                                              100,
                                                                          decoration: BoxDecoration(
                                                                              borderRadius: BorderRadius.circular(100),
                                                                              color: Colors.white,
                                                                              border: Border.all(width: 1, color: Colors.red)),
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              Text(
                                                                            "DELETE",
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.red,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          deleteRequestAPI(
                                                                              index);
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        AppHelper.ShildWidget(
                                                            usersModel
                                                                .licenseExpiryDate,
                                                            16,
                                                            16),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                onTap: () {
                                                  // we changing sender_id to id
                                                  UsersModel tempUserModel =
                                                      UsersModel.fromJson(
                                                          usersModel.toJson());
                                                  tempUserModel.id =
                                                      tempUserModel.sender_id;
                                                  _navigateToUserProfile(
                                                      context, tempUserModel);
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
                                          ))),
                                  if (isPaging &&
                                      invitationModel.data.nextPageUrl != null)
                                    Container(
                                      height: 50,
                                      child: ProgressDialog
                                          .getCircularProgressIndicator(),
                                    ),
                                ])
                              : AppHelper.getNoRecordWidget(
                                  context,
                                  "assets/icons/connection.png",
                                  "No invitations yet",
                                  MainAxisAlignment.center);
                        }
                        return ProgressDialog.getCircularProgressIndicator();
                      });
                } /*else if(connectedSelected){

                  return FutureBuilder<List<UsersModel>>(
                      future: futureConnectedUsers, // async work
                      builder: (BuildContext context,
                          AsyncSnapshot<List<UsersModel>> snapshot) {
                        if (snapshot.hasData) {
                          return connectedUsersList.length > 0
                              ? ListView.separated(
                            itemCount: connectedUsersList.length,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemBuilder: (ctx, index) {
                              UsersModel usersModel =
                              connectedUsersList[index];
                              return GestureDetector(
                                child: Container(
                                  width: AppHelper.getDeviceWidth(context),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: usersModel.status != null
                                        ? AppColor.skyBlueBoxColor
                                        : Colors.white,
                                  ),
                                  padding: EdgeInsets.all(5),
                                  child: Container(
                                    child: Row(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 50,
                                          width: 50,
                                          margin: EdgeInsets.all(5),
                                          child: ClipRRect(
                                            child: Stack(
                                              children: [
                                                CustomWidget.imageView(
                                                  usersModel
                                                      .profilePicture,
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,forProfileImage: true,),
                                                Align(
                                                  alignment:
                                                  Alignment.bottomRight,
                                                  child: Container(
                                                    height: 22,
                                                    width: 22,
                                                    decoration:
                                                    BoxDecoration(
                                                      color: AppColor
                                                          .darkBlueColor,
                                                      borderRadius:
                                                      BorderRadius.only(
                                                          topLeft: Radius
                                                              .circular(
                                                              10)),
                                                    ),
                                                    alignment:
                                                    Alignment.center,
                                                    child: Text(
                                                      usersModel.profession_symbol.toString(),
                                                      style: TextStyle(
                                                          fontSize: 10,
                                                          color:
                                                          Colors.white,
                                                          fontWeight:
                                                          FontWeight
                                                              .bold),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            margin: EdgeInsets.all(5),
                                            alignment: Alignment.centerLeft,
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
                                                    MainAxisSize.max,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text(
                                                            usersModel.name,
                                                            style: TextStyle(
                                                                fontSize:
                                                                16,
                                                                fontFamily:
                                                                "Lato_Bold",
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          usersModel.status !=
                                                              null
                                                              ? Image.asset(
                                                            "assets/icons/shield.png",
                                                            height:
                                                            16,
                                                            width: 16,
                                                          )
                                                              : SizedBox(
                                                            height:
                                                            16,
                                                            width: 16,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 5,
                                                      ),
                                                      Text(
                                                        usersModel
                                                            .profession.toString(),
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color: AppColor
                                                                .textGrayColor),
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
                                  _navigateToUserProfile(context,usersModel);
                                },
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) {
                              return SizedBox(
                                height: 20,
                              );
                            },
                          )
                              : Center(
                            child: Text("No record found"),
                          );
                        }
                        return ProgressDialog.getCircularProgressIndicator();
                      });
                }*/
                else {
                  return Container();
                }
              }),
            )
          ],
        ),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
    );
  }

  @override
  void initState() {
    if (mounted) {
      getConnectionAPI();
      getInvitationAPI();
    }
    super.initState();
  }

  getConnectionAPI() {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: true,
          httpType: HttpMethods.POST,
          url: Url.connectionList,
          apiAction: ApiAction.connectionList,
          body: body);
    } else {
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: false,
          httpType: HttpMethods.POST,
          url: Url.connectionList,
          apiAction: ApiAction.connectionList,
          body: body);
    }
  }

  getConnectionNextAPI(String url) {
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

  getInvitationAPI() {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: true,
          httpType: HttpMethods.POST,
          url: Url.invitationList,
          apiAction: ApiAction.invitationList,
          body: body);
    } else {
      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.invitationList,
        apiAction: ApiAction.invitationList,
      );
    }
  }

  getInvitationNextAPI(String url) {
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
        apiAction: ApiAction.invitationPagination,
        body: body);
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.connectionList) {
      connectionModel = ConnectionModel.fromJson(result);
      if (connectionModel.success) {
        connectionUsersList.clear();

        connectionModel.data.list.forEach((element) {
          connectionUsersList.add(UsersModel.fromJson(element.toJson()));
        });

        futureConnection = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return connectionUsersList;
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
              connectionUsersList.add(UsersModel.fromJson(element.toJson()));
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
    } else if (action == ApiAction.invitationList) {
      invitationModel = InvitationModel.fromJson(result);
      if (invitationModel.success) {
        invitationUsersList.clear();

        invitationModel.data.list.forEach((element) {
          invitationUsersList.add(UsersModel.fromJson(element.toJson()));
        });

        futureInvitation = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return invitationUsersList;
        });
      } else {
        AppHelper.showToastMessage(invitationModel.message);
      }
    } else if (action == ApiAction.invitationPagination) {
      InvitationModel pagination = InvitationModel.fromJson(result);
      if (pagination.success) {
        if (invitationModel != null) {
          invitationModel.data.nextPageUrl = pagination.data.nextPageUrl;

          for (var element in pagination.data.list) {
            if (!invitationModel.data.list.contains(element)) {
              invitationModel.data.list.add(element);
              invitationUsersList.add(UsersModel.fromJson(element.toJson()));
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
    }
    /*else if (action == ApiAction.networkList) {
      ConnectionModel connectionModel = ConnectionModel.fromJson(result);
      if (connectionModel.success) {
        connectedUsersList.clear();

        connectionModel.data.forEach((element) {
          connectedUsersList.add(UsersModel.fromJson(element.toJson()));
          tempConnectedUsersList.add(UsersModel.fromJson(element.toJson()));
        });
        futureConnectedUsers = Future.delayed(Duration(seconds: 0), () {
          setState(() {});
          return connectedUsersList;
        });
      } else {
        AppHelper.showToastMessage(connectionModel.message);
      }
    }*/
    else if (action == ApiAction.sendConnectionRequuest) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        showRequestConnectionDialog(connectionSelectedIndex);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.acceptConnectionRequuest) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        showAcceptInvitationDialog(invitationSelectedIndex);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.deleteConnectionRequuest) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        showDeleteInvitationDialog(invitationSelectedIndex);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

  void showRequestConnectionDialog(int index) {
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
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/icons/checked.png",
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              child: Image.asset(
                                "assets/icons/close.png",
                                height: 16,
                                width: 16,
                              ),
                              onTap: () {
                                Navigator.pop(ctx);

                                connectionUsersList
                                    .removeAt(connectionSelectedIndex);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Connection request has been sent successfully to " +
                            connectionUsersList[index].name.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  void showAcceptInvitationDialog(int index) {
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
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/icons/checked.png",
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              child: Image.asset(
                                "assets/icons/close.png",
                                height: 16,
                                width: 16,
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                invitationUsersList
                                    .removeAt(invitationSelectedIndex);

                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "You are now able to send a message to " +
                            invitationUsersList[index].name.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  void showDeleteInvitationDialog(int index) {
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
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              "assets/icons/checked.png",
                              height: 50,
                              width: 50,
                            ),
                          ),
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              child: Image.asset(
                                "assets/icons/close.png",
                                height: 16,
                                width: 16,
                              ),
                              onTap: () {
                                Navigator.pop(ctx);

                                invitationUsersList
                                    .removeAt(invitationSelectedIndex);
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        invitationUsersList[index].name.toString() +
                            " is removed.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      )
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }

  void sendRequestAPI(int index) {
    connectionSelectedIndex = index;
    Map<String, String> body = Map();
    body["user_id"] = connectionUsersList[index].id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        url: Url.sendConnectionRequuest,
        apiAction: ApiAction.sendConnectionRequuest,
        body: body);
  }

  void acceptRequestAPI(int index) {
    invitationSelectedIndex = index;
    Map<String, String> body = Map();
    body["connection_request_id"] = invitationUsersList[index].id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        url: Url.acceptConnectionRequuest,
        apiAction: ApiAction.acceptConnectionRequuest,
        body: body);
  }

  void deleteRequestAPI(int index) {
    invitationSelectedIndex = index;
    Map<String, String> body = Map();
    body["connection_request_id"] = invitationUsersList[index].id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        url: Url.deleteConnectionRequuest,
        apiAction: ApiAction.deleteConnectionRequuest,
        body: body);
  }

  void _navigateToUserProfile(BuildContext context, UsersModel usersModel) {
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          UserProfileScreen(
        usersModel: usersModel,
      ),
      transitionDuration: Duration(seconds: 0),
    ));
  }
}
