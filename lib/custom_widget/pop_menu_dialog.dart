import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/constants/Enums.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/route/routes.dart';
import 'package:names/ui/MeetingScheduling/CalendarScreen.dart';
import 'package:names/ui/MeetingScheduling/MyScheduleScreen.dart';
import 'package:names/ui/PrivacyPolicyScreen.dart';
import 'package:names/ui/RepostAbuseScreen.dart';
import 'package:names/ui/TermsAndConditionsScreen.dart';
import 'package:names/ui/save_videos_screen.dart';
import 'package:popup_menu/triangle_painter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/ApiAction.dart';
import '../api/ApiRequest.dart';
import '../api/HttpMethods.dart';
import '../api/Url.dart';
import '../model/ApiResponseModel.dart';
import '../model/UserSession.dart';
import '../ui/chat/ConnectedUserScreen.dart';

/* Created by Bholendra Singh  */
class PopMenuDialog implements ApiCallBackListener {
  Rect _showRect;
  var arrowHeight = 10.0;
  var itemWidth = 99.0;
  var itemHeight = 40.0;

  Size _screenSize;

  OverlayEntry _entry;
  Offset _offset;

  bool _isShow = false;

  bool _isDown = false;
  bool isShowing = false;
  BuildContext context;
  GlobalKey globalKey;

  void show(BuildContext context, GlobalKey globalKey) {
    this.context = context;
    this.globalKey = globalKey;
    _showRect = getWidgetGlobalRect(globalKey);
    _screenSize = window.physicalSize / window.devicePixelRatio;
    _offset = _calculateOffset(context);

    _entry = OverlayEntry(builder: (context) {
      return buildPopupMenuLayout(_offset);
    });
    Overlay.of(context).insert(_entry);
    _isShow = true;
  }

  getCircularProgressIndicator({double height, double width}) {
    if (height == null) {
      height = 40.0;
    }
    if (width == null) {
      width = 40.0;
    }
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(AppColor.darkBlueColor),
        ),
        height: height,
        width: width,
      ),
    );
  }

  getErrorWidget() {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: Text("Oops! Something went wrong."),
      ),
    );
  }

  Offset _calculateOffset(BuildContext context) {
    double dx = _showRect.left + _showRect.width / 2.0 - menuWidth() / 2.0;
    if (dx < 10.0) {
      dx = 10.0;
    }

    if (dx + menuWidth() > _screenSize.width && dx > 10.0) {
      double tempDx = _screenSize.width - menuWidth() - 10;
      if (tempDx > 10) dx = tempDx;
    }

    double dy = _showRect.top - menuHeight();
    if (dy <= MediaQuery.of(context).padding.top + 10) {
      // The have not enough space above, show menu under the widget.
      dy = arrowHeight + _showRect.height + _showRect.top;
    } else {
      dy -= arrowHeight;
    }

    return Offset(dx, dy);
  }

  double menuWidth() {
    return itemWidth * 2;
  }

  // This height exclude the arrow
  double menuHeight() {
    return itemHeight * 11;
  }

  Rect getWidgetGlobalRect(GlobalKey key) {
    RenderBox renderBox = key.currentContext.findRenderObject();
    var offset = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
        offset.dx, offset.dy, renderBox.size.width, renderBox.size.height);
  }

  LayoutBuilder buildPopupMenuLayout(Offset offset) {
    return LayoutBuilder(builder: (context, constraints) {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          dismiss();
        },
//        onTapDown: (TapDownDetails details) {
//          dismiss();
//        },
        // onPanStart: (DragStartDetails details) {
        //   dismiss();
        // },
        onVerticalDragStart: (DragStartDetails details) {
          dismiss();
        },
        onHorizontalDragStart: (DragStartDetails details) {
          dismiss();
        },
        child: Container(
          child: Stack(
            children: <Widget>[
              // triangle arrow
              Positioned(
                left: _showRect.left + _showRect.width / 2.0 - 7.5,
                top: _isDown
                    ? offset.dy + menuHeight()
                    : offset.dy - arrowHeight,
                child: CustomPaint(
                  size: Size(15.0, arrowHeight),
                  painter:
                      TrianglePainter(isDown: _isDown, color: Colors.white),
                ),
              ),
              // menu content
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Container(
                  width: menuWidth(),
                  height: menuHeight(),
                  child: Column(
                    children: <Widget>[
                      ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Container(
                            width: menuWidth(),
                            height: menuHeight(),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10.0)),
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Material(
                              color: Colors.transparent,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/user.png",
                                            height: 14,
                                            width: 14,
                                            color: HexColor("#33c3f5"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "My Profile",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "profile",
                                    clickCallback: (value) {
                                      dismiss();
                                      UsersModel userModel = new UsersModel();
                                      userModel.id = appUserSession.value.id;
                                      userModel.name =
                                          appUserSession.value.name;
                                      Navigator.of(context).pushNamed(
                                          Routes.UserProfileScreen,
                                          arguments: userModel);
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/group.png",
                                            height: 14,
                                            width: 14,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Edit Profile",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "edit",
                                    clickCallback: (value) {
                                      dismiss();
                                      Navigator.of(context)
                                          .pushNamed(Routes.UpdateProfile);
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/conecntion_color.png",
                                            height: 16,
                                            width: 16,
                                            color: HexColor("#33c3f5"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "My Connection",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "edit",
                                    clickCallback: (value) {
                                      dismiss();
                                      Navigator.of(context)
                                          .push(PageRouteBuilder(
                                        pageBuilder: (BuildContext context,
                                                Animation<double> animation,
                                                Animation<double>
                                                    secondaryAnimation) =>
                                            ConnectedUserScreen(
                                                title: "My Connection"),
                                        transitionDuration:
                                            Duration(seconds: 0),
                                      ));
                                    },
                                  ),
                                  // MenuItemWidget(
                                  //   item: Container(
                                  //     height: itemHeight,
                                  //     padding:
                                  //         EdgeInsets.symmetric(horizontal: 10),
                                  //     child: Row(
                                  //       children: [
                                  //         Image.asset(
                                  //           "assets/icons/bussiness.png",
                                  //           height: 14,
                                  //           width: 14,
                                  //         ),
                                  //         SizedBox(
                                  //           width: 10,
                                  //         ),
                                  //         Text(
                                  //           "Sign up as Business",
                                  //           style:
                                  //               TextStyle(color: Colors.black),
                                  //         )
                                  //       ],
                                  //     ),
                                  //   ),
                                  //   menuValue: "bussiness",
                                  //   clickCallback: (value) async {
                                  //     dismiss();
                                  //     const url =
                                  //         "https://vendurs.cmsbox.in/user/business";
                                  //     if (await canLaunch(url))
                                  //       await launch(url);
                                  //     else
                                  //       AppHelper.showToastMessage(
                                  //           "Browser not found");
                                  //   },
                                  // ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/calendar.png",
                                            height: 14,
                                            width: 14,
                                            color: AppColor.lightSkyBlueColor,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "My Schedule",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "schedule",
                                    clickCallback: (value) async {
                                      dismiss();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider<
                                                          ScheduleCalendarProvider>(
                                                      create: (context) =>
                                                          ScheduleCalendarProvider(),
                                                      child:
                                                          MyScheduleScreen())));
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/calendar.png",
                                            height: 14,
                                            width: 14,
                                            color: AppColor.lightSkyBlueColor,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "NAMES Calendar",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "calendar",
                                    clickCallback: (value) async {
                                      dismiss();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ChangeNotifierProvider<
                                                          ScheduleCalendarProvider>(
                                                      create: (context) =>
                                                          ScheduleCalendarProvider(),
                                                      child:
                                                          CalendarScreen())));
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/video.png",
                                            height: 14,
                                            width: 14,
                                            color: AppColor.lightSkyBlueColor,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Save Videos",
                                            style:
                                            TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "save video",
                                    clickCallback: (value) async {
                                      dismiss();
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                              SaveVideoScreen(title: "Save Video",)
                                          ));
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/PrivacyPolicy.png",
                                            height: 14,
                                            width: 14,
                                            color: HexColor("#33c3f5"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Privacy Policy",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "privacyPolicy",
                                    clickCallback: (value) {
                                      dismiss();
                                      Navigator.of(context)
                                          .push(PageRouteBuilder(
                                        pageBuilder: (BuildContext context,
                                                Animation<double> animation,
                                                Animation<double>
                                                    secondaryAnimation) =>
                                            PrivacyPolicyScreen(),
                                        transitionDuration:
                                            Duration(seconds: 0),
                                      ));
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/TermsAndConditions.png",
                                            height: 14,
                                            width: 14,
                                            color: HexColor("#33c3f5"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Flexible(
                                            child: Text(
                                              "Terms and Conditions",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "termsAndConditions",
                                    clickCallback: (value) {
                                      print(value);
                                      dismiss();
                                      Navigator.of(context)
                                          .push(PageRouteBuilder(
                                        pageBuilder: (BuildContext context,
                                                Animation<double> animation,
                                                Animation<double>
                                                    secondaryAnimation) =>
                                            TermsAndConditionsScreen(),
                                        transitionDuration:
                                            Duration(seconds: 0),
                                      ));
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/reportAbuse.png",
                                            height: 14,
                                            width: 14,
                                            color: HexColor("#33c3f5"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Report Abuse",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "reportAbuse",
                                    clickCallback: (value) {
                                      print(value);
                                      dismiss();
                                      Navigator.of(context)
                                          .push(PageRouteBuilder(
                                        pageBuilder: (BuildContext context,
                                                Animation<double> animation,
                                                Animation<double>
                                                    secondaryAnimation) =>
                                            ReportAbuseScreen(),
                                        transitionDuration:
                                            Duration(seconds: 0),
                                      ));
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/delProfile.png",
                                            height: 14,
                                            width: 14,
                                            color: HexColor("#33c3f5"),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Delete Profile",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "deleteProfile",
                                    clickCallback: (value) {
                                      dismiss();
                                      showDeleteProfileDialog();
                                    },
                                  ),
                                  MenuItemWidget(
                                    item: Container(
                                      height: itemHeight,
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        children: [
                                          Image.asset(
                                            "assets/icons/logout.png",
                                            height: 14,
                                            width: 14,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Log Out",
                                            style:
                                                TextStyle(color: Colors.black),
                                          )
                                        ],
                                      ),
                                    ),
                                    menuValue: "logout",
                                    clickCallback: (value) {
                                      dismiss();
                                      showLogoutnDialog();
                                    },
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }

  void dismiss() {
    if (!_isShow) {
      // Remove method should only be called once
      return;
    }

    _entry.remove();
    _isShow = false;
    // if (dismissCallback != null) {
    //   dismissCallback();
    // }
  }

  Future<void> deleteUser() async {
    print("--------------------deleting------------------");
    print(appUserSession.value.social_type);
    bool isGoogleLogin = false;
    if (appUserSession.value.social_type != null &&
        (appUserSession.value.social_type == LoginType.google.name ||
            appUserSession.value.social_type == LoginType.ios.name)) {
      isGoogleLogin = true;
    }

    await FirebaseFirestore.instance
        .collection(FirebaseKey.users)
        .doc(appUserSession.value.id.toString())
        .delete();
    await FirebaseFirestore.instance
        .collection(FirebaseKey.usersStatus)
        .doc(appUserSession.value.id.toString())
        .delete();

    appUserSession.value = null;
    appProfileModel.value = null;
    AppHelper.clearUserSession().then((value) async {
      if (isGoogleLogin) {
        HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
          'deleteProfile',
          options: HttpsCallableOptions(),
        );

        try {
          final userId = FirebaseAuth.instance.currentUser.uid;
          if (userId != null) {
            callable.call(<String, dynamic>{
              'uid': userId,
            });
          }
        } on FirebaseFunctionsException catch (e) {
          print(e.message.toString());
        } catch (e) {
          print(e.toString());
        }

        new GoogleSignIn().signOut();

        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.LoginScreen, (route) => false);
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.LoginScreen, (route) => false);
      }
    });
  }

  void logout() {
    bool isGoogleLogin = false;
    if (appUserSession.value.social_type != null &&
        appUserSession.value.social_type == LoginType.google.name) {
      isGoogleLogin = true;
    }
    FirebaseFirestore.instance
        .collection(FirebaseKey.usersStatus)
        .doc(appUserSession.value.id.toString())
        .set({
      FirebaseKey.isOnline: false,
      FirebaseKey.offlineTime: FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    appUserSession.value = null;
    appProfileModel.value = null;
    AppHelper.clearUserSession().then((value) async {
      if (isGoogleLogin) {
        await FirebaseAuth.instance.signOut().then((value) {
          new GoogleSignIn().signOut();
          print("google logout successfull");
          Navigator.of(context)
              .pushNamedAndRemoveUntil(Routes.LoginScreen, (route) => false);
        });
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(Routes.LoginScreen, (route) => false);
      }
    });
  }

  void showLogoutnDialog() {
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
                        "Do you want logout?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(
                        height: 20,
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
                            width: 20,
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              logoutApi();
                              UserSession userSession = appUserSession.value;
                              userSession.apntoken = "";
                              userSession.firebaseToken = "";
                              userSession.token = "";
                              userSession.devicetype = "";
                              FirebaseFirestore.instance
                                  .collection(FirebaseKey.users)
                                  .doc(userSession.id.toString())
                                  .set(userSession.toJson())
                                  .then((value) {});
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

  void showDeleteProfileDialog() {
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
                        "Are you sure you want to delete profile?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(
                        height: 20,
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
                            width: 20,
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
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                              userDeleteAPI();
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

  void logoutApi() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.logout,
      apiAction: ApiAction.logout,
    );
  }

  void userDeleteAPI() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.userDelete,
      apiAction: ApiAction.userDelete,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.logout) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);
        logout();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.userDelete) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);
        deleteUser();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }
}

class MenuItemWidget extends StatefulWidget {
  final Widget item;
  final dynamic menuValue;
  final Color backgroundColor;
  final Color highlightColor;

  final Function(dynamic menuValue) clickCallback;

  MenuItemWidget(
      {this.item,
      this.clickCallback,
      this.backgroundColor,
      this.highlightColor,
      this.menuValue});

  @override
  State<StatefulWidget> createState() {
    return _MenuItemWidgetState();
  }
}

class _MenuItemWidgetState extends State<MenuItemWidget> {
  var highlightColor = Color(0x55000000);
  var color = Color(0xff232323);

  @override
  void initState() {
    color = widget.backgroundColor;
    highlightColor = widget.highlightColor;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        color = highlightColor;
        setState(() {});
      },
      onTapUp: (details) {
        color = widget.backgroundColor;
        setState(() {});
      },
      onLongPressEnd: (details) {
        color = widget.backgroundColor;
        setState(() {});
      },
      onTap: () {
        if (widget.clickCallback != null) {
          widget.clickCallback(widget.menuValue);
        }
      },
      child: widget.item,
    );
  }
}
