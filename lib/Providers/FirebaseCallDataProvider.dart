import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/model/CallStatusModel.dart';

class FirebaseCallDataProvider extends ChangeNotifier {
  CallStatusModel callStatus;

  void getuserCallStatus(String userId) {
    print("-----------------------hello--------------------");
    FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
        .doc(userId)
        .snapshots()
        .listen((event) {
      if (event.data() != null) {
        print("------------event----------------");
        callStatus = CallStatusModel.fromMap(event.data());
        print(" call from status data " + callStatus.toJson().toString());
      }

      notifyListeners();
    });
  }
}
