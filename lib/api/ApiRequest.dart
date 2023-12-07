import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/ui/LoginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import 'Url.dart';
/* Created by Bholendra Singh  */

class ApiRequest {
  JsonDecoder jsonDecoder = new JsonDecoder();
  String url, action = "", httpType = "";
  Map<String, String> headers;
  Map<String, String> body;
  Map<String, dynamic> jsonResult;
  BuildContext context;
  Encoding encoding;
  Duration connectionTimeout = Duration(minutes: 10);
  ApiCallBackListener apiCallBackListener;
  bool showLoader = true;
  bool isMultiPart = false;
  Map<String, File> mapOfFilesAndKey;

  ApiRequest(
      {@required BuildContext context,
      @required ApiCallBackListener apiCallBackListener,
      bool showLoader: true,
      @required String httpType,
      @required String url,
      @required String apiAction,
      Map<String, String> headers,
      Map<String, String> body,
      encoding,
      bool isMultiPart,
      Map<String, File> mapOfFilesAndKey}) {
    this.apiCallBackListener = apiCallBackListener;
    this.url = url;
    this.isMultiPart = isMultiPart;
    this.mapOfFilesAndKey = mapOfFilesAndKey;
    this.body = body;
    this.headers = headers;
    this.encoding = encoding;
    this.context = context;
    this.action = apiAction;
    this.httpType = httpType;
    this.showLoader = showLoader;
    print("url==" + url.toString() + "\nshowLoader==" + showLoader.toString());
    if (context != null) {
      AppHelper.checkInternetConnectivity().then((bool isConnected) async {
        if (isConnected) {
          try {
            if (showLoader) {
              ProgressDialog.show(context);
            }
            String accessToken = "";
            if (appUserSession.value != null &&
                appUserSession.value.token != null &&
                appUserSession.value.token.isNotEmpty) {
              accessToken = appUserSession.value.token;
            }
            headers = getApiHeader(accessToken);
            if (isMultiPart != null && isMultiPart) {
              getAPIMultiRequest(url,
                  headers: headers,
                  body: body,
                  encoding: encoding,
                  mapOfFilesAndKey: mapOfFilesAndKey);
            } else {
              getAPIRequest(url,
                  headers: headers, body: body, encoding: encoding);
            }
          } catch (onError) {
            print(onError.toString());
          }
        } else {
          AppHelper.showToastMessage("No Internet Connection.");
        }
      });
    }
  }

  getAPIRequest(String url,
      {Map<String, String> headers, body, encoding}) async {
    print(
        "\n****************************API REQUEST************************************\n");
    print("\nApiRequest_url===" + url.toString());
    print("\nApiRequest_headers===" + headers.toString());
    print("\nApiRequest_body===" + body.toString());
    print(
        "\n****************************API REQUEST************************************\n");
    AppHelper.hideKeyBoard(context);
    Uri uri = Uri.parse(url);
    if (this.httpType == HttpMethods.GET) {
      return http
          .get(
            uri,
            headers: headers,
          )
          .then(httpResponse)
          .catchError(httpCatch)
          .timeout(connectionTimeout, onTimeout: () {
        apiTimeOut();
      });
    } else if (this.httpType == HttpMethods.POST) {
      return http
          .post(uri, headers: headers, body: body)
          .then(httpResponse)
          .catchError(httpCatch)
          .timeout(connectionTimeout, onTimeout: () {
        apiTimeOut();
      });
    } else if (this.httpType == HttpMethods.PUT) {
      return http
          .put(uri, headers: headers, body: body)
          .then(httpResponse)
          .catchError(httpCatch)
          .timeout(connectionTimeout, onTimeout: () {
        apiTimeOut();
      });
    } else if (this.httpType == HttpMethods.DELETE) {
      return http
          .delete(uri, headers: headers)
          .then(httpResponse)
          .catchError(httpCatch)
          .timeout(connectionTimeout, onTimeout: () {
        apiTimeOut();
      });
    } else if (this.httpType == HttpMethods.PATCH) {
      return http
          .patch(uri, headers: headers, body: body)
          .then(httpResponse)
          .catchError(httpCatch)
          .timeout(connectionTimeout, onTimeout: () {
        apiTimeOut();
      });
    }
  }

  httpCatch(onError) {
    if (showLoader) {
      ProgressDialog.hide();
    }
    print("httpCatch===" + onError.toString());
    AppHelper.showToastMessage("Oops! Something went wrong.");
  }

  FutureOr httpResponse(Response response) {
    try {
      if (showLoader) {
        ProgressDialog.hide();
      }
      var res = response.body;
      var statusCode = response.statusCode;
      jsonResult = jsonDecoder.convert(res);
      if (statusCode == 401) {
        print(
            "\n****************************401 API RESPONSE************************************\n");

        print("\n\nApiRequest_HTTP_RESPONSE===" + jsonResult.toString());
        log("\n\nApiRequest_HTTP_BODY_RESPONSE===" + res);
        print("\n\nApiRequest_HTTP_RESPONSE_CODE===" + statusCode.toString());

        if (jsonResult != null && jsonResult['message'] != null) {
          AppHelper.showToastMessage(jsonResult['message'].toString());
        }
        print("error===");
        logout();
        return null;
      }

      print(
          "\n****************************API RESPONSE************************************\n");

      print("\n\nApiRequest_HTTP_RESPONSE===" + jsonResult.toString());
      log("\n\nApiRequest_HTTP_BODY_RESPONSE===" + res);
      print("\n\nApiRequest_HTTP_RESPONSE_CODE===" + statusCode.toString());

      print(
          "\n****************************API RESPONSE************************************\n");

      if (jsonResult != null) {
        print("success===" + jsonResult.toString());
        return apiCallBackListener.apiCallBackListener(action, jsonResult);
      } else {
        if (jsonResult != null && jsonResult['message'] != null) {
          AppHelper.showToastMessage(jsonResult['message'].toString());
        }
      }
    } catch (onError) {
      httpCatch(onError);
    }
  }

  Future uploadImage(BuildContext context,
      ApiCallBackListener apiCallBackListener, String url, String action,
      {Map<String, String> headers, body, encoding}) async {
    this.apiCallBackListener = apiCallBackListener;
    this.url = url;
    this.body = body;
    this.headers = headers;
    this.encoding = encoding;
    this.context = context;
    this.action = action;
    try {
      ProgressDialog.show(context);
    } catch (onError) {
      print(onError.toString());
    }
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // this.headers = getApiHeader(prefs.getString(Constants.ACCESS_TOKEN));
    var uri = Uri.parse(url);
    var request = new MultipartRequest("POST", uri);
    var multipartFile = await MultipartFile.fromPath("file", body);
    request.files.add(multipartFile);

    StreamedResponse response = await request.send();
    response.stream.transform(utf8.decoder).listen((value) {
      apiCallBackListener.apiCallBackListener(action, value);
      print(value);
    });
  }

  apiTimeOut() {
    if (showLoader) {
      ProgressDialog.hide();
    }
    print('Please try again .');
    AppHelper.showToastMessage("Connection timeout Please try again...");
  }

  void logoutApi() {
    String accessToken = "";
    if (appUserSession.value != null &&
        appUserSession.value.token != null &&
        appUserSession.value.token.isNotEmpty) {
      accessToken = appUserSession.value.token;
    }
    headers = getApiHeader(accessToken);
    print(
        "\n****************************API REQUEST************************************\n");
    print("\nApiRequest_url===" + url.toString());
    print("\nApiRequest_headers===" + headers.toString());
    print("\nApiRequest_body===" + body.toString());
    print(
        "\n****************************API REQUEST************************************\n");
    http
        .post(Uri.parse(Url.logout), headers: headers, body: null)
        .then((response) {
          try {
            if (showLoader) {
              ProgressDialog.hide();
            }
            var res = response.body;
            var statusCode = response.statusCode;
            /*if (statusCode == 401) {
          print("error===");
          logout();
          return null;
        }*/
            jsonResult = jsonDecoder.convert(res);

            print(
                "\n****************************Logout API RESPONSE************************************\n");

            print("\n\nApiRequest_HTTP_RESPONSE===" + jsonResult.toString());
            log("\n\nApiRequest_HTTP_BODY_RESPONSE===" + res);
            print(
                "\n\nApiRequest_HTTP_RESPONSE_CODE===" + statusCode.toString());

            print(
                "\n****************************API RESPONSE************************************\n");

            if (jsonResult != null) {
              print("success===" + jsonResult.toString());
              logout();
              // return apiCallBackListener.apiCallBackListener(action, jsonResult);
            } else {
              if (jsonResult != null && jsonResult['message'] != null) {
                AppHelper.showToastMessage(jsonResult['message'].toString());
              }
            }
          } catch (onError) {
            httpCatch(onError);
          }
        })
        .catchError(httpCatch)
        .timeout(connectionTimeout, onTimeout: () {
          apiTimeOut();
        });
  }

  Future logout() async {
    print('logout');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (appUserSession != null &&
        appUserSession.value != null &&
        appUserSession.value.id != null) {
      FirebaseFirestore.instance
          .collection(FirebaseKey.usersStatus)
          .doc(appUserSession.value.id.toString())
          .set({
        FirebaseKey.isOnline: false,
        FirebaseKey.offlineTime: FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    appUserSession.value = null;
    appProfileModel.value = null;
    print("12341 ");
    await FirebaseAuth.instance.signOut().then((value) {
      print("12341 ");
      prefs.clear();
      print("12341 ");
      new GoogleSignIn().signOut();
      print("google logout successfull");
      Navigator.pushAndRemoveUntil<void>(context,
          MaterialPageRoute(builder: (_) => LoginScreen()), (_) => false);
    });
  }

  Map<String, String> getApiHeader(String accessToken) {
    return {
      HttpHeaders.acceptHeader: 'application/json',
      // HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "Bearer " + accessToken,
    };
  }

  Future getAPIMultiRequest(String url,
      {Map<String, String> headers,
      body,
      encoding,
      Map<String, File> mapOfFilesAndKey}) async {
    print(
        "\n****************************API REQUEST************************************\n");
    print("\nApiRequest_url===" + url.toString());
    print("\nApiRequest_headers===" + headers.toString());
    print("\nApiRequest_body===" + body.toString());
    print(
        "\n****************************API REQUEST************************************\n");
    var uri = Uri.parse(url);
    var request = new MultipartRequest(httpType, uri);

    List<String> keysForImage = [];
    for (int i = 0; i < mapOfFilesAndKey.length; i++) {
      String key = mapOfFilesAndKey.keys.elementAt(i);
      keysForImage.add(key);
    }

    if (body != null) {
      for (int i = 0; i < body.length; i++) {
        String key = body.keys.elementAt(i);
        request.fields[key] = body[key];
      }
    }

    for (int i = 0; i < keysForImage.length; i++) {
      var multipartFile = await MultipartFile.fromPath(
          keysForImage[i], mapOfFilesAndKey[keysForImage[i]].path);
      request.files.add(multipartFile);
    }

    for (var filesdata in request.files) {
      print("filesdata==" + filesdata.field.toString());
      print("filesdata==" + filesdata.filename.toString());
      print("filesdata==" + filesdata.contentType.toString());
      print("filesdata==" + filesdata.toString());
    }

    print("request.files=" + request.files.toString());
    print("request.send=" + request.fields.toString());
    print("request.send=" + request.toString());

    request.headers.addAll(headers);
    http.Response.fromStream(await request.send())
        .then(httpResponse)
        .catchError(httpCatch)
        .timeout(connectionTimeout, onTimeout: () {
      apiTimeOut();
    });
  }
}
