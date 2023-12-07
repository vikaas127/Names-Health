import 'package:flutter/material.dart';

class AddPostModel {
  String file;
  bool isVideo = false;
  String id;
  AddPostModel.name(
      {@required this.file, @required this.isVideo, @required this.id});
}
