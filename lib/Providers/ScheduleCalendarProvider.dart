import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/ScheduleListModel.dart';
import 'package:names/ui/MeetingScheduling/MeetingDataSource.dart';

import '../api/ApiCallBackListener.dart';

class ScheduleCalendarProvider extends ChangeNotifier with ApiCallBackListener {
  BuildContext context;

  List<ScheduleModel> mySchedules = [];
  ScheduleListModel scheduleListModel;
  List<Meeting> meetings = <Meeting>[];
  List<Meeting> events = [];
  getScheduleListAPI() {
    Map<String, String> body = {};

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.scheduleList,
      apiAction: ApiAction.scheduleList,
    );
  }

  // getMyScheduleListAPI() {
  //   Map<String, String> body = {};

  //   ApiRequest(
  //     context: context,
  //     apiCallBackListener: this,
  //     showLoader: true,
  //     httpType: HttpMethods.POST,
  //     url: Url.scheduleList,
  //     apiAction: ApiAction.mySchedules,
  //   );
  // }

  getAcceptRejectRequestAPI(String scheduleId, String status) {
    Map<String, String> body = {};
    body['schedule_id'] = scheduleId;
    body['status'] = status;

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.acceptRejectScheduleRequest,
        apiAction: ApiAction.acceptRejectScheduleRequest,
        body: body);
  }

  // deleteScheduleAPI(String scheduleId) {
  //   Map<String, String> body = {};
  //   body['schedule_id'] = scheduleId;

  //   ApiRequest(
  //       context: context,
  //       apiCallBackListener: this,
  //       showLoader: true,
  //       httpType: HttpMethods.POST,
  //       url: Url.deleteSchedule,
  //       apiAction: ApiAction.deleteSchedule,
  //       body: body);
  // }

  cancelScheduleAPI(String scheduleId, String userId) {
    Map<String, String> body = {};
    body['schedule_id'] = scheduleId;
    body['user_id'] = userId;

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: true,
        httpType: HttpMethods.POST,
        url: Url.cancelSchedule,
        apiAction: ApiAction.cancelSchedule,
        body: body);
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.scheduleList) {
      scheduleListModel = ScheduleListModel.fromMap(result);
      if (scheduleListModel.success) {
        mySchedules = [];
        for (var element in scheduleListModel.data) {
          mySchedules.add(element);
        }

        for (var element in scheduleListModel.invitations) {
          mySchedules.add(element);
        }
        mySchedules.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        _getDataSource();
      } else {
        AppHelper.showToastMessage(scheduleListModel.message);
      }
    } else if (action == ApiAction.acceptRejectScheduleRequest) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        events = [];
        getScheduleListAPI();
        AppHelper.showToastMessage(apiResponseModel.message);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    } else if (action == ApiAction.cancelSchedule) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        events = [];
        getScheduleListAPI();
        AppHelper.showToastMessage(apiResponseModel.message);
      } else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

  List<Meeting> _getDataSource() {
    meetings = [];
    mySchedules.forEach((element) {
      final DateTime from = DateFormat('yyyy-MM-dd HH:mm:ssZ')
          .parseUtc(element.startTime)
          .toLocal();
      final DateTime to = DateFormat('yyyy-MM-dd HH:mm:ssZ')
          .parseUtc(element.endTime)
          .toLocal();

      if (from.difference(to).inDays >= 1) {
        Meeting meeting = Meeting(
            eventName: element.worksite,
            from: from,
            to: to,
            startTime: element.startTime,
            endTime: element.endTime,
            location: element.location,
            background: Colors.green,
            isAllDay: true,
            status: element.acceptStatus,
            eventType: element.eventType,
            shiftType: element.shiftType,
            id: element.id.toString(),
            managerName: element.managerName,
            managerId: element.managerId,
            userId: element.userId,
            schedulerName: element.schedulerName);
        meetings.add(meeting);
      } else if ((DateTime.now().isAfter(to))) {
          SizedBox();
      } else {
        Meeting meeting = Meeting(
            eventName: element.worksite,
            from: from,
            to: to,
            startTime: element.startTime,
            endTime: element.endTime,
            location: element.location,
            background: Colors.green,
            isAllDay: true,
            status: element.acceptStatus,
            eventType: element.eventType,
            shiftType: element.shiftType,
            id: element.id.toString(),
            managerName: element.managerName,
            managerId: element.managerId,
            userId: element.userId,
            schedulerName: element.schedulerName);
        meetings.add(meeting);
      }
    });
    notifyListeners();

    return meetings;
  }
}
