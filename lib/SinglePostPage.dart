import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/FeedModel.dart';
import 'package:names/route/routes.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'api/ApiAction.dart';
import 'api/ApiCallBackListener.dart';
import 'api/ApiRequest.dart';
import 'api/HttpMethods.dart';
import 'constants/app_color.dart';
import 'custom_widget/gradient_app_bar.dart';
import 'helper/AppHelper.dart';
import 'helper/ProgressDialog.dart';
import 'main.dart';
import 'model/LikeUnlikeModel.dart';
import 'model/SingleFeedModel.dart';

class SinglePostPage extends StatefulWidget {
  String userId, postId, notificationId = null;
  bool fromNotification = false;
  SinglePostPage(
      {Key key,
      this.notificationId,
      this.userId,
      this.postId,
      this.fromNotification})
      : super(key: key);

  @override
  State<SinglePostPage> createState() => _SinglePostPageState();
}

class _SinglePostPageState extends State<SinglePostPage>
    with ApiCallBackListener {
  bool isLoading = false;
  Future<Feed> futureFeed;
  // Feed feedData;
  @override
  void initState() {
    if (mounted) {
      // _validateIsLogedIn();
      getDiaryDetailsAPI();
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
    super.initState();
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
                              GradientAppBar(
                                  brightness: Brightness.light,
                                  elevation: 0,
                                  centerTitle: false,
                                  automaticallyImplyLeading: false,
                                  title: Row(
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
                                            if (widget.fromNotification !=
                                                    null &&
                                                widget.fromNotification) {
                                              Navigator.of(context).pop(true);
                                            } else {
                                              if (Navigator.canPop(context)) {
                                                Navigator.of(context).pop();
                                              } else {
                                                Navigator
                                                    .pushNamedAndRemoveUntil(
                                                        context,
                                                        Routes.DashboardScreen,
                                                        (route) => false);
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Post",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: "Lato_Bold",
                                              color: Colors.black),
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
                                  ),
                                  gradient: LinearGradient(colors: [
                                    AppColor.skyBlueColor,
                                    AppColor.skyBlueColor
                                  ])),
                            ],
                          ),
                        )
                      : GradientAppBar(
                          brightness: Brightness.light,
                          elevation: 0,
                          centerTitle: false,
                          automaticallyImplyLeading: false,
                          title: Row(
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
                                    if (widget.fromNotification != null &&
                                        widget.fromNotification) {
                                      Navigator.of(context).pop(true);
                                    } else {
                                      if (Navigator.canPop(context)) {
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            Routes.DashboardScreen,
                                            (route) => false);
                                      }
                                    }
                                  },
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "Post",
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontFamily: "Lato_Bold",
                                      color: Colors.black),
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
                          ),
                          gradient: LinearGradient(colors: [
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
                      FutureBuilder<Feed>(
                          future: futureFeed, // async work
                          builder: (BuildContext context,
                              AsyncSnapshot<Feed> snapshot) {
                            if (snapshot.hasData) {
                              return snapshot.data != null
                                  ? snapshot.data.saveAs == 4
                                      ? AppHelper.feedWidget(
                                          context, snapshot.data, signUnsignAPI)
                                      : AppHelper.feedWidget(
                                          context, snapshot.data, likeUnlikeAPI)
                                  : Center(
                                      child: Text(FirebaseKey.noPostAvailable),
                                    );
                            }
                            return ProgressDialog
                                .getCircularProgressIndicator();
                          }),
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

  _validateIsLogedIn() {
    Future.delayed(Duration(seconds: 3), () {
      if (appUserSession.value != null && appUserSession.value.token != null) {
        getDiaryDetailsAPI();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Do everything you want here...
          Navigator.pushNamedAndRemoveUntil(
              context, Routes.LoginScreen, (route) => false);
        });
      }
    });
  }

  getDiaryDetailsAPI() {
    Map<String, String> body = Map();
    body["diary_id"] = widget.postId;
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: Url.getDiaryDetails,
      body: body,
      apiAction: ApiAction.getDiaryDetails,
    );
  }

  void likeUnlikeAPI(Feed feed) {
    // this.feed = feed;
    Map<String, String> body = Map();
    body['post_id'] = feed.id.toString();

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      httpType: HttpMethods.POST,
      url: Url.likeUnlike,
      body: body,
      apiAction: ApiAction.likeUnlike,
      showLoader: true,
    );
  }

  void signUnsignAPI(Feed feed) {
    Map<String, String> body = Map();
    body['post_id'] = feed.id.toString();

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      httpType: HttpMethods.POST,
      url: Url.signUnsign,
      body: body,
      apiAction: ApiAction.signUnsign,
      showLoader: true,
    );
  }

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

  @override
  apiCallBackListener(String action, result) {
    // TODO: implement apiCallBackListener
    if (action == ApiAction.getDiaryDetails) {
      SingleFeedModel connectionModel = SingleFeedModel.fromJson(result);
      if (connectionModel.success) {
        // feedData=connectionModel.data;

        futureFeed = Future.delayed(Duration(seconds: 0), () {
          setState(() {});
          return connectionModel.data;
        });
      } else {
        AppHelper.showToastMessage(connectionModel.message);
      }
    } else if (action == ApiAction.likeUnlike) {
      LikeUnlikeModel likeUnlikeModel = LikeUnlikeModel.fromJson(result);
      if (likeUnlikeModel.success) {
        getDiaryDetailsAPI();
      } else {
        AppHelper.showToastMessage(likeUnlikeModel.message);
      }
    } else if (action == ApiAction.signUnsign) {
      LikeUnlikeModel likeUnlikeModel = LikeUnlikeModel.fromJson(result);
      if (likeUnlikeModel.success) {
        getDiaryDetailsAPI();
      } else {
        AppHelper.showToastMessage(likeUnlikeModel.message);
      }
    } else if (action == ApiAction.readNotification) {}
    // throw UnimplementedError();
  }
}
