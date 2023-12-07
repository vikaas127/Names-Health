import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/gradient_app_bar.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/ApiResponseModel.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key key}) : super(key: key);

  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword>
    with ApiCallBackListener {
  bool passwordVisible = false;
  bool cnfPasswordVisible = false;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  _appBarWidget(BuildContext context) {
    return Row(
      children: [
        Container(
          child: IconButton(
            icon: Image.asset(
              "assets/icons/back_arrow.png",
              height: 20,
              width: 20,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: Text(
            "Change Password",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.white),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHelper.appBar(context, _appBarWidget(context),
          LinearGradient(colors: [AppColor.blueColor, AppColor.blueColor])),
      backgroundColor: AppColor.skyBlueColor,
      body: SafeArea(
          child: GestureDetector(
        child: Container(
          width: AppHelper.getDeviceWidth(context),
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 50,
                      child: TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          controller: passwordController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          obscureText: !passwordVisible,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "New Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible = !passwordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle:
                                TextStyle(color: Colors.black, fontSize: 14),
                            hintStyle:
                                TextStyle(color: Colors.black, fontSize: 14),
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 50,
                      child: TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          controller: confirmPasswordController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          obscureText: !cnfPasswordVisible,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Confirm Password",
                            suffixIcon: IconButton(
                              icon: Icon(
                                cnfPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  cnfPasswordVisible = !cnfPasswordVisible;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            labelStyle:
                                TextStyle(color: Colors.black, fontSize: 14),
                            hintStyle:
                                TextStyle(color: Colors.black, fontSize: 14),
                          )),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
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
                    "UPDATE",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  updatePasswordAPI();
                },
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

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.changePassword) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        AppHelper.showToastMessage(apiResponseModel.message);
        Navigator.pop(context);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

  void updatePasswordAPI() {
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    if (password.isEmpty) {
      AppHelper.showToastMessage("Please enter password.");
    } else if (confirmPassword.isEmpty) {
      AppHelper.showToastMessage("Please enter confirm password.");
    } else if (password != confirmPassword) {
      AppHelper.showToastMessage("Password & confirm does not match.");
    } else {
      Map<String, String> body = Map();
      body["new_password"] = password;

      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.changePassword,
        apiAction: ApiAction.changePassword,
        body: body,
      );
    }
  }
}
