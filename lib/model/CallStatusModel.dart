class CallStatusModel {
  String callFrom;
  bool onCall;
  String token;
  String callStatus;
  bool stopRinging;
  int callType;
  int callerId;
  String callerPhoto;
  CallStatusModel(
      {this.callFrom,
      this.onCall,
      this.token,
      this.callStatus,
      this.stopRinging,
      this.callType,
      this.callerPhoto,
      this.callerId});
  CallStatusModel.fromMap(Map<String, dynamic> map) {
    callFrom = map['callFrom'];
    onCall = map['onCall'] ?? false;
    token = map['token'];
    callStatus = map['callStatus'] ?? "";
    stopRinging = map['stopRinging'] ?? true;
    callType = map['callType'] ?? 1;
    callerPhoto = map['callerPhoto'];
    callerId = map['callerId'];
  }
  toJson() {
    return {
      "callFrom": callFrom,
      "onCall": onCall,
      "token": token,
      "callStatus": callStatus,
      "callType": callType,
      "callerPhoto": callerPhoto,
      "callerId": callerId
    };
  }
}
