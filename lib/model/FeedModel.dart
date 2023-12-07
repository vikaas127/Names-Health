class FeedModel {
  bool success;
  FeedModelData data;
  String message;

  FeedModel({this.success, this.data, this.message});

  FeedModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = FeedModelData.fromMap(json['data']);
    }
    message = json['message'];
  }
}

class FeedModelData {
  List<Feed> feedList;
  String nextPageUrl;
  FeedModelData.fromMap(Map<String, dynamic> map) {
    nextPageUrl = map['next_page_url'];
    feedList = [];
    if (map['data'] != null) {
      map['data'].forEach((e) {
        feedList.add(Feed.fromJson(e));
      });
    }
  }
}

class Feed {
  int id;
  int userId;
  String title;
  String description;
  int saveAs;
  String location;
  int status;
  String createdAt;
  String updatedAt;
  String date;
  String userName;
  String userProfilePicture;
  String userProfession;
  String userSpecialist;
  bool liked;
  int likedCount;
  var views;
  int commentCount;
  dynamic mediaType;
  List<Medias> medias;
  String type;
  String link;
  String image;
  int signedCount;
  bool signed;

  Feed(
      {this.id,
      this.userId,
      this.title,
      this.description,
      this.saveAs,
      this.location,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.userName,
      this.userProfilePicture,
      this.userProfession,
      this.userSpecialist,
      this.liked,
      this.likedCount,
      this.views,
      this.commentCount,
      this.mediaType,
      this.medias,
      this.type,
      this.link,
      this.image,
      this.signedCount});

  Feed.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    title = json['title'];
    description = json['description'];
    saveAs = json['save_as'];
    location = json['location'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    date = json['date'];
    userName = json['user_name'];
    userProfilePicture = json['user_profile_picture'];
    userProfession = json['user_profession'];
    userSpecialist = json['user_specialist'];
    liked = json['liked'];
    likedCount = json['liked_count'];
    views = json['views'];
    commentCount = json['comment_count'] ?? 0;
    signedCount = json['signed_count'] ?? 0;
    signed = json['signed'] ?? false;
    mediaType = json['media_type'];
    if (json['medias'] != null) {
      medias = new List<Medias>();
      json['medias'].forEach((v) {
        medias.add(new Medias.fromJson(v));
      });
    }
    type = json['type'];
    link = json['link'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['title'] = this.title;
    data['description'] = this.description;
    data['save_as'] = this.saveAs;
    data['location'] = this.location;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['date'] = this.date;
    data['user_name'] = this.userName;
    data['user_profile_picture'] = this.userProfilePicture;
    data['user_profession'] = this.userProfession;
    data['user_specialist'] = this.userSpecialist;
    data['liked'] = this.liked;
    data['liked_count'] = this.likedCount;
    data['views'] = this.views;
    data['comment_count'] = this.commentCount;
    data['signed_cound'] = this.signedCount;
    data['signed'] = this.signed;
    data['media_type'] = this.mediaType;
    if (this.medias != null) {
      data['medias'] = this.medias.map((v) => v.toJson()).toList();
    }
    data['type'] = this.type;
    data['link'] = this.link;
    data['image'] = this.image;
    return data;
  }
}

class Medias {
  int id;
  int userId;
  int diaryId;
  dynamic mediaType;
  String media;
  bool isViewed;
  String createdAt;
  String updatedAt;

  Medias(
      {this.id,
      this.userId,
      this.diaryId,
      this.mediaType,
      this.media,
      this.isViewed,
      this.createdAt,
      this.updatedAt});

  Medias.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    diaryId = json['diary_id'];
    mediaType = json['media_type'];
    media = json['media'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['diary_id'] = this.diaryId;
    data['media_type'] = this.mediaType;
    data['media'] = this.media;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
