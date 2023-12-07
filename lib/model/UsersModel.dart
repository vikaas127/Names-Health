class UsersModel {
  int id;
  int sender_id;
  String firstName;
  String lastName;
  String apntoken;
  String devicetype;
  String name;
  String email;
  String location;
  String profession;
  String specialist;
  String profilePicture;
  String license;
  String licenseExpiryDate;
  String resume;
  String status;
  String licenseValid;
  String profession_symbol;

  bool isSelected = false;

  UsersModel(
      {this.id,
      this.sender_id,
      this.apntoken,
      this.devicetype,
      this.firstName,
      this.lastName,
      this.name,
      this.email,
      this.location,
      this.profession,
      this.specialist,
      this.profilePicture,
      this.license,
      this.licenseExpiryDate,
      this.resume,
      this.status,
      this.licenseValid});

  UsersModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    apntoken = json['apn_token'];
    devicetype = json['device_type'];
    sender_id = json['sender_id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    email = json['email'];
    location = json['location'];
    profession = json['profession'];
    specialist = json['specialist'];
    profilePicture = json['profile_picture'];
    license = json['license'];
    licenseExpiryDate = json['license_expiry_date'];
    resume = json['resume'];
    status = json['status'] != null ? json['status'].toString() : null;
    licenseValid = json['license_valid'];
    profession_symbol = json['profession_symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> UsersModel = new Map<String, dynamic>();
    UsersModel['id'] = this.id;
    UsersModel['sender_id'] = this.sender_id;
    UsersModel['first_name'] = this.firstName;
    UsersModel['last_name'] = this.lastName;
    UsersModel['device_type'] = this.devicetype;
    UsersModel['apn_token'] = this.apntoken;
    UsersModel['name'] = this.name;
    UsersModel['email'] = this.email;
    UsersModel['location'] = this.location;
    UsersModel['profession'] = this.profession;
    UsersModel['specialist'] = this.specialist;
    UsersModel['profile_picture'] = this.profilePicture;
    UsersModel['license'] = this.license;
    UsersModel['license_expiry_date'] = this.licenseExpiryDate;
    UsersModel['resume'] = this.resume;
    UsersModel['status'] = this.status;
    UsersModel['license_valid'] = this.licenseValid;
    UsersModel['profession_symbol'] = this.profession_symbol;
    return UsersModel;
  }
}
