class ConnectionModel {
  bool success;
  ConnectionModelData data;
  String message;

  ConnectionModel({this.success, this.data, this.message});

  ConnectionModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = ConnectionModelData.fromMap(json['data']);
    }
    message = json['message'];
  }
}

class ConnectionModelData {
  List<Data> list;
  String nextPageUrl;
  ConnectionModelData.fromMap(Map<String, dynamic> map) {
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

  Data(
      {this.id,
      this.firstName,
      this.lastName,
        this.apntoken,
        this.devicetype,
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

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    apntoken=json['apn_token'];
    devicetype=json['device_type'];
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['device_type']=this.devicetype;
    data['apn_token']=this.apntoken;
    data['name'] = this.name;
    data['email'] = this.email;
    data['location'] = this.location;
    data['profession'] = this.profession;
    data['specialist'] = this.specialist;
    data['profile_picture'] = this.profilePicture;
    data['license'] = this.license;
    data['license_expiry_date'] = this.licenseExpiryDate;
    data['resume'] = this.resume;
    data['status'] = this.status;
    data['license_valid'] = this.licenseValid;
    data['profession_symbol'] = this.profession_symbol;
    return data;
  }
}
