import 'dart:io';

import 'package:chunked_uploader/chunked_uploader.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_upchunk/flutter_upchunk.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/Enums.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/custom_widget/gradient_app_bar.dart';
import 'package:names/custom_widget/post_pop_menu.dart';
import 'package:names/custom_widget/video_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ImageHelper.dart';
import 'package:names/model/AddPostModel.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/FeedModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_compress/video_compress.dart';

import '../main.dart';

class AddNewPost extends StatefulWidget {
  Feed feed;

  AddNewPost({this.feed});

  @override
  _AddNewPostState createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> with ApiCallBackListener {
  bool passwordVisible = false;
  GlobalKey globalKey = GlobalKey();

  String selectedMenu = "Save as private";
  String selectedMenuIcon = "assets/icons/earth.png";
  List<AddPostModel> postModel = [];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // File videoFile;

  String saveAs = "1";

  int selectedIndex = 0;
  double progress = 0.0;
  bool isStart = false;

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
            widget.feed != null ? "Edit Your Post" : "Add Your New Post",
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
                  width: AppHelper.getDeviceWidth(context),
                  padding: EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    physics: ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 40,
                                      width: 40,
                                      margin: EdgeInsets.all(5),
                                      child: CustomWidget.imageView(
                                          appUserSession.value.profilePicture,
                                          circle: true,
                                          height: 40,
                                          width: 40,
                                          forProfileImage: true,
                                          fit: BoxFit.cover),
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  getName(),
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              GestureDetector(
                                                child: Container(
                                                  key: globalKey,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color:
                                                          AppColor.blueColor),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  margin: EdgeInsets.only(
                                                      bottom: 5),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        selectedMenuIcon,
                                                        height: 14,
                                                        width: 14,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        selectedMenu,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Image.asset(
                                                        "assets/icons/down_arrow.png",
                                                        height: 12,
                                                        width: 12,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  PostMenuDialog()
                                                      .show(context, globalKey,
                                                          (value) {
                                                    switch (value) {
                                                      case "private":
                                                        {
                                                          setState(() {
                                                            saveAs = "1";
                                                            selectedMenu =
                                                                "Save as private";
                                                            selectedMenuIcon =
                                                                "assets/icons/private.png";
                                                          });
                                                          break;
                                                        }
                                                      case "yournetwork":
                                                        {
                                                          setState(() {
                                                            saveAs = "2";
                                                            selectedMenu =
                                                                "Your Network";
                                                            selectedMenuIcon =
                                                                "assets/icons/your_network.png";
                                                          });
                                                          break;
                                                        }
                                                      case "public":
                                                        {
                                                          setState(() {
                                                            saveAs = "3";
                                                            selectedMenu =
                                                                "Public";
                                                            selectedMenuIcon =
                                                                "assets/icons/earth.png";
                                                          });
                                                          break;
                                                        }
                                                      case "service":
                                                        {
                                                          setState(() {
                                                            saveAs = "4";
                                                            selectedMenu =
                                                                "In-Service";
                                                            selectedMenuIcon =
                                                                "assets/icons/service.png";
                                                          });
                                                          break;
                                                        }
                                                    }
                                                  });
                                                },
                                              )
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.access_time_rounded,
                                                color: AppColor.textGrayColor,
                                                size: 18,
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                AppHelper.getDateMonth(),
                                                style: TextStyle(
                                                    color:
                                                        AppColor.textGrayColor),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "|",
                                                style: TextStyle(
                                                    color:
                                                        AppColor.textGrayColor),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                appUserSession.value.location !=
                                                        null
                                                    ? appUserSession
                                                        .value.location
                                                    : "",
                                                style: TextStyle(
                                                    color:
                                                        AppColor.textGrayColor),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: TextFormField(
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    maxLines: null,
                                    controller: titleController,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.text,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15.0),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: "Enter Title",
                                      filled: true,
                                      fillColor: AppColor.skyBlueColor,
                                      labelStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                      hintStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: TextFormField(
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    controller: descriptionController,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    minLines: 4,
                                    maxLines: null,
                                    textAlign: TextAlign.start,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15.0),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      hintText: "Enter some text",
                                      filled: true,
                                      fillColor: AppColor.skyBlueColor,
                                      labelStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                      hintStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                    )),
                              ),

                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height:
                                    (AppHelper.getDeviceWidth(context) - 40) /
                                        2,
                                width: AppHelper.getDeviceWidth(context) - 80,
                                alignment: Alignment.center,
                                child: postModel.length > 0
                                    ? Center(
                                        child: ListView.separated(
                                          itemCount: postModel.length,
                                          shrinkWrap: true,
                                          scrollDirection: Axis.horizontal,
                                          physics: ClampingScrollPhysics(),
                                          itemBuilder: (ctx, index) {
                                            if (postModel[index].isVideo) {
                                              return Container(
                                                height:
                                                    (AppHelper.getDeviceWidth(
                                                                context) -
                                                            40) /
                                                        2,
                                                width: AppHelper.getDeviceWidth(
                                                        context) -
                                                    80,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      width: AppHelper
                                                              .getDeviceWidth(
                                                                  context) -
                                                          80,
                                                      child: VideoWidget(
                                                        postModel[index].file,
                                                          postModel[index].id,
                                                        isLocalVideo: AppHelper
                                                            .isFileExist(File(
                                                                postModel[index]
                                                                    .file)),
                                                      ),
                                                      margin: EdgeInsets.only(
                                                          top: 0, right: 0),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: GestureDetector(
                                                        child: Container(
                                                          width: 20,
                                                          height: 20,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              color: AppColor
                                                                  .blueColor),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          deleteMedia(0);
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }
                                            return Container(
                                              height: (AppHelper.getDeviceWidth(
                                                          context) -
                                                      80) /
                                                  2,
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 100,
                                                width: 140,
                                                child: Stack(
                                                  children: [
                                                    Container(
                                                      height: 95,
                                                      width: 135,
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: AppHelper.isImageExist(postModel[index].file)
                                                          ? Image.file(File(postModel[index].file),
                                                              height: 50,
                                                              width: 50,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : CustomWidget.imageView(postModel[index].file,
                                                              height: 50,
                                                              width: 50,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                    Align(
                                                      alignment:
                                                          Alignment.topRight,
                                                      child: GestureDetector(
                                                        child: Container(
                                                          width: 15,
                                                          height: 15,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          100),
                                                              color: AppColor
                                                                  .blueColor),
                                                          alignment:
                                                              Alignment.center,
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 10,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          deleteMedia(index);
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                          separatorBuilder:
                                              (BuildContext context,
                                                  int index) {
                                            return SizedBox(
                                              width: 20,
                                            );
                                          },
                                        ),
                                      )
                                    : Center(
                                        child: Image.asset(
                                          "assets/images/image_placeholder.png",
                                          width: 150,
                                          height: 100,
                                        ),
                                      ),
                              ),


                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            border: Border.all(
                                                width: 1, color: Colors.grey)),
                                        alignment: Alignment.center,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "assets/icons/image.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "IMAGE",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ),
                                      ),
                                      onTap: () {
                                        int count = 0;
                                        postModel.forEach((element) {
                                          if (element.isVideo) {
                                            // postModel.remove(element);
                                          } else {
                                            count = count + 1;
                                          }
                                        });
                                        if (count == 5) {
                                          AppHelper.showToastMessage(
                                              "You have already selected maximum number of images");
                                          return;
                                        }

                                        ImageHelper().showPhotoBottomDialog(
                                            context, Platform.isIOS, (file) {
                                          setState(() {
                                            // videoFile = null;

                                            /*postModel.forEach((element) {
                                      if (element.isVideo) {
                                        postModel.remove(element);
                                      }
                                    });*/
                                            postModel.add(AddPostModel.name(
                                              file: file.path,
                                              isVideo: false,
                                              id: null,
                                            ));
                                          });
                                        });
                                      },
                                    ),
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.translucent,
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                            border: Border.all(
                                                width: 1, color: Colors.grey)),
                                        alignment: Alignment.center,
                                        child: Row(
                                          children: [
                                            Image.asset(
                                              "assets/icons/video.png",
                                              height: 25,
                                              width: 25,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Text(
                                              "VIDEO",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ),
                                      ),
                                      onTap: () {
                                        int count = 0;
                                        postModel.forEach((element) {
                                          if (element.isVideo) {
                                            count = count + 1;
                                          } else {}
                                        });
                                        if (count == 1) {
                                          AppHelper.showToastMessage(
                                              "You have already selected maximum number of video");
                                          return;
                                        }

                                        ImageHelper().showPhotoBottomDialog(
                                            context, Platform.isIOS, (file) async{

                                          postModel.add(AddPostModel.name(
                                            //file: mediaInfo.path,
                                            file: file.path,
                                            isVideo: true,
                                            id: null,
                                          ));
                                          setState(() {});

                                        }, fileType: FileType.video);
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                  "**Video will be available for 12 minutes only.")
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        GestureDetector(
                          child: Container(
                            width: AppHelper.getDeviceWidth(context),
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColor.lightSkyBlueColor),
                            alignment: Alignment.center,
                            child: Text(
                              widget.feed != null ? "UPDATE POST" : "ADD POST",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () {
                            addPostAPI();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                },
              )),
            );
          }
          return Container(color: AppColor.skyBlueColor);
        }));
  }

  @override
  void initState() {
    if (widget.feed != null) {
      titleController.text = widget.feed.title;
      descriptionController.text = widget.feed.description;
      if (widget.feed.medias.length > 0) {
        widget.feed.medias.forEach((element) {
          if (element.mediaType.toString() == "1") {
            /// 1 for image
            postModel.add(AddPostModel.name(
                file: element.media,
                isVideo: false,
                id: element.id.toString()));
          } else {
            // 2 for video
            postModel.add(AddPostModel.name(
                file: element.media, isVideo: true, id: element.id.toString()));
          }
        });
      }
    }
    super.initState();
  }

  double fileValidationCheck() {
    double fileSize = 0;

    for (int i = 0; i < postModel.length; i++) {
      if (AppHelper.isFileExist(File(postModel[i].file))) {
        final size = (File(postModel[i].file).readAsBytesSync().lengthInBytes) /
            (1024 * 1024);

        fileSize += size;
      }
    }

    print(fileSize);

    return double.parse(fileSize.toStringAsFixed(2));
  }

  void addPostAPI() {
    String title = titleController.text.trim();
    String description = descriptionController.text.trim();
    if (title.isEmpty) {
      AppHelper.showToastMessage("Please enter title.");
    } else if (description.isEmpty) {
      AppHelper.showToastMessage("Please enter description.");
    } else if (postModel.isNotEmpty && fileValidationCheck() > 700) {
      AppHelper.showToastMessage(
          "File size should not be greater than 700 MB.");
    } else {
      Map<String, String> body = Map();
      body["title"] = title;
      body["description"] = description;
      if (appUserSession.value.location != null) {
        body["location"] = appUserSession.value.location;
      }
      body["media_type"] =
          widget.feed != null && widget.feed.mediaType.toString().isNotEmpty
              ? widget.feed.mediaType.toString()
              : "3"; //required | 1=images,2=video 3=none
      body["save_as"] =
          saveAs; //required  | 1 = private, 2 = your network, 3= public
      if (widget.feed != null) {
        body['diary_id'] = widget.feed.id.toString();
      }

      Map<String, File> mapOfFilesAndKey = Map();
      bool isImage = false, isVideo = false;
      for (int i = 0; i < postModel.length; i++) {
        if (AppHelper.isFileExist(File(postModel[i].file))) {
          mapOfFilesAndKey["media[" + i.toString() + "]"] =
              File(postModel[i].file);
          if (postModel[i].isVideo) {
            // body["media_type"] = "2"; //required | 1=images,2=video
            // mapOfFilesAndKey["media"] = File(postModel[i].file);
            isVideo = true;
          } else {
            // body["media_type"] = "1"; //required | 1=images,2=video
            isImage = true;
          }
        }
      }

      body["media_type"] = "3";
      print("body===" + body.toString());
      /*if(isImage && isVideo){
        body["media_type"] = "3"; //required | 1=images,2=video, 3=both
      }else if(isVideo){
        body["media_type"] = "2"; //required | 1=images,2=video, 3=both
      }else{
        body["media_type"] = "1"; //required | 1=images,2=video, 3=both
      }*/

      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: widget.feed == null ? Url.createDiary : Url.editDiary,
        apiAction: ApiAction.createDiary,
        body: body,
        isMultiPart: true,
        mapOfFilesAndKey: mapOfFilesAndKey,
      );
    }
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.createDiary) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);
        Navigator.of(context).pop(true);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.deletePostMedia) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        setState(() {
          postModel.removeAt(selectedIndex);
        });
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

  void deleteMedia(int index) {
    selectedIndex = index;
    if (AppHelper.isFileExist(File(postModel[selectedIndex].file))) {
      setState(() {
        postModel.removeAt(selectedIndex);
      });
    } else {
      deleteMediaAPI();
    }
  }

  deleteMediaAPI() {
    Map<String, String> body = Map();
    body['id'] = postModel[selectedIndex].id;

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.deletePostMedia,
        apiAction: ApiAction.deletePostMedia,
        body: body);
  }

  String getName() {
    if (appUserSession.value.social_type != null &&
        (appUserSession.value.social_type == LoginType.google.name ||
            appUserSession.value.social_type == LoginType.linkedin.name ||
            appUserSession.value.social_type == "apple")) {
      return appUserSession.value.name != null ? appUserSession.value.name : "";
    }

    return appUserSession.value.firstName + " " + appUserSession.value.lastName;
  }
}


class CustomProgressIndicator extends StatelessWidget {
  final double progress;

  const CustomProgressIndicator({
     this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200.0,
      height: 20.0,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
