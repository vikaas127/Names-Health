import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  String messageID;
  String message;
  String file;
  String sender;
  String receiver;
  dynamic sentAt;
  String messageType;
  bool senderRead = false;
  bool receiverRead = false;
  String strDate;
  bool visible = false;
  List<String> delete_from;
  DocumentReference ref;
  ChatModel(
      this.messageID,
      this.message,
      this.file,
      this.sender,
      this.receiver,
      this.sentAt,
      this.messageType,
      this.senderRead,
      this.receiverRead,
      this.delete_from);

  ChatModel.fromJson(Map<String, dynamic> json) {
    messageID = json['messageID'];
    message = json['message'];
    file = json['file'];
    sender = json['sender'];
    receiver = json['receiver'];
    sentAt = json['sentAt'];
    messageType = json['messageType'];
    senderRead = json['senderRead'];
    receiverRead = json['receiverRead'];
    delete_from =
        json['delete_from'] != null ? json['delete_from'].cast<String>() : [];
  }
  ChatModel.fromJsonDate(Map<String, dynamic> json, date) {
    messageID = json['messageID'];
    message = json['message'];
    file = json['file'];
    sender = json['sender'];
    receiver = json['receiver'];
    sentAt = json['sentAt'];
    messageType = json['messageType'];
    senderRead = json['senderRead'];
    receiverRead = json['receiverRead'];
    delete_from =
        json['delete_from'] != null ? json['delete_from'].cast<String>() : [];
    strDate = date;
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageID'] = this.messageID;
    data['message'] = this.message;
    data['file'] = this.file;
    data['sender'] = this.sender;
    data['receiver'] = this.receiver;
    print(sentAt);
    data['sentAt'] = this.sentAt;
    data['messageType'] = this.messageType;
    data['senderRead'] = this.senderRead;
    data['receiverRead'] = this.receiverRead;
    data['strDate'] = this.strDate;
    data['delete_from'] = this.delete_from;
    return data;
  }

  Map<String, dynamic> toJsonAddId(id) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageID'] = id;
    data['message'] = this.message;
    data['file'] = this.file;
    data['sender'] = this.sender;
    data['receiver'] = this.receiver;
    data['sentAt'] = this.sentAt;
    data['messageType'] = this.messageType;
    data['senderRead'] = this.senderRead;
    data['receiverRead'] = this.receiverRead;
    data['strDate'] = this.strDate;
    data['delete_from'] = this.delete_from;
    return data;
  }
}
