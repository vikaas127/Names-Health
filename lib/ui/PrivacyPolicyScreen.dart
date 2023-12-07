import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';

import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/ContentListModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

import '../api/ApiAction.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({Key key}) : super(key: key);

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen>
    with ApiCallBackListener {
  Future<ContentListModel> future;
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
            "Privacy Policy",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return appUserSession.value != null
        ? StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseHelper.getuserCallStatus(
                appUserSession.value.id.toString()),
            builder: ((context, snapshot) {
              if (snapshot.hasData &&
                  snapshot.data != null &&
                  snapshot.data.data() != null) {
                final data = CallStatusModel.fromMap(snapshot.data.data());
                if (data.callStatus == "Ringing") {
                  AppHelper.callRingtone();
                  AppHelper.playRingtone();
                }
                if (data.stopRinging) {
                  AppHelper.stopRingtone();
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
                    body: privacyPolicyWidget());
              }
              return Scaffold(
                  appBar: AppHelper.appBar(
                      context,
                      _appBarWidget(context),
                      LinearGradient(colors: [
                        AppColor.skyBlueColor,
                        AppColor.skyBlueColor
                      ])),
                  backgroundColor: AppColor.skyBlueColor,
                  body: privacyPolicyWidget());
            }))
        : Scaffold(
            appBar: AppHelper.appBar(
                context,
                _appBarWidget(context),
                LinearGradient(
                    colors: [AppColor.skyBlueColor, AppColor.skyBlueColor])),
            backgroundColor: AppColor.skyBlueColor,
            body: privacyPolicyWidget());
  }

  void initState() {
    getContentListAPI();
    super.initState();
  }

  getContentListAPI() {
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.GET,
        url: Url.contentList,
        apiAction: ApiAction.contentList,
        isMultiPart: false);
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.contentList) {
      ContentListModel contentListModel = ContentListModel.fromMap(result);
      if (contentListModel.success) {
        future = Future.delayed(Duration(seconds: 1), () {
          return contentListModel;
        });
        setState(() {});
      } else {
        AppHelper.showToastMessage(contentListModel.message);
      }
    }
  }

  Widget privacyPolicyWidget() {
    return FutureBuilder<ContentListModel>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.data != null &&
                snapshot.data.data.privacyPolicy != null) {
              return SafeArea(
                  child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Html(
                    data: snapshot.data.data.privacyPolicy,
                  ),
                ),
              ));
            } else {
              return Container();
            }
          } else {
            return ProgressDialog.getCircularProgressIndicator();
          }
        });
  }
}
