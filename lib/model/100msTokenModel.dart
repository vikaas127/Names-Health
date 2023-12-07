class HmsTokenDetailModel {
  bool success;
  String message;
  String roomName;
  String roomId;
  String token;
  String user;
  HmsTokenDetailModel.fromMap(Map<String, dynamic> map) {
    success = map['Status'] ?? false;
    message = map['Msg'];
    if (success) {
      roomName = map['room_name'];
      roomId = map['room_id'];
      user = map['user'];
      token = map['token'];
    }
  }
}
