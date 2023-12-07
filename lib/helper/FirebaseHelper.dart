import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/GroupDataModel.dart';

import '../main.dart';

class FirebaseHelper with ChangeNotifier {
  static Stream<DocumentSnapshot<Map<String, dynamic>>> getuserCallStatus(String userId)
  {
    return FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .snapshots();
  }

  static Future<bool> isUserAvailable(String userId) async {
    final value = await FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .get();

    if (value.exists) {
      if (value.data() != null) {
        final callstatus = CallStatusModel.fromMap(value.data());
        if (callstatus.onCall) {
          return false;
        }
        return true;
      }
      return true;
    }
    return true;
  }

  static Future<void> updateUserCallStatusFromNotification(
      String userId, int callerId,
      {
      String token = "",
      String callFrom = "",
      int calltype = 1,
      String callerPhoto = ""}) async {
    await FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .set({
      "token": token,
      "callFrom": callFrom,
      "onCall": false,
      "stopRinging": false,
      "callType": calltype,
      "callerPhoto": callerPhoto,
      "callerId": callerId
    }, SetOptions(merge: true));
  }
  static Future<void> updateUserCallRingingStatusFromNotification(String userId) async {
   print("notification callStatus"+userId.toString());
    await FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .set({
      "callStatus": "ringing",


    }, SetOptions(merge: true));

  }

  static Future<void> resetUserCallStatus(String userId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .set({
      "token": "",
      "callFrom": "",
      "callStatus": "",
      "onCall": false,
      "stopRinging": true,
      "callerPhoto": "",
      "callerId": null
    }, SetOptions(merge: true));
  }

  // static Future<void> updateRingingStatus(String userId) async {
  //   await FirebaseFirestore.instance
  //       .collection(FirebaseKey.usersCallStatus)
  //       .doc(userId)
  //       .set({"ringing": false}, SetOptions(merge: true));
  // }

  static Future<void> callAccepted(String userId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .set({
      "callStatus": "accepted",
      "onCall": true,

    }, SetOptions(merge: true));

  }

  static Future<void> callRejected(String userId) async {
    await FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .set({
      "callStatus": "rejected",
      "stopRinging": true,
    }, SetOptions(merge: true));
  }

  void getUserMessageCount() {
    int chat = 0;
    int group = 0;
    FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .where(FirebaseKey.users,
            arrayContains: appUserSession.value.id.toString())
        .snapshots()
        .listen((event) {
      chat = 0;
      messageCount.value = 0;
      for (var element in event.docs) {
        print('-------------------user---------------------');
        // if (element.data()[FirebaseKey.unreadCount == null])
        // //[appUserSession.value.id.toString()] > 0)
        // {
        //   // [appUserSession.value.id.toString()] > 0) {
        //   print("ghkgfhgf");
        //   chat++;
        //   messageCount.value = chat + group;
        //   notifyListeners();
        // }else
        if (element.data()[FirebaseKey.unreadCount] != null) {
          var unreadCount = element.data()[FirebaseKey.unreadCount];
          var userId = appUserSession.value.id.toString();

          if (unreadCount[userId] != null && unreadCount[userId] > 0) {
            // Your code here
            print("ghkgfhgf");
            chat++;
            messageCount.value = chat + group;
            notifyListeners();
          }else {
            print("-------------else----------------");
            messageCount.value = chat + group;
            print(chat);
            print(group);
            print(messageCount.value);
            notifyListeners();
          }
        }
        //   if (element.data()[FirebaseKey.unreadCount]
        //         [appUserSession.value.id.toString()] > 0) {
        //        // [appUserSession.value.id.toString()] > 0) {
        //   print("ghkgfhgf");
        //   chat++;
        //   messageCount.value = chat + group;
        //   notifyListeners();
        // } else {
        //   print("-------------else----------------");
        //   messageCount.value = chat + group;
        //   print(chat);
        //   print(group);
        //   print(messageCount.value);
        //   notifyListeners();
        // }
      }
      notifyListeners();
    });
    FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .where(FirebaseKey.users,
            arrayContains: appUserSession.value.id.toString())
        .snapshots()
        .listen((event) {
      group = 0;
      messageCount.value = 0;
      for (var element in event.docs) {
        GroupDataModel groupDataModel = GroupDataModel.fromJson(element.data());
        if (groupDataModel.deleted_user.isEmpty) {
          if (element.data()[FirebaseKey.unreadCount]
                  [appUserSession.value.id.toString()] >
              0) {
            group++;
            messageCount.value = chat + group;
            notifyListeners();
          } else {
            messageCount.value = chat + group;

            notifyListeners();
          }
        } else if (groupDataModel.deleted_user.isNotEmpty &&
            !groupDataModel.deleted_user.contains(appUserSession.value.id)) {
          if (element.data()[FirebaseKey.unreadCount]
                  [appUserSession.value.id.toString()] >
              0) {
            group++;
            messageCount.value = chat + group;
            notifyListeners();
          } else {
            messageCount.value = chat + group;

            notifyListeners();
          }
        }
      }
      notifyListeners();
    });
  }
}
