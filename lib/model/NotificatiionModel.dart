import 'dart:convert';

class NotificationModel {
  bool success;
  NotificationModelData data;
  String message;

  NotificationModel({this.success, this.data, this.message});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = NotificationModelData.fromMap(json['data']);
    }
    message = json['message'];
  }
}

class NotificationModelData {
  List<Data> notificationList;
  String nextPageUrl;
  NotificationModelData.fromMap(Map<String, dynamic> map) {
    nextPageUrl = map['next_page_url'];
    notificationList = [];
    if (map['data'] != null) {
      map['data'].forEach((e) {
        notificationList.add(Data.fromJson(e));
      });
    }
  }
}

class Data {
  int id;
  int userId;
  int senderUserId;
  String title;
  int readStatus;
  String createdAt;
  String updatedAt;
  String userName;
  String profilePicture;
  String notification_type;
  String user_name;
  String user_profile;
  int clickable;
  int notification_to;
  int notification_from;
  String event_id;

  Data(
      {this.id,
      this.userId,
      this.senderUserId,
      this.title,
      this.readStatus,
      this.createdAt,
      this.updatedAt,
      this.userName,
      this.profilePicture});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'] != null ? tryParse(json['id'].toString()) : -1;
    userId =
        json['user_id'] != null ? tryParse(json['user_id'].toString()) : -1;
    senderUserId = json['sender_user_id'] != null
        ? tryParse(json['sender_user_id'].toString())
        : -1;
    title = json['title'];
    readStatus = json['read_status'] != null
        ? tryParse(json['read_status'].toString())
        : -1;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    userName = json['user_name'];
    profilePicture = json['profile_picture'];
    notification_type = json['notification_type'];
    print(notification_type);
    print(title);
    user_name = json['user_name'];
    user_profile = json['user_profile'];
    clickable =
        json['clickable'] != null ? tryParse(json['clickable'].toString()) : -1;
    notification_to = json['notification_to'] != null
        ? tryParse(json['notification_to'].toString())
        : -1;
    notification_from = json['notification_from'] != null
        ? tryParse(json['notification_from'].toString())
        : -1;
    event_id = json['event_id'] != null ? json['event_id'].toString() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['sender_user_id'] = this.senderUserId;
    data['title'] = this.title;
    data['read_status'] = this.readStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['user_name'] = this.userName;
    data['profile_picture'] = this.profilePicture;
    data['notification_type'] = this.notification_type;
    data['clickable'] = this.clickable;
    data['notification_to'] = this.notification_to;
    data['notification_from'] = this.notification_from;
    data['event_id'] = this.event_id;
    data['user_name'] = this.user_name;
    data['user_profile'] = this.user_profile;
    return data;
  }

  int tryParse(String input) {
    String source = input.trim();
    return int.parse(source);
  }
}
