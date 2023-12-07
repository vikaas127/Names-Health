import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:names/Providers/AddScheduleProvider.dart';
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:intl/intl.dart' as intl;
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:names/ui/MeetingScheduling/AddScheduleScreen.dart';
import 'package:names/ui/MeetingScheduling/MeetingDataSource.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  ScheduleCalendarProvider calendarProvider;
  // String formatdate = "" ;
  void initState() {
    calendarProvider =
        Provider.of<ScheduleCalendarProvider>(context, listen: false);
    calendarProvider.context = context;
    calendarProvider.getScheduleListAPI();

    final now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd  kk:mm:ss').format(now);
    print(formattedDate);

    super.initState();
  }

  _appBarWidget(BuildContext context) {
    return Row(children: [
      Container(
        child: IconButton(
          icon: Image.asset(
            "assets/icons/back_arrow.png",
            height: 20,
            width: 20,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      Expanded(
        child: Text(
          "NAMES CALENDAR",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double fontSize = screenWidth * 0.04;
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseHelper.getuserCallStatus(
            appUserSession.value.id.toString()),
        builder: ((context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data.data() != null) {
            final data = CallStatusModel.fromMap(snapshot.data.data());
            if (data.stopRinging) {
              AppHelper.stopRingtone();
            }
            if (data.callStatus == "ringing") {
              AppHelper.callRingtone();
              AppHelper.playRingtone();
            }

            return Scaffold(
                appBar: data.callStatus == "ringing"
                    ? PreferredSize(
                        child: CallNotificationPopup(),
                        preferredSize: Size(200, 140))
                    : data.onCall
                        ? PreferredSize(
                            preferredSize: Size(200, 140),
                            child: Column(
                              children: [
                                Flexible(child: CallNotificationPopup()),
                                AppHelper.appBar(
                                    context,
                                    _appBarWidget(context),
                                    LinearGradient(colors: [
                                      AppColor.skyBlueColor,
                                      AppColor.skyBlueColor
                                    ])),
                              ],
                            ),
                          )
                        : AppHelper.appBar(
                            context,
                            _appBarWidget(context),
                            LinearGradient(colors: [
                              AppColor.skyBlueColor,
                              AppColor.skyBlueColor
                            ])),
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    final value = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                ChangeNotifierProvider<AddScheduleProvider>(
                                    create: (context) => AddScheduleProvider(),
                                    child: AddScheduleScreen(
                                      meetings: calendarProvider.meetings,
                                    ))));
                    if (value != null && value) {
                      calendarProvider.getScheduleListAPI();
                    }
                  },
                  child: Icon(Icons.add),
                ),
                body: Consumer<ScheduleCalendarProvider>(
                    builder: ((context, value, child) {
                  if (value.scheduleListModel != null) {
                    return Column(children: [
                      SizedBox(
                        height: 400,
                        child: SfCalendar(
                          headerStyle:
                              CalendarHeaderStyle(textAlign: TextAlign.center),
                          onTap: (calendarTapDetails) {
                            value.events = [];
                            for (var element
                                in calendarTapDetails.appointments) {
                              value.events.add(Meeting.fromMap(element));
                            }
                            setState(() {});
                          },
                          allowAppointmentResize: true,

                          view: CalendarView.month,
                          dataSource: MeetingDataSource(value.meetings),
                          // by default the month appointment display mode set as Indicator, we can
                          // change the display mode as appointment using the appointment display
                          // mode s
                          monthViewSettings: const MonthViewSettings(
                              appointmentDisplayMode: MonthAppointmentDisplayMode.indicator),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: value.events.length,
                            itemBuilder: (context, i) {
                              final event = value.events[i];
                              //
                              // if(event.status == '2' || event.status == '3'){
                              //   return Container();
                              // }

                              if(event.endTime == null){
                                return SizedBox();
                              }
                              var formattedDate =  DateFormat('yyyy-MM-dd  kk:mm:ss').format(DateTime.now());
                              final endTime =
                              intl.DateFormat('yyyy-MM-dd HH:mm:ssZ').parseUtc(event.endTime).toLocal();
                              final endTimeVal =  intl.DateFormat('yyyy-MM-dd  kk:mm:ss').format(endTime);
                              if((endTimeVal == formattedDate) || (DateFormat('yyyy-MM-dd  kk:mm').parse(formattedDate).isAfter(endTime))){
                                return Container();
                              }
                              return Container(
                                  margin: EdgeInsets.only(
                                      bottom: 10, left: 10, right: 10),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                      color: AppColor.skyBlueBoxColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/icons/calendar.png",
                                              height: 20,
                                              width: 20,
                                              color: AppColor.lightSkyBlueColor,
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${value.events[i].eventName}, ${event.location}",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey[600]),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                              "Manager Name - ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  // event.userId != appUserSession.value.id
                                                  //     ? event.schedulerName
                                                  //     :
                                                  event.managerName,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 30,
                                            right: 10,
                                          ),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Start Date & Time - ",
                                                style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  '${AppHelper.scheduleDateFormat(event.startTime)}',
                                                  style: TextStyle(
                                                      fontSize: fontSize,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "End Date & Time - ",
                                                style: TextStyle(
                                                    fontSize: fontSize,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  '${AppHelper.scheduleDateFormat(event.endTime)}',
                                                  style: TextStyle(
                                                      fontSize: fontSize,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 30,
                                            right: 10,
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Event Type - ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                event.eventType == "1"
                                                    ? "12 Hours Shift"
                                                    : event.eventType == '2'
                                                        ? '24 Hours Shift'
                                                        : "8 Hours Shift",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Shift Type - ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                event.shiftType == "1"
                                                    ? "Day"
                                                    : event.shiftType == '2'
                                                        ? 'Night'
                                                        : "Regular",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 0),
                                          child: Row(
                                            children: [
                                              Text(
                                                "Status - ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(
                                                event.status == "0"
                                                    ? "Pending"
                                                    : event.status == "1"
                                                        ? "Accepted"
                                                        : event.status == '2'
                                                            ? "Declined"
                                                            : "Request Off",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: event.status == '0'
                                                        ? Colors.orange
                                                        : event.status == '1'
                                                            ? Colors.green
                                                            : Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 30, vertical: 10),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Created by - ",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Flexible(
                                                child: Text(
                                                  event.schedulerName,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if ((event.status == '0' && event.userId != appUserSession.value.id) ||
                                            (event.status == '3' && event.userId != appUserSession.value.id))
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                        .green[
                                                                    500])),
                                                    onPressed: () {
                                                      value
                                                          .getAcceptRejectRequestAPI(
                                                              event.id
                                                                  .toString(),
                                                              '1');
                                                    },
                                                    child: Text("Accept")),
                                                ElevatedButton(
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .red[500])),
                                                    onPressed: () {
                                                      value
                                                          .getAcceptRejectRequestAPI(
                                                              event.id
                                                                  .toString(),
                                                              '2');
                                                    },
                                                    child: Text("Decline"))
                                              ]),
                                        if ((event.status != '2' &&
                                                event.status != '3' &&
                                                event.userId ==
                                                    appUserSession.value.id) ||
                                            event.status == '1' &&
                                                event.userId !=
                                                    appUserSession.value.id)
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 30),
                                            child: ElevatedButton(
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors
                                                                .orange[500])),
                                                onPressed: () {
                                                  if (appUserSession.value.id
                                                          .toString() ==
                                                      event.managerId) {
                                                    value.cancelScheduleAPI(
                                                        event.id,
                                                        event.userId
                                                            .toString());
                                                  } else {
                                                    value.cancelScheduleAPI(
                                                        event.id,
                                                        event.managerId);
                                                  }
                                                },
                                                child: Text(event.userId != appUserSession.value.id
                                                    ? "Cancel"
                                                    : "Request off")),
                                          )
                                      ]));
                            }),
                      )
                    ]);
                  } else {
                    return Container();
                  }
                })));
          } else {
            return Container();
          }
        }));
  }
}
