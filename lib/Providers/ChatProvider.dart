import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/ChatModel.dart';

class ChatProvider extends ChangeNotifier {
  int chatCount = 100;
  String userId;
  List<ChatModel> chats;
  QueryDocumentSnapshot lastDoc;

  void getChats() {
    FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .doc(AppHelper.getChatID(appUserSession.value.id.toString(), userId))
        .collection(FirebaseKey.messages)
        .limit(chatCount)
        .orderBy(
          FirebaseKey.sentAt,
          descending: true,
        )
        .snapshots()
        .listen((snap) {
      print("------------------helper-------------------");
      chats = [];
      for (var element in snap.docs) {
        ChatModel chat = ChatModel.fromJson(element.data());
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
        .collection(FirebaseKey.chatroom)
        .doc(AppHelper.getChatID(appUserSession.value.id.toString(), userId))
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
      ChatModel chat = ChatModel.fromJson(element.data());
      chat.ref = element.reference;
      chats.add(chat);
    }

    if (previousChats != null && previousChats.docs.isNotEmpty) {
      lastDoc = previousChats.docs.last;
    }
    notifyListeners();
  }
}
