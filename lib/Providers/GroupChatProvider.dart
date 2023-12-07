import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/model/GroupModel.dart';
class GroupChatProvider extends ChangeNotifier {
  String groupId;
  int chatCount = 100;
  List<GroupModel> chats;
  QueryDocumentSnapshot lastDoc;

  void getChats() {
    FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .doc(groupId)
        .collection(FirebaseKey.messages)
        .limit(chatCount)
        .orderBy(
          FirebaseKey.sentAt,
          descending: true,
        )
        .snapshots()
        .listen((snap) {
      chats = [];
      for (var element in snap.docs) {
        GroupModel chat = GroupModel.fromJson(element.data());
        chat.ref = element.reference;
        chats.add(chat);
      }
      print(chats.length);
      notifyListeners();
      if (snap.docs.isNotEmpty) {
        lastDoc = snap.docs.last;
      }
    });
  }

  Future<void> fetchPreviousChats() async {
    final previousChats = await FirebaseFirestore.instance
        .collection(FirebaseKey.groupRoom)
        .doc(groupId)
        .collection(FirebaseKey.messages)
        .limit(chatCount)
        .orderBy(
          FirebaseKey.sentAt,
          descending: true,
        )
        .startAfterDocument(lastDoc)
        .limit(chatCount)
        .get();
    for (var element in chats) {
      element.visible = false;
    }

    for (var element in previousChats.docs) {
      GroupModel chat = GroupModel.fromJson(element.data());
      chat.ref = element.reference;
      chats.add(chat);
    }

    if (previousChats != null && previousChats.docs.isNotEmpty) {
      lastDoc = previousChats.docs.last;
    }
    notifyListeners();
  }
}
