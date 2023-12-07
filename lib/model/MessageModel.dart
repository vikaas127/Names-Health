class MessageModel {
  String message;
  String file;
  String sender;
  String receiver;
  dynamic sentAt;
  String messageType;
  bool isSelected = false;
  bool receiverRead = false;
  bool senderRead = false;
  List<String> delete_from;

  MessageModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    file = json['file'];
    sender = json['sender'];
    receiver = json['receiver'];
    sentAt = json['sentAt'];
    messageType = json['messageType'];
    receiverRead = json['receiverRead'];
    senderRead = json['senderRead'];
    delete_from = json['delete_from']!=null?json['delete_from'].cast<String>():[];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['message'] = this.message;
    data['file'] = this.file;
    data['sender'] = this.sender;
    data['receiver'] = this.receiver;
    data['sentAt'] = this.sentAt;
    data['messageType'] = this.messageType;
    data['receiverRead'] = this.receiverRead;
    data['senderRead'] = this.senderRead;
    data['delete_from'] = this.delete_from;
    return data;
  }
}
