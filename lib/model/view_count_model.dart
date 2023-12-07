// To parse this JSON data, do
//
//     final viewCountModel = viewCountModelFromJson(jsonString);

import 'dart:convert';

ViewCountModel viewCountModelFromJson(String str) => ViewCountModel.fromJson(json.decode(str));

String viewCountModelToJson(ViewCountModel data) => json.encode(data.toJson());

class ViewCountModel {
  bool success;
  Data data;
  String message;

  ViewCountModel({
    this.success,
    this.data,
    this.message,
  });

  factory ViewCountModel.fromJson(Map<String, dynamic> json) => ViewCountModel(
    success: json["success"],
    data: Data.fromJson(json["data"]),
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "data": data.toJson(),
    "message": message,
  };
}

class Data {
  int userId;
  String diaryId;
  int views;
  DateTime updatedAt;
  DateTime createdAt;
  int id;

  Data({
    this.userId,
    this.diaryId,
    this.views,
    this.updatedAt,
    this.createdAt,
    this.id,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    userId: json["user_id"],
    diaryId: json["diary_id"],
    views: json["views"],
    updatedAt: DateTime.parse(json["updated_at"]),
    createdAt: DateTime.parse(json["created_at"]),
    id: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "diary_id": diaryId,
    "views": views,
    "updated_at": updatedAt.toIso8601String(),
    "created_at": createdAt.toIso8601String(),
    "id": id,
  };
}
