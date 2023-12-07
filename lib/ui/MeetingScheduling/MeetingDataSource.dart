import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// An object to set the appointment collection data source to calendar, which
/// used to map the custom appointment data to the calendar appointment, and
/// allows to add, remove or reset the appointment collection.
class MeetingDataSource extends CalendarDataSource {
  /// Creates a meeting data source, which used to set the appointment
  /// collection to the calendar
  MeetingDataSource(List<Meeting> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return _getMeetingData(index).from;
  }

  @override
  DateTime getEndTime(int index) {
    return _getMeetingData(index).to;
  }

  @override
  String getSubject(int index) {
    return _getMeetingData(index).eventName;
  }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).background;
  }

  @override
  bool isAllDay(int index) {
    return _getMeetingData(index).isAllDay;
  }

  Meeting _getMeetingData(int index) {
    final dynamic meeting = appointments[index];
    Meeting meetingData;
    if (meeting is Meeting) {
      meetingData = meeting;
    }

    return meetingData;
  }
}

/// Custom business object class which contains properties to hold the detailed
/// information about the event data which will be rendered in calendar.
class Meeting {
  /// Creates a meeting class with required details.
  Meeting(
      {this.eventName,
      this.from,
      this.to,
      this.background,
      this.isAllDay,
      this.startTime,
      this.endTime,
      this.location,
      this.status,
      this.eventType,
      this.shiftType,
      this.id,
      this.managerName,
      this.managerId,
      this.userId,
      this.schedulerName});

  /// Event name which is equivalent to subject property of [Appointment].
  String eventName;

  /// From which is equivalent to start time property of [Appointment].
  DateTime from;

  /// To which is equivalent to end time property of [Appointment].
  DateTime to;

  /// Background which is equivalent to color property of [Appointment].
  Color background;
  String startTime;
  String endTime;
  String location;
  String status;
  String eventType;
  String shiftType;
  String id;
  String managerName;
  String managerId;
  int userId;
  String schedulerName;

  /// IsAllDay which is equivalent to isAllDay property of [Appointment].
  bool isAllDay;
  Meeting.fromMap(Meeting appointment) {
    eventName = appointment.eventName;
    startTime = appointment.startTime;
    endTime = appointment.endTime;
    location = appointment.location;
    status = appointment.status;
    eventType = appointment.eventType;
    shiftType = appointment.shiftType;
    id = appointment.id;
    managerName = appointment.managerName;
    managerId = appointment.managerId;
    userId = appointment.userId;
    schedulerName = appointment.schedulerName;
  }
}
