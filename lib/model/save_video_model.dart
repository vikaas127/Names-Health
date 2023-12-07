// To parse this JSON data, do
//
//     final saveVideoModel = saveVideoModelFromJson(jsonString);

import 'dart:convert';

SaveVideoModel saveVideoModelFromJson(String str) => SaveVideoModel.fromJson(json.decode(str));

String saveVideoModelToJson(SaveVideoModel data) => json.encode(data.toJson());

class SaveVideoModel {
  bool success;
  List<Datum> data;
  String message;

  SaveVideoModel({
    this.success,
    this.data,
    this.message,
  });

  factory SaveVideoModel.fromJson(Map<String, dynamic> json) => SaveVideoModel(
    success: json["success"],
    data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "message": message,
  };
}

class Datum {
  int id;
  int userId;
  int diaryId;
  int videoId;
  DateTime createdAt;
  DateTime updatedAt;
  String media;

  Datum({
    this.id,
    this.userId,
    this.diaryId,
    this.videoId,
    this.createdAt,
    this.updatedAt,
    this.media,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    id: json["id"],
    userId: json["user_id"],
    diaryId: json["diary_id"],
    videoId: json["video_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    media: json["media"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "diary_id": diaryId,
    "video_id": videoId,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "media": media,
  };
}
