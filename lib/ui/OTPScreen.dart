import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/route/routes.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({Key key}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool passwordVisible = false;

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
                  "Enter 4 Digits Code",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Roboto_Bold", fontSize: 26),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Enter 4 Digits code that you received on your email.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: "Roboto_Regular",
                        fontSize: 16,
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
                        "Verification",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Roboto_Bold",
                            fontSize: 26,
                            color: Colors.white),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 50,
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        child: PinCodeTextField(
                          length: 4,
                          obscureText: false,
                          animationType: AnimationType.fade,
                          pinTheme: PinTheme(
                              shape: PinCodeFieldShape.box,
                              borderRadius: BorderRadius.circular(5),
                              fieldHeight: 50,
                              fieldWidth: 50,
                              borderWidth: 0,
                              activeColor: AppColor.blueBoxColor,
                              activeFillColor: AppColor.blueBoxColor,
                              disabledColor: AppColor.blueBoxColor,
                              inactiveColor: AppColor.blueBoxColor,
                              selectedColor: AppColor.blueBoxColor,
                              inactiveFillColor: AppColor.blueBoxColor,
                              selectedFillColor: AppColor.blueBoxColor),
                          animationDuration: Duration(milliseconds: 300),
                          textStyle: TextStyle(color: Colors.white),
                          useExternalAutoFillGroup: true,
                          autoDismissKeyboard: true,
                          enablePinAutofill: true,
                          enableActiveFill: true,
                          onCompleted: (v) {
                            print("Completed");
                          },
                          onChanged: (value) {
                            print(value);
                            setState(() {
                              // currentText = value;
                            });
                          },
                          beforeTextPaste: (text) {
                            print("Allowing to paste $text");
                            return true;
                          },
                          appContext: context,
                        ),
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
                            "VERIFY",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.DashboardScreen, (route) => false);
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
}
