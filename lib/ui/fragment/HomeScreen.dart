import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/custom_widget/image_slider.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/model/FeedModel.dart';
import 'package:names/model/LikeUnlikeModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/route/routes.dart';
import 'package:names/ui/PostAllComments.dart';
import 'package:names/ui/PostLikeScreen.dart';
import 'package:names/ui/RepostAbuseScreen.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../constants/firebaseKey.dart';
import '../../main.dart';
import '../../model/ApiResponseModel.dart';
import '../UserProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with ApiCallBackListener {
  ScrollController _scrollController = ScrollController();
  bool isPaging = false;
  FeedModel feedModel;
  Future<FeedModel> future;
  Feed feed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: FutureBuilder<FeedModel>(
          future: future, // async work
          builder: (BuildContext context, AsyncSnapshot<FeedModel> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  appProfileModel.value != null &&
                          appProfileModel.value.data != null &&
                          appProfileModel.value.data.percentage != 100
                      ? Container(
                          width: AppHelper.getDeviceWidth(context),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: AppColor.darkBlueColor),
                          padding: EdgeInsets.all(20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Align(
                                child: CircularPercentIndicator(
                                  radius: 40.0,
                                  lineWidth: 3.0,
                                  percent: AppHelper.getPercentage(
                                      appProfileModel.value.data.percentage),
                                  backgroundColor: AppColor.textGrayColor,
                                  center: Container(
                                    height: 85,
                                    width: 85,
                                    padding: EdgeInsets.all(3),
                                    child: CustomWidget.imageView(
                                      appProfileModel.value.data.profilePicture,
                                      circle: true,
                                      height: 85,
                                      width: 85,
                                      fit: BoxFit.cover,
                                      forProfileImage: true,
                                    ),
                                  ),
                                  progressColor: AppColor.lightSkyBlueColor,
                                ),
                                alignment: Alignment.center,
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Profile is " +
                                          appProfileModel.value.data.percentage
                                              .toString() +
                                          "% Complete",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: "Lato_Bold",
                                          color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Complete your profile",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    GestureDetector(
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(100)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 10),
                                        child: Text(
                                          "UPDATE NOW",
                                          style: TextStyle(
                                              color: AppColor.darkBlueColor,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.of(context)
                                            .pushNamed(Routes.UpdateProfile);
                                      },
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              AppHelper.ShildWidget(
                                  appProfileModel.value.data.licenseExpiryDate,
                                  24,
                                  24)
                            ],
                          ),
                        )
                      : SizedBox(),
                  feedModel.data.feedList.length > 0
                      ? Expanded(
                          child: Column(children: [
                            Expanded(
                                child: NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification scroll) {
                                      if (scroll is ScrollEndNotification &&
                                          _scrollController
                                                  .position.maxScrollExtent ==
                                              _scrollController
                                                  .position.pixels) {
                                        if (snapshot.data.data.nextPageUrl !=
                                                null &&
                                            !isPaging) {
                                          setState(() {
                                            isPaging = true;
                                          });
                                          getFeedNextAPI(
                                              snapshot.data.data.nextPageUrl);
                                        }
                                      }
                                      return false;
                                    },
                                    child: ListView.builder(
                                      itemCount: feedModel.data.feedList.length,
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      controller: _scrollController,
                                      itemBuilder: (ctx, index) {
                                        Feed feed = feedModel.data.feedList[index];
                                        if (feed.type == "feed") {
                                          return Container(
                                            margin: EdgeInsets.only(bottom: 20),
                                            width: AppHelper.getDeviceWidth(
                                                context),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color: Colors.white,
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5),
                                                    child: Row(
                                                      crossAxisAlignment:CrossAxisAlignment .start,
                                                      children: [
                                                        Container(
                                                          height: 40,
                                                          width: 40,
                                                          margin: EdgeInsets.all(5),
                                                          child: ClipRRect(
                                                            child: CustomWidget.imageView(
                                                              feed.userProfilePicture,
                                                              fit: BoxFit.cover,
                                                              forProfileImage: true,
                                                            ),
                                                            borderRadius: BorderRadius.circular(100),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment .start,
                                                            mainAxisAlignment:MainAxisAlignment  .center,
                                                            children: [
                                                              Text(
                                                                feed.userName,
                                                                maxLines: 2,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16,
                                                                    color: Colors
                                                                        .black),
                                                              ),
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Icon(
                                                                    Icons
                                                                        .access_time_rounded,
                                                                    size: 16,
                                                                    color: AppColor
                                                                        .textGrayColor,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 3,
                                                                  ),
                                                                  Text(
                                                                    AppHelper.timeZoneDateConverter(
                                                                            feed.createdAt)
                                                                        .toString(),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            13,
                                                                        color: AppColor
                                                                            .textGrayColor),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  Expanded(
                                                                    child: AppHelper.getFeedLocation(
                                                                        context,
                                                                        feed.location),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        IconButton(
                                                          key: GlobalObjectKey(
                                                              feed),
                                                          icon: Container(
                                                            child: Image.asset(
                                                              "assets/icons/menu.png",
                                                              height: 16,
                                                              width: 16,
                                                              // color: Colors.white,
                                                            ),
                                                          ),
                                                          onPressed: () {
                                                            RenderBox
                                                                renderBox =
                                                                GlobalObjectKey(
                                                                        feed)
                                                                    .currentContext
                                                                    .findRenderObject();
                                                            Offset offset = renderBox
                                                                .localToGlobal(
                                                                    Offset
                                                                        .zero);

                                                            OverlayEntry
                                                                overlayEntry;
                                                            overlayEntry =
                                                                OverlayEntry(
                                                                    builder:
                                                                        (context) {
                                                              return GestureDetector(
                                                                behavior:
                                                                    HitTestBehavior
                                                                        .translucent,
                                                                onTap: () {
                                                                  overlayEntry
                                                                      .remove();
                                                                },
                                                                child:
                                                                    Container(
                                                                  color: Colors
                                                                      .transparent,
                                                                  child: Stack(
                                                                    children: [
                                                                      Positioned(
                                                                          right:
                                                                              5,
                                                                          // left: offset.dx - 10,
                                                                          top: offset.dy +
                                                                              10,
                                                                          child:
                                                                              SizedBox(
                                                                            height:
                                                                                120,
                                                                            width:
                                                                                220,
                                                                            child:
                                                                                SimpleDialog(
                                                                              shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(15),
                                                                              ),
                                                                              contentPadding: EdgeInsets.all(30),
                                                                              children: [
                                                                                GestureDetector(
                                                                                  onTap: () {
                                                                                    overlayEntry.remove();
                                                                                    Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) => ReportAbuseScreen(
                                                                                                  postId: feed.id.toString(),
                                                                                                )));
                                                                                  },
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      'Report Post',
                                                                                      style: TextStyle(fontWeight: FontWeight.w800),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                            Overlay.of(context)
                                                                .insert(
                                                                    overlayEntry);
                                                          },
                                                        ),
                                                      ],
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
                                                          id: feed.userId,
                                                          name: feed.userName,
                                                          profilePicture: feed.userProfilePicture,
                                                          profession: feed.userProfession,
                                                          specialist: feed.userSpecialist,
                                                        ),
                                                      ),
                                                      transitionDuration:
                                                          Duration(seconds: 0),
                                                    ));
                                                  },
                                                ),
                                                feed.medias.isNotEmpty
                                                    ? Container(
                                                        // child: MediaWidgets(medias:feed.medias),
                                                        child: ImageSlider(
                                                            feed.medias,feed.id.toString()),
                                                      )
                                                    : SizedBox(),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                feed.title != null
                                                    ? Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 10,
                                                        ),
                                                        child: Text(
                                                          feed.title,
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              color:
                                                                  Colors.black,
                                                              fontFamily:
                                                                  "Lato_Bold"),
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0,
                                                      ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                feed.description != null
                                                    ?
                                                Container(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          horizontal: 10,
                                                        ),
                                                        child: AppHelper.getReadMore(
                                                                context,
                                                                feed.title,
                                                                feed.description
                                                        ),
                                                      )
                                                    : SizedBox(
                                                        height: 0,
                                                      ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      AppHelper.HartWidget(
                                                          feed, likeUnlikeAPI),
                                                      SizedBox(
                                                        width: 5,
                                                      ),

                                                      InkWell(
                                                        onTap: () {
                                                          Navigator.of(context)
                                                              .push(
                                                                  PageRouteBuilder(
                                                            pageBuilder: (BuildContext context,
                                                                    Animation<
                                                                            double>
                                                                        animation,
                                                                    Animation<
                                                                            double>
                                                                        secondaryAnimation) =>
                                                                PostLikeScreen(
                                                              feed: feed,
                                                            ),
                                                            transitionDuration:
                                                                Duration(
                                                                    seconds: 0),
                                                          ));
                                                        },
                                                        child: AppHelper.countWidget(feed.likedCount),
                                                      ),
                                                      if(feed.medias.isNotEmpty)...{
                                                        if(feed.medias.first.mediaType == 2)...{
                                                          if(feed.views.toString() != "0")...{
                                                            SizedBox(width: 5,),
                                                            Icon(
                                                              Icons.remove_red_eye_outlined,
                                                              size: 22,
                                                              color: AppColor
                                                                  .textGrayColor,
                                                            ),
                                                            AppHelper.countWidget(feed.views.toString())
                                                          }
                                                        }
                                                      },

                                                      Spacer(),
                                                      // for repost the post
                                                      GestureDetector(
                                                        onTap: () {
                                                          if(feed.medias.isNotEmpty){
                                                            repostThePostApi(
                                                                feed.id.toString(),
                                                            );
                                                          }
                                                        },
                                                        child: Image.asset("assets/icons/repostIcon.png",
                                                        scale: 12.0,)
                                                        // Icon(
                                                        //   Icons.re,
                                                        //   size: 22,
                                                        //   color: AppColor.textGrayColor,
                                                        // ),
                                                      ),
                                                      SizedBox(width: 9,),

                                                      // for save the video
                                                      if(feed.medias.isNotEmpty)...{
                                                        if(feed.medias.first.mediaType == 2)...{
                                                          GestureDetector(
                                                            onTap: () {
                                                              if(feed.medias.isNotEmpty){
                                                                saveVideoApi(
                                                                    feed.id.toString(),
                                                                    feed.medias.first.id.toString()
                                                                );
                                                              }
                                                            },
                                                            child: Icon(
                                                              Icons.save,
                                                              size: 22,
                                                              color: AppColor
                                                                  .textGrayColor,
                                                            ),
                                                          ),
                                                        }
                                                      },


                                                      SizedBox(width: 10,),
                                                      // to show the comment
                                                      if (feed.commentCount !=
                                                          0)
                                                        AppHelper.countWidget(
                                                            feed.commentCount),
                                                      GestureDetector(
                                                        onTap: () {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          PostAllComments(
                                                                            diaryId:
                                                                                feed.id.toString(),
                                                                          )));
                                                        },
                                                        child: Icon(
                                                          Icons.comment,
                                                          size: 20,
                                                          color: AppColor
                                                              .textGrayColor,
                                                        ),
                                                      ),


                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      AppHelper.shareWidget(
                                                          feed),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 5,
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return Visibility(
                                              visible: feed.image != null,
                                              child: Container(
                                                height:
                                                    AppHelper.getDeviceWidth(
                                                            context) /
                                                        3,
                                                margin:
                                                    EdgeInsets.only(bottom: 20),
                                                child: CustomWidget.imageView(
                                                  feed.image,
                                                  fit: BoxFit.cover,
                                                  height: double.maxFinite,
                                                  width: double.maxFinite,
                                                ),
                                              ));
                                        }
                                      },
                                    )
                                )),
                            if (isPaging && feedModel.data.nextPageUrl != null)
                              Container(
                                height: 50,
                                child: ProgressDialog
                                    .getCircularProgressIndicator(),
                              ),
                          ]),
                        )
                      : Expanded(
                          child: Container(
                            child: AppHelper.getNoRecordWidget(
                                context,
                                null,
                                FirebaseKey.noPostAvailable,
                                MainAxisAlignment.end),
                            height: AppHelper.getDeviceWidth(context) / 2,
                            width: AppHelper.getDeviceWidth(context),
                          ),
                        ),
                ],
              );
            }
            return ProgressDialog.getCircularProgressIndicator();
          }),
    );
  }

  @override
  void initState() {
    if (mounted) {
      getFeedAPI();
    }

    super.initState();
  }

  getFeedAPI() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: Url.dashboardFeeds,
      apiAction: ApiAction.dashboardFeeds,
    );
  }

  getFeedNextAPI(String url) {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: url,
      apiAction: ApiAction.pagination,
    );
  }

  saveVideoApi(String diaryId, String videoId) {
    Map<String, String> body = Map();
    body['diary_id'] = diaryId.toString();
    body['video_id'] = videoId.toString();
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: Url.saveVideo,
      body: body,
      apiAction: ApiAction.saveVideo,
    );
  }

  repostThePostApi(String diaryId) {
    Map<String, String> body = Map();
    body['post_id'] = diaryId.toString();
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.recreateDiary,
      body: body,
      apiAction: ApiAction.recreateDiary,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.dashboardFeeds) {
      feedModel = FeedModel.fromJson(result);
      if (feedModel.success) {
        future = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return feedModel;
        });
      } else {
        AppHelper.showToastMessage(feedModel.message);
      }
    } else if (action == ApiAction.pagination) {
      FeedModel pagination = FeedModel.fromJson(result);
      if (pagination.success) {
        if (feedModel != null) {
          feedModel.data.nextPageUrl = pagination.data.nextPageUrl;

          for (var element in pagination.data.feedList) {
            if (!feedModel.data.feedList.contains(element)) {
              feedModel.data.feedList.add(element);
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
    } else if (action == ApiAction.likeUnlike) {
      LikeUnlikeModel likeUnlikeModel = LikeUnlikeModel.fromJson(result);
      if (likeUnlikeModel.success) {
        feed.likedCount = likeUnlikeModel.data;
        feed.liked = !feed.liked;
        setState(() {});
        // AppHelper.showToastMessage(likeUnlikeModel.message);
      } else {
        AppHelper.showToastMessage(likeUnlikeModel.message);
      }
    }else if (action == ApiAction.saveVideo) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
         AppHelper.showToastMessage("Video save successfully");
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }else if (action == ApiAction.recreateDiary) {
      feedModel = FeedModel.fromJson(result);
     // ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (feedModel.success) {
        getFeedAPI();
        //AppHelper.showToastMessage("Video save successfully");
      } else {
        AppHelper.showToastMessage(feedModel.message);
      }
    }
  }

  void likeUnlikeAPI(Feed feed) {
    this.feed = feed;
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
}
