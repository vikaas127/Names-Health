class UserSession {
  int id;
  String firstName;
  String lastName;
  String name;
  String apntoken;
  String devicetype;
  String email;
  String profilePicture;
  String location;
  String profession;
  String profession_symbol;
  String token;
  String firebaseToken;

  String social_type;

  UserSession({
    this.id,
    this.firstName,
    this.devicetype,
    this.apntoken,
    this.lastName,
    this.email,
    this.profilePicture,
    this.location,
    this.profession,
    this.token,
    this.firebaseToken,
  });

  UserSession.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    devicetype=json['device_type'];
    apntoken=json['apn_token'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    email = json['email'];
    profilePicture = json['profile_picture'];
    location = json['location'];
    profession = json['profession'];
    social_type = json['social_type'];
    token = json['token'];
    firebaseToken = json['firebaseToken'];
    profession_symbol = json['profession_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['device_type']=this.devicetype;
    data['apn_token']=this.apntoken;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['email'] = this.email;
    data['profile_picture'] = this.profilePicture;
    data['location'] = this.location;
    data['profession'] = this.profession;
    data['token'] = this.token;
    data['firebaseToken'] = this.firebaseToken;
    data['social_type'] = this.social_type;

    data['profession_symbol'] = this.profession_symbol;
    return data;
  }
}
