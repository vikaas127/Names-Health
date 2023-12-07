class ScheduleListModel {
  bool success;
  String message;
  List<ScheduleModel> data = [];
  List<ScheduleModel> invitations = [];
  ScheduleListModel.fromMap(Map<String, dynamic> map) {
    success = map['success'];
    message = map['message'];
    if (map['data'] != null) {
      map['data']['schedules'].forEach((e) {
        data.add(ScheduleModel.fromMap(e));
      });
      map['data']['invitation'].forEach((e) {
        invitations.add(ScheduleModel.fromMap(e));
      });
    }
  }
}

class ScheduleModel {
  int id;
  int userId;
  String schedulerName;
  String worksite;
  String location;
  String eventType;
  String shiftType;
  String startTime;
  String endTime;
  String managerId;
  String managerName;
  String scheduleDate;
  String acceptStatus;
  int updatedBy;
  String createdAt;
  ScheduleModel.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    userId = map['user_id'];
    schedulerName = map['scheduler']['name'];

    worksite = map['worksite'];
    location = map['location'];
    eventType = map['event_type'];
    shiftType = map['shift_type'].toString();
    startTime = map['start_time'].toString();
    endTime = map['end_time'].toString();
    managerId = map['manager_id'].toString();
    scheduleDate = map['schedule_date'];
    acceptStatus = map['schedule_request']['accept_status'];
    managerName = map['manager']['name'];
    updatedBy = map['schedule_request']['updated_by'];
    createdAt = map['schedule_request']['created_at'];
  }
}
