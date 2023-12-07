class UserProfileModel {
  bool success;
  Data data;
  String message;

  UserProfileModel({this.success, this.data, this.message});

  UserProfileModel.fromJson(Map<String, dynamic> json) {
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
  String apntoken;
  String devicetype;
  String socialType;
  String firstName;
  String lastName;
  String name;
  String email;
  String emailVerifiedAt;
  var isAdmin;
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
  var isBusinessman;
  bool connected;
  bool already_requested;
  List<String> certificates;
  List<String> inservices;
  List<String> credentials;
  List<String> qualifications;
  int postCount;
  int totalConnection;
  int invitation_request;
  String cover_picture;
  String profession_symbol;
  String about;
  bool blockStatus;
  ScheduleList scheduleList;
  int profileLock;

  Data(
      {this.id,
      this.socialId,
      this.socialType,
        this.apntoken,
        this.devicetype,
      this.firstName,
      this.lastName,
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
      this.connected,
      this.already_requested,
      this.certificates,
      this.postCount,
      this.totalConnection, this.scheduleList,this.profileLock});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    socialId = json['social_id'];
    socialType = json['social_type'];
    devicetype=json['device_type'];
    apntoken=json['apn_token'];
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
    isBusinessman = json['is_businessman'];
    connected = json['connected'];
    already_requested = json['already_requested'];
    certificates = json['certificates'].cast<String>();
    inservices = json['inservices'].cast<String>();
    qualifications = json['qualifications'].cast<String>();
    credentials = json['credentials'].cast<String>();
    postCount = json['post_count'];
    totalConnection = json['total_connection'];
    cover_picture = json['cover_picture'];
    profession_symbol = json['profession_symbol'];
    about = json['about'];
    blockStatus = json['block_status'] ?? false;
    invitation_request = json['invitation_request'] != null
        ? int.parse(json['invitation_request'].toString())
        : -1;
    scheduleList= ScheduleList.fromJson(json["schedule_list"],);
    profileLock = json['profile_lock'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['block_status'] = this.blockStatus;
    data['social_id'] = this.socialId;
    data['device_type']=this.devicetype;
    data['apn_token']=this.apntoken;
    data['social_type'] = this.socialType;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['name'] = this.name;
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
    data['connected'] = this.connected;
    data['already_requested'] = this.already_requested;
    data['certificates'] = this.certificates;
    data['inservices'] = this.inservices;
    data['qualifications'] = this.qualifications;
    data['credentials'] = this.credentials;
    data['post_count'] = this.postCount;
    data['total_connection'] = this.totalConnection;
    data['invitation_request'] = this.invitation_request;
    data['cover_picture'] = this.cover_picture;
    data['profession_symbol'] = this.profession_symbol;
    data['about'] = this.about;
    data["schedule_list"] = scheduleList.toJson();
    data["profile_lock"] = this.profileLock;
    return data;
  }
}


class ScheduleList {
  List<Invitation> schedules;
  List<Invitation> invitation;
  List<Invitation> get commonSch {
    List<Invitation> temp = [];
    temp.addAll(schedules);
    temp.addAll(invitation.where((element) => element.status == "1").toList());
    return temp;
  }



  ScheduleList({
    this.schedules,
    this.invitation,
  });

  factory ScheduleList.fromJson(Map<String, dynamic> json) => ScheduleList(
    schedules: List<Invitation>.from(json["schedules"].map((x) => Invitation.fromJson(x))),
    invitation: List<Invitation>.from(json["invitation"].map((x) => Invitation.fromJson(x))),

  );

  List<Invitation> addAllSc(){
    return [];
  }

  Map<String, dynamic> toJson() => {
    "schedules": List<dynamic>.from(schedules.map((x) => x.toJson())),
    "invitation": List<dynamic>.from(invitation.map((x) => x.toJson())),
  };
}

class Invitation {
  int id;
  int userId;
  String worksite;
  String location;
  String eventType;
  String shiftType;
  String startTime;
  String endTime;
  int managerId;
  DateTime scheduleDate;
  String status;
  ScheduleRequest scheduleRequest;
  Manager manager;
  Manager scheduler;

  Invitation({
    this.id,
    this.userId,
    this.worksite,
    this.location,
    this.eventType,
    this.shiftType,
    this.startTime,
    this.endTime,
    this.managerId,
    this.scheduleDate,
    this.status,
    this.scheduleRequest,
    this.manager,
    this.scheduler,
  });

  factory Invitation.fromJson(Map<String, dynamic> json) => Invitation(
    id: json["id"],
    userId: json["user_id"],
    worksite: json["worksite"],
    location: json["location"],
    eventType: json["event_type"],
    shiftType: json["shift_type"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    managerId: json["manager_id"],
    scheduleDate: DateTime.parse(json["schedule_date"]),
    status: json["status"],
    scheduleRequest: ScheduleRequest.fromJson(json["schedule_request"]),
    manager: Manager.fromJson(json["manager"]),
    scheduler: Manager.fromJson(json["scheduler"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "worksite": worksite,
    "location": location,
    "event_type": eventType,
    "shift_type": shiftType,
    "start_time": startTime,
    "end_time": endTime,
    "manager_id": managerId,
    "schedule_date": "${scheduleDate.year.toString().padLeft(4, '0')}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}",
    "status": status,
    "schedule_request": scheduleRequest.toJson(),
    "manager": manager.toJson(),
    "scheduler": scheduler.toJson(),
  };
}

class Manager {
  int id;
  String name;
  String firstName;

  Manager({
    this.id,
    this.name,
    this.firstName,
  });

  factory Manager.fromJson(Map<String, dynamic> json) => Manager(
    id: json["id"],
    name: json["name"],
    firstName: json["first_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "first_name": firstName,
  };
}

class ScheduleRequest {
  int id;
  int scheduleId;
  int senderId;
  int receiverId;
  String acceptStatus;
  DateTime scheduleDate;
  dynamic updatedBy;
  DateTime createdAt;
  DateTime updatedAt;

  ScheduleRequest({
    this.id,
    this.scheduleId,
    this.senderId,
    this.receiverId,
    this.acceptStatus,
    this.scheduleDate,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleRequest.fromJson(Map<String, dynamic> json) => ScheduleRequest(
    id: json["id"],
    scheduleId: json["schedule_id"],
    senderId: json["sender_id"],
    receiverId: json["receiver_id"],
    acceptStatus: json["accept_status"],
    scheduleDate: DateTime.parse(json["schedule_date"]),
    updatedBy: json["updated_by"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "schedule_id": scheduleId,
    "sender_id": senderId,
    "receiver_id": receiverId,
    "accept_status": acceptStatus,
    "schedule_date": "${scheduleDate.year.toString().padLeft(4, '0')}-${scheduleDate.month.toString().padLeft(2, '0')}-${scheduleDate.day.toString().padLeft(2, '0')}",
    "updated_by": updatedBy,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}