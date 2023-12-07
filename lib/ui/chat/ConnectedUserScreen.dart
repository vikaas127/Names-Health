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
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/ConnectionModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:names/ui/chat/ChatScreen.dart';
import 'package:names/ui/UserProfileScreen.dart';

class ConnectedUserScreen extends StatefulWidget {
  String title = null;
  ConnectedUserScreen({Key key, this.title}) : super(key: key);

  @override
  _ConnectedUserScreenState createState() => _ConnectedUserScreenState();
}

class _ConnectedUserScreenState extends State<ConnectedUserScreen>
    with ApiCallBackListener {
  TextEditingController textEditingController = TextEditingController();
  GlobalKey globalKey = GlobalKey();
  ScrollController _scrollController = ScrollController();
  ConnectionModel connectionModel;
  TextEditingController controller = TextEditingController();
  bool isSearching = false;

  bool isPaging = false;

  Future<List<UsersModel>> futureConnectedUsers;
  List<UsersModel> connectedUsersList = [];
  // List<UsersModel> tempConnectedUsersList = [];

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
            widget.title != null ? widget.title : "New Message",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
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
              body: SafeArea(
                  child: GestureDetector(
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: TextFormField(
                                  style:
                                      TextStyle(color: AppColor.textGrayColor),
                                  controller: controller,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      labelStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                      hintStyle: TextStyle(
                                          color: AppColor.textGrayColor),
                                      hintText: "Search Connection",
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 20, vertical: 12)),
                                  textAlignVertical: TextAlignVertical.center,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  String name = controller.text.trim();
                                  if (name.isNotEmpty) {
                                    setState(
                                      () {
                                        isSearching = true;
                                      },
                                    );
                                    getConnectedUsersAPI();
                                  }
                                },
                                icon: Container(
                                  child: const Icon(
                                    Icons.search_outlined,
                                    size: 18,
                                  ),
                                  padding: const EdgeInsets.all(5),
                                  margin: const EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                      color: AppColor.blueColor,
                                      shape: BoxShape.circle),
                                ),
                                color: Colors.white,
                              ),
                              if (isSearching)
                                IconButton(
                                  onPressed: () {
                                    setState(
                                      () {
                                        isSearching = false;
                                      },
                                    );

                                    controller.clear();
                                    getConnectedUsersAPI();
                                  },
                                  icon: Container(
                                    child: const Icon(
                                      Icons.close,
                                      size: 18,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    margin: const EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                        color: AppColor.blueColor,
                                        shape: BoxShape.circle),
                                  ),
                                  color: Colors.white,
                                ),
                            ]),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Expanded(
                        child: FutureBuilder<List<UsersModel>>(
                            future: futureConnectedUsers, // async work
                            builder: (BuildContext context,
                                AsyncSnapshot<List<UsersModel>> snapshot) {
                              if (snapshot.hasData) {
                                return connectedUsersList.length > 0
                                    ? Column(children: [
                                        Expanded(
                                            child:
                                                NotificationListener<
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
                                                        if (connectionModel.data
                                                                    .nextPageUrl !=
                                                                null &&
                                                            !isPaging) {
                                                          setState(() {
                                                            isPaging = true;
                                                          });
                                                          getConnectionNextAPI(
                                                              connectionModel
                                                                  .data
                                                                  .nextPageUrl);
                                                        }
                                                      }
                                                      return false;
                                                    },
                                                    child: ListView.separated(
                                                      itemCount:
                                                          connectedUsersList
                                                              .length,
                                                      shrinkWrap: true,
                                                      controller:
                                                          _scrollController,
                                                      physics:
                                                          ClampingScrollPhysics(),
                                                      itemBuilder:
                                                          (ctx, index) {
                                                        UsersModel usersModel =
                                                            connectedUsersList[index];
                                                        return GestureDetector(
                                                          child: Container(
                                                            width: AppHelper
                                                                .getDeviceWidth(
                                                                    context),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: usersModel
                                                                          .status !=
                                                                      null
                                                                  ? AppColor
                                                                      .skyBlueBoxColor
                                                                  : Colors
                                                                      .white,
                                                            ),
                                                            padding:
                                                                EdgeInsets.all(
                                                                    5),
                                                            child: Container(
                                                              child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    height: 70,
                                                                    width: 60,
                                                                    margin: EdgeInsets
                                                                        .all(5),
                                                                    child:
                                                                        ClipRRect(
                                                                      child:
                                                                          Stack(
                                                                        children: [
                                                                          CustomWidget
                                                                              .imageView(
                                                                            usersModel.profilePicture,
                                                                            fit:
                                                                                BoxFit.cover,
                                                                            backgroundColor:
                                                                                AppColor.profileBackColor,
                                                                            width:
                                                                                60,
                                                                            height:
                                                                                60,
                                                                            forProfileImage:
                                                                                true,
                                                                          ),
                                                                          AppHelper.professtionWidget(
                                                                              usersModel.profession_symbol),
                                                                        ],
                                                                      ),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      height:
                                                                          70,
                                                                      margin: EdgeInsets
                                                                          .all(
                                                                              5),
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              mainAxisSize: MainAxisSize.max,
                                                                              children: [
                                                                                Row(
                                                                                  children: [
                                                                                    Flexible(
                                                                                      child: Text(
                                                                                        usersModel.name,
                                                                                        maxLines: 2,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: TextStyle(fontSize: 16, fontFamily: "Lato_Bold", color: Colors.black),
                                                                                      ),
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: 5,
                                                                                    ),
                                                                                    AppHelper.ShildWidget(usersModel.licenseExpiryDate, 16, 16)
                                                                                  ],
                                                                                ),
                                                                                SizedBox(
                                                                                  height: 5,
                                                                                ),
                                                                                Text(
                                                                                  AppHelper.setText(usersModel.profession),
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: TextStyle(color: AppColor.textGrayColor),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                  SizedBox(
                                                                    width: 5,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () {
                                                            if (widget.title !=
                                                                null) {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                      PageRouteBuilder(
                                                                pageBuilder: (BuildContext context,
                                                                        Animation<double>
                                                                            animation,
                                                                        Animation<double>
                                                                            secondaryAnimation) =>
                                                                    UserProfileScreen(
                                                                  usersModel:
                                                                      usersModel,
                                                                ),
                                                                transitionDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            0),
                                                              ))
                                                                  .then(
                                                                      (value) {
                                                                if (value !=
                                                                        null &&
                                                                    value) {
                                                                  getConnectedUsersAPI();
                                                                }
                                                              });
                                                            } else {
                                                              Navigator.of(
                                                                      context)
                                                                  .push(
                                                                      PageRouteBuilder(
                                                                pageBuilder: (BuildContext context,
                                                                        Animation<double>
                                                                            animation,
                                                                        Animation<double>
                                                                            secondaryAnimation) =>
                                                                    ChatScreen(
                                                                        usersModel),
                                                                transitionDuration:
                                                                    Duration(
                                                                        seconds:
                                                                            0),
                                                              ));
                                                            }
                                                          },
                                                        );
                                                      },
                                                      separatorBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return SizedBox(
                                                          height: 20,
                                                        );
                                                      },
                                                    ))),
                                        if (isPaging &&
                                            connectionModel.data.nextPageUrl !=
                                                null)
                                          Container(
                                            height: 50,
                                            child: ProgressDialog
                                                .getCircularProgressIndicator(),
                                          ),
                                      ])
                                    : Center(
                                        child: AppHelper.getNoRecordWidget(
                                            context,
                                            "assets/icons/connection.png",
                                            "No connections yet",
                                            MainAxisAlignment.center),
                                      );
                              }
                              return ProgressDialog
                                  .getCircularProgressIndicator();
                            }),
                      ),
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

  getConnectedUsersAPI() {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: true,
          httpType: HttpMethods.POST,
          url: Url.networkList,
          apiAction: ApiAction.networkList,
          body: body);
    } else {
      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.networkList,
        apiAction: ApiAction.networkList,
      );
    }
  }

  getConnectionNextAPI(String url) {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
    }

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: url,
        apiAction: ApiAction.pagination,
        body: body);
  }

  @override
  void initState() {
    if (mounted) {
      getConnectedUsersAPI();
    }
    super.initState();
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.networkList) {
      connectionModel = ConnectionModel.fromJson(result);
      if (connectionModel.success) {
        connectedUsersList.clear();

        connectionModel.data.list.forEach((element) {
          connectedUsersList.add(UsersModel.fromJson(element.toJson()));
        });
        futureConnectedUsers = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return connectedUsersList;
        });
      } else {
        AppHelper.showToastMessage(connectionModel.message);
      }
    } else if (action == ApiAction.pagination) {
      ConnectionModel pagination = ConnectionModel.fromJson(result);
      if (pagination.success) {
        if (connectionModel != null) {
          connectionModel.data.nextPageUrl = pagination.data.nextPageUrl;

          for (var element in pagination.data.list) {
            if (!connectionModel.data.list.contains(element)) {
              connectionModel.data.list.add(element);
              connectedUsersList.add(UsersModel.fromJson(element.toJson()));
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
  }
}
