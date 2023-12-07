import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/NotificatiionModel.dart';
import 'package:names/model/ReadNotification.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:names/ui/MeetingScheduling/MyScheduleScreen.dart';
import 'package:provider/provider.dart';

import '../SinglePostPage.dart';
import '../constants/firebaseKey.dart';
import '../main.dart';
import '../model/UsersModel.dart';
import 'UserProfileScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with ApiCallBackListener {
  Future<NotificationModel> futureNotification;
  NotificationModel notificationModel;
  ScrollController _scrollController = ScrollController();
  bool isPaging = false;

  int selectedIndex = 0;
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
            "Notification",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
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
                  padding: EdgeInsets.all(20),
                  child: FutureBuilder<NotificationModel>(
                      future: futureNotification, // async work
                      builder: (BuildContext context,
                          AsyncSnapshot<NotificationModel> snapshot) {
                        if (snapshot.hasData && notificationModel != null) {
                          return notificationModel
                                  .data.notificationList.isNotEmpty
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                                  if (snapshot.data.data
                                                              .nextPageUrl !=
                                                          null &&
                                                      !isPaging) {
                                                    setState(() {
                                                      isPaging = true;
                                                    });
                                                    getNotificationNextAPI(
                                                        snapshot.data.data
                                                            .nextPageUrl);
                                                  }
                                                }
                                                return false;
                                              },
                                              child:
                                                  _ListViewBuilder(context))),
                                      if (isPaging &&
                                          notificationModel.data.nextPageUrl !=
                                              null)
                                        Container(
                                          height: 50,
                                          child: ProgressDialog
                                              .getCircularProgressIndicator(),
                                        ),
                                    ])
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                          margin: EdgeInsets.only(
                                              top: 10, bottom: 30),
                                          child: Text("No notifications yet")),
                                    ],
                                  ),
                                );
                        }
                        return ProgressDialog.getCircularProgressIndicator();
                      }),
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

  @override
  void initState() {
    futureNotification = getNotification();
    super.initState();
  }

  Future<NotificationModel> getNotification() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: Url.getNotifications,
      apiAction: ApiAction.getNotifications,
    );
  }

  void getNotificationNextAPI(String url) {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: url,
      apiAction: ApiAction.pagination,
    );
  }

  Future<NotificationModel> readNotification(int index) {
    selectedIndex = index;
    Map<String, String> body = Map();
    body['notification_id'] =
        notificationModel.data.notificationList[selectedIndex].id.toString();
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.readNotification,
        apiAction: ApiAction.readNotification,
        body: body);
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.getNotifications) {
      notificationModel = NotificationModel.fromJson(result);
      if (notificationModel.success) {
        futureNotification = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return notificationModel;
        });
      } else {
        AppHelper.showToastMessage(notificationModel.message);
      }
    } else if (action == ApiAction.pagination) {
      NotificationModel pagination = NotificationModel.fromJson(result);
      if (pagination.success) {
        if (notificationModel != null) {
          notificationModel.data.nextPageUrl = pagination.data.nextPageUrl;

          for (var element in pagination.data.notificationList) {
            if (!notificationModel.data.notificationList.contains(element)) {
              notificationModel.data.notificationList.add(element);
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
    if (action == ApiAction.readNotification) {
      ReadNotification readNotification = ReadNotification.fromJson(result);
      if (readNotification.success) {
        setState(() {
          notificationModel.data.notificationList[selectedIndex].readStatus =
              readNotification.notificationData.readStatus;
        });
      } else {
        AppHelper.showToastMessage(readNotification.message);
      }
    }
  }

  _ListViewBuilder(BuildContext context) {
    int count = 0;
    for (int i = 0; i < notificationModel.data.notificationList.length; i++) {
      if (notificationModel.data.notificationList[i].readStatus == 0) {
        count++;
      }
    }
    AppHelper.notificationCounterHelper(count);
    return ListView.separated(
      controller: _scrollController,
      physics: ClampingScrollPhysics(),
      itemBuilder: (ctx, index) {
        Data data = notificationModel.data.notificationList[index];
        print(data.title);
        print(data.title == 'Scheduling invitation');
        return Container(
          width: AppHelper.getDeviceWidth(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color:
                data.readStatus == 0 ? AppColor.skyBlueBoxColor : Colors.white,
          ),
          padding: EdgeInsets.all(5),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  width: 50,
                  margin: EdgeInsets.all(5),
                  child: ClipRRect(
                    child: Stack(
                      children: [
                        CustomWidget.imageView(
                          data.profilePicture,
                          fit: BoxFit.cover,
                          height: 50,
                          width: 50,
                          forProfileImage: true,
                          backgroundColor: AppColor.profileBackColor,
                        ),
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
                      height: 72,
                      margin: EdgeInsets.only(right: 5),
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                                text: data.userName ?? " " + " ",
                                style: TextStyle(fontSize: 14)),
                            TextSpan(
                                text: " " +
                                    (data.title == 'Scheduling request'
                                        ? " sent you a scheduling request"
                                        : data.title == 'Scheduling accepted'
                                            ? " accepted your scheduling request"
                                            : data.title ==
                                                    'Scheduling declined'
                                                ? " declined your scheduling request"
                                                : data.title ==
                                                        'Scheduling request off'
                                                    ? " request off the scheduling request"
                                                    : data.title),
                                style: TextStyle(
                                    fontSize: 14, fontFamily: "Lato_Bold")),
                          ],
                        ),
                      )),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Text(
                    AppHelper.timeAgoSince(data.createdAt),
                    style: TextStyle(
                      color: AppColor.textGrayColor,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
              ],
            ),
            onTap: () {
              if (data.clickable == 1 && data.notification_type != null) {
                if (data.notification_type == 'schedule') {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ChangeNotifierProvider<ScheduleCalendarProvider>(
                                  create: (context) =>
                                      ScheduleCalendarProvider(),
                                  child: MyScheduleScreen())));
                } else if (data.notification_type == FirebaseKey.post) {
                  Navigator.of(context)
                      .push(PageRouteBuilder(
                        pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) =>
                            SinglePostPage(
                                notificationId: data.id.toString(),
                                userId: data.notification_to.toString(),
                                postId: data.event_id.toString(),
                                fromNotification: data.readStatus == 0),
                        transitionDuration: Duration(seconds: 0),
                      ))
                      .then((value) => {
                            if (value != null && value) {getNotification()}
                          });
                } else if (data.notification_type == FirebaseKey.connection) {
                  Navigator.of(context)
                      .push(PageRouteBuilder(
                        pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) =>
                            UserProfileScreen(
                          notificationId: data.id.toString(),
                          fromNotification: data.readStatus == 0,
                          usersModel: UsersModel(
                            id: data.notification_from,
                            name: data.user_name,
                            profilePicture: data.profilePicture,
                          ),
                        ),
                        transitionDuration: Duration(seconds: 0),
                      ))
                      .then((value) => {
                            if (value != null && value) {getNotification()}
                          });
                }
              } else if (data.readStatus == 0) {
                readNotification(index);
              }
            },
          ),
        );
      },
      itemCount: notificationModel.data.notificationList.length,
      shrinkWrap: true,
      separatorBuilder: (BuildContext context, int index) {
        return SizedBox(
          height: 10,
        );
      },
    );
  }
}
