import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/Providers/SchedulingManagerController.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:provider/provider.dart';

class SchedulingManagerListScreen extends StatefulWidget {
  const SchedulingManagerListScreen({Key key}) : super(key: key);

  @override
  State<SchedulingManagerListScreen> createState() =>
      _SchedulingManagerListScreenState();
}

class _SchedulingManagerListScreenState
    extends State<SchedulingManagerListScreen> {
  SchedulingManagerController managerController;

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
            "Select Scheduling Manager",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
      ],
    );
  }

  void initState() {
    managerController =
        Provider.of<SchedulingManagerController>(context, listen: false);
    managerController.context = context;
    managerController.getConnectedUsersAPI();

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
                body: Consumer<SchedulingManagerController>(
                    builder: (context, provider, child) {
                  if (provider.connectionModel != null) {
                    return SafeArea(
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
                                        style: TextStyle(
                                            color: AppColor.textGrayColor),
                                        controller: provider.controller,
                                        decoration: InputDecoration(
                                            border: InputBorder.none,
                                            labelStyle: TextStyle(
                                                color: AppColor.textGrayColor),
                                            hintStyle: TextStyle(
                                                color: AppColor.textGrayColor),
                                            hintText: "Search Connection",
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 20,
                                                    vertical: 12)),
                                        textAlignVertical:
                                            TextAlignVertical.center,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        String name =
                                            provider.controller.text.trim();
                                        if (name.isNotEmpty) {
                                          setState(
                                            () {
                                              provider.isSearching = true;
                                            },
                                          );
                                          provider.getConnectedUsersAPI();
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
                                    if (provider.isSearching)
                                      IconButton(
                                        onPressed: () {
                                          setState(
                                            () {
                                              provider.isSearching = false;
                                            },
                                          );

                                          provider.controller.clear();
                                          provider.getConnectedUsersAPI();
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
                              child: provider.connectedUsersList.length > 0
                                  ? Column(children: [
                                      Expanded(
                                          child: NotificationListener<
                                                  ScrollNotification>(
                                              onNotification:
                                                  (ScrollNotification scroll) {
                                                if (scroll
                                                        is ScrollEndNotification &&
                                                    provider
                                                            .scrollController
                                                            .position
                                                            .maxScrollExtent ==
                                                        provider
                                                            .scrollController
                                                            .position
                                                            .pixels) {
                                                  if (provider
                                                              .connectionModel
                                                              .data
                                                              .nextPageUrl !=
                                                          null &&
                                                      !provider.isPaging) {
                                                    setState(() {
                                                      provider.isPaging = true;
                                                    });
                                                    provider
                                                        .getConnectionNextAPI(
                                                            provider
                                                                .connectionModel
                                                                .data
                                                                .nextPageUrl);
                                                  }
                                                }
                                                return false;
                                              },
                                              child: ListView.separated(
                                                itemCount: provider
                                                    .connectedUsersList.length,
                                                shrinkWrap: true,
                                                controller:
                                                    provider.scrollController,
                                                physics:
                                                    ClampingScrollPhysics(),
                                                itemBuilder: (ctx, index) {
                                                  UsersModel usersModel =
                                                      provider.connectedUsersList[
                                                          index];
                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        provider.selectedIndex =
                                                            index;
                                                      });
                                                      Future.delayed(
                                                          Duration(seconds: 1),
                                                          () {
                                                        Navigator.of(context)
                                                            .pop([
                                                          usersModel.id
                                                              .toString(),
                                                          usersModel.name
                                                        ]);
                                                      });
                                                    },
                                                    child: Container(
                                                      width: AppHelper
                                                          .getDeviceWidth(
                                                              context),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: provider
                                                                    .selectedIndex ==
                                                                index
                                                            ? AppColor
                                                                .skyBlueBoxColor
                                                            : Colors.white,
                                                      ),
                                                      padding:
                                                          EdgeInsets.all(5),
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
                                                              child: ClipRRect(
                                                                child: Stack(
                                                                  children: [
                                                                    CustomWidget
                                                                        .imageView(
                                                                      usersModel
                                                                          .profilePicture,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      backgroundColor:
                                                                          AppColor
                                                                              .profileBackColor,
                                                                      width: 60,
                                                                      height:
                                                                          60,
                                                                      forProfileImage:
                                                                          true,
                                                                    ),
                                                                    AppHelper.professtionWidget(
                                                                        usersModel
                                                                            .profession_symbol),
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
                                                                height: 70,
                                                                margin:
                                                                    EdgeInsets
                                                                        .all(5),
                                                                alignment: Alignment
                                                                    .centerLeft,
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        mainAxisSize:
                                                                            MainAxisSize.max,
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
                                                                            height:
                                                                                5,
                                                                          ),
                                                                          Text(
                                                                            usersModel.profession ??
                                                                                "",
                                                                            maxLines:
                                                                                1,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                TextStyle(color: AppColor.textGrayColor),
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
                                      if (provider.isPaging &&
                                          provider.connectionModel.data
                                                  .nextPageUrl !=
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
                                    ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                      },
                    ));
                  } else {
                    return Container();
                  }
                }));
          }
          return Container(
            color: AppColor.skyBlueColor,
          );
        }));
  }
}
