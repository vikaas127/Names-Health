import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/gradient_app_bar.dart';
import 'package:names/custom_widget/post_pop_menu.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/AddPostModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

class UpdatePost extends StatefulWidget {
  @override
  _UpdatePostState createState() => _UpdatePostState();
}

class _UpdatePostState extends State<UpdatePost> {
  bool passwordVisible = false;
  GlobalKey globalKey = GlobalKey();

  String selectedMenu = "Save as private";
  String selectedMenuIcon = "assets/icons/earth.png";
  List<AddPostModel> postModel = [];

  _appBarWidget(BuildContext context) {
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
            "Edit Your Post",
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
                                  children: [
                                    Container(
                                      height: 30,
                                      width: 30,
                                      margin: EdgeInsets.all(5),
                                      child: ClipRRect(
                                        child: Image.asset(
                                          "assets/images/person.jpeg",
                                          fit: BoxFit.cover,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "Steve Smith",
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.black),
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
                                                  margin: EdgeInsets.only(
                                                      bottom: 5),
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  child: Row(
                                                    children: [
                                                      Image.asset(
                                                        selectedMenuIcon,
                                                        height: 10,
                                                        width: 10,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Text(
                                                        selectedMenu,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 10),
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      Image.asset(
                                                        "assets/icons/down_arrow.png",
                                                        height: 10,
                                                        width: 10,
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
                                                            selectedMenu =
                                                                "Public";
                                                            selectedMenuIcon =
                                                                "assets/icons/earth.png";
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
                                                size: 11,
                                                color: AppColor.textGrayColor,
                                              ),
                                              SizedBox(
                                                width: 3,
                                              ),
                                              Text(
                                                "28 April",
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    color:
                                                        AppColor.textGrayColor),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "|",
                                                style: TextStyle(
                                                    fontSize: 9,
                                                    color:
                                                        AppColor.textGrayColor),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Allentown, New Mexico",
                                                style: TextStyle(
                                                    fontSize: 9,
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
                                height: 50,
                                child: TextFormField(
                                    initialValue: "Hello everyone",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
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
                                          color: AppColor.textGrayColor,
                                          fontSize: 14),
                                      hintStyle: TextStyle(
                                          color: AppColor.textGrayColor,
                                          fontSize: 14),
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                child: TextFormField(
                                    initialValue:
                                        "ll the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet.",
                                    style: TextStyle(
                                      color: Colors.black,
                                    ),
                                    minLines: 4,
                                    maxLines: 4,
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
                                          color: AppColor.textGrayColor,
                                          fontSize: 14),
                                      hintStyle: TextStyle(
                                          color: AppColor.textGrayColor,
                                          fontSize: 14),
                                    )),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                height: 100,
                                child: postModel.length > 0
                                    ? ListView.separated(
                                        itemCount: postModel.length,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (ctx, index) {
                                          return Container(
                                            height: 100,
                                            width: 140,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  height: 95,
                                                  width: 135,
                                                  margin:
                                                      EdgeInsets.only(top: 5),
                                                  child: Image.asset(
                                                    postModel[index].file,
                                                    height: 50,
                                                    width: 50,
                                                    fit: BoxFit.fill,
                                                  ),
                                                ),
                                                Align(
                                                  alignment: Alignment.topRight,
                                                  child: Container(
                                                    width: 15,
                                                    height: 15,
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color:
                                                            AppColor.blueColor),
                                                    alignment: Alignment.center,
                                                    child: Icon(
                                                      Icons.close,
                                                      size: 10,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            width: 20,
                                          );
                                        },
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
                                            height: 20,
                                            width: 20,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "IMAGE",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
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
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Expanded(
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
                                            height: 20,
                                            width: 20,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "VIDEO",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
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
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          width: AppHelper.getDeviceWidth(context),
                          height: 50,
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: AppColor.lightSkyBlueColor),
                          alignment: Alignment.center,
                          child: Text(
                            "UPDATE POST",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
          return Container(
            color: AppColor.skyBlueColor,
          );
        }));
  }

  @override
  void initState() {
    // postModel.add(AddPostModel.name("assets/images/image1.png", false, null));
    // postModel.add(AddPostModel.name("assets/images/image2.png", false, null));
    // postModel.add(AddPostModel.name("assets/images/image1.png", false, null));
    // postModel.add(AddPostModel.name("assets/images/image2.png", false, null));
    super.initState();
  }
}
