import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/ApiResponseModel.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key key}) : super(key: key);

  @override
  _ForgotScreenState createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> with ApiCallBackListener {
  bool passwordVisible = false;
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.skyBlueColor,
      body: SafeArea(
          child: GestureDetector(
        child: Container(
          width: AppHelper.getDeviceWidth(context),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                Image.asset(
                  "assets/icons/logo.png",
                  width: 180,
                  height: 90,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  "Forgot Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Roboto_Bold", fontSize: 24),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Enter your email for the  verification process, we will send 4 digits code to your email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Roboto_Regular",
                        fontSize: 14,
                        color: AppColor.textGrayColor),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  decoration: BoxDecoration(
                      color: AppColor.blueColor,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50),
                          bottomRight: Radius.circular(50))),
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.all(20),
                  width: AppHelper.getDeviceWidth(context),
                  child: Column(
                    children: [
                      Text(
                        "Email Address",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Roboto_Bold",
                            fontSize: 24,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            controller: emailController,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Email Address",
                              filled: true,
                              fillColor: AppColor.blueBoxColor,
                              labelStyle: TextStyle(color: Colors.white),
                              hintStyle: TextStyle(color: Colors.white),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        child: Container(
                          width: AppHelper.getDeviceWidth(context),
                          height: 50,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white),
                          alignment: Alignment.center,
                          child: Text(
                            "CONTINUE",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColor.blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          forgotAPI();
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
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

  void forgotAPI() {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      AppHelper.showToastMessage("Please enter email.");
    } else if (!AppHelper.isValidEmail(email)) {
      AppHelper.showToastMessage("Please enter valid email.");
    } else {
      Map<String, String> body = Map();
      body["email"] = email;

      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.forgotPassword,
        apiAction: ApiAction.forgotPassword,
        body: body,
      );
    }
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.forgotPassword) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);
        // Navigator.of(context).pushNamed(Routes.OTPScreen);
        Navigator.of(context).pop(true);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }
}
