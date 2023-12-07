import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/ConnectionModel.dart';
import 'package:names/model/UsersModel.dart';

import '../api/ApiCallBackListener.dart';

class SchedulingManagerController extends ChangeNotifier
    with ApiCallBackListener {
  BuildContext context;
  TextEditingController textEditingController = TextEditingController();
  GlobalKey globalKey = GlobalKey();
  ScrollController scrollController = ScrollController();
  ConnectionModel connectionModel;
  TextEditingController controller = TextEditingController();
  bool isSearching = false;

  bool isPaging = false;
  int selectedIndex = -1;

  List<UsersModel> connectedUsersList = [];
  getConnectedUsersAPI() {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: true,
          httpType: HttpMethods.POST,
          url: Url.userList,
          apiAction: ApiAction.networkList,
          body: body);
    } else {
      ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.userList,
        apiAction: ApiAction.networkList,
      );
    }
  }

  getConnectionNextAPI(String url) {
    Map<String, String> body = {};
    if (controller.text.isNotEmpty) {
      body['search_keyword'] = controller.text;
    }

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: url,
        apiAction: ApiAction.pagination,
        body: body);
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.networkList) {
      connectionModel = ConnectionModel.fromJson(result);
      if (connectionModel.success) {
        connectedUsersList.clear();

        connectionModel.data.list.forEach((element) {
          connectedUsersList.add(UsersModel.fromJson(element.toJson()));
        });
        notifyListeners();
      } else {
        AppHelper.showToastMessage(connectionModel.message);
      }
    } else if (action == ApiAction.pagination) {
      ConnectionModel pagination = ConnectionModel.fromJson(result);
      if (pagination.success) {
        if (connectionModel != null) {
          connectionModel.data.nextPageUrl = pagination.data.nextPageUrl;

          for (var element in pagination.data.list) {
            if (!connectionModel.data.list.contains(element)) {
              connectionModel.data.list.add(element);
              connectedUsersList.add(UsersModel.fromJson(element.toJson()));
            }
          }
        }

        isPaging = false;
        notifyListeners();
      } else {
        isPaging = false;
        notifyListeners();

        AppHelper.showToastMessage(pagination.message);
      }
    }
  }
}
