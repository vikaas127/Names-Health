class RegisterModel {
  bool success;
  Data data;
  String message;

  RegisterModel({this.success, this.data, this.message});

  RegisterModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  String apntoken;
  int id;
  String firstName;
  String lastName;
  String email;
  String devicetype;
  String profilePicture;
  String location;
  String profession;
  String token;
  String firebase_token;

  Data(
      {this.id,
        this.apntoken,
        this.devicetype,
      this.firstName,
      this.lastName,
      this.email,
      this.profilePicture,
      this.location,
      this.profession,
      this.token});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    devicetype=json['device_type'];
    apntoken=json['apn_token'];
    profilePicture = json['profile_picture'];
    location = json['location'];
    profession = json['profession'];
    token = json['token'];
    firebase_token = json['firebase_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['device_type']=this.devicetype;
    data['apn_toke']=this.apntoken;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['device_type']=this.devicetype;
    data['profile_picture'] = this.profilePicture;
    data['location'] = this.location;
    data['profession'] = this.profession;
    data['token'] = this.token;
    data['firebase_token'] = this.firebase_token;
    return data;
  }
}
