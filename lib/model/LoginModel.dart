class LoginModel {
  bool success;
  Data data;
  String message;

  LoginModel({this.success, this.data, this.message});

  LoginModel.fromJson(Map<String, dynamic> json) {
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
  int id;
  String devicetype;
  String firstName;
  String lastName;
  String email;
  String profilePicture;
  String location;
  String profession;
  String token;
  String apntoken;
  String firebase_token;
  bool firstTime;

  Data(
      {this.id,
        this.devicetype,
        this.apntoken,
      this.firstName,
      this.lastName,
      this.email,
      this.profilePicture,
      this.location,
      this.profession,
      this.token,
      this.firstTime});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    devicetype= json['device_type'];
    profilePicture = json['profile_picture'];
    location = json['location'];
    profession = json['profession'];
    token = json['token'];
    firstTime = json['first_time'];
    firebase_token = json['firebase_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['profile_picture'] = this.profilePicture;
    data['location'] = this.location;
    data['profession'] = this.profession;
    data['token'] = this.token;
    data['first_time'] = this.firstTime;
    data['device_type'] = this.devicetype;
    data['firebase_token'] = this.firebase_token;
    return data;
  }
}
