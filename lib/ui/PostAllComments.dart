import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:link_text/link_text.dart';
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
import 'package:names/model/PostCommentModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:url_launcher/url_launcher.dart';

class PostAllComments extends StatefulWidget {
  final String diaryId;
  const PostAllComments({Key key, this.diaryId}) : super(key: key);

  @override
  State<PostAllComments> createState() => _PostAllCommentsState();
}

class _PostAllCommentsState extends State<PostAllComments>
    with ApiCallBackListener {
  Future<PostCommentModel> future;
  TextEditingController messageController = TextEditingController();
  PostCommentModel postCommentModel;
  bool showEmoji = false;
  ScrollController _scrollController = ScrollController();
  bool isPaging = false;
  _appBarWidget(context) {
    return Row(
      children: [
        Container(
          child: IconButton(
            icon: Image.asset("assets/icons/back_arrow.png",
                height: 20, width: 20, color: Colors.black),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: Text(
            "Comments",
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
                body: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(children: [
                      Expanded(
                        child: Column(children: [
                          Expanded(
                            child: FutureBuilder<PostCommentModel>(
                                future: future,
                                builder: ((context, snapshot) {
                                  if (snapshot.hasData) {
                                    return postCommentModel.data.list.isNotEmpty
                                        ? Column(children: [
                                            Expanded(
                                                child: NotificationListener<
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
                                                        if (snapshot.data.data
                                                                    .nextPageUrl !=
                                                                null &&
                                                            !isPaging) {
                                                          setState(() {
                                                            isPaging = true;
                                                          });
                                                          getAllPostCommentsNext(
                                                              snapshot.data.data
                                                                  .nextPageUrl);
                                                        }
                                                      }
                                                      return false;
                                                    },
                                                    child: ListView.builder(
                                                        controller: _scrollController,
                                                        itemCount: postCommentModel.data .list.length,
                                                        itemBuilder: (context, i) {
                                                          PostCommentData data = postCommentModel.data.list[i];
                                                          return Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  height: 40,
                                                                  width: 40,
                                                                  margin:
                                                                      EdgeInsets
                                                                          .all(
                                                                              5),
                                                                  child:
                                                                      ClipRRect(
                                                                    child: CustomWidget
                                                                        .imageView(
                                                                      data.profilePicture,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      forProfileImage:
                                                                          true,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            100),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            10),
                                                                    decoration: BoxDecoration(
                                                                        color: Colors
                                                                            .white,
                                                                        borderRadius:
                                                                            BorderRadius.circular(10)),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(5),
                                                                    child: ListTile(
                                                                        title: Text(data.name,
                                                                        style: TextStyle(fontWeight: FontWeight.w700),),
                                                                        subtitle: Row(
                                                                            children: [

                                                                          // Expanded(
                                                                          //   child:
                                                                          //       Text(data.comment,
                                                                          //       style: TextStyle(color: Colors.black),),
                                                                          // ),
                                                                              SizedBox(
                                                                                width: MediaQuery.of(context).size.width * 0.59,
                                                                                child: LinkText(
                                                                                  data.comment,
                                                                                  textAlign: TextAlign.start,
                                                                                  textStyle: TextStyle(fontSize: 14,color: Colors.black),
                                                                                  linkStyle: TextStyle(
                                                                                      fontSize: 14,
                                                                                      color: Colors.blue,
                                                                                      letterSpacing: 0,
                                                                                  ),
                                                                                  onLinkTap: (link) async {
                                                                                    final Uri _url = Uri.parse(link);
                                                                                    await launchUrl(_url, mode: LaunchMode.externalApplication);
                                                                                  },
                                                                                ),
                                                                              ),
                                                                          if (appUserSession.value.id ==
                                                                              data.userId)
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                deleteCommentAPI(data.id.toString());
                                                                              },
                                                                              child: Icon(
                                                                                Icons.delete,
                                                                                color: AppColor.textGrayColor,
                                                                              ),
                                                                            )
                                                                        ])),
                                                                  ),
                                                                )
                                                              ]);
                                                        }))),
                                            if (isPaging &&
                                                postCommentModel
                                                        .data.nextPageUrl !=
                                                    null)
                                              Container(
                                                height: 50,
                                                child: ProgressDialog
                                                    .getCircularProgressIndicator(),
                                              ),
                                          ])
                                        : Center(child: Text("No comments."));
                                  } else {
                                    return Container();
                                  }
                                })),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                    width: 1, color: AppColor.textGrayColor)),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    showEmoji
                                        ? Icons.keyboard
                                        : Icons.emoji_emotions,
                                    color: AppColor.textGrayColor,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      showEmoji = !showEmoji;
                                      if (showEmoji) {
                                        FocusScope.of(context)
                                            .requestFocus(new FocusNode());
                                      }
                                    });
                                  },
                                ),
                                Expanded(
                                    child: TextFormField(
                                        style: TextStyle(
                                            color: Colors.black),
                                        textInputAction:
                                            TextInputAction.newline,
                                        keyboardType: TextInputType.multiline,
                                        maxLines: 3,
                                        minLines: 1,
                                        controller: messageController,
                                        decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "comment here...",
                                          labelStyle: TextStyle(
                                              color: AppColor.textGrayColor,
                                              fontSize: 14),
                                          hintStyle: TextStyle(
                                              color: AppColor.textGrayColor,
                                              fontSize: 14),
                                        ))),
                                IconButton(
                                  icon: Icon(
                                    Icons.send,
                                    color: AppColor.lightSkyBlueColor,
                                  ),
                                  onPressed: () {
                                    if (messageController.text
                                        .trim()
                                        .isNotEmpty) {
                                      addCommentAPI();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ]),
                      ),
                      Offstage(
                        offstage: !showEmoji,
                        child: Container(
                          height: AppHelper.getDeviceWidth(context) / 2,
                          child: EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              messageController
                                ..text += emoji.emoji
                                ..selection = TextSelection.fromPosition(
                                    TextPosition(
                                        offset: messageController.text.length));
                            },
                            onBackspacePressed: () {
                              messageController
                                ..text = messageController.text.characters
                                    .skipLast(1)
                                    .toString()
                                ..selection = TextSelection.fromPosition(
                                    TextPosition(
                                        offset: messageController.text.length));
                            },
                            config: Config(
                                columns: 7,
                                emojiSizeMax: 25.0,
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                initCategory: Category.RECENT,
                                bgColor: AppColor.skyBlueColor,
                                indicatorColor: Colors.blue,
                                iconColor: Colors.grey,
                                iconColorSelected: Colors.blue,
                                // progressIndicatorColor: Colors.blue,
                                showRecentsTab: true,
                                recentsLimit: 28,
                                // noRecentsText: "No Recent",
                                // noRecentsStyle: const TextStyle(
                                //     fontSize: 20, color: Colors.black26),
                                categoryIcons: const CategoryIcons(),
                                buttonMode: ButtonMode.MATERIAL),
                          ),
                        ),
                      )
                    ])));
          }
          return Container(
            color: AppColor.skyBlueColor,
          );
        }));
  }

  @override
  void initState() {
    getAllPostComments();
    super.initState();
  }

  getAllPostComments() {
    Map<String, String> map = {};
    map['post_id'] = widget.diaryId;

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.postCommentList,
      body: map,
      apiAction: ApiAction.postCommentList,
    );
  }

  getAllPostCommentsNext(String url) {
    Map<String, String> map = {};
    map['post_id'] = widget.diaryId;

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: url,
      body: map,
      apiAction: ApiAction.pagination,
    );
  }

  addCommentAPI() {
    Map<String, String> map = {};
    map['post_id'] = widget.diaryId;
    map['user_id'] = appUserSession.value.id.toString();
    map['comment'] = messageController.text.trim();

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.addComment,
      body: map,
      apiAction: ApiAction.addComment,
    );
  }

  deleteCommentAPI(String commentId) {
    Map<String, String> map = {};
    map['user_id'] = appUserSession.value.id.toString();
    map['comment_id'] = commentId;

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.deleteComment,
      body: map,
      apiAction: ApiAction.deleteComment,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.postCommentList) {
      postCommentModel = PostCommentModel.fromJson(result);
      if (postCommentModel.success) {
        future = Future.delayed(Duration(seconds: 1), () {
          return postCommentModel;
        });
        if (mounted) {
          setState(() {});
        }
      } else {
        AppHelper.showToastMessage(postCommentModel.message);
      }
    } else if (action == ApiAction.pagination) {
      PostCommentModel pagination = PostCommentModel.fromJson(result);
      if (pagination.success) {
        if (postCommentModel != null) {
          postCommentModel.data.nextPageUrl = pagination.data.nextPageUrl;

          for (var element in pagination.data.list) {
            if (!postCommentModel.data.list.contains(element)) {
              postCommentModel.data.list.add(element);
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
    } else if (action == ApiAction.addComment) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        PostCommentData postCommentData =
            PostCommentData.fromJson(result['data']);
        postCommentModel.data.list.add(postCommentData);
        print(postCommentData.name);
        messageController.clear();
        if (mounted) {
          setState(() {});
        }
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.deleteComment) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        getAllPostComments();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

}







