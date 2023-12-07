import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  String message;
  String file;
  String sender;
  dynamic sentAt;
  String messageType;
  String strDate;
  String messageID;
  bool visible = false;
  List<String> users;
  List<String> delete_from;
  DocumentReference ref;
  GroupModel(this.messageID, this.message, this.file, this.sender, this.sentAt,
      this.messageType);

  GroupModel.fromJson(Map<String, dynamic> json) {
    messageID = json['messageID'];
    message = json['message'];
    file = json['file'];
    sender = json['sender'];
    sentAt = json['sentAt'];
    messageType = json['messageType'];
    users = json['seen_by'] != null
        ? json['seen_by'].cast<String>()
        : List<String>();
    delete_from =
        json['delete_from'] != null ? json['delete_from'].cast<String>() : [];
  }
  GroupModel.fromJsonDate(Map<String, dynamic> json, date) {
    messageID = json['messageID'];
    message = json['message'];
    file = json['file'];
    sender = json['sender'];
    sentAt = json['sentAt'];
    messageType = json['messageType'];
    users = json['seen_by'] != null
        ? json['seen_by'].cast<String>()
        : List<String>();
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
    data['sentAt'] = this.sentAt;
    data['messageType'] = this.messageType;
    data['delete_from'] = this.delete_from;
    return data;
  }

  Map<String, dynamic> toJsonAddId(messaged_id) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['messageID'] = messaged_id;
    data['message'] = this.message;
    data['file'] = this.file;
    data['sender'] = this.sender;
    data['sentAt'] = this.sentAt;
    data['messageType'] = this.messageType;
    data['delete_from'] = this.delete_from;
    return data;
  }
}
