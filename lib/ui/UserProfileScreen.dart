import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:full_screen_image/full_screen_image.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart' as intl;
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/custom_widget/gradient_app_bar.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/DownloadProgressDialog.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/UserProfileModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:provider/provider.dart';
import '../constants/firebaseKey.dart';
import '../helper/ImageHelper.dart';
import '../route/routes.dart';
import 'chat/ChatScreen.dart';
import 'fragment/UserPostScreen.dart';

class UserProfileScreen extends StatefulWidget {
  UsersModel usersModel;
  String notificationId = null;
  bool fromNotification = false;
  UserProfileScreen(
      {this.notificationId, this.fromNotification, @required this.usersModel});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with ApiCallBackListener {
  bool postSelected = true;
  bool aboutSelected = false;

  Future<UserProfileModel> futureProfile;

  UserProfileModel userProfileModel;
  int countSch = 0;

  @override
  void initState() {
    if (mounted) {
      futureProfile = getUserProfileAPI();
      print("2112 fromNotification =" + widget.fromNotification.toString());
      if (widget.fromNotification == null && widget.notificationId != null) {
        //from notification tap
        readNotification();
      } else if (widget.fromNotification != null &&
          widget.fromNotification &&
          widget.notificationId != null) {
        //from notification LIST tap
        readNotification();
      }
    }
    countSch =  0;
    // var calendarProvider =
    //      Provider.of<ScheduleCalendarProvider>(context, listen: false);
    //  calendarProvider.context = context;
    //  calendarProvider.getScheduleListAPI();
    super.initState();
  }

  bool _switchValue = true;
// for appbar
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
              _backPress();
            },
          ),
        ),
        Expanded(
          child: Text(
            widget.usersModel.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
      ],
    );
  }

  bool unfriendCalled = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    double fontSize = screenWidth * 0.04;
    return WillPopScope(
        onWillPop: () async {
          _backPress();
          return Future.value(true);
        },
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
                    child: FutureBuilder<UserProfileModel>(
                        future: futureProfile, // async work
                        builder: (BuildContext context,
                            AsyncSnapshot<UserProfileModel> snapshot) {
                          if (snapshot.hasData) {
                            UserProfileModel userProfileModel = snapshot.data;
                            return SingleChildScrollView(
                              physics: ClampingScrollPhysics(),
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      Container(
                                        height:
                                            AppHelper.getDeviceWidth(context) /
                                                2,
                                        width:
                                            AppHelper.getDeviceWidth(context),
                                        margin: EdgeInsets.only(bottom: 60),
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: AppHelper.getDeviceWidth(
                                                  context),
                                              height: AppHelper.getDeviceWidth(
                                                      context) /
                                                  2,
                                              // color: AppColor.profileBackColor,
                                              child: FittedBox(
                                                child: FullScreenWidget(
                                                    child: Hero(
                                                        tag: "coverP" +
                                                            userProfileModel
                                                                .data.id
                                                                .toString(),
                                                        child: CustomWidget
                                                            .imageView(
                                                          /*"https://vendurs.cmsbox.in/public/"+*/
                                                          userProfileModel.data
                                                              .cover_picture,
                                                          // fit: BoxFit.fill,
                                                          // height: 120,
                                                          // width: 120,
                                                          forCoverImage: true,
                                                          // backgroundColor: AppColor.profileBackColor
                                                        ))),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                            Visibility(
                                              visible:
                                                  userProfileModel.data.id ==
                                                      appUserSession.value.id,
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      ImageHelper()
                                                          .showPhotoBottomDialog(
                                                              context,
                                                              Platform.isIOS,
                                                              (file) {
                                                        uploadCoverPhoto(file);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: 30,
                                                      height: 30,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          color: Colors.white),
                                                      alignment:
                                                          Alignment.center,
                                                      child: Icon(
                                                        Icons.camera_alt,
                                                        size: 20,
                                                        color:
                                                            AppColor.blueColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Align(
                                        child: Container(
                                          height: 120,
                                          width: 120,
                                          child: ClipRRect(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 120,
                                                  width: 120,
                                                  child: FittedBox(
                                                    child: FullScreenWidget(
                                                        child: Hero(
                                                      tag: "userProfile" +
                                                          userProfileModel
                                                              .data.id
                                                              .toString(),
                                                      child: CustomWidget.imageView(
                                                          userProfileModel.data
                                                              .profilePicture,
                                                          fit: BoxFit.scaleDown,
                                                          // height: 120,
                                                          // width: 120,
                                                          forProfileImage: true,
                                                          backgroundColor: AppColor
                                                              .profileBackColor),
                                                    )),
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),

                                                /*CustomWidget.imageView(
                                  userProfileModel.data.profilePicture,
                                  fit: BoxFit.cover,
                                  height: 120,
                                  width: 120,
                                forProfileImage: true
                              ),*/
                                                AppHelper.professtionWidget(
                                                    userProfileModel
                                                        .data.profession_symbol)
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            userProfileModel.data.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontFamily: "Lato_Bold",
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        AppHelper.ShildWidget(
                                            userProfileModel
                                                .data.licenseExpiryDate,
                                            24,
                                            24)
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    AppHelper.setText(
                                        userProfileModel.data.profession),
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: AppColor.textGrayColor),
                                  ),

                                  userProfileModel .data .id == appUserSession.value.id ?
                                  Padding(
                                    padding:  EdgeInsets.only(right: 0),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: Container(
                                        width: 150,
                                        child: FlutterSwitch(
                                          width: 95.0,
                                          height: 35.0,
                                          valueFontSize: 15.0,
                                          toggleSize: 20.0,
                                          value: userProfileModel.data.profileLock == 0 ? false : true,
                                         // value: _switchValue,
                                          borderRadius: 30.0,
                                          activeText: "Public",
                                          activeTextColor: Colors.black,
                                          inactiveText: "Private",
                                          inactiveTextColor: Colors.black,
                                          padding: 8.0,
                                          showOnOff: true,
                                          onToggle: (val) {
                                            setState(() {
                                              _switchValue = val;
                                              // Future.delayed(const Duration(seconds: 2), () {
                                              //   setState(() {
                                                  getDocView();
                                              //   });
                                              // });
                                            });
                                            // setState(() {
                                            //   _switchValue = val;
                                            // });
                                          },
                                        ),
                                      )

                                      //     Switch(
                                      //   value: userProfileModel.data.profileLock == 0 ? false : true,
                                      //   onChanged: (value) {
                                      //     setState(() {
                                      //       _switchValue = value;
                                      //       Future.delayed(const Duration(seconds: 2), () {
                                      //         setState(() {
                                      //           getDocView();
                                      //         });
                                      //       });
                                      //     });
                                      //   },
                                      // ),
                                    ),
                                  ): SizedBox(height: 20,),

                                  Container(
                                    padding: EdgeInsets.only(
                                        bottom: 20, left: 20, right: 20),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 0,
                                        ),
                                        userProfileModel.data.id !=
                                                appUserSession.value.id
                                            ? userProfileModel.data.connected
                                                ? Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              color: Colors.red,
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              "Unfriend",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          callDialog(
                                                              'Do you want to \nunfriend?',
                                                              unFriendAPI,
                                                              1);
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      GestureDetector(
                                                        child: Container(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              color: AppColor
                                                                  .lightSkyBlueColor,
                                                            ),
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        20,
                                                                    vertical:
                                                                        10),
                                                            child: Text(
                                                              "CONSULT",
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          messageScreen(
                                                              userProfileModel);
                                                        },
                                                      ),
                                                      SizedBox(width: 10),
                                                      if (!userProfileModel
                                                          .data.blockStatus)
                                                        GestureDetector(
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                              child: Text(
                                                                "Block",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            callDialog(
                                                                'Do you want to \nblock?',
                                                                getBlockUnblockAPI,
                                                                2);
                                                          },
                                                        ),
                                                      if (userProfileModel
                                                          .data.blockStatus)
                                                        GestureDetector(
                                                          child: Container(
                                                            alignment: Alignment
                                                                .center,
                                                            child: Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            100),
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          20,
                                                                      vertical:
                                                                          10),
                                                              child: Text(
                                                                "Unblock",
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            callDialog(
                                                                'Do you want to \nunblock?',
                                                                getBlockUnblockAPI,
                                                                3);
                                                          },
                                                        ),
                                                    ],
                                                  )
                                                : GestureDetector(
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      100),
                                                          color: AppColor
                                                              .lightSkyBlueColor,
                                                        ),
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 30,
                                                                vertical: 10),
                                                        child: Text(
                                                          userProfileModel.data
                                                                  .already_requested
                                                              ? "REQUESTED"
                                                              : "CONNECT",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      if (!userProfileModel
                                                              .data.connected &&
                                                          !userProfileModel.data
                                                              .already_requested) {
                                                        connectAPI();
                                                      }
                                                      /*if (!userProfileModel
                                            .data.connected) {
                                      if(userProfileModel
                                          .data.already_requested){
                                        acceptRequestAPI(userProfileModel
                                            .data.invitation_request);
                                      }else{
                                        connectAPI();
                                      }
                                    }*/
                                                    },
                                                  )
                                            : SizedBox(),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          padding: EdgeInsets.all(5),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  child: Container(
                                                    height: double.maxFinite,
                                                    width: double.maxFinite,
                                                    alignment: Alignment.center,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    decoration: BoxDecoration(
                                                        color: postSelected
                                                            ? AppColor.blueColor
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    child: Text(
                                                      "POST",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: postSelected
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      postSelected = true;
                                                      aboutSelected = false;
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
                                                        color: aboutSelected
                                                            ? AppColor.blueColor
                                                            : Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    alignment: Alignment.center,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 5),
                                                    child: Text(
                                                      "ABOUT",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: aboutSelected
                                                            ? Colors.white
                                                            : Colors.black,
                                                      ),
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    setState(() {
                                                      postSelected = false;
                                                      aboutSelected = true;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        userProfileModel.data.id != appUserSession.value.id
                                            ? Container(
                                                width: AppHelper.getDeviceWidth(
                                                    context),
                                                height: 50,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: AppColor
                                                      .lightSkyBlueColor,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  userProfileModel
                                                          .data.totalConnection
                                                          .toString() +
                                                      " Total Connection",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Builder(builder: (ctx) {
                                          final endTime = intl.DateFormat(
                                                  'yyyy-MM-dd kk:mm')
                                              .parseUtc(userProfileModel
                                                      .data
                                                      .scheduleList
                                                      .commonSch
                                                      .isNotEmpty
                                                  ? userProfileModel
                                                      .data
                                                      .scheduleList
                                                      .commonSch
                                                      .first
                                                      .endTime
                                                  : "2023-06-07 16:02:00")
                                              .toLocal();
                                          final endTimeVal = intl.DateFormat(
                                                  'yyyy-MM-dd  kk:mm')
                                              .format(endTime);
                                          if (postSelected) {
                                            return UserPostScreen(widget
                                                .usersModel.id
                                                .toString());
                                          } else {
                                            return Column(
                                              children: [
                                                Container(
                                                  width:
                                                      AppHelper.getDeviceWidth(
                                                          context),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.white,
                                                  ),
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      Text(
                                                        "Personal Information:",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "Name:",
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            flex: 1,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              userProfileModel
                                                                  .data.name,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: AppColor
                                                                    .lightSkyBlueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            flex: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 10,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "Email address:",
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            flex: 1,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              userProfileModel
                                                                  .data.email,
                                                              textAlign:
                                                                  TextAlign
                                                                      .start,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                color: AppColor
                                                                    .lightSkyBlueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            flex: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      Visibility(
                                                          visible:
                                                              userProfileModel
                                                                      .data
                                                                      .location !=
                                                                  null,
                                                          child: Column(
                                                            children: [
                                                              SizedBox(
                                                                height: 10,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Text(
                                                                      "Location:",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    flex: 1,
                                                                  ),
                                                                  Expanded(
                                                                    child: Text(
                                                                      userProfileModel.data.location !=
                                                                              null
                                                                          ? userProfileModel
                                                                              .data
                                                                              .location
                                                                          : "",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .start,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        color: AppColor
                                                                            .lightSkyBlueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    flex: 1,
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ))
                                                    ],
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                userProfileModel.data.id == appUserSession.value.id ||
                                                        userProfileModel.data.connected
                                                    ? Column(
                                                        children: [
                                                          Container(
                                                            width: AppHelper
                                                                .getDeviceWidth(
                                                                    context),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    20),
                                                            child: Column(
                                                              children: [
                                                                Text(
                                                                  "Biography:",
                                                                  textAlign: TextAlign.center,
                                                                  style: TextStyle( fontSize:  16,
                                                                    color: Colors.black,
                                                                    fontWeight: FontWeight.bold,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                Text(
                                                                  AppHelper.setText(
                                                                      userProfileModel
                                                                          .data
                                                                          .about),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: AppColor
                                                                        .textGrayColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                              ],
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Container(
                                                            width: AppHelper
                                                                .getDeviceWidth(
                                                                    context),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                            padding:
                                                                EdgeInsets.only(
                                                                    top: 15),
                                                            child: Column(
                                                              children: [
                                                                Padding(
                                                                  padding: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              15.0),
                                                                  child: Text(
                                                                    "NAMES Schedule: ",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                if (userProfileModel  .data .scheduleList.commonSch.isNotEmpty) ...{
                                                                  if (userProfileModel.data .connected ||
                                                                      userProfileModel .data .id ==
                                                                          appUserSession.value.id) ...{
                                                                    ListView.builder(
                                                                        shrinkWrap: true,
                                                                        physics: NeverScrollableScrollPhysics(),
                                                                        itemCount: userProfileModel.data.scheduleList.commonSch.length,
                                                                        itemBuilder: (context, i) {
                                                                          print("length"+userProfileModel.data.scheduleList.commonSch.length.toString());

                                                                          final event = userProfileModel
                                                                              .data
                                                                              .scheduleList
                                                                              .commonSch[i];
                                                                          final endTime = intl.DateFormat('yyyy-MM-dd kk:mm').parseUtc(event.endTime).toLocal();
                                                                          final endTimeVal = intl.DateFormat('yyyy-MM-dd  kk:mm').format(endTime);
                                                                          DateTime tempDate = DateFormat("yyyy-MM-dd kk:mm").parse(event.endTime);
                                                                          var formattedDate = DateFormat('yyyy-MM-dd  kk:mm:ss').format(DateTime.now());
                                                                          if ((DateTime.now().isAfter(endTime))) {
                                                                           countSch = countSch+1;
                                                                            print(countSch);
                                                                            // print(countSch);
                                                                            if (countSch == (userProfileModel.data.scheduleList.commonSch.length * 2)) {
                                                                              return Center(
                                                                                child: Padding(
                                                                                  padding: EdgeInsets.only(top: 5, bottom: 15),
                                                                                  child: Text("No Schedule yet"),
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              return SizedBox();
                                                                            }
                                                                          }

                                                                          return Container(
                                                                              margin: EdgeInsets.only(bottom: 10, left: 8, right: 10),
                                                                              padding: EdgeInsets.all(8),
                                                                              decoration: BoxDecoration(color: AppColor.skyBlueBoxColor, borderRadius: BorderRadius.circular(10)),
                                                                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Image.asset(
                                                                                      "assets/icons/calendar.png",
                                                                                      height: 20,
                                                                                      width: 20,
                                                                                      color: AppColor.lightSkyBlueColor,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 10,
                                                                                    ),
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        "${event.worksite}, ${event.location}",
                                                                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(
                                                                                    left: 30,
                                                                                    right: 10,
                                                                                    top: 10,
                                                                                  ),
                                                                                  child: Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        "Start Date & Time - ",
                                                                                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                      Flexible(
                                                                                        child: Text(
                                                                                          '${AppHelper.scheduleDateFormat(event.startTime.toString())}',
                                                                                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.only(left: 30, right: 10, top: 10, bottom: 10),
                                                                                  child: Row(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Text(
                                                                                        "End Date & Time - ",
                                                                                        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                                                                                      ),
                                                                                      Flexible(
                                                                                        child: Text(
                                                                                          '${AppHelper.scheduleDateFormat(event.endTime.toString())}',
                                                                                          style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ]));
                                                                          //return Container();
                                                                        })
                                                                  }
                                                                } else ...{
                                                                  Center(
                                                                    child:
                                                                        Padding(
                                                                      padding: EdgeInsets.only(
                                                                          top:
                                                                              5,
                                                                          bottom:
                                                                              15),
                                                                      child: Text(
                                                                          "No Schedule yet"),
                                                                    ),
                                                                  )
                                                                }
                                                              ],
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),

                                                          if(userProfileModel.data.id == appUserSession.value.id)...{
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                // for qualification
                                                                customDocumentWidget(
                                                                    "qualification",
                                                                    userProfileModel
                                                                        .data
                                                                        .qualifications,
                                                                    userProfileModel
                                                                        .data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                // for certificate
                                                                customDocumentWidget(
                                                                    "certificate",
                                                                    userProfileModel.data.certificates, userProfileModel.data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),

                                                                Container(
                                                                  width: AppHelper.getDeviceWidth(context),
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    color: Colors.white,
                                                                  ),
                                                                  padding: EdgeInsets.all(20),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        "Licences:",
                                                                        textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                        style:
                                                                        TextStyle(
                                                                          fontSize:
                                                                          16,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      userProfileModel
                                                                          .data
                                                                          .license !=
                                                                          null
                                                                          ? Container(
                                                                        alignment:
                                                                        Alignment.center,
                                                                        // width: AppHelper.getDeviceWidth(context),
                                                                        child: fullScreenImage(
                                                                            "licence" +
                                                                                userProfileModel.data.id.toString(),
                                                                            userProfileModel.data.license),
                                                                      )
                                                                          : Center(
                                                                          child: Text(
                                                                              "No licences yet"))
                                                                    ],
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),


                                                                customDocumentWidget(
                                                                    "credential",
                                                                    userProfileModel
                                                                        .data
                                                                        .credentials,
                                                                    userProfileModel
                                                                        .data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),

                                                                customDocumentWidget(
                                                                    "inservice",
                                                                    userProfileModel
                                                                        .data
                                                                        .inservices,
                                                                    userProfileModel
                                                                        .data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),

                                                                // for resume
                                                                userProfileModel.data
                                                                    .resume !=
                                                                    null
                                                                    ? Container(
                                                                  width: AppHelper
                                                                      .getDeviceWidth(
                                                                      context),
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        10),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                      20),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          "Resume:",
                                                                          textAlign:
                                                                          TextAlign.start,
                                                                          style:
                                                                          TextStyle(
                                                                            fontSize:
                                                                            16,
                                                                            color:
                                                                            Colors.black,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                        10,
                                                                      ),
                                                                      userProfileModel.data.resume !=
                                                                          null
                                                                          ? GestureDetector(
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            color: AppColor.blueBoxColor,
                                                                          ),
                                                                          padding: EdgeInsets.all(10),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.download_rounded,
                                                                                color: Colors.white,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Text(
                                                                                "Download",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        onTap: () {
                                                                          downloadResume(userProfileModel.data.resume);
                                                                        },
                                                                      )
                                                                          : Center(
                                                                          child: Text("No downloads yet"))
                                                                    ],
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                  ),
                                                                )
                                                                    : Container(
                                                                  width: AppHelper
                                                                      .getDeviceWidth(
                                                                      context),
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        10),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                      20),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        "Resume:",
                                                                        textAlign:
                                                                        TextAlign.center,
                                                                        style:
                                                                        TextStyle(
                                                                          fontSize:
                                                                          16,
                                                                          color:
                                                                          Colors.black,
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                        10,
                                                                      ),
                                                                      Center(
                                                                          child:
                                                                          Text("No resumes yet"))
                                                                    ],
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          }else...{
                                                            userProfileModel .data.profileLock == 1
                                                                ? Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                // for qualification
                                                                customDocumentWidget(
                                                                    "qualification",
                                                                    userProfileModel
                                                                        .data
                                                                        .qualifications,
                                                                    userProfileModel
                                                                        .data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),
                                                                // for certificate
                                                                customDocumentWidget(
                                                                    "certificate",
                                                                    userProfileModel.data.certificates, userProfileModel.data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),

                                                                Container(
                                                                  width: AppHelper.getDeviceWidth(context),
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.circular(10),
                                                                    color: Colors.white,
                                                                  ),
                                                                  padding: EdgeInsets.all(20),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        "Licences:",
                                                                        textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                        style:
                                                                        TextStyle(
                                                                          fontSize:
                                                                          16,
                                                                          color: Colors
                                                                              .black,
                                                                          fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height: 10,
                                                                      ),
                                                                      userProfileModel
                                                                          .data
                                                                          .license !=
                                                                          null
                                                                          ? Container(
                                                                        alignment:
                                                                        Alignment.center,
                                                                        // width: AppHelper.getDeviceWidth(context),
                                                                        child: fullScreenImage(
                                                                            "licence" +
                                                                                userProfileModel.data.id.toString(),
                                                                            userProfileModel.data.license),
                                                                      )
                                                                          : Center(
                                                                          child: Text(
                                                                              "No licences yet"))
                                                                    ],
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),


                                                                customDocumentWidget(
                                                                    "credential",
                                                                    userProfileModel
                                                                        .data
                                                                        .credentials,
                                                                    userProfileModel
                                                                        .data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),

                                                                customDocumentWidget(
                                                                    "inservice",
                                                                    userProfileModel
                                                                        .data
                                                                        .inservices,
                                                                    userProfileModel
                                                                        .data.id),
                                                                SizedBox(
                                                                  height: 10,
                                                                ),

                                                                // for resume
                                                                userProfileModel.data
                                                                    .resume !=
                                                                    null
                                                                    ? Container(
                                                                  width: AppHelper
                                                                      .getDeviceWidth(
                                                                      context),
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        10),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                      20),
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                        Text(
                                                                          "Resume:",
                                                                          textAlign:
                                                                          TextAlign.start,
                                                                          style:
                                                                          TextStyle(
                                                                            fontSize:
                                                                            16,
                                                                            color:
                                                                            Colors.black,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                        10,
                                                                      ),
                                                                      userProfileModel.data.resume !=
                                                                          null
                                                                          ? GestureDetector(
                                                                        child: Container(
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(10),
                                                                            color: AppColor.blueBoxColor,
                                                                          ),
                                                                          padding: EdgeInsets.all(10),
                                                                          child: Row(
                                                                            children: [
                                                                              Icon(
                                                                                Icons.download_rounded,
                                                                                color: Colors.white,
                                                                              ),
                                                                              SizedBox(
                                                                                width: 5,
                                                                              ),
                                                                              Text(
                                                                                "Download",
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        onTap: () {
                                                                          downloadResume(userProfileModel.data.resume);
                                                                        },
                                                                      )
                                                                          : Center(
                                                                          child: Text("No downloads yet"))
                                                                    ],
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                  ),
                                                                )
                                                                    : Container(
                                                                  width: AppHelper
                                                                      .getDeviceWidth(
                                                                      context),
                                                                  decoration:
                                                                  BoxDecoration(
                                                                    borderRadius:
                                                                    BorderRadius.circular(
                                                                        10),
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                  padding:
                                                                  EdgeInsets
                                                                      .all(
                                                                      20),
                                                                  child: Column(
                                                                    children: [
                                                                      Text(
                                                                        "Resume:",
                                                                        textAlign:
                                                                        TextAlign.center,
                                                                        style:
                                                                        TextStyle(
                                                                          fontSize:
                                                                          16,
                                                                          color:
                                                                          Colors.black,
                                                                          fontWeight:
                                                                          FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        height:
                                                                        10,
                                                                      ),
                                                                      Center(
                                                                          child:
                                                                          Text("No resumes yet"))
                                                                    ],
                                                                    crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                                : SizedBox(),
                                                          },


                                                        ],
                                                      )
                                                    : Container()
                                              ],
                                            );
                                          }
                                        })
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return Container();
                          //ProgressDialog.getCircularProgressIndicator();
                        }),
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                  )),
                );
              }
              return Container(
                color: AppColor.skyBlueColor,
              );
            })));
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

  getDocView() {
    Map<String, String> body = Map();
    body['profile_lock'] =  _switchValue == false ? "0" : "1";

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.profileShowLock,
        apiAction: ApiAction.profileShowLock,
        body: body);
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.userProfileView) {
      userProfileModel = UserProfileModel.fromJson(result);
      if (userProfileModel.success) {
        futureProfile = Future.delayed(Duration(seconds: 0), () {
          setState(() {});
          return userProfileModel;
        });
      } else {
        AppHelper.showToastMessage(userProfileModel.message);
      }
    } else if (action == ApiAction.sendConnectionRequuest) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        getUserProfileAPI();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.readNotification) {
    } else if (action == ApiAction.acceptConnectionRequuest) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        showAcceptInvitationDialog();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.updateCoverProfile) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        getUserProfileAPI();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.removeConnection) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        unfriendCalled = true;
        getUserProfileAPI();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.userBlockUnblock) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        blockUnblockUserFirebase();
        getUserProfileAPI();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }else if (action == ApiAction.profileShowLock) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        getUserProfileAPI();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

  Future<void> blockUnblockUserFirebase() async {
    List<int> blockedBy = [];
    FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
            widget.usersModel.id.toString()))
        .get()
        .then((value) {
      blockedBy = [];
      for (var data in value.data()['blocked_by'] ?? []) {
        blockedBy.add(data);
      }
      print(blockedBy);

      if (blockedBy.contains(appUserSession.value.id)) {
        FirebaseFirestore.instance
            .collection(FirebaseKey.chatroom)
            .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
                widget.usersModel.id.toString()))
            .set({
          "blocked_by": FieldValue.arrayRemove([appUserSession.value.id]),
        }, SetOptions(merge: true));
      } else {
        FirebaseFirestore.instance
            .collection(FirebaseKey.chatroom)
            .doc(AppHelper.getChatID(appUserSession.value.id.toString(),
                widget.usersModel.id.toString()))
            .set({
          "blocked_by": FieldValue.arrayUnion([appUserSession.value.id]),
        }, SetOptions(merge: true));
      }
    });
  }

  void messageScreen(UserProfileModel userProfileModel) {
    UsersModel usersModel = UsersModel.fromJson(userProfileModel.data.toJson());

    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          ChatScreen(usersModel),
      transitionDuration: Duration(seconds: 0),
    ));
  }

  void unFriendAPI(String userId) {
    Map<String, String> body = Map();
    body["other_user_id"] = widget.usersModel.id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        url: Url.removeConnection,
        apiAction: ApiAction.removeConnection,
        body: body);
  }

  Future<void> downloadResume(String resume) async {
    DownloadProgressDialog.show(context, resume);
  }

  Future<void> getUserProfileAPI() {
    Map<String, String> body = Map();
    body['user_id'] = widget.usersModel.id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.userProfileView,
        apiAction: ApiAction.userProfileView,
        body: body);
  }

//connected true alre=true // frends hai
//connected false alre=true // response
  readNotification() {
    Map<String, String> body = Map();
    body['notification_id'] = widget.notificationId.toString();
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.readNotification,
        apiAction: ApiAction.readNotification,
        body: body);
  }

  void connectAPI() {
    Map<String, String> body = Map();
    body["user_id"] = widget.usersModel.id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        url: Url.sendConnectionRequuest,
        apiAction: ApiAction.sendConnectionRequuest,
        body: body);
  }

  void acceptRequestAPI(int id) {
    Map<String, String> body = Map();
    body["connection_request_id"] = id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        url: Url.acceptConnectionRequuest,
        apiAction: ApiAction.acceptConnectionRequuest,
        body: body);
  }

  void showAcceptInvitationDialog() {
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
                                getUserProfileAPI();
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
                            widget.usersModel.name.toString(),
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

  void uploadCoverPhoto(File file) {
    Map<String, File> mapOfFilesAndKey = Map();
    if (AppHelper.isFileExist(file)) {
      mapOfFilesAndKey["cover_picture"] = file;
    }

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.updateCoverProfile,
      apiAction: ApiAction.updateCoverProfile,
      isMultiPart: true,
      mapOfFilesAndKey: mapOfFilesAndKey,
    );
  }

  fullScreenImage(tag, url) {
    return Container(
      height: 120,
      width: 120,
      child: FittedBox(
        child: FullScreenWidget(
            child: Hero(
          tag: tag,
          child: CustomWidget.imageView(url,
              paddingProgressBar: true, fullImage: true),
        )),
        fit: BoxFit.fill,
      ),
    );
  }

  _isImage(String imageUrl) {
    if (imageUrl != null &&
        (imageUrl.contains(".png") ||
            imageUrl.contains(".jpeg") ||
            imageUrl.contains(".jpg"))) {
      return true;
    }
    return false;
  }

  docWidget(url) {
    return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          downloadResume(url);
        },
        child: Container(
          decoration: BoxDecoration(
              color: AppColor.fileBoxColor,
              borderRadius: BorderRadius.circular(10)),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.only(top: 5),
          child: Icon(
            Icons.file_copy,
            size: 50,
          ),
        ));
  }

  void callDialog(String message, Function function, int type) {
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
                      /*Stack(
                        children: [
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
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),*/
                      Text(
                        message,
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
                                color: AppColor.lightSkyBlueColor,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "NO",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
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
                                color: Colors.red,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "YES",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              if (type == 1) {
                                function('1');
                              } else if (type == 2) {
                                function('1');
                              } else if (type == 3) {
                                function('2');
                              }
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

  void _backPress() {
    if (widget.fromNotification != null && widget.fromNotification) {
      Navigator.of(context).pop(true);
    } else {
      if (Navigator.canPop(context)) {
        print("unfriendCalled=" + unfriendCalled.toString());
        Navigator.of(context).pop(unfriendCalled);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.DashboardScreen, (route) => false);
      }
    }
  }

  Widget customDocumentWidget(String docName, List<String> docList, int id) {
    return Container(
      width: AppHelper.getDeviceWidth(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            docName[0].toUpperCase() +
                docName.substring(
                  1,
                ) +
                "s:",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          docList.length > 0
              ? docList.length == 1
                  ? Container(
                      alignment: Alignment.center,
                      child: _isImage(docList[0])
                          ? fullScreenImage(docName + id.toString(), docList[0])
                          : docWidget(docList[0]))
                  : GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.0,
                          mainAxisSpacing: 10.0),
                      itemBuilder: (_, index) {
                        if (_isImage(docList[index])) {
                          return fullScreenImage(
                              docName +
                                  index.toString() +
                                  docList[index].toString(),
                              docList[index]);
                        }
                        return docWidget(docList[index]);
                      },
                      itemCount: docList.length,
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    )
              : Center(child: Text("No ${docName}s yet"))
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
