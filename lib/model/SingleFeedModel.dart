import 'FeedModel.dart';

class SingleFeedModel {
  bool success;
  Feed data;
  String message;

  SingleFeedModel({this.success, this.data, this.message});

  SingleFeedModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    if (json['data'] != null) {
      data = Feed.fromJson(json['data']);
    } else {
      json['data'] = null;
    }
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
