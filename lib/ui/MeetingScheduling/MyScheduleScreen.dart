import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' as intl;

import '../../helper/AppHelper.dart';
import '../../model/ScheduleListModel.dart';

class MyScheduleScreen extends StatefulWidget {
  const MyScheduleScreen({Key key}) : super(key: key);

  @override
  State<MyScheduleScreen> createState() => _MyScheduleScreenState();
}

class _MyScheduleScreenState extends State<MyScheduleScreen> {
  ScheduleCalendarProvider calendarProvider;
  String formatdate = "" ; 
  // var currentdta ;
  bool showNo = true;
  void initState() {
    calendarProvider =
        Provider.of<ScheduleCalendarProvider>(context, listen: false);
    calendarProvider.context = context;
    calendarProvider.getScheduleListAPI();

    final now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd  kk:mm:ss').format(now);
    formatdate = formattedDate;
    var currentdta = DateFormat.yMd().add_jms();
    //DateTime currentdta = DateFormat('yyyy-MM-dd  kk:mm:ss').format(now);
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
          "My Schedule",
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
    int emptyTime = 0;
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
                body: Consumer<ScheduleCalendarProvider>(
                    builder: ((context, value, child) {

                      final endTime = intl.DateFormat('yyyy-MM-dd kk:mm').parseUtc(value.mySchedules.isNotEmpty ?
                      value.mySchedules.first.endTime  :"2023-06-07 16:02:00").toLocal();
                      final endTimeVal =  intl.DateFormat('yyyy-MM-dd  kk:mm').format(endTime);

                  if (value.scheduleListModel != null) {
                    if (value.mySchedules.isEmpty ) {
                      return Center(
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16, top: 5),
                            child: Text("No Schedule yet"),
                          ),
                        ),
                      );
                    }
                    return Column(
                        children: [

                        if((endTimeVal == formatdate) || (DateTime.now().isAfter(endTime)))...{
                        //if((endTimeVal == formatdate) && (DateFormat('yyyy-MM-dd  kk:mm').parse(formatdate).isAfter(endTime)))...{
                          Center(
                            child: Container(
                              child: Padding(
                                padding:  EdgeInsets.only(top: 300),
                                child: Text("No Schedule yet"),
                              ),
                            ),
                          )
                      },
                      Expanded(
                        child: ListView.builder(
                            itemCount: value.mySchedules.length,
                            itemBuilder: (context, i) {
                              final event = value.mySchedules[i];
                              final endTime = intl.DateFormat('yyyy-MM-dd kk:mm').parseUtc(event.endTime).toLocal();
                              final endTimeVal =  intl.DateFormat('yyyy-MM-dd  kk:mm').format(endTime);
                              if((endTimeVal == formatdate) || (DateTime.now().isAfter(endTime)) ){
                                return Center(
                                  child: Container(),
                                );
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
                                              width: 20,
                                            ),
                                            Flexible(
                                              child: Text(
                                                "${event.worksite}, ${event.location}",
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
                                              left: 40,
                                              right: 10,
                                              top: 10,
                                              bottom: 10),
                                          child: Row(
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
                                            left: 40,
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
                                              left: 40,
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
                                            left: 40,
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
                                              left: 40,
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
                                              horizontal: 40, vertical: 0),
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
                                                event.acceptStatus == "0"
                                                    ? "Pending"
                                                    : event.acceptStatus == "1"
                                                    ? "Accepted"
                                                    : event.acceptStatus ==
                                                    '2'
                                                    ? "Declined"
                                                    : "Request Off",
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: event.acceptStatus ==
                                                        '0'
                                                        ? Colors.orange
                                                        : event.acceptStatus ==
                                                        '1'
                                                        ? Colors.green
                                                        : Colors.red),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 40, vertical: 10),
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
                                        if ((event.userId ==
                                            appUserSession.value.id &&
                                            event.acceptStatus != '2' && event.acceptStatus != '3') ||
                                            event.acceptStatus == '1' &&
                                                event.userId !=
                                                    appUserSession.value.id)
                                          Padding(
                                            padding:
                                            const EdgeInsets.only(left: 40),
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
                                                        event.id.toString(),
                                                        event.userId
                                                            .toString());
                                                  } else {
                                                    value.cancelScheduleAPI(
                                                        event.id.toString(),
                                                        event.managerId);
                                                  }
                                                },
                                                child: Text(
                                                    event.userId != appUserSession.value.id
                                                        ? "Cancel"
                                                        : "Request off")),
                                          ),
                                        if ((event.acceptStatus == '0' && event.userId != appUserSession.value.id) ||
                                            (event.acceptStatus == '3' && event.userId != appUserSession.value.id) )
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
                                              ])
                                      ]));
                            }),
                      ),
                          // if(showNo)...{
                          //   Expanded(child: Center(child: Text("No Schedule yet"),),)
                          // },
                    ]);
                  } else {
                    return Container();
                  }
                }))
            );
          } else {
            return Container();
          }
        }));
  }
}
