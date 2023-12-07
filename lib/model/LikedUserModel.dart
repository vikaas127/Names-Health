class LikedUserModel {
  bool success;
  LikedUserDataModel data;
  String message;

  LikedUserModel({this.success, this.data, this.message});

  LikedUserModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = LikedUserDataModel.fromMap(json['data']);
    }
    message = json['message'];
  }
}

class LikedUserDataModel {
  List<Data> list;
  String nextPageUrl;
  LikedUserDataModel.fromMap(Map<String, dynamic> map) {
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
  String name;
  String profilePicture;
  bool conneted;
  bool already_requested;

  Data(
      {this.id,
      this.name,
      this.profilePicture,
      this.conneted,
      this.already_requested});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    profilePicture = json['profile_picture'];
    conneted = json['conneted'];
    already_requested = json['already_requested'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['profile_picture'] = this.profilePicture;
    data['conneted'] = this.conneted;
    data['already_requested'] = this.already_requested;
    return data;
  }
}
