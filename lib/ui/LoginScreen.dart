import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linkedin_login/linkedin_login.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/app/FirebasePushNotification.dart';
import 'package:names/constants/Enums.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:names/model/LoginModel.dart';
import 'package:names/model/UserSession.dart';
import 'package:names/route/routes.dart';

import 'dart:io' show Platform;
import 'package:crypto/crypto.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with ApiCallBackListener {
  bool passwordVisible = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount googleSignInAccount;
  String storeDeviceapnToken;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.skyBlueColor,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        //set your own hight for appbar.
        child: AppBar(
            elevation: 0,
            brightness: Brightness.light,

            //Brightness.light = Dark icon
            //Brghtness.dark = Light icon

            backgroundColor: AppColor.skyBlueColor,
            title: Text("Statusbar Color")
            //if you want to set title

            ),
      ),
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
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: "Roboto_Bold", fontSize: 26),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Login back into your account",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: "Roboto_Regular",
                      fontSize: 16,
                      color: AppColor.textGrayColor),
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
                        "Login",
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
                              counterText: "",
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
                              contentPadding: EdgeInsets.all(10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                                borderSide: BorderSide.none,
                              ),
                              hintText: "Password",
                              counterText: "",
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
                              fillColor: AppColor.blueBoxColor,
                              labelStyle: TextStyle(color: Colors.white),
                              hintStyle: TextStyle(color: Colors.white),
                            )),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          child: Text(
                            "Forgot Password?",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: "Roboto_Regular",
                                fontSize: 16,
                                color: Colors.white),
                          ),
                          onTap: () {
                            Navigator.of(context)
                                .pushNamed(Routes.ForgotScreen)
                                .then((value) {
                              if (value != null && value) {
                                String email = emailController.text.trim();
                                String pass = passwordController.text.trim();
                                if (email.isNotEmpty || pass.isNotEmpty) {
                                  setState(() {
                                    emailController.text = "";
                                    passwordController.text = "";
                                  });
                                }
                              }
                            });
                          },
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
                            "SIGN IN",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColor.blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () {
                          String email = emailController.text.trim();
                          String password = passwordController.text.trim();
                          loginAPI(context, email, password,
                              LoginType.normal.name, "", "");
                        },
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          "or login with",
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                              onTap: () {
                                signInWithGoogle(context);
                              },
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.white),
                                alignment: Alignment.center,
                                child: Image.asset("assets/icons/google.png"),
                                padding: EdgeInsets.all(8),
                              )),
                          SizedBox(
                            width: 20,
                          ),
                          SignInButton(
                            Buttons.LinkedIn,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(60)),
                            mini: true,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      LinkedInUserWidget(
                                    appBar: AppBar(
                                      title: Text("Names"),
                                    ),
                                    destroySession: true,
                                    // redirectUrl: FirebaseKey.redirectUrl,
                                    redirectUrl: FirebaseKey.redirectUrl,
                                    clientId: FirebaseKey.clientId,
                                    clientSecret: FirebaseKey.clientSecret,
                                    projection: [
                                      ProjectionParameters.id,
                                      ProjectionParameters.localizedFirstName,
                                      ProjectionParameters.localizedLastName,
                                      ProjectionParameters.firstName,
                                      ProjectionParameters.lastName,
                                      ProjectionParameters.profilePicture,
                                    ],
                                    onError: (UserFailedAction e) {
                                      print('Error: ${e.toString()}');
                                      print(
                                          'Error: ${e.stackTrace.toString()}');
                                    },
                                    onGetUserProfile:
                                        (UserSucceededAction linkedInUser) {
                                      print(
                                          'Access token ${linkedInUser.user.token.accessToken}');

                                      print(
                                          'User id: ${linkedInUser.user.userId}');
                                      print(
                                          'User firstName: ${linkedInUser?.user?.firstName?.localized?.label}');
                                      // String name=
                                      loginAPI(
                                          context,
                                          linkedInUser?.user?.email?.elements[0]
                                              ?.handleDeep?.emailAddress,
                                          "",
                                          LoginType.linkedin.name,
                                          linkedInUser.user.userId,
                                          linkedInUser?.user?.firstName
                                              ?.localized?.label);
                                      /*user = UserObject(
                                        firstName:
                                        linkedInUser?.user?.firstName?.localized?.label,
                                        lastName:
                                        linkedInUser?.user?.lastName?.localized?.label,
                                        email: linkedInUser?.user?.email?.elements[0]
                                            ?.handleDeep?.emailAddress,
                                        profileImageUrl: linkedInUser
                                            ?.user
                                            ?.profilePicture
                                            ?.displayImageContent
                                            ?.elements[0]
                                            ?.identifiers[0]
                                            ?.identifier,
                                      );*/

                                      /*setState(() {
                                        logoutUser = false;
                                      });*/

                                      Navigator.pop(context);
                                    },
                                  ),
                                  fullscreenDialog: true,
                                ),
                              );
                            },
                          ),
                          Visibility(
                            visible: Platform.isIOS,
                            // visible: false,
                            child: Container(
                              margin: EdgeInsets.only(left: 13),
                              child: SignInButton(
                                Buttons.Apple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(60)),
                                mini: true,
                                onPressed: () {
                                  appleLogin();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: "Roboto_Regular",
                          fontSize: 16,
                          color: AppColor.textGrayColor),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    GestureDetector(
                      child: Text(
                        "SIGN UP",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: "Roboto_Regular",
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColor.blueColor),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(Routes.RegisterScreen);
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

  Future<void> loginAPI(BuildContext context, String email, String password,
      String type, String social_id, String name) async {
    print("loginAPI called");
    if (email.isEmpty) {
      AppHelper.showToastMessage("Please enter email.");
    } else if (!AppHelper.isValidEmail(email)) {
      AppHelper.showToastMessage("Please enter valid email.");
    } /*else if (password.isEmpty) {
      AppHelper.showToastMessage("Please enter password.");
    } */
    else {
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      messaging.getToken().then((token) {
        String deviceToken = token;
        storeDeviceapnToken = token??"";
        print('-------------------------------Device Token: $deviceToken');
      });
      Map<String, String> body = Map();
      body["email"] = email;
      body["password"] = password;
      body["type"] = type;
      if(Platform.isIOS){
        body["apn_token"]= await CallKeep.instance.getDevicePushTokenVoIP();
      }
      else{
      body["apn_token"]= storeDeviceapnToken;
      }

      body["device_type"] = Platform.isAndroid?"Android":"IOS";
      if (type == LoginType.google.name ||
          type == LoginType.linkedin.name ||
          type == LoginType.ios.name) {
        body["social_id"] = social_id;

        body["name"] = name;
      }
      print("firebaseToken=" + FirebasePushNotification.instance().firebaseToken.toString());

      if (FirebasePushNotification.instance().firebaseToken != null) {
        body["firebaseToken"] = FirebasePushNotification.instance().firebaseToken;
      }

      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.login,
        apiAction: ApiAction.login,
        body: body,
      );
    }
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.login) {
      ProgressDialog.show(context);

      LoginModel loginModel = LoginModel.fromJson(result);
      if (loginModel.success) {
        print("Login  data" + loginModel.data.toJson().toString());
        UserSession userSession =
            UserSession.fromJson(loginModel.data.toJson());
        userSession.firebaseToken = FirebasePushNotification.instance().firebaseToken;
        FirebaseHelper.resetUserCallStatus(userSession.id.toString());
        FirebaseFirestore.instance
            .collection(FirebaseKey.users)
            .doc(userSession.id.toString())
            .set(userSession.toJson())
            .then((value) {
          AppHelper.showToastMessage(loginModel.message);
          AppHelper.saveUserSession(userSession).then((value) {
            appUserSession.value = userSession;
            ProgressDialog.hide();
            Navigator.of(context).pushNamedAndRemoveUntil(
                Routes.DashboardScreen, (route) => false);
          });
        });
      } else {
        ProgressDialog.hide();
        AppHelper.showToastMessage(loginModel.message);
      }
    }
  }

  void signInWithGoogle(BuildContext context) async {
    ProgressDialog.show(context);
    if (googleSignInAccount != null) {
      await _googleSignIn.disconnect();
      await _auth.signOut();
    }

    googleSignInAccount = await _googleSignIn.signIn();

    if (googleSignInAccount != null) {
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      _auth.signInWithCredential(credential).then((UserCredential result) {
        ProgressDialog.hide();
        // afterLogIn(context,result.user,Constants.USER);
        print("UserCredential afterLogIn=" + result.user.toString());
        print("result.user.email=" + result.user.email.toString());
        loginAPI(context, result.user.email, "", LoginType.google.name,
            result.user.uid, result.user.displayName);
      }).catchError((e) {
        print(e.toString());
        String errorMessage;
        switch (e.code) {
          case "ERROR_INVALID_EMAIL":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "ERROR_WRONG_PASSWORD":
            errorMessage = "Your password is wrong.";
            break;
          case "ERROR_USER_NOT_FOUND":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "ERROR_USER_DISABLED":
            errorMessage = "User with this email has been disabled.";
            break;
          case "ERROR_TOO_MANY_REQUESTS":
            errorMessage = "Too many requests. Try again later.";
            break;
          case "ERROR_OPERATION_NOT_ALLOWED":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        if (errorMessage != null) {
          AppHelper.showToastMessage(errorMessage);
        }

        ProgressDialog.hide();
      });
    } else {
      ProgressDialog.hide();
      /* Future.delayed(Duration(seconds: 1)).then((valuess) {
        ProgressDialog.hide();
      });*/
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> appleLogin() async {
    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      print("-------------------started ------------------");

      // Request credential for the currently signed in Apple account.
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      // Create an `OAuthCredential` from the credential returned by Apple.
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
        rawNonce: rawNonce,
      );
      final fixDisplayNameFromApple = [
        appleCredential.givenName ?? '',
        appleCredential.familyName ?? '',
      ].join(' ').trim();

      await _auth.signInWithCredential(oauthCredential);

      User user = FirebaseAuth.instance.currentUser;

      if (fixDisplayNameFromApple != null &&
          fixDisplayNameFromApple != ' ' &&
          user.displayName == null) {
        await user.updateDisplayName(fixDisplayNameFromApple);
        await user.reload();
      }
      user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        if (user.displayName == null ||
            user.displayName == '' ||
            user.displayName == ' ') {
          ProgressDialog.show(context);
          showNameBottomDialog(context, 'apple');
        } else {
          final user = FirebaseAuth.instance.currentUser;
          loginAPI(context, user.email, "", LoginType.ios.name, user.uid,
              user.displayName);
        }
      }
    } on FirebaseAuthException catch (e) {
      AppHelper.showToastMessage(e.message.toString());
      print('Firebase auth error');
      print(e);
      // AppHelper.showToastMessage(e.toString());
    } catch (e) {
      print(e.toString());

      // AppHelper.showToastMessage(e.toString());
    }

    return null;
  }

  void showNameBottomDialog(BuildContext context, String loginType) {
    showDialog(
        context: context,
        builder: (ctx) {
          ProgressDialog.hide();
          return AlertDialog(
            insetPadding: EdgeInsets.symmetric(
              horizontal: 15.0,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            title: Center(
              child: Column(children: [
                Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: Colors.cyan,
                                borderRadius: BorderRadius.circular(15)),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            )))),
              ]),
            ),
            content: Container(
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width - 60.0,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: ListView(
                children: [
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Full Name",
                      filled: true,
                      fillColor: Colors.grey[300],
                      labelStyle: TextStyle(color: Colors.black),
                      hintStyle: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        AppHelper.showToastMessage('Please enter Full Name');
                      } else {
                        Navigator.of(ctx).pop();
                        print(FirebaseAuth.instance.currentUser.displayName);
                        try {
                          await FirebaseAuth.instance.currentUser
                              .updateDisplayName(name);
                          final user = FirebaseAuth.instance.currentUser;
                          loginAPI(context, user.email, "", LoginType.ios.name,
                              user.uid, user.displayName);
                        } on FirebaseAuthException catch (e) {
                          AppHelper.showToastMessage(e.message.toString());
                        } catch (e) {}
                      }
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.35,
                      height: 40.0,
                      decoration: BoxDecoration(
                          color: AppColor.blueColor,
                          borderRadius: BorderRadius.circular(100.0)),
                      child: Center(
                          child: Text('Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                              ))),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
