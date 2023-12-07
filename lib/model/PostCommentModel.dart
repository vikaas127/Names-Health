class PostCommentModel {
  bool success;
  String message;
  PostCommentModelData data;
  PostCommentModel.fromJson(Map<String, dynamic> map) {
    success = map['success'];
    message = map['message'];
    if (map['data'] != null) {
      data = PostCommentModelData.fromMap(map['data']);
    }
  }
}

class PostCommentModelData {
  List<PostCommentData> list;
  String nextPageUrl;
  PostCommentModelData.fromMap(Map<String, dynamic> map) {
    nextPageUrl = map['next_page_url'];
    list = [];
    if (map['data'] != null) {
      map['data'].forEach((e) {
        list.add(PostCommentData.fromJson(e));
      });
    }
  }
}

class PostCommentData {
  int id;
  int userId;
  int diaryId;
  String name;
  String profilePicture;
  String comment;
  String createdAt;
  PostCommentData.fromJson(Map<String, dynamic> map) {
    id = map['id'];
    userId = map['user_id'];
    diaryId = map['diary_id'];
    name = map['name'];
    profilePicture = map['profile_picture'];
    comment = map['comment'];
    createdAt = map['created_at'];
  }
}
