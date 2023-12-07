import 'package:names/model/GroupModel.dart';

class GroupDataModel {
  String groupName;
  List<UsersData> usersData;
  int groupCount;
  String groupAdminID;
  GroupModel lastMessage;
  dynamic unreadCount;
  String groupImage;
  bool isGroup;
  List<String> users;
  List<int> deleted_user;
  dynamic groupCreatedTime;

  String groupID;

  GroupDataModel(
      {this.groupName,
      this.usersData,
      this.groupCount,
      this.groupAdminID,
      this.lastMessage,
      this.unreadCount,
      this.groupImage,
      this.isGroup,
      this.users,
      this.groupCreatedTime,
      this.groupID});

  GroupDataModel.fromJson(Map<String, dynamic> json) {
    groupName = json['groupName'];
    if (json['usersData'] != null) {
      usersData = new List<UsersData>();
      json['usersData'].forEach((v) {
        usersData.add(new UsersData.fromJson(v));
      });
    }
    groupCount = json['groupCount'];
    groupAdminID = json['groupAdminID'];
    lastMessage = json['lastMessage'] != null
        ? GroupModel.fromJson(json['lastMessage'])
        : null;
    unreadCount = json['unreadCount'] != null ? json['unreadCount'] : null;
    groupImage = json['groupImage'];
    isGroup = json['isGroup'];
    users = json['users'].cast<String>();
    deleted_user =
        json['deleted_user'] != null ? json['deleted_user'].cast<int>() : [];
    groupCreatedTime = json['groupCreatedTime'];
    groupID = json['groupID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['groupName'] = this.groupName;
    if (this.usersData != null) {
      data['usersData'] = this.usersData.map((v) => v.toJson()).toList();
    }
    data['groupCount'] = this.groupCount;
    data['groupAdminID'] = this.groupAdminID;
    data['lastMessage'] = this.lastMessage;
    if (this.unreadCount != null) {
      data['unreadCount'] = this.unreadCount.toJson();
    }
    data['groupImage'] = this.groupImage;
    data['isGroup'] = this.isGroup;
    data['users'] = this.users;
    data['deleted_user'] = this.deleted_user != null ? this.deleted_user : [];
    data['groupID'] = this.groupID;
    return data;
  }
}

class UsersData {
  String resume;
  String profession;
  String licenseValid;
  String licenseExpiryDate;
  String lastName;
  String profilePicture;
  String senderId;
  String license;
  String specialist;
  String name;
  String location;
  int id;
  String firstName;
  String email;
  String status;
  String profession_symbol;
  String apntoken;

  UsersData(
      {this.resume,
      this.profession,
      this.licenseValid,
      this.licenseExpiryDate,
      this.lastName,
      this.profilePicture,
      this.senderId,
      this.license,
      this.specialist,
      this.name,
      this.location,
      this.id,
      this.firstName,
      this.email,
      this.status,
      this.apntoken});

  UsersData.fromJson(Map<String, dynamic> json) {
    resume = json['resume'];
    profession = json['profession'];
    licenseValid = json['license_valid'];
    licenseExpiryDate = json['license_expiry_date'];
    lastName = json['last_name'];
    profilePicture = json['profile_picture'];
    senderId = json['sender_id'];
    license = json['license'];
    specialist = json['specialist'];
    name = json['name'];
    location = json['location'];
    id = json['id'];
    firstName = json['first_name'];
    email = json['email'];
    status = json['status'];
    profession_symbol = json['profession_symbol'];
    apntoken = json['apn_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['resume'] = this.resume;
    data['profession'] = this.profession;
    data['license_valid'] = this.licenseValid;
    data['license_expiry_date'] = this.licenseExpiryDate;
    data['last_name'] = this.lastName;
    data['profile_picture'] = this.profilePicture;
    data['sender_id'] = this.senderId;
    data['license'] = this.license;
    data['specialist'] = this.specialist;
    data['name'] = this.name;
    data['location'] = this.location;
    data['id'] = this.id;
    data['first_name'] = this.firstName;
    data['email'] = this.email;
    data['status'] = this.status;
    data['profession_symbol'] = this.profession_symbol;
    data['apn_token'] = this.apntoken;
    return data;
  }
}
