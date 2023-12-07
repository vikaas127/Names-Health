import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';

class ReportAbuseScreen extends StatefulWidget {
  final String postId;
  const ReportAbuseScreen({Key key, this.postId}) : super(key: key);

  @override
  State<ReportAbuseScreen> createState() => _ReportAbuseScreenState();
}

class _ReportAbuseScreenState extends State<ReportAbuseScreen>
    with ApiCallBackListener {
  TextEditingController nameController = TextEditingController();
  TextEditingController _controller = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController subjectController = TextEditingController();

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
            "Report Abuse",
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
              body: Container(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: TextFormField(
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              maxLines: null,
                              controller: nameController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Your Name",
                                filled: true,
                                counterText: "",
                                contentPadding: EdgeInsets.all(8),
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Colors.black),
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
                              maxLines: null,
                              controller: emailController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Email Address",
                                filled: true,
                                counterText: "",
                                contentPadding: EdgeInsets.all(8),
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Colors.black),
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
                              maxLines: null,
                              controller: phoneController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.phone,
                              textCapitalization: TextCapitalization.sentences,
                              autocorrect: false,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Phone Number",
                                filled: true,
                                counterText: "",
                                contentPadding: EdgeInsets.all(8),
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Colors.black),
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
                              maxLines: null,
                              maxLength: 190,
                              controller: subjectController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Subject",
                                filled: true,
                                counterText: "",
                                contentPadding: EdgeInsets.all(8),
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Colors.black),
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
                              maxLines: 10,
                              minLines: 10,
                              controller: _controller,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.text,
                              textCapitalization: TextCapitalization.sentences,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Write here...",
                                filled: true,
                                counterText: "",
                                contentPadding: EdgeInsets.all(8),
                                fillColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.black),
                                hintStyle: TextStyle(color: Colors.black),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            if (_controller.text.isEmpty &&
                                _controller.text == null) {
                              AppHelper.showToastMessage("Please enter report");
                            } else {
                              getReportAbuseAPI();
                            }
                          },
                          child: Container(
                            width: AppHelper.getDeviceWidth(context),
                            height: 50,
                            margin: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColor.lightSkyBlueColor),
                            alignment: Alignment.center,
                            child: Text(
                              "SUBMIT",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return Container(
            color: AppColor.skyBlueColor,
          );
        }));
  }

  getReportAbuseAPI() {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String phoneNumber = phoneController.text.trim();
    String subject = subjectController.text.trim();
    String message = _controller.text.trim();
    if (name.isEmpty) {
      AppHelper.showToastMessage("Please enter name.");
    } else if (email.isEmpty) {
      AppHelper.showToastMessage("Please enter email.");
    } else if (!AppHelper.isValidEmail(email)) {
      AppHelper.showToastMessage("Please enter valid email.");
    } else if (phoneNumber.isEmpty) {
      AppHelper.showToastMessage("Please enter phone number");
    } else if (phoneNumber.length < 10 || phoneNumber.length > 12) {
      AppHelper.showToastMessage("Mobile Number must be 10-12 digits.");
    } else if (subject.isEmpty) {
      AppHelper.showToastMessage("Please enter subject.");
    } else if (message.isEmpty) {
      AppHelper.showToastMessage("Please enter report.");
    } else {
      Map<String, String> map = {};

      map['name'] = name;
      map['email'] = email;
      map['phone'] = phoneNumber;
      map['subject'] = subject;
      map['message'] = message;
      if (widget.postId != null) {
        map['user_diaries_post_id'] = widget.postId;
      }
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: true,
          httpType: HttpMethods.POST,
          url: Url.contactUs,
          apiAction: ApiAction.contactUs,
          isMultiPart: false,
          body: map);
    }
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.contactUs) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);
        Navigator.of(context).pop();
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }
}
