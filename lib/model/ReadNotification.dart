class ReadNotification {
  bool success;
  NotificationData notificationData;
  String message;

  ReadNotification({this.success, this.notificationData, this.message});

  ReadNotification.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    notificationData = json['data'] != null
        ? new NotificationData.fromJson(json['data'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.notificationData != null) {
      data['data'] = this.notificationData.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class NotificationData {
  int id;
  int userId;
  int senderUserId;
  String title;
  int readStatus;
  String createdAt;
  String updatedAt;

  NotificationData(
      {this.id,
      this.userId,
      this.senderUserId,
      this.title,
      this.readStatus,
      this.createdAt,
      this.updatedAt});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    senderUserId = json['sender_user_id'];
    title = json['title'];
    readStatus = json['read_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
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
    return data;
  }
}
