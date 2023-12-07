import 'package:flutter/material.dart';
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
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/FeedModel.dart';
import 'package:names/ui/PostAllComments.dart';

import '../../constants/firebaseKey.dart';
import '../AddNewPost.dart';

class PublicFeedScreen extends StatefulWidget {
  const PublicFeedScreen({Key key}) : super(key: key);

  @override
  _PublicFeedScreenState createState() => _PublicFeedScreenState();
}

class _PublicFeedScreenState extends State<PublicFeedScreen>
    with ApiCallBackListener {
  Future<FeedModel> futureFeed;
  FeedModel feedModel;
  ScrollController _scrollController = ScrollController();
  bool isPaging = false;
  TextEditingController searchtextController = TextEditingController();

  Feed feed;

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<FeedModel>(
          future: futureFeed, // async work
          builder: (BuildContext context, AsyncSnapshot<FeedModel> snapshot) {
            if (snapshot.hasData) {
              return snapshot.data.data.feedList.length > 0
                  ? Column(children: [
                      Expanded(
                          child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scroll) {
                                if (scroll is ScrollEndNotification &&
                                    _scrollController
                                            .position.maxScrollExtent ==
                                        _scrollController.position.pixels) {
                                  if (snapshot.data.data.nextPageUrl != null &&
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
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    SizedBox(
                                      height: 50,
                                      child: TextField(
                                        controller: searchtextController,
                                        onSubmitted: (value) {
                                          // searchController.getSearchingAPI();
                                          //searchController.searchController.refresh();
                                          print("Go button is clicked");
                                        },
                                        decoration: InputDecoration(
                                          suffixIcon: IconButton(
                                              icon: const Icon(Icons.search),
                                              onPressed: () {
                                                getSearchData();
                                                // searchtextController.refresh();
                                              }),
                                          hintText: "Search ...",
                                          hintStyle: const TextStyle(color: Colors.grey),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Colors.black,
                                              width: 1,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                              style: BorderStyle.solid,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    ListView.builder(
                                      itemCount: snapshot.data.data.feedList.length,
                                      shrinkWrap: true,
                                      physics: ClampingScrollPhysics(),
                                      controller: _scrollController,
                                      itemBuilder: (ctx, index) {
                                        Feed feed =
                                            snapshot.data.data.feedList[index];
                                        return Container(
                                          margin: EdgeInsets.only(bottom: 20),
                                          width: AppHelper.getDeviceWidth(context),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(20),
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.symmetric(vertical: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10, vertical: 5),
                                                child: Row(
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
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                100),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            feed.userName,
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors.black),
                                                          ),
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
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
                                                                    fontSize: 13,
                                                                    color: AppColor
                                                                        .textGrayColor),
                                                              ),
                                                              SizedBox(
                                                                width: 5,
                                                              ),
                                                              Flexible(
                                                                child: AppHelper
                                                                    .getFeedLocation(
                                                                        context,
                                                                        feed.location),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              feed.medias.isNotEmpty
                                                  ? Container(
                                                      // child: MediaWidgets(medias:feed.medias),
                                                      child: ImageSlider(feed.medias,""),
                                                    )
                                                  : SizedBox(),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              feed.title != null
                                                  ? Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                      ),
                                                      child: Text(
                                                        feed.title,
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: Colors.black,
                                                            fontFamily: "Lato_Bold"),
                                                      ),
                                                    )
                                                  : SizedBox(
                                                      height: 0,
                                                    ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              feed.description != null
                                                  ? Container(
                                                      padding: EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                      ),
                                                      child: AppHelper.getReadMore(
                                                          context,
                                                          feed.title,
                                                          feed.description),
                                                      /*child: ReadMoreText(
                                              feed.description,
                                              trimLines: 3,
                                              colorClickableText: Colors.red,
                                              trimMode: TrimMode.Line,
                                              trimCollapsedText: 'Read more',
                                              trimExpandedText: 'Read less',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColor.textGrayColor),
                                              moreStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColor.lightSkyBlueColor,
                                                  fontFamily: "Lato_Bold"),
                                              lessStyle: TextStyle(
                                                  fontSize: 12,
                                                  color: AppColor.lightSkyBlueColor,
                                                  fontFamily: "Lato_Bold"),
                                            ),*/
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
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                 // mainAxisAlignment: MainAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    GestureDetector(
                                                      child: Container(
                                                        height: 30,
                                                        width: 110,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    100),
                                                            color: Colors.white,
                                                            border: Border.all(
                                                                width: 1,
                                                                color: Colors.red)),
                                                        alignment: Alignment.center,
                                                        child: Row(
                                                          children: [
                                                            Icon(
                                                              Icons.delete_forever,
                                                              size: 18,
                                                              color: Colors.red,
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Text(
                                                              "DELETE",
                                                              textAlign:
                                                                  TextAlign.center,
                                                              style: TextStyle(
                                                                color: Colors.red,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                            ),
                                                          ],
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        selectedIndex = index;
                                                        showDeleteDialog();
                                                      },
                                                    ),

                                                    Row(
                                                      children: [
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

                                                        feed.commentCount != 0
                                                            ?AppHelper.countWidget(
                                                            feed.commentCount):SizedBox(width: 8,),
                                                        GestureDetector(
                                                          onTap: () {
                                                            Navigator.of(context).push(
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        PostAllComments(
                                                                          diaryId: feed.id
                                                                              .toString(),
                                                                        )));
                                                          },
                                                          child: Icon(
                                                            Icons.comment,
                                                            size: 20,
                                                            color: AppColor.textGrayColor,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ))),
                      if (isPaging && feedModel.data.nextPageUrl != null)
                        Container(
                          height: 50,
                          child: ProgressDialog.getCircularProgressIndicator(),
                        ),
                    ])
                  : Center(
                      child: AppHelper.getNoRecordWidget(
                          context,
                          null,
                          FirebaseKey.noPostAvailable,
                          MainAxisAlignment.center),
                    );
            }
            return ProgressDialog.getCircularProgressIndicator();
          }),
      floatingActionButton: Container(
        margin: EdgeInsets.only(bottom: 100),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.white,
                blurRadius: 3.0,
              ),
            ],
            color: AppColor.blueColor,
            border: Border.all(width: 3, color: Colors.white)),
        child: IconButton(
          icon: Image.asset(
            "assets/icons/add.png",
            height: 24,
            width: 24,
          ),
          onPressed: () {
            Navigator.of(context)
                .push(PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  AddNewPost(),
              transitionDuration: Duration(seconds: 0),
            ))
                .then((value) {
              if (value != null) {
                if (mounted) {
                  getFeedAPI();
                }
              }
            });
          },
        ),
      ),
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
    Map<String, String> body = Map();
    body['type'] = "3"; //1 = public
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.diaryList,
        apiAction: ApiAction.diaryList,
        body: body);
  }

  getFeedNextAPI(String url) {
    Map<String, String> body = Map();
    body['type'] = "3"; //1 = public
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: url,
        apiAction: ApiAction.pagination,
        body: body);
  }

  getSearchData() {
    final search = searchtextController.value.text.trim();
    if (search.isEmpty) {
      AppHelper.showToastMessage(
          "Please enter keyword to search");
    }else{
      Map<String, String> body = Map();
      body['save_as'] = "3"; //1 = private
      body['keyword'] = search; //1 = private
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: false,
          httpType: HttpMethods.POST,
          url: Url.searchDiary,
          apiAction: ApiAction.searchDiary,
          body: body);
    }
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

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.diaryList) {
      feedModel = FeedModel.fromJson(result);
      if (feedModel.success) {
        futureFeed = Future.delayed(Duration(seconds: 0), () {
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
    } else if (action == ApiAction.deleteDiary) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        setState(() {
          feedModel.data.feedList.removeAt(selectedIndex);
        });
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }else if (action == ApiAction.searchDiary) {
      feedModel = FeedModel.fromJson(result);
      if (feedModel.success) {
        futureFeed = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return feedModel;
        });
        searchtextController.clear();
      } else {
        AppHelper.showToastMessage(feedModel.message);
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

  void showDeleteDialog() {
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
                        "Are you sure to delete\nthe post?",
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
                              deleteAPI();
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

  void deleteAPI() {
    Map<String, String> body = Map();
    body["diary_id"] = feedModel.data.feedList[selectedIndex].id.toString();

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.deleteDiary,
      apiAction: ApiAction.deleteDiary,
      body: body,
    );
  }
}
