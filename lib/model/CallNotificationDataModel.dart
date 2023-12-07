import 'dart:convert';

class CallNotificationDataModel {
  String token;
  String username;
  String userId;
  List<String> userIds;
  String receiverId;
  String userProfile;
  String roomId;
  int calltype;
  CallNotificationDataModel.fromJson(Map<String, dynamic> map) {
    token = map['token'];
    username = map['user_name'];
    roomId = map['room_id'];
    userProfile = map['user_profile'];
    userId = map['user_id'];
    userIds = [];

    json.decode(map['user_ids']).forEach((e) {

     userIds.add(e);

    });

    receiverId = map['receiver_id'];
    calltype = int.parse(map['call_type']);
  }
}
