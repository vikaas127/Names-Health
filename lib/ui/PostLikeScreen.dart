import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
import 'package:names/main.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/FeedModel.dart';
import 'package:names/model/LikedUserModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

import 'UserProfileScreen.dart';

class PostLikeScreen extends StatefulWidget {
  Feed feed;
  PostLikeScreen({@required this.feed});

  @override
  _PostLikeScreenState createState() => _PostLikeScreenState();
}

class _PostLikeScreenState extends State<PostLikeScreen>
    with ApiCallBackListener {
  Future<LikedUserModel> futureData;
  ScrollController _scrollController = ScrollController();
  bool isPaging = false;

  LikedUserModel likedUserModel;

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
            _getTitle(),
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
                child: FutureBuilder<LikedUserModel>(
                    future: futureData, // async work
                    builder: (BuildContext context,
                        AsyncSnapshot<LikedUserModel> snapshot) {
                      if (snapshot.hasData) {
                        return likedUserModel.data.list.length > 0
                            ? Column(children: [
                                Expanded(
                                    child: NotificationListener<
                                            ScrollNotification>(
                                        onNotification:
                                            (ScrollNotification scroll) {
                                          if (scroll is ScrollEndNotification &&
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
                                              getLikedUserNextAPI(snapshot
                                                  .data.data.nextPageUrl);
                                            }
                                          }
                                          return false;
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          child: ListView.separated(
                                            controller: _scrollController,
                                            physics: ClampingScrollPhysics(),
                                            itemBuilder: (ctx, index) {
                                              Data data = likedUserModel
                                                  .data.list[index];
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
                                                              .center,
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
                                                                  data.profilePicture,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  circle: true,
                                                                  height: 50,
                                                                  width: 50,
                                                                  forProfileImage:
                                                                      true,
                                                                ),
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
                                                              height: 60,
                                                              margin: EdgeInsets
                                                                  .all(5),
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                        text: data
                                                                            .name,
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                "Lato_Bold")),
                                                                  ],
                                                                ),
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              )),
                                                        ),
                                                        appUserSession
                                                                    .value.id !=
                                                                data.id
                                                            ? GestureDetector(
                                                                child:
                                                                    Container(
                                                                  height: 30,
                                                                  width: 100,
                                                                  decoration: BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              100),
                                                                      color: data
                                                                              .conneted
                                                                          ? AppColor
                                                                              .lightSkyBlueColor
                                                                              .withOpacity(0.5)
                                                                          : AppColor.lightSkyBlueColor),
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  child: Text(
                                                                    data.conneted
                                                                        ? "CONNECTED"
                                                                        : data.already_requested
                                                                            ? "REQUESTED"
                                                                            : "CONNECT",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: data.conneted
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  if (!data
                                                                          .conneted &&
                                                                      !data
                                                                          .already_requested) {
                                                                    selectedIndex =
                                                                        index;
                                                                    sendRequestAPI(data
                                                                        .id
                                                                        .toString());
                                                                  }
                                                                },
                                                              )
                                                            : SizedBox(),
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
                                                        UserProfileScreen(
                                                      usersModel: UsersModel(
                                                        id: data.id,
                                                        name: data.name,
                                                        profilePicture:
                                                            data.profilePicture,
                                                      ),
                                                    ),
                                                    transitionDuration:
                                                        Duration(seconds: 0),
                                                  ));
                                                },
                                              );
                                            },
                                            itemCount:
                                                likedUserModel.data.list.length,
                                            shrinkWrap: true,
                                            separatorBuilder:
                                                (BuildContext context,
                                                    int index) {
                                              return SizedBox(
                                                height: 10,
                                              );
                                            },
                                          ),
                                        ))),
                                if (isPaging &&
                                    likedUserModel.data.nextPageUrl != null)
                                  Container(
                                    height: 50,
                                    child: ProgressDialog
                                        .getCircularProgressIndicator(),
                                  ),
                              ])
                            : Center(
                                child: Text("No likes yet"),
                              );
                      }
                      return ProgressDialog.getCircularProgressIndicator();
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
        }));
  }

  @override
  void initState() {
    futureData = getLikedUserAPI();
    super.initState();
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.likeUserList) {
      likedUserModel = LikedUserModel.fromJson(result);
      if (likedUserModel.success) {
        futureData = Future.delayed(Duration(seconds: 0), () {
          return likedUserModel;
        });
        if (mounted) {
          setState(() {});
        }
      } else {
        AppHelper.showToastMessage(likedUserModel.message);
      }
    } else if (action == ApiAction.pagination) {
      LikedUserModel pagination = LikedUserModel.fromJson(result);
      if (pagination.success) {
        if (likedUserModel != null) {
          likedUserModel.data.nextPageUrl = pagination.data.nextPageUrl;

          for (var element in pagination.data.list) {
            if (!likedUserModel.data.list.contains(element)) {
              likedUserModel.data.list.add(element);
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
    } else if (action == ApiAction.sendConnectionRequuest) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);
        likedUserModel.data.list[selectedIndex].already_requested = true;
        futureData = Future.delayed(Duration(seconds: 0), () {
          return likedUserModel;
        });
        if (mounted) {
          setState(() {});
        }
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

  Future<void> getLikedUserAPI() {
    Map<String, String> body = Map();
    body['post_id'] = widget.feed.id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        showLoader: false,
        url: Url.likeUserList,
        apiAction: ApiAction.likeUserList,
        body: body);
  }

  getLikedUserNextAPI(String url) {
    Map<String, String> body = Map();
    body['post_id'] = widget.feed.id.toString();

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        showLoader: false,
        url: url,
        apiAction: ApiAction.pagination,
        body: body);
  }

  void sendRequestAPI(String user_id) {
    Map<String, String> body = Map();
    body["user_id"] = user_id;

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        httpType: HttpMethods.POST,
        url: Url.sendConnectionRequuest,
        apiAction: ApiAction.sendConnectionRequuest,
        body: body);
  }

  String _getTitle() {
    if (widget.feed.likedCount == 0) {
      return "Like ";
    } else if (widget.feed.likedCount == 1) {
      return "Like (" + widget.feed.likedCount.toString() + ")";
    }
    return "Likes (" + widget.feed.likedCount.toString() + ")";
  }
}
