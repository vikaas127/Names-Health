import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:intl/intl.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/WorkSiteModel.dart';
import 'package:names/ui/MeetingScheduling/MeetingDataSource.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

import '../api/ApiCallBackListener.dart';

class AddScheduleProvider extends ChangeNotifier with ApiCallBackListener {
  BuildContext context;
  List<AutocompletePrediction> predictions = [];
  TextEditingController worksiteController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController startTimeController = TextEditingController();

  TextEditingController endTimeController = TextEditingController();
  String selectedShift;
  String selectedEvent;
  String managerId;
  String managerName;
  GooglePlace googlePlace;
  List<String> worksiteList = [];
  List<String> searchWorksiteList = [];
  List<Meeting> meetings;

  showDatePopUp(TextEditingController controller, bool fromEnd) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SizedBox(
                height: 300,
                width: AppHelper.getDeviceWidth(context) * 0.8,
                child: SfCalendar(
                  monthViewSettings:
                      MonthViewSettings(showTrailingAndLeadingDates: false),
                  dataSource: MeetingDataSource(meetings),
                  initialSelectedDate: DateTime.now(),
                  selectionDecoration:
                      BoxDecoration(border: Border.all(color: Colors.orange)),
                  minDate: DateTime.now(),
                  headerStyle: CalendarHeaderStyle(textAlign: TextAlign.center),
                  onTap: (calendarTapDetails) {
                    final date = calendarTapDetails.date;
                    if (calendarTapDetails.appointments.isEmpty) {
                      isEndDateGreaterThanStartDate(date, fromEnd, controller);
                    } else {
                      bool isAvailable = true;
                      for (var element in calendarTapDetails.appointments) {
                        final meet = Meeting.fromMap(element);
                        if (meet.status == '1' || meet.status == '0') {
                         // isAvailable = false;
                          break;
                        }
                      }
                      if (isAvailable) {
                        isEndDateGreaterThanStartDate(
                            date, fromEnd, controller);
                      }
                      // else {
                      //   AppHelper.showToastMessage(
                      //       "This date is already scheduled");
                      // }
                    }
                  },
                  allowAppointmentResize: true,
                  view: CalendarView.month,
                ),
              ),
            ));
  }

  pickTime(TextEditingController controller) async {
    await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
        builder: (BuildContext context, Widget child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          );
        }).then((value) {
      if (value != null) {
        final minute = value.format(context).split(':').last.split(' ').first;
        controller.text += ' ${value.hour}:$minute';
      } else {
        controller.clear();
      }
    });
  }

  addScheduleAPI() {
    String worksite = worksiteController.text.trim();
    String location = locationController.text.trim();
    String shiftType = selectedShift;
    String eventType = selectedEvent;
    String startTime = startTimeController.text.trim();
    String endTime = endTimeController.text.trim();
    if (worksite.isEmpty) {
      AppHelper.showToastMessage("Please add worksite.");
    } else if (location.isEmpty) {
      AppHelper.showToastMessage("Please add location.");
    } else if (shiftType == null) {
      AppHelper.showToastMessage("Please select shift type.");
    } else if (eventType == null) {
      AppHelper.showToastMessage("Please select event type.");
    } else if (startTime.isEmpty) {
      AppHelper.showToastMessage("Please select start time.");
    } else if (endTime.isEmpty) {
      AppHelper.showToastMessage("Please select end time.");
    } else if (!isStartTimeGreaterThanCurrentTime(startTime)) {
      AppHelper.showToastMessage(
          "Start Time should be greater than current Time");
    } else if (!isEndTimeGreaterThanStartTime(startTime, endTime)) {
      AppHelper.showToastMessage("End Time should be greater than start Time");
    } else if (managerId == null) {
      AppHelper.showToastMessage("Please select scheduling manager.");
    } else {
      Map<String, String> body = {};
      body['worksite'] = worksite;
      body['location'] = location;
      body['shift_type'] = shiftType;
      body['event_type'] = eventType;

      body['start_time'] = convertDateToUTC(startTime);

      body['end_time'] = convertDateToUTC(endTime);

      body['schedule_date'] = convertDateToUTCs(startTime);
      body['manager_id'] = managerId;

      ApiRequest(
          context: context,
          apiCallBackListener: this,
          showLoader: true,
          httpType: HttpMethods.POST,
          url: Url.addSchedule,
          apiAction: ApiAction.addSchedule,
          body: body);
    }
  }

  String convertDateToUTC(String date) {
    return DateTime(
            int.parse(date.split('-')[2].split(' ').first),
            int.parse(date.split('-')[0]),
            int.parse(date.split('-')[1]),
            int.parse(date.split(' ').last.split(':').first),
            int.parse(date.split(' ').last.split(':').last))
        .toUtc()
        .toString();
  }

  String convertDateToUTCs(String date) {
    String dateString = date;
    // DateTime dateTime = DateTime.parse(dateString).toUtc();
    // DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

    final DateFormat displayFormater = DateFormat('dd-MM-yyyy ');
    final DateFormat serverFormater = DateFormat('yyyy-MM-dd');
    final DateTime displayDate = displayFormater.parse(date).toUtc();
    final String formattedDate = serverFormater.format(displayDate);
    //String formattedDate = dateFormatter.format(dateTime);
    print(formattedDate);
    return formattedDate;
    //   DateTime(
    //     int.parse(formattedDate.split('-')[2].split(' ').first),
    //     int.parse(formattedDate.split('-')[0]),
    //     int.parse(formattedDate.split('-')[1]),
    //     //int.parse(date.split('T')[0]),
    //     // int.parse(date.split(' ').last.split(':').last)
    // )
    //     .toUtc()
    //     .toString();
  }

  getWorksiteListAPI() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.GET,
      url: Url.worksiteList,
      apiAction: ApiAction.worksiteList,
    );
  }

  bool isEndTimeGreaterThanStartTime(String start, String end) {
    int startDay = int.parse(start.split('-')[1]);
    int endDay = int.parse(end.split('-')[1]);
    int startMonth = int.parse(start.split('-')[0]);
    int endMonth = int.parse(end.split('-')[0]);

    int startYear = int.parse(start.split('-')[2].split(' ').first);

    int endYear = int.parse(end.split('-')[2].split(' ').first);
    int startHour = int.parse(start.split(' ').last.split(':').first);

    int endHour = int.parse(end.split(" ").last.split(':').first);
    int startTime = int.parse(start.split(' ').last.split(':').last);
    int endTime = int.parse(end.split(' ').last.split(':').last);

    if (startDay < endDay && startMonth == endMonth && startYear == endYear) {
      return true;
    } else if (startMonth < endMonth && startYear == endYear) {
      return true;
    } else if (startDay == endDay) {
      if (startHour < endHour) {
        return true;
      } else if (startTime < endTime) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  bool isStartTimeGreaterThanCurrentTime(String start) {
    int startDay = int.parse(start.split('-')[1]);

    int startMonth = int.parse(start.split('-')[0]);

    int startYear = int.parse(start.split('-')[2].split(' ').first);

    final currentDate = DateTime.now();
    int startHour = int.parse(start.split(' ').last.split(':').first);

    int currentHour = DateTime.now().hour;

    if (DateTime(startYear, startMonth, startDay)
            .difference(
                DateTime(currentDate.year, currentDate.month, currentDate.day))
            .inDays !=
        0) {
      return true;
    } else {
      if (startHour < currentHour) {
        return false;
      }
      return true;
    }
  }

  isEndDateGreaterThanStartDate(
      DateTime date, bool fromEnd, TextEditingController controller) {
    if (fromEnd) {
      final start = startTimeController.text.trim();
      int startDay = int.parse(start.split('-')[1]);

      int startMonth = int.parse(start.split('-')[0]);

      int startYear = int.parse(start.split('-')[2].split(' ').first);

      final difference = DateTime(date.year, date.month, date.day)
          .difference(DateTime(startYear, startMonth, startDay))
          .inDays;

      if (difference < 0) {
        AppHelper.showToastMessage(
            "End date should be greater than start date");
      } else if (difference > 1) {
        AppHelper.showToastMessage(
            "Event time should not be more than 24 hours.");
      } else {
        controller.text = '${date.month}-${date.day}-${date.year} ';
        Navigator.of(context).pop();
        pickTime(controller);
      }
    } else {
      endTimeController.clear();
      controller.text = '${date.month}-${date.day}-${date.year} ';
      Navigator.of(context).pop();
      pickTime(controller);
    }
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.worksiteList) {
      WorkSiteModel workSiteModel = WorkSiteModel.fromMap(result);
      if (workSiteModel.success) {
        worksiteList = workSiteModel.data;
      } else {
        AppHelper.showToastMessage(workSiteModel.message);
      }
    } else if (action == ApiAction.addSchedule) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        Navigator.of(context).pop(true);
        AppHelper.showToastMessage(apiResponseModel.message);
      }else {
        AppHelper.showToastMessage(apiResponseModel.message);
      }
    }
  }

  void autoCompleteSearch(String value) async {
    var result = await googlePlace.autocomplete.get(value);
    if (result != null && result.predictions != null) {
      predictions = result.predictions;
      print(predictions.length);
      notifyListeners();
    }
  }

  void getDetails(String placeId) async {
    var result = await googlePlace.details.get(placeId);
    if (result != null && result.result != null) {
      DetailsResult detailsResult = result.result;
      locationController.text = detailsResult.formattedAddress;

      predictions = [];
      notifyListeners();
    }
  }
}
