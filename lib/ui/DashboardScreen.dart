import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/app/FirebasePushNotification.dart';
import 'package:names/callBack/HomeScreenCallBack.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/custom_widget/pop_menu_dialog.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/ProfileModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:names/ui/MeetingScheduling/CalendarScreen.dart';
import 'package:names/ui/NotificationScreen.dart';
import 'package:names/ui/chat/MessageScreen.dart';
import 'package:names/ui/fragment/ConnectionScreen.dart';
import 'package:names/ui/fragment/HomeScreen.dart';
import 'package:names/ui/fragment/NewsFeedScreen.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import '../main.dart';
import 'fragment/YourDiaryScreen.dart';
import 'package:http/http.dart' as http;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with
        ApiCallBackListener,
        HomeScreenCallBackListener,
        WidgetsBindingObserver {
  BottomMenu bottomMenu = BottomMenu.HOME;
  GlobalKey globalKey = GlobalKey();
  // VideoCallProvider _videoCallProvider;
  // AudioCallProvider _audioCallProvider;
  ProfileModel profileModel;
  DateTime currentBackPressTime;
  String storeDeviceapnToken;
  Widget logoWidget() {
    return Padding(
      padding: const EdgeInsets.only(left: 5),
      child: Image.asset(
        "assets/icons/logo.png",
        fit: BoxFit.fitHeight,
        height: 30,
      ),
    );
  }

  _appBarWidget(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (bottomMenu != BottomMenu.HOME)
          Container(
            child: IconButton(
              icon: Image.asset(
                getHeaderLogo(),
                height: 20,
                width: 20,
              ),
              onPressed: () {},
            ),
          ),
        bottomMenu == BottomMenu.HOME
            ? logoWidget()
            : Text(
                getHeaderTitle(),
                style: TextStyle(
                    fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
              ),
        Spacer(),
        IconButton(
          icon: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColor.lightSkyBlueColor.withOpacity(0.2),
            ),
            alignment: Alignment.center,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Icon(
                  Icons.notifications,
                  size: 24,
                  color: AppColor.lightSkyBlueColor,
                ),
                ValueListenableBuilder(
                    valueListenable: notificationCount,
                    builder: (context, value, child) {
                      return Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 10,
                          width: 10,
                          margin: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: notificationCount.value > 0
                                ? Colors.red
                                : Colors.grey,
                          ),
                        ),
                      );
                    })
              ],
            ),
          ),
          onPressed: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  NotificationScreen(),
              transitionDuration: Duration(seconds: 0),
            ));
          },
        ),
        if (bottomMenu == BottomMenu.HOME)
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ChangeNotifierProvider<ScheduleCalendarProvider>(
                              create: (context) => ScheduleCalendarProvider(),
                              child: CalendarScreen())));
            },
            child: Image.asset(
              "assets/icons/calendar.png",
              height: 22,
              width: 22,
              color: AppColor.lightSkyBlueColor,
            ),
          ),
        IconButton(
          icon: Container(
            height: 40,
            width: 40,
            key: globalKey,
            child: CustomWidget.imageView(appUserSession.value.profilePicture,
                circle: true,
                height: 40,
                width: 40,
                fit: BoxFit.cover,
                forProfileImage: true),
          ),
          onPressed: () {
            PopMenuDialog().show(context, globalKey);
          },
        ),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // FlutterCallkitIncoming.endAllCalls();
      if (mounted) {
        setState(
          () {},
        );
      }
    } else if (state == AppLifecycleState.paused) {
      // if (_videoCallProvider.hmsSDK != null) {
      //   _videoCallProvider.endRoom();
      // }
      // if (_audioCallProvider.hmsSDK != null) {
      //   _audioCallProvider.endRoom();
      // }
    }
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
                appBar: bottomMenu != BottomMenu.MESSAGE
                    ? (data.callStatus == "ringing"
                        ? PreferredSize(
                            child: CallNotificationPopup(),
                            preferredSize: Size(200, 140))
                        : data.onCall
                            ? PreferredSize(
                                preferredSize: Size(200, 140),
                                child: Column(children: [
                                  Flexible(child: CallNotificationPopup()),
                                  AppHelper.appBar(
                                      context,
                                      _appBarWidget(context),
                                      LinearGradient(colors: [
                                        AppColor.skyBlueColor,
                                        AppColor.skyBlueColor
                                      ]))
                                ]))
                            : AppHelper.appBar(
                                context,
                                _appBarWidget(context),
                                LinearGradient(colors: [
                                  AppColor.skyBlueColor,
                                  AppColor.skyBlueColor
                                ])))
                    : null,
                backgroundColor: AppColor.skyBlueColor,
                extendBody: true,
                resizeToAvoidBottomInset: false,
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
                floatingActionButton: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 3.0,
                        ),
                      ],
                      color: AppColor.lightSkyBlueColor,
                      border: Border.all(width: 3, color: Colors.white)),
                  child: IconButton(
                    icon: Image.asset(
                      "assets/icons/diary.png",
                      height: 24,
                      width: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        bottomMenu = BottomMenu.DIARY;
                      });
                    },
                  ),
                ),
                body: WillPopScope(
                    child: appProfileModel.value != null
                        ? Stack(children: [
                            Builder(builder: (ctx) {
                              switch (bottomMenu) {
                                case BottomMenu.HOME:
                                  {
                                    return HomeScreen();
                                  }
                                case BottomMenu.CONNECTION:
                                  {
                                    return ConnectionScreen();
                                  }
                                case BottomMenu.NEWSFEED:
                                  {
                                    return NewsFeedScreen();
                                  }
                                case BottomMenu.MESSAGE:
                                  {
                                    return MessageScreen();
                                  }
                                case BottomMenu.DIARY:
                                  {
                                    return YourDiaryScreen();
                                  }
                                default:
                                  {
                                    return Container();
                                  }
                              }
                            }),
                          ])
                        : Center(
                            child:
                                ProgressDialog.getCircularProgressIndicator(),
                          ),
                    onWillPop: onWillPop),
                bottomNavigationBar: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: BottomAppBar(
                    shape: CircularNotchedRectangle(),
                    color: Colors.white,
                    notchMargin: 8.0,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          IconButton(
                            icon: Image.asset(
                              "assets/icons/home_icon.png",
                              height: 24,
                              width: 24,
                              color: bottomMenu == BottomMenu.HOME
                                  ? AppColor.lightSkyBlueColor
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                bottomMenu = BottomMenu.HOME;
                              });
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                              "assets/icons/connection.png",
                              height: 24,
                              width: 24,
                              color: bottomMenu == BottomMenu.CONNECTION
                                  ? AppColor.lightSkyBlueColor
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                bottomMenu = BottomMenu.CONNECTION;
                              });
                            },
                          ),
                          IconButton(
                            icon: Container(),
                            onPressed: null,
                          ),
                          IconButton(
                            icon: Image.asset(
                              "assets/icons/newsfeed.png",
                              height: 24,
                              width: 24,
                              color: bottomMenu == BottomMenu.NEWSFEED
                                  ? AppColor.lightSkyBlueColor
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                bottomMenu = BottomMenu.NEWSFEED;
                              });
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                bottomMenu = BottomMenu.MESSAGE;
                              });
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.topCenter,
                              children: [
                                Image.asset(
                                  "assets/icons/message.png",
                                  height: 44,
                                  width: 26,
                                  color: bottomMenu == BottomMenu.MESSAGE
                                      ? AppColor.lightSkyBlueColor
                                      : null,
                                ),
                                ValueListenableBuilder<int>(
                                    valueListenable: messageCount,
                                    builder: (context, value, child) {
                                      if (value > 0) {
                                        return SizedBox(
                                          height: 20,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10, top: 0),
                                            child: Align(
                                              alignment: Alignment.topCenter,
                                              child: CircleAvatar(
                                                radius: 10,
                                                backgroundColor: Colors.red,
                                                child: Text(
                                                  value.toString(),
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return SizedBox(
                                          height: 5,
                                        );
                                      }
                                    }),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ));
          }
          return Container(
            color: AppColor.skyBlueColor,
          );
        }));
  }

  registerTwilio() async {
    print(
        "------------------------------------registering twilio------------------------------------------------");
    String androidToken;
    if (Platform.isAndroid) {
      String pushSid = "CR54ae5b54f73f14383984e7eaf44a3e68";
      http.Response response = await http.get(Uri.parse(
          'https://good-pike-outerwear.cyclic.app/accessToken?identity=${'vikasyadav123'}&pushid=${pushSid}'));

      if (response.statusCode == 200) {
        print(response.body);
        // TwilioVoice.instance.registerClient(jsonDecode(response.body)['token']);
        //  print("TOKENNN"+response.body.toString());
      }
    } else {
      String pushSid = "CRfc4b637fb0f4b549635ca053904d55b5";
      http.Response response = await http.get(Uri.parse(
          'https://good-pike-outerwear.cyclic.app/accessToken?identity=${appUserSession.value.id.toString()}&pushid=${pushSid}'));
      print(response.body);
      if (response.statusCode == 200) {
        //  TwilioVoice.instance.registerClient(jsonDecode(response.body)['token']);
        //  print("TOKENNN"+response.body.toString());
      }
    }
  }

  @override
  void initState() {
    // _videoCallProvider = Provider.of<VideoCallProvider>(context, listen: false);
    // _audioCallProvider = Provider.of<AudioCallProvider>(context, listen: false);

    FirebaseHelper().getUserMessageCount();
    HomeScreenCallBack.setHomeScreenCallBack(this);
    if (mounted) {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.getToken().then((token) {
        String deviceToken = token;
        storeDeviceapnToken = token;
        print('-------------------------------Device Token: $deviceToken');
      });
      print("------------addking in firebase");

      FirebaseFirestore.instance
          .collection(FirebaseKey.usersStatus)
          .doc(appUserSession.value.id.toString())
          .set({
        FirebaseKey.isOnline: true,
        FirebaseKey.onlineTime: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      getProfileAPI();

      FirebasePushNotification.instance().getInitialMessage();
      dynamicLinkService.handleDynamicLinks();
    }
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    if (appUserSession != null &&
        appUserSession.value != null &&
        appUserSession.value.id != null) {
      FirebaseFirestore.instance
          .collection(FirebaseKey.usersStatus)
          .doc(appUserSession.value.id.toString())
          .set({
        FirebaseKey.isOnline: false,
        FirebaseKey.offlineTime: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  String getHeaderTitle() {
    switch (bottomMenu) {
      case BottomMenu.HOME:
        return "NAMES";
      case BottomMenu.CONNECTION:
        return "Network";
      case BottomMenu.NEWSFEED:
        return "News Feed";
      case BottomMenu.MESSAGE:
        return "Consults";
      case BottomMenu.DIARY:
        return "Journal/In-Service";
    }
    return "";
  }

  String getHeaderLogo() {
    switch (bottomMenu) {
      case BottomMenu.HOME:
        return "assets/icons/home.png";
      case BottomMenu.CONNECTION:
        return "assets/icons/network.png";
      case BottomMenu.NEWSFEED:
        return "assets/icons/newsfeed_black.png";
      case BottomMenu.MESSAGE:
        return "assets/icons/message_black.png";
      case BottomMenu.DIARY:
        return "assets/icons/diary_black.png";
    }
    return "assets/icons/home.png";
  }

  getProfileAPI({bool showLoader: false}) {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: showLoader,
      httpType: HttpMethods.POST,
      url: Url.dashboardProfile,
      apiAction: ApiAction.dashboardProfile,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.createAccessToken) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);

        /*TwilioVoice.instance.setOnDeviceTokenChanged((token) {

          //  register();
        });*/
      }
    } else if (action == ApiAction.dashboardProfile) {
      profileModel = ProfileModel.fromJson(result);
      if (profileModel.success) {
        appProfileModel.value = profileModel;
        appUserSession.value.firstName = profileModel.data.firstName;
        appUserSession.value.lastName = profileModel.data.lastName;
        appUserSession.value.email = profileModel.data.email;
        appUserSession.value.email = profileModel.data.email;
        appUserSession.value.profilePicture = profileModel.data.profilePicture;
        appUserSession.value.social_type = profileModel.data.socialType;
        appUserSession.value.devicetype = profileModel.data.devicetype;
        appUserSession.value.apntoken = profileModel.data.apntoken;
        // appUserSession.value.apntoken = storeDeviceapnToken;
        // profileModel.data.apntoken = storeDeviceapnToken;
        appUserSession.value.name = profileModel.data.name;
        appUserSession.value.profession_symbol = profileModel.data.profession_symbol;
        if (profileModel.data.notification) {
          AppHelper.notificationCounterHelper(1);
        } else {
          AppHelper.notificationCounterHelper(0);
        }
        AppHelper.saveUserSession(appUserSession.value);
        FirebaseFirestore.instance
            .collection(FirebaseKey.users)
            .doc(profileModel.data.id.toString())
            .set(profileModel.data.toJson())
            .then((value) {
          print("updated in firebase");
        });
        if (mounted) {
          setState(() {});
        }
      } else {
        AppHelper.showToastMessage(profileModel.message);
      }
    }
  }

  @override
  callBack(value) {
    if (value == "UPDATE_PROFILE") {
      getProfileAPI(showLoader: true);
    }
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      AppHelper.showToastMessage("Press back again to exit");
      return Future.value(false);
    }
    return Future.value(true);
  }
}

enum BottomMenu { HOME, CONNECTION, NEWSFEED, MESSAGE, DIARY }
