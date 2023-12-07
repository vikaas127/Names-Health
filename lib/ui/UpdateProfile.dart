import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/callBack/HomeScreenCallBack.dart';
import 'package:names/constants/Enums.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/custom_widget/DocumentWidget.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ImageHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/CertificateModel.dart';
import 'package:names/model/ProfessionModel.dart';
import 'package:names/model/ProfessionResponse.dart';
import 'package:names/model/ProfileModel.dart';
import 'package:names/model/SpecialistModel.dart';
import 'package:names/model/SpecialistResponse.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/route/routes.dart';
import 'package:names/ui/CallNotificationPopup.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({Key key}) : super(key: key);

  @override
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile>
    with ApiCallBackListener {
  bool passwordVisible = false;
  bool cnfPasswordVisible = false, socialLogin = false;
  File profileImage;

  TextEditingController nameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  TextEditingController dateController = TextEditingController();

  TextEditingController locationController = TextEditingController();
  TextEditingController specalistController = TextEditingController();
  TextEditingController aboutController = TextEditingController();
  File resume;

  Future<ProfileModel> futureProfile;

  File license;
  List<CertificateModel> certificationList = [];
  List<CertificateModel> qualificationList = [];
  List<CertificateModel> credentialList = [];

  List<CertificateModel> inservicesList = [];

  ProfileModel profileModel;

  int selectedIndex = 0;

  ProfessionModel selectedProfessionModel;

  List<ProfessionModel> professionList = [];

  SpecialistModel selectedSpecialistModel;

  List<SpecialistModel> specialistList = [];
  bool isFirstTime = true;

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
            "Update Profile",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.white),
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
                                    AppColor.blueColor,
                                    AppColor.blueColor
                                  ])),
                            ],
                          ),
                        )
                      : AppHelper.appBar(
                          context,
                          _appBarWidget(context),
                          LinearGradient(colors: [
                            AppColor.blueColor,
                            AppColor.blueColor
                          ])),
              backgroundColor: AppColor.skyBlueColor,
              body: SafeArea(
                  child: GestureDetector(
                child: FutureBuilder<ProfileModel>(
                    future: futureProfile, // async work
                    builder: (BuildContext context,
                        AsyncSnapshot<ProfileModel> snapshot) {
                      if (snapshot.hasData) {
                        ProfileModel profileModel = snapshot.data;

                        return Container(
                          width: AppHelper.getDeviceWidth(context),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: AppColor.blueColor,
                                        borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(25),
                                            bottomRight: Radius.circular(25))),
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Container(
                                      height: 80,
                                      width: 80,
                                      child: Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            child: profileImage != null
                                                ? Image.file(
                                                    profileImage,
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.cover,
                                                  )
                                                : CustomWidget.imageView(
                                                    profileModel
                                                        .data.profilePicture,
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.cover,
                                                    forProfileImage: true),
                                          ),
                                          GestureDetector(
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    color: Colors.white),
                                                alignment: Alignment.center,
                                                child: Icon(
                                                  Icons.camera_alt,
                                                  size: 16,
                                                  color: AppColor.blueColor,
                                                ),
                                                padding: EdgeInsets.all(5),
                                              ),
                                            ),
                                            onTap: () {
                                              ImageHelper()
                                                  .showPhotoBottomDialog(
                                                      context, Platform.isIOS,
                                                      (file) {
                                                setState(() {
                                                  profileImage = file;
                                                });
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics: ClampingScrollPhysics(),
                                  child: Container(
                                    padding: EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          child: TextFormField(
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                              maxLines: null,
                                              controller: nameController,
                                              textInputAction:
                                                  TextInputAction.done,
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15.0),
                                                  ),
                                                  borderSide: BorderSide.none,
                                                ),
                                                hintText: socialLogin
                                                    ? "Full Name"
                                                    : "First Name",
                                                filled: true,
                                                counterText: "",
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                              )),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Visibility(
                                            visible: !socialLogin,
                                            child: Column(
                                              children: [
                                                Container(
                                                  child: TextFormField(
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                      ),
                                                      maxLines: null,
                                                      controller:
                                                          lastnameController,
                                                      textInputAction:
                                                          TextInputAction.done,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .sentences,
                                                      autocorrect: false,
                                                      enableSuggestions: false,
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(
                                                                15.0),
                                                          ),
                                                          borderSide:
                                                              BorderSide.none,
                                                        ),
                                                        hintText: "Last Name",
                                                        filled: true,
                                                        counterText: "",
                                                        contentPadding:
                                                            EdgeInsets.all(8),
                                                        fillColor: Colors.white,
                                                        labelStyle: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                        hintStyle: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      )),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                              ],
                                            )),
                                        Container(
                                          child: TextFormField(
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                              maxLines: null,
                                              readOnly: true,
                                              controller: emailController,
                                              textInputAction:
                                                  TextInputAction.done,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15.0),
                                                  ),
                                                  borderSide: BorderSide.none,
                                                ),
                                                hintText: "Email",
                                                filled: true,
                                                counterText: "",
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                              )),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          child: TextFormField(
                                              maxLines: null,
                                              style: TextStyle(
                                                color: Colors.black,
                                              ),
                                              controller: dateController,
                                              onTap: () async {
                                                FocusScope.of(context)
                                                    .requestFocus(
                                                        new FocusNode());
                                                DateTime date =
                                                    await showDatePicker(
                                                        context: context,
                                                        initialDate:
                                                            DateTime.now(),
                                                        firstDate:
                                                            DateTime.now(),
                                                        lastDate: DateTime(
                                                            DateTime.now()
                                                                    .year +
                                                                10));
                                                if (date != null) {
                                                  dateController.text = date
                                                          .year
                                                          .toString() +
                                                      "-" +
                                                      date.month.toString() +
                                                      "-" +
                                                      date.day.toString();
                                                }
                                              },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15.0),
                                                  ),
                                                  borderSide: BorderSide.none,
                                                ),
                                                counterText: "",
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                hintText:
                                                    "Date of License Expiration",
                                                suffixIcon: Icon(
                                                  Icons.calendar_today,
                                                  color: Colors.black,
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
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
                                              controller: locationController,
                                              textInputAction:
                                                  TextInputAction.done,
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15.0),
                                                  ),
                                                  borderSide: BorderSide.none,
                                                ),
                                                hintText: "Location",
                                                // suffixIcon: Transform.rotate(
                                                //   angle: 90 * pi / 180,
                                                //   child: Icon(
                                                //     Icons.arrow_forward_ios_sharp,
                                                //     color: Colors.black,
                                                //   ),
                                                // ),
                                                filled: true,
                                                counterText: "",
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
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
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child:
                                              DropdownButton<ProfessionModel>(
                                            items: professionList
                                                .map((ProfessionModel value) {
                                              return new DropdownMenuItem<
                                                  ProfessionModel>(
                                                value: value,
                                                child: new Text(
                                                  value.professionName,
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 14),
                                                ),
                                              );
                                            }).toList(),
                                            isExpanded: true,
                                            dropdownColor: Colors.white,
                                            underline: SizedBox(),
                                            hint: Text(
                                              "Select Profession",
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            value: selectedProfessionModel,
                                            icon: Transform.rotate(
                                              angle: 90 * pi / 180,
                                              child: Icon(
                                                Icons.arrow_forward_ios_sharp,
                                                color: Colors.black,
                                              ),
                                            ),
                                            onChanged: (value) {
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
                                                color: Colors.black,
                                              ),
                                              maxLines: null,
                                              controller: specalistController,
                                              textInputAction:
                                                  TextInputAction.done,
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15.0),
                                                  ),
                                                  borderSide: BorderSide.none,
                                                ),
                                                hintText: "Enter Specialist",
                                                filled: true,
                                                counterText: "",
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
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
                                              controller: aboutController,
                                              textInputAction:
                                                  TextInputAction.done,
                                              keyboardType: TextInputType.text,
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              autocorrect: false,
                                              enableSuggestions: false,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(15.0),
                                                  ),
                                                  borderSide: BorderSide.none,
                                                ),
                                                hintText: "Enter Biography",
                                                filled: true,
                                                counterText: "",
                                                contentPadding:
                                                    EdgeInsets.all(8),
                                                fillColor: Colors.white,
                                                labelStyle: TextStyle(
                                                    color: Colors.black),
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                              ),
                                              inputFormatters: [
                                                new LengthLimitingTextInputFormatter(
                                                    100),
                                              ]),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "PLEASE ADD YOUR QUALIFICATIONS :",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Roboto_Regular",
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          child: documentTile(
                                              "Qualifications", context),
                                          onTap: () {
                                            if (qualificationList.length < 5) {
                                              ImageHelper()
                                                  .showPhotoBottomDialog(
                                                      context, Platform.isIOS,
                                                      (file) {
                                                qualificationList.add(
                                                    CertificateModel(
                                                        file,
                                                        null,
                                                        profileModel.data.id,
                                                        null));
                                                setState(() {});
                                              }, allowFile: true);
                                            } else {
                                              AppHelper.showToastMessage(
                                                  "Allow only 5 qualifications");
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        qualificationList.length > 0
                                            ? DocumentWidget(
                                                docList: qualificationList,
                                                docName: "Qualification")
                                            : SizedBox(),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "PLEASE ADD YOUR RESUME :",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Roboto_Regular",
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          child: Container(
                                            width: AppHelper.getDeviceWidth(
                                                context),
                                            height: 80,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 1,
                                                    color: AppColor
                                                        .textGrayColor)),
                                            alignment: Alignment.center,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                resume != null
                                                    ? AppHelper.isImageExist(
                                                            resume.path)
                                                        ? Image.file(
                                                            resume,
                                                            height: 50,
                                                            width: 50,
                                                          )
                                                        : Icon(
                                                            Icons.file_copy,
                                                            size: 40,
                                                            color: AppColor
                                                                .blueColor,
                                                          )
                                                    : profileModel
                                                                .data.resume !=
                                                            null
                                                        ? Icon(
                                                            Icons.file_copy,
                                                            size: 50,
                                                            color: AppColor
                                                                .blueColor,
                                                          )
                                                        : Image.asset(
                                                            "assets/icons/file.png",
                                                            height: 50,
                                                            width: 50,
                                                          ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "Resume",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontFamily: "Lato_Bold"),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            ImageHelper().showPhotoBottomDialog(
                                                context, Platform.isIOS,
                                                (file) {
                                              setState(() {
                                                resume = file;
                                              });
                                            }, allowFile: true);
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "PLEASE ADD YOUR CERTIFICATION :",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Roboto_Regular",
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          child: documentTile(
                                              "Certification", context),
                                          onTap: () {
                                            if (certificationList.length < 5) {
                                              ImageHelper()
                                                  .showPhotoBottomDialog(
                                                      context, Platform.isIOS,
                                                      (file) {
                                                certificationList.add(
                                                    CertificateModel(
                                                        file,
                                                        null,
                                                        profileModel.data.id,
                                                        null));
                                                setState(() {});
                                              }, allowFile: true);
                                            } else {
                                              AppHelper.showToastMessage(
                                                  "Allow only 5 certificates");
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        certificationList.length > 0
                                            ? DocumentWidget(
                                                docList: certificationList,
                                                docName: "Certificate")
                                            : SizedBox(),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "PLEASE ADD YOUR LICENSE :",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Roboto_Regular",
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          child: Container(
                                            width: AppHelper.getDeviceWidth(
                                                context),
                                            height: 80,
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                border: Border.all(
                                                    width: 1,
                                                    color: AppColor
                                                        .textGrayColor)),
                                            alignment: Alignment.center,
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                license != null
                                                    ? AppHelper.isImageExist(
                                                            license.path)
                                                        ? Image.file(
                                                            license,
                                                            height: 50,
                                                            width: 50,
                                                          )
                                                        : Icon(
                                                            Icons.file_copy,
                                                            size: 40,
                                                            color: AppColor
                                                                .blueColor,
                                                          )
                                                    : profileModel
                                                                .data.license !=
                                                            null
                                                        ? Icon(
                                                            Icons.file_copy,
                                                            size: 50,
                                                            color: AppColor
                                                                .blueColor,
                                                          )
                                                        : Image.asset(
                                                            "assets/icons/file.png",
                                                            height: 50,
                                                            width: 50,
                                                          ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  "License",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black,
                                                      fontFamily: "Lato_Bold"),
                                                ),
                                              ],
                                            ),
                                          ),
                                          onTap: () {
                                            ImageHelper().showPhotoBottomDialog(
                                                context, Platform.isIOS,
                                                (file) {
                                              setState(() {
                                                license = file;
                                              });
                                            }, allowFile: true);
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "PLEASE ADD YOUR CREDENTIALS :",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Roboto_Regular",
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          child: documentTile(
                                              "Credentials", context),
                                          onTap: () {
                                            if (credentialList.length < 5) {
                                              ImageHelper()
                                                  .showPhotoBottomDialog(
                                                      context, Platform.isIOS,
                                                      (file) {
                                                credentialList.add(
                                                    CertificateModel(
                                                        file,
                                                        null,
                                                        profileModel.data.id,
                                                        null));
                                                if (mounted) {
                                                  setState(() {});
                                                }
                                              }, allowFile: true);
                                            } else {
                                              AppHelper.showToastMessage(
                                                  "Allow only 5 credentials");
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        credentialList.length > 0
                                            ? DocumentWidget(
                                                docList: credentialList,
                                                docName: "Credential")
                                            : SizedBox(),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "PLEASE ADD YOUR INSERVICES :",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: "Roboto_Regular",
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          child: documentTile(
                                              "Inservices", context),
                                          onTap: () {
                                            if (inservicesList.length < 5) {
                                              ImageHelper()
                                                  .showPhotoBottomDialog(
                                                      context, Platform.isIOS,
                                                      (file) {
                                                inservicesList.add(
                                                    CertificateModel(
                                                        file,
                                                        null,
                                                        profileModel.data.id,
                                                        null));
                                                if (mounted) {
                                                  setState(() {});
                                                }
                                              }, allowFile: true);
                                            } else {
                                              AppHelper.showToastMessage(
                                                  "Allow only 5 inservices");
                                            }
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        inservicesList.length > 0
                                            ? DocumentWidget(
                                                docList: inservicesList,
                                                docName: "Inservice")
                                            : SizedBox(),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        GestureDetector(
                                          child: Container(
                                            width: AppHelper.getDeviceWidth(
                                                context),
                                            height: 50,
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                color:
                                                    AppColor.lightSkyBlueColor),
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
                                            updateAPI();
                                          },
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Visibility(
                                          visible: !socialLogin,
                                          child: GestureDetector(
                                            child: Container(
                                              width: AppHelper.getDeviceWidth(
                                                  context),
                                              height: 50,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 20),
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  color: AppColor.yellowColor),
                                              alignment: Alignment.center,
                                              child: Text(
                                                "CHANGE PASSWORD",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.of(context).pushNamed(
                                                  Routes.ChangePassword);
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ProgressDialog.getCircularProgressIndicator();
                    }),
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
    futureProfile = getProfileAPI();
    super.initState();
  }

  getProfileAPI() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      httpType: HttpMethods.POST,
      showLoader: false,
      url: Url.dashboardProfile,
      apiAction: ApiAction.dashboardProfile,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.dashboardProfile) {
      profileModel = ProfileModel.fromJson(result);
      if (profileModel.success) {
        if (profileModel.data.socialType != null &&
            (profileModel.data.socialType == LoginType.google.name ||
                profileModel.data.socialType == LoginType.linkedin.name)) {
          socialLogin = true;
          nameController.text = profileModel.data.name;
        } else {
          socialLogin = false;
          nameController.text = profileModel.data.firstName;
          lastnameController.text = profileModel.data.lastName;
        }

        aboutController.text = profileModel.data.about;
        emailController.text = profileModel.data.email;
        dateController.text = profileModel.data.licenseExpiryDate;
        locationController.text = profileModel.data.location;
        specalistController.text = profileModel.data.specialist != null
            ? profileModel.data.specialist
            : "";
        // selectedProfessionModel =
        //     ProfessionModel(professionName: profileModel.data.profession);
        // selectedSpecialistModel =
        //     SpecialistModel(specialist: profileModel.data.specialist);

        resume = profileModel.data.resume != null
            ? File(profileModel.data.resume)
            : null;
        license = profileModel.data.license != null
            ? File(profileModel.data.license)
            : null;

        if (profileModel.data.certificate != null) {
          for (int i = 0; i < profileModel.data.certificate.length; i++) {
            certificationList.add(CertificateModel.name(
                File(profileModel.data.certificate[i].document),
                profileModel.data.certificate[i].id,
                profileModel.data.certificate[i].userId,
                profileModel.data.certificate[i].document));
          }
        }
        print(profileModel.data.qualifications);
        if (profileModel.data.qualifications != null) {
          for (int i = 0; i < profileModel.data.qualifications.length; i++) {
            qualificationList.add(CertificateModel.name(
                File(profileModel.data.qualifications[i].document),
                profileModel.data.qualifications[i].id,
                profileModel.data.qualifications[i].userId,
                profileModel.data.qualifications[i].document));
          }
        }
        if (profileModel.data.inservices != null) {
          for (int i = 0; i < profileModel.data.inservices.length; i++) {
            inservicesList.add(CertificateModel.name(
                File(profileModel.data.inservices[i].document),
                profileModel.data.inservices[i].id,
                profileModel.data.inservices[i].userId,
                profileModel.data.inservices[i].document));
          }
        }
        if (profileModel.data.credentials != null) {
          for (int i = 0; i < profileModel.data.credentials.length; i++) {
            credentialList.add(CertificateModel.name(
                File(profileModel.data.credentials[i].document),
                profileModel.data.credentials[i].id,
                profileModel.data.credentials[i].userId,
                profileModel.data.credentials[i].document));
          }
        }
        getProfessionAPI();
        futureProfile = Future.delayed(Duration(seconds: 0), () {
          return profileModel;
        });
        if (mounted) {
          setState(() {});
        }
      } else {
        AppHelper.showToastMessage(profileModel.message);
      }
    } else if (action == ApiAction.updateProfile) {
      ProfileModel profileModel = ProfileModel.fromJson(result);
      if (profileModel.success) {
        UsersModel user = UsersModel.fromJson(result['data']);

        firebaseChatUpdateProfile(user);
        AppHelper.showToastMessage(profileModel.message);
        Navigator.pop(context);
        HomeScreenCallBack.getHomeScreenCallBack().callBack("UPDATE_PROFILE");
      } else {
        AppHelper.showToastMessage(profileModel.message);
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
          ProfessionModel professionModel =
              ProfessionModel.fromJson(element.toJson());
          professionList.add(professionModel);
          if (isFirstTime &&
              profileModel.data.profession == professionModel.professionName) {
            selectedProfessionModel = professionModel;
          }
        });
        if (selectedProfessionModel != null) {
          getSpecialistAPI();
        }
        if (mounted) {
          setState(() {});
        }
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
          SpecialistModel specialistModel =
              SpecialistModel.fromJson(element.toJson());
          specialistList.add(specialistModel);
          if (isFirstTime &&
              profileModel.data.specialist == specialistModel.symbol) {
            selectedSpecialistModel = specialistModel;
            isFirstTime = false;
          }
        });
        if (mounted) {
          setState(() {});
        }
      } else {
        AppHelper.showToastMessage(specialistResponse.message);
      }
    }
  }

  void updateAPI() {
    String fullName = nameController.text.trim();
    String lastname = lastnameController.text.trim();
    String expirationDate = dateController.text.trim();
    String location = locationController.text.trim();
    String specialist = specalistController.text.trim();
    String about = aboutController.text.trim();

    if (fullName.isEmpty) {
      AppHelper.showToastMessage(
          socialLogin ? "Please enter name." : "Please enter first name.");
    } else if (!socialLogin && lastname.isEmpty) {
      AppHelper.showToastMessage("Please enter last name.");
    } else if (selectedProfessionModel == null) {
      AppHelper.showToastMessage("Please select profession.");
    } else {
      Map<String, String> body = Map();
      if (!socialLogin) {
        body["first_name"] = fullName;
        body["last_name"] = lastname;
        body["name"] = fullName + " " + lastname;
      } else {
        body["name"] = fullName;
      }
      body["license_expiry_date"] = expirationDate;
      body["location"] = location;
      body["profession"] = selectedProfessionModel.id.toString();
      body["specialist"] = specialist;
      body["about"] = about;

      Map<String, File> mapOfFilesAndKey = Map();
      if (AppHelper.isFileExist(profileImage)) {
        mapOfFilesAndKey["profile_picture"] = profileImage;
      }
      if (AppHelper.isFileExist(license)) {
        mapOfFilesAndKey["license"] = license;
      }
      if (AppHelper.isFileExist(resume)) {
        mapOfFilesAndKey["resume"] = resume;
      }

      for (int i = 0; i < certificationList.length; i++) {
        if (AppHelper.isFileExist(certificationList[i].file)) {
          mapOfFilesAndKey["certificate[" + i.toString() + "]"] =
              certificationList[i].file;
        }
      }
      for (int i = 0; i < qualificationList.length; i++) {
        if (AppHelper.isFileExist(qualificationList[i].file)) {
          mapOfFilesAndKey["qualification[" + i.toString() + "]"] =
              qualificationList[i].file;
        }
      }
      for (int i = 0; i < credentialList.length; i++) {
        if (AppHelper.isFileExist(credentialList[i].file)) {
          mapOfFilesAndKey["credential[" + i.toString() + "]"] =
              credentialList[i].file;
        }
      }
      for (int i = 0; i < inservicesList.length; i++) {
        if (AppHelper.isFileExist(inservicesList[i].file)) {
          mapOfFilesAndKey["inservice[" + i.toString() + "]"] =
              inservicesList[i].file;
        }
      }

      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.updateProfile,
        apiAction: ApiAction.updateProfile,
        body: body,
        isMultiPart: true,
        mapOfFilesAndKey: mapOfFilesAndKey,
      );
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
      showLoader: false,
      httpType: HttpMethods.POST,
      url: Url.getProfessionList,
      apiAction: ApiAction.getProfessionList,
    );
  }

  firebaseChatUpdateProfile(UsersModel user) {
    FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .where(FirebaseKey.users,
            arrayContains: appUserSession.value.id.toString())
        .get()
        .then((value) {
      for (var element in value.docs) {
        var usersData = element.data()[FirebaseKey.usersData];
        print(usersData.toString());
        if (element.data()[FirebaseKey.users][0] ==
            appUserSession.value.id.toString()) {
          usersData[0] = user.toJson();
        } else {
          usersData[1] = user.toJson();
        }

        FirebaseFirestore.instance
            .collection(FirebaseKey.chatroom)
            .doc(element.id)
            .update({
          FirebaseKey.usersData: usersData,
        });
      }
    });
  }
}
