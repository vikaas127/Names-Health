class UserStatusModel {
  bool isOnline;
  dynamic onlineTime;
  dynamic offlineTime;

  UserStatusModel.fromJson(Map<String, dynamic> json) {
    isOnline = json['isOnline'];
    onlineTime = json['onlineTime'];
    offlineTime = json['offlineTime'];
  }
}
