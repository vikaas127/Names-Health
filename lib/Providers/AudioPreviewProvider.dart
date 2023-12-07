import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/CallStatusEnum.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/100msTokenModel.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/ChatModel.dart';
import 'package:names/ui/Calling/AudioCallScreen.dart';

class AudioPreviewProvider extends ChangeNotifier with ApiCallBackListener {
  BuildContext context;
  String otherUserId;
  String apntoken;
  String username;
  String devicetype;
  String otherUsername;
  String profilePicture;
  bool isDisposed = false;
  bool notificationSend = false;
  String hmstoken;
  bool isAvailable = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubcription;
  Timer timer;
  addMissedCallChat() async {
    String userId = otherUserId;
    ChatModel chatModel = ChatModel(
        null,
        "Missed Voice Call",
        null,
        appUserSession.value.id.toString(),
        otherUserId,
        FieldValue.serverTimestamp(),
        'Call',
        true,
        false,
        [appUserSession.value.id.toString()]);
    Map<String, dynamic> usersCountMap = Map();
    usersCountMap[userId] = FieldValue.increment(1);

    await FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .doc(AppHelper.getChatID(
            appUserSession.value.id.toString(), otherUserId))
        .collection(FirebaseKey.messages)
        .add(chatModel.toJson())
        .then((value) {
      FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(), userId))
          .collection(FirebaseKey.messages)
          .doc(value.id)
          .update({
        FirebaseKey.messageID: value.id,
      }).then((valuess) {
        FirebaseFirestore.instance
            .collection(FirebaseKey.chatroom)
            .doc(
                AppHelper.getChatID(appUserSession.value.id.toString(), userId))
            .set({
          FirebaseKey.lastMessage: chatModel.toJsonAddId(value.id),
          FirebaseKey.unreadCount: usersCountMap,
        }, SetOptions(merge: true));
      });
    });
  }
  void resetData() {
    notificationSend = false;
    context = null;
    otherUserId = null;
    hmstoken = null;
    isAvailable = true;
    otherUsername = null;
    profilePicture = null;
    timer.cancel();
  }
  void leaveMeeting() {
    AppHelper.stopRingtone();
    print("Stoppped");
    if (streamSubcription != null) {
      streamSubcription.cancel();
    }
    notifyListeners();
  }
  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }
  void generate100msTokenAPI() {
    Map<String, String> map = {};
    map['call_type'] = '2';

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.generate100msToken,
        apiAction: ApiAction.generate100msToken,
        body: map);
  }

  void sendCallNotificationAPI(String roomId, String token) {
    Map<String, String> map = {};
    map['room_id'] = roomId;
    map['user_ids'] = json.encode([otherUserId]);
    map['ms_token'] = token;
    map['call_type'] = '2';
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.sendCallNotification,
        apiAction: ApiAction.sendCallNotification,
        body: map);
  }
  void listenToTheChanges() {
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (!isDisposed) {
        FirebaseHelper.callRejected(otherUserId);
        addMissedCallChat();
        FirebaseHelper.resetUserCallStatus(appUserSession.value.id.toString());
        FirebaseHelper.resetUserCallStatus(otherUserId);
      }
    });

    streamSubcription =
        FirebaseHelper.getuserCallStatus(otherUserId).listen((event) {
      if (event.data() != null) {
        print(otherUserId);
        final callStatus = CallStatusModel.fromMap(event.data());
        print(callStatus.toJson());

        if (callStatus.callStatus == "accepted") {
          leaveMeeting();
          FirebaseHelper.callAccepted(appUserSession.value.id.toString());
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => AudioCallScreen(
                      )));
        } else if (callStatus.callStatus == "rejected") {
          leaveMeeting();
          if (!isDisposed) {
            Navigator.of(context).pop();
          }
        }
      }
    });
  }
  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.generate100msToken) {
      HmsTokenDetailModel hmsTokenDetailModel =
          HmsTokenDetailModel.fromMap(result);
      if (hmsTokenDetailModel.success) {
        hmstoken = hmsTokenDetailModel.token;
        FirebaseHelper.isUserAvailable(otherUserId).then(
          (value) {
            print("-------------------user available----------------------");
           print("otheruserid"+otherUserId);
           print("Userid"+appUserSession.value.id.toString());
            print(devicetype );
            print(apntoken);
           // devicetype="IOS";
           // apntoken="8030b1dd235157b94ddf95c28efe21dab4956edfac80c4d8f5ec2f9a53f778c7f5697756b88a59949d7a4aded1aab9359d96b8649cce0331b55957b9f32c0edf45fcaa08c7f484435e13f335a2175472";
            if (value != null && value) {
              if(devicetype=="IOS" && apntoken!=null && devicetype!=null){
                //print();
                HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
                  'sendNotification',
                  options: HttpsCallableOptions(),
                );

                try {
                  final token = apntoken;
                  if (token != null) {
                    callable.call(<String, dynamic>{
                      'id':otherUserId,
                      'token': token,
                      'callerName':username,
                      'isVideo':false,
                      'callerId':appUserSession.value.id
                    });
                    FirebaseHelper.updateUserCallStatusFromNotification(
                        appUserSession.value.id.toString(), int.parse(otherUserId),
                        token: hmstoken,
                        callFrom: otherUsername,
                        calltype: 2,
                        callerPhoto: profilePicture);
                    FirebaseHelper.updateUserCallStatusFromNotification(
                        otherUserId, appUserSession.value.id,
                        token: hmstoken,
                        callFrom:
                        appUserSession.value.firstName ?? appUserSession.value.name,
                        calltype: 2,
                        callerPhoto: appUserSession.value.profilePicture);
                    print("${token}");
                    notificationSend = true;
                    AppHelper.callRingtone();
                    notifyListeners();
                    listenToTheChanges();
                    AppHelper.playRingtone();
                    notifyListeners();
                  }
                } on FirebaseFunctionsException catch (e) {
                  print(e.message.toString());
                } catch (e) {
                  print(e.toString());
                }
              }
              else if(devicetype!="IOS") {
                sendCallNotificationAPI(hmsTokenDetailModel.roomId, hmsTokenDetailModel.token);
              }
            } else {
              isAvailable = false;
              notificationSend = true;
              notifyListeners();
              Future.delayed(Duration(seconds: 4), (() {
                leaveMeeting();
                if (!isDisposed) {
                  print("-------------------user available----------------------");
                  Navigator.of(context).pop();
                }
              }));
            }
          },
        );
      } else {
        AppHelper.showToastMessage(hmsTokenDetailModel.message);
      }
    } else if (action == ApiAction.sendCallNotification) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        FirebaseHelper.updateUserCallStatusFromNotification(
            appUserSession.value.id.toString(), int.parse(otherUserId),
            token: hmstoken,
            callFrom: otherUsername,
            calltype: 2,
            callerPhoto: profilePicture);
        FirebaseHelper.updateUserCallStatusFromNotification(
            otherUserId, appUserSession.value.id,

            token: hmstoken,
            callFrom:
                appUserSession.value.firstName ?? appUserSession.value.name,
            calltype: 2,
            callerPhoto: appUserSession.value.profilePicture);
        notificationSend = true;
        AppHelper.callRingtone();
        notifyListeners();
        listenToTheChanges();
        AppHelper.playRingtone();
      }
    }
  }
}
