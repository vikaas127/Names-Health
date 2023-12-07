class InvitationModel {
  bool success;
  InvitationModelData data;
  String message;

  InvitationModel({this.success, this.data, this.message});

  InvitationModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = InvitationModelData.fromMap(json['data']);
    }
    message = json['message'];
  }
}

class InvitationModelData {
  List<Data> list;
  String nextPageUrl;
  InvitationModelData.fromMap(Map<String, dynamic> map) {
    nextPageUrl = map['next_page_url'];
    list = [];
    if (map['data'] != null) {
      map['data'].forEach((e) {
        list.add(Data.fromJson(e));
      });
    }
  }
}

class Data {
  int id;
  int senderId;
  int receiverId;
  int acceptStatus;
  String createdAt;
  String updatedAt;
  String name;
  String profilePicture;
  String profession;
  String specialist;
  String licenseValid;
  String profession_symbol;

  Data(
      {this.id,
      this.senderId,
      this.receiverId,
      this.acceptStatus,
      this.createdAt,
      this.updatedAt,
      this.name,
      this.profilePicture,
      this.profession,
      this.specialist,
      this.licenseValid});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    senderId = json['sender_id'];
    receiverId = json['receiver_id'];
    acceptStatus = json['accept_status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    name = json['name'];
    profilePicture = json['profile_picture'];
    profession = json['profession'];
    specialist = json['specialist'];
    licenseValid = json['license_valid'];
    profession_symbol = json['profession_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['sender_id'] = this.senderId;
    data['receiver_id'] = this.receiverId;
    data['accept_status'] = this.acceptStatus;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['name'] = this.name;
    data['profile_picture'] = this.profilePicture;
    data['profession'] = this.profession;
    data['specialist'] = this.specialist;
    data['license_valid'] = this.licenseValid;
    data['profession_symbol'] = this.profession_symbol;
    return data;
  }
}
