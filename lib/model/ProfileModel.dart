class ProfileModel {
  bool success;
  Data data;
  String message;

  ProfileModel({this.success, this.data, this.message});

  ProfileModel.fromJson(Map<String, dynamic> json) {
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
  String socialId;
  String socialType;
  String firstName;
  String devicetype;
  String lastName;
  String name;
  String email;
  String emailVerifiedAt;
  bool isAdmin;
  String location;
  String profession;
  String specialist;
  String profilePicture;
  String license;
  String licenseExpiryDate;
  String resume;
  String status;
  String createdAt;
  String updatedAt;
  String about;
  int isBusinessman;
  List<Certificate> certificate;
  List<Certificate> qualifications;
  List<Certificate> credentials;
  List<Certificate> inservices;
  int percentage;
  bool notification;
  String profession_symbol;

  String apntoken;

  Data(
      {this.id,
      this.socialId,
      this.apntoken,
      this.socialType,
      this.firstName,
      this.lastName,
      this.devicetype,
      this.name,
      this.email,
      this.emailVerifiedAt,
      this.isAdmin,
      this.location,
      this.profession,
      this.specialist,
      this.profilePicture,
      this.license,
      this.licenseExpiryDate,
      this.resume,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.isBusinessman,
      this.certificate,
      this.qualifications,
      this.percentage,
      this.notification});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    devicetype = json['device_type'];
    apntoken = json['apn_token'];
    socialId = json['social_id'];
    socialType = json['social_type'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    name = json['name'];
    email = json['email'];
    emailVerifiedAt = json['email_verified_at'];
    isAdmin = json['is_admin'];
    location = json['location'];
    profession = json['profession'];
    specialist = json['specialist'];
    profilePicture = json['profile_picture'];
    license = json['license'];
    licenseExpiryDate = json['license_expiry_date'];
    resume = json['resume'];
    status = json['status'] != null ? json['status'].toString() : null;
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    // isBusinessman = json['is_businessman']!=null?json['is_businessman']:-1;
    if (json['certificate'] != null) {
      certificate = new List<Certificate>();
      json['certificate'].forEach((v) {
        certificate.add(new Certificate.fromJson(v, 'certificate'));
      });
    }

    if (json['qualifications'] != null) {
      qualifications = [];
      json['qualifications'].forEach((v) {
        qualifications.add(new Certificate.fromJson(v, "qualification"));
      });
    }
    if (json['inservices'] != null) {
      inservices = [];
      json['inservices'].forEach((v) {
        inservices.add(new Certificate.fromJson(v, "inservice"));
      });
    }
    if (json['credentials'] != null) {
      credentials = [];
      json['credentials'].forEach((v) {
        credentials.add(new Certificate.fromJson(v, "credential"));
      });
    }
    about = json['about'];
    percentage = json['percentage'];
    profession_symbol = json['profession_symbol'];
    notification = json['notification'] != null ? json['notification'] : false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['social_id'] = this.socialId;
    data['social_type'] = this.socialType;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
    data['device_type'] = this.devicetype;
    data['apn_token'] = this.apntoken;
    data['email'] = this.email;
    data['email_verified_at'] = this.emailVerifiedAt;
    data['is_admin'] = this.isAdmin;
    data['location'] = this.location;
    data['profession'] = this.profession;
    data['specialist'] = this.specialist;
    data['profile_picture'] = this.profilePicture;
    data['license'] = this.license;
    data['license_expiry_date'] = this.licenseExpiryDate;
    data['resume'] = this.resume;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['is_businessman'] = this.isBusinessman;
    if (this.certificate != null) {
      data['certificate'] =
          this.certificate.map((v) => v.toJson('certificate')).toList();
    }
    if (this.qualifications != null) {
      data['qualification'] =
          this.qualifications.map((v) => v.toJson('qualification')).toList();
    }
    if (this.inservices != null) {
      data['inservice'] =
          this.inservices.map((v) => v.toJson('inservice')).toList();
    }
    if (this.credentials != null) {
      data['credential'] =
          this.credentials.map((v) => v.toJson('credential')).toList();
    }
    data['percentage'] = this.percentage;
    data['about'] = this.about;
    data['notification'] = this.notification;
    data['profession_symbol'] = this.profession_symbol;
    return data;
  }
}

class Certificate {
  int id;
  int userId;
  String document;
  String createdAt;
  String updatedAt;

  Certificate(
      {this.id, this.userId, this.document, this.createdAt, this.updatedAt});

  Certificate.fromJson(Map<String, dynamic> json, String value) {
    id = json['id'];
    userId = json['user_id'];
    document = json[value];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson(String value) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data[value] = this.document;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
