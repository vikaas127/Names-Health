import 'dart:io';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/custom_widget/circle_checkbox.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ImageHelper.dart';
import 'package:names/model/ProfessionModel.dart';
import 'package:names/model/ProfessionResponse.dart';
import 'package:names/model/RegisterModel.dart';
import 'package:names/model/SpecialistModel.dart';
import 'package:names/model/SpecialistResponse.dart';
import 'package:names/model/UserSession.dart';
import 'package:names/route/routes.dart';
import 'package:names/ui/PrivacyPolicyScreen.dart';
import 'package:names/ui/TermsAndConditionsScreen.dart';
import '../app/FirebasePushNotification.dart';
import '../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with ApiCallBackListener {
  bool passwordVisible = false;
  bool cnfPasswordVisible = false;
  bool checkBox = false;
  File profileImage;
  File document;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController specalistController = TextEditingController();

  ProfessionModel selectedProfessionModel;

  List<ProfessionModel> professionList = [];

  SpecialistModel selectedSpecialistModel;

  List<SpecialistModel> specialistList = [];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: AppColor.skyBlueColor,
    ));
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
                  "Welcome",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Roboto_Bold", fontSize: 26),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Sign up into your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Roboto_Regular",
                      fontSize: 16,
                      color: AppColor.textGrayColor),
                ),
                SizedBox(
                  height: 20,
                ),
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: AppColor.darkBlueColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50),
                              bottomRight: Radius.circular(50))),
                      padding: EdgeInsets.only(
                          right: 20, top: 40, bottom: 20, left: 20),
                      margin: EdgeInsets.only(
                          right: 20, top: 40, bottom: 20, left: 20),
                      width: AppHelper.getDeviceWidth(context),
                      child: Column(
                        children: [
                          Text(
                            "Register",
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
                            child: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                maxLines: null,
                                controller: firstNameController,
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
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8),
                                  hintText: "First Name",
                                  filled: true,
                                  fillColor: AppColor.darkBlueBoxColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                maxLines: null,
                                controller: lastNameController,
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
                                  hintText: "Last Name",
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8),
                                  filled: true,
                                  fillColor: AppColor.darkBlueBoxColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                                controller: emailController,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.emailAddress,
                                maxLines: null,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Email Address",
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8),
                                  filled: true,
                                  fillColor: AppColor.darkBlueBoxColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              maxLines: null,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15.0),
                                  ),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Date of License Expiration",
                                filled: true,
                                suffixIcon: Icon(
                                  Icons.calendar_today,
                                  color: Colors.white,
                                ),
                                counterText: "",
                                contentPadding: EdgeInsets.all(8),
                                fillColor: AppColor.darkBlueBoxColor,
                                labelStyle: TextStyle(color: Colors.white),
                                hintStyle: TextStyle(color: Colors.white),
                              ),
                              controller: dateController,
                              onTap: () async {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                DateTime date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate:
                                        DateTime(DateTime.now().year + 10));
                                if (date != null) {
                                  dateController.text = date.year.toString() +
                                      "-" +
                                      date.month.toString() +
                                      "-" +
                                      date.day.toString();
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                controller: locationController,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.streetAddress,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                autocorrect: false,
                                enableSuggestions: false,
                                maxLines: null,
                                decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15.0),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                  hintText: "Location",
                                  filled: true,
                                  // suffixIcon: Transform.rotate(
                                  //   angle: 90 * pi / 180,
                                  //   child: Icon(
                                  //     Icons.arrow_forward_ios_sharp,
                                  //     color: Colors.white,
                                  //   ),
                                  // ),
                                  fillColor: AppColor.darkBlueBoxColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              color: AppColor.darkBlueBoxColor,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: DropdownButton<ProfessionModel>(
                              items:
                                  professionList.map((ProfessionModel value) {
                                return new DropdownMenuItem<ProfessionModel>(
                                  value: value,
                                  child: new Text(
                                    value.professionName,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                );
                              }).toList(),
                              isExpanded: true,
                              dropdownColor: AppColor.darkBlueBoxColor,
                              underline: SizedBox(),
                              hint: Text(
                                "Select Profession",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              value: selectedProfessionModel,
                              icon: Transform.rotate(
                                angle: 90 * pi / 180,
                                child: Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  color: Colors.white,
                                ),
                              ),
                              onChanged: (value) {
                                print(
                                    "profession onChanged=" + value.toString());
                                setState(() {
                                  selectedProfessionModel = value;
                                  getSpecialistAPI();
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                maxLines: null,
                                controller: specalistController,
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
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8),
                                  hintText: "Enter Specialist",
                                  filled: true,
                                  fillColor: AppColor.darkBlueBoxColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
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
                                  hintText: "Password",
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      passwordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: AppColor.darkBlueBoxColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: TextFormField(
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                                controller: confirmPasswordController,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                obscureText: !cnfPasswordVisible,
                                decoration: InputDecoration(
                                  counterText: "",
                                  contentPadding: EdgeInsets.all(8),
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
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        cnfPasswordVisible =
                                            !cnfPasswordVisible;
                                      });
                                    },
                                  ),
                                  filled: true,
                                  fillColor: AppColor.darkBlueBoxColor,
                                  labelStyle: TextStyle(color: Colors.white),
                                  hintStyle: TextStyle(color: Colors.white),
                                )),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "PLEASE ADD YOUR LICENSE :",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: "Roboto_Regular",
                                  fontSize: 16,
                                  color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          GestureDetector(
                            child: Container(
                              width: AppHelper.getDeviceWidth(context),
                              height: 80,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: AppColor.lightSkyBlueColor),
                              alignment: Alignment.center,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  document != null
                                      ? AppHelper.isImage(document.path)
                                          ? Image.file(
                                              document,
                                              height: 40,
                                              width: 40,
                                            )
                                          : Icon(
                                              Icons.file_copy,
                                              size: 40,
                                              color: Colors.white,
                                            )
                                      : Image.asset(
                                          "assets/icons/upload.png",
                                          height: 40,
                                          width: 40,
                                        ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    "Upload License",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: "Lato_Bold"),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              ImageHelper().showPhotoBottomDialog(
                                  context, Platform.isIOS, (file) {
                                setState(() {
                                  document = file;
                                });
                              }, allowFile: true);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              CircleCheckbox(
                                  value: checkBox,
                                  activeColor: Colors.green,
                                  checkColor: Colors.black,
                                  onChanged: (value) {
                                    setState(() {
                                      checkBox = value;
                                    });
                                  }),
                              SizedBox(
                                width: 10,
                              ),
                              Flexible(
                                child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.8,
                                    child: RichText(
                                      textAlign: TextAlign.start,
                                      text: TextSpan(children: <TextSpan>[
                                        TextSpan(
                                            text:
                                                "By continuing , I confirm I have read the ",
                                            style: TextStyle(
                                                color: HexColor('A8A8A8'),
                                                fontSize: 14.0)),
                                        TextSpan(
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // do something here
                                                print("TermsAndConditions");
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            TermsAndConditionsScreen()));
                                              },
                                            text: "Terms and Conditions",
                                            style: TextStyle(
                                                color:
                                                    AppColor.lightSkyBlueColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.0)),
                                        TextSpan(
                                            text: " and",
                                            style: TextStyle(
                                                color: HexColor('A8A8A8'),
                                                fontSize: 14.0)),
                                        TextSpan(
                                            recognizer: TapGestureRecognizer()
                                              ..onTap = () {
                                                // do something here
                                                print("Privacy Policy");
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            PrivacyPolicyScreen()));
                                              },
                                            text: " Privacy Policy",
                                            style: TextStyle(
                                                color:
                                                    AppColor.lightSkyBlueColor,
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.0)),
                                      ]),
                                    )),
                              ),
                            ],
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
                                "SIGN UP",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColor.blueColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              registerAPI();
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        height: 80,
                        width: 80,
                        margin: EdgeInsets.only(right: 40),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(50),
                                  bottomLeft: Radius.circular(50),
                                  bottomRight: Radius.circular(50)),
                              child: Container(
                                color: profileImage == null
                                    ? AppColor.profileBackColor
                                    : null,
                                child: profileImage != null
                                    ? Image.file(
                                        profileImage,
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        "assets/images/doctor_def_circle.png",
                                        height: double.maxFinite,
                                        width: double.maxFinite,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: Colors.white),
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: AppColor.blueColor,
                                  ),
                                ),
                                onTap: () {
                                  ImageHelper().showPhotoBottomDialog(
                                      context, Platform.isIOS, (file) {
                                    setState(() {
                                      profileImage = file;
                                    });
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Roboto_Regular",
                          fontSize: 14,
                          color: AppColor.textGrayColor),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      child: Text(
                        "SIGN IN",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Roboto_Regular",
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColor.blueColor),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
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

  Future<void> registerAPI() async {
    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String email = emailController.text.trim();
    String expirationDate = dateController.text.trim();
    String location = locationController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String specalist = specalistController.text.trim();
    if (profileImage == null) {
      AppHelper.showToastMessage("Please upload profile picture.");
    } else if (firstName.isEmpty) {
      AppHelper.showToastMessage("Please enter first name.");
    } else if (lastName.isEmpty) {
      AppHelper.showToastMessage("Please enter last name.");
    } else if (email.isEmpty) {
      AppHelper.showToastMessage("Please enter email.");
    } else if (!AppHelper.isValidEmail(email)) {
      AppHelper.showToastMessage("Please enter valid email.");
    } else if (expirationDate.isEmpty) {
      AppHelper.showToastMessage("Please select date of license expiration.");
    } else if (location.isEmpty) {
      AppHelper.showToastMessage("Please enter location.");
    } else if (selectedProfessionModel == null) {
      AppHelper.showToastMessage("Please select profession.");
    } else if (specalist.isEmpty) {
      AppHelper.showToastMessage("Please enter specialist.");
    } else if (password.isEmpty) {
      AppHelper.showToastMessage("Please enter password.");
    } else if (confirmPassword.isEmpty) {
      AppHelper.showToastMessage("Please enter confirm password.");
    } else if (password != confirmPassword) {
      AppHelper.showToastMessage("Password & confirm does not match.");
    } else if (document == null) {
      AppHelper.showToastMessage("Please upload document.");
    } else if (!checkBox) {
      AppHelper.showToastMessage("Please check terms & conditions.");
    } else {
      Map<String, String> body = Map();
      body["first_name"] = firstName;
      body["last_name"] = lastName;
      body["email"] = email;
      body["password"] = password;
      body["license_expiry_date"] = expirationDate;
      body["location"] = location;
      body["profession"] = selectedProfessionModel.id.toString();
      body["specialist"] = specalist;
      if (Platform.isIOS) {
        body["apn_token"] = await CallKeep.instance.getDevicePushTokenVoIP();
      } else {
        body["apn_token"] = "";
      }
      body["device_type"] = Platform.isAndroid ? "Android" : "IOS";
      if (FirebasePushNotification.instance().firebaseToken != null) {
        body["firebaseToken"] =
            FirebasePushNotification.instance().firebaseToken;
      }

      Map<String, File> mapOfFilesAndKey = Map();
      mapOfFilesAndKey["profile_picture"] = profileImage;
      mapOfFilesAndKey["license"] = document;

      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.register,
        apiAction: ApiAction.register,
        body: body,
        isMultiPart: true,
        mapOfFilesAndKey: mapOfFilesAndKey,
      );
    }
  }

  @override
  void initState() {
    if (mounted) {
      getProfessionAPI();
    }
    super.initState();
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.register) {
      RegisterModel registerModel = RegisterModel.fromJson(result);
      if (registerModel.success) {
        UserSession userSession =
            UserSession.fromJson(registerModel.data.toJson());

        developer.log("usersession =" + userSession.toJson().toString());
        FirebaseHelper.resetUserCallStatus(userSession.id.toString());
        FirebaseFirestore.instance
            .collection(FirebaseKey.users)
            .doc(userSession.id.toString())
            .set(userSession.toJson())
            .then((value) {
          AppHelper.showToastMessage(registerModel.message);
          AppHelper.saveUserSession(userSession).then((value) {
            appUserSession.value = userSession;
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.DashboardScreen, (route) => false);
          });
        });
      } else {
        AppHelper.showToastMessage(registerModel.message);
      }
    } else if (action == ApiAction.getProfessionList) {
      ProfessionResponse professionResponse =
          ProfessionResponse.fromJson(result);
      if (professionResponse.success) {
        professionList.clear();
        specialistList.clear();
        selectedProfessionModel = null;
        selectedSpecialistModel = null;
        professionResponse.data.forEach((element) {
          professionList.add(ProfessionModel.fromJson(element.toJson()));
        });
        setState(() {});
      } else {
        AppHelper.showToastMessage(professionResponse.message);
      }
    } else if (action == ApiAction.getSpecialist) {
      SpecialistResponse specialistResponse =
          SpecialistResponse.fromJson(result);
      if (specialistResponse.success) {
        specialistList.clear();
        selectedSpecialistModel = null;
        specialistResponse.data.forEach((element) {
          specialistList.add(SpecialistModel.fromJson(element.toJson()));
        });
        setState(() {});
      } else {
        AppHelper.showToastMessage(specialistResponse.message);
      }
    }
  }

  void getSpecialistAPI() {
    Map<String, String> body = Map();
    body["profession_name"] = selectedProfessionModel.professionName;
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.getSpecialist,
        apiAction: ApiAction.getSpecialist,
        body: body);
  }

  void getProfessionAPI() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.getProfessionList,
      apiAction: ApiAction.getProfessionList,
    );
  }
}
