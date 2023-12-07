import 'package:names/model/MessageModel.dart';
import 'package:names/model/UsersModel.dart';

class SearchUserModel {
  MessageModel messageModel;
  UsersModel usersModel;
  bool isGroup = false;

  SearchUserModel(this.messageModel, this.usersModel);
}
