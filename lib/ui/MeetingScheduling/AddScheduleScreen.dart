import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:names/Providers/AddScheduleProvider.dart';
import 'package:names/Providers/SchedulingManagerController.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/CallNotificationPopup.dart';
import 'package:names/ui/MeetingScheduling/MeetingDataSource.dart';
import 'package:names/ui/MeetingScheduling/SchedulingManagerListScreen.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class AddScheduleScreen extends StatefulWidget {
  final List<Meeting> meetings;
  const AddScheduleScreen({Key key, @required this.meetings}) : super(key: key);

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  AddScheduleProvider addProvider;
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
          "Add Schedule",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
        ),
      ),
      ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.green[500])),
        onPressed: () {
          addProvider.addScheduleAPI();
        },
        child: Text(
          "Save",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 18, fontFamily: "Lato_Bold", color: Colors.white),
        ),
      ),
    ]);
  }

  void initState() {
    addProvider = Provider.of<AddScheduleProvider>(context, listen: false);
    addProvider.context = context;
    addProvider.meetings = widget.meetings;
    addProvider.googlePlace = GooglePlace(googleMapKey);
    addProvider.getWorksiteListAPI();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
                body: Consumer<AddScheduleProvider>(
                    builder: ((context, provider, child) {
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(15.0),
                    child: ListView(children: [
                      Text("WORKSITE"),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          controller: provider.worksiteController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          maxLines: null,
                          onChanged: (value) {
                            if (value.isEmpty) {
                              provider.searchWorksiteList = [];
                              setState(() {});
                            } else {
                              provider.searchWorksiteList = [];
                              for (var element in provider.worksiteList) {
                                if (element
                                    .toLowerCase()
                                    .contains(value.toLowerCase())) {
                                  provider.searchWorksiteList.add(element);
                                }
                              }
                              setState(() {});
                            }
                          },
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Add Worksite",
                            filled: true,
                            fillColor: AppColor.skyBlueColor,
                            labelStyle:
                                TextStyle(color: AppColor.textGrayColor),
                            hintStyle: TextStyle(color: AppColor.textGrayColor),
                          )),
                      if (provider.searchWorksiteList.isNotEmpty)
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            itemCount: provider.searchWorksiteList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(provider.searchWorksiteList[index]),
                                onTap: () {
                                  provider.worksiteController.text =
                                      provider.searchWorksiteList[index];
                                  provider.searchWorksiteList = [];
                                  setState(() {});
                                  AppHelper.hideKeyBoard(context);
                                },
                              );
                            },
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Location",
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextFormField(
                          controller: provider.locationController,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          onChanged: (value) {
                            print(provider.predictions.length);
                            if (value.isNotEmpty) {
                              provider.autoCompleteSearch(value);
                            } else {
                              if (provider.predictions.isNotEmpty && mounted) {
                                setState(() {
                                  provider.predictions = [];
                                });
                              }
                            }
                          },
                          maxLines: null,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: false,
                          enableSuggestions: false,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.all(10),
                            hintText: "Add Location",
                            filled: true,
                            fillColor: AppColor.skyBlueColor,
                            labelStyle:
                                TextStyle(color: AppColor.textGrayColor),
                            hintStyle: TextStyle(color: AppColor.textGrayColor),
                          )),
                      if (provider.predictions.isNotEmpty)
                        SizedBox(
                          height: 250,
                          child: ListView.builder(
                            itemCount: provider.predictions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Icon(
                                    Icons.pin_drop,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                    provider.predictions[index].description),
                                onTap: () {
                                  provider.getDetails(
                                      provider.predictions[index].placeId);
                                  AppHelper.hideKeyBoard(context);
                                },
                              );
                            },
                          ),
                        ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Shift Type",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: AppColor.skyBlueColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownButton(
                          underline: Container(),
                          hint: Text("Select Shift"),
                          onChanged: (value) {
                            setState(() {
                              provider.selectedShift = value;
                            });
                          },
                          value: provider.selectedShift,
                          items: [
                            DropdownMenuItem(
                                value: "1", child: Text("Day Shift")),
                            DropdownMenuItem(
                                value: "2", child: Text("Night Shift")),
                            DropdownMenuItem(
                                value: "3", child: Text("Regular Shift"))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Event Type",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: AppColor.skyBlueColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownButton(
                          underline: Container(),
                          hint: Text("Select Shift"),
                          onChanged: (value) {
                            setState(() {
                              provider.selectedEvent = value;
                            });
                          },
                          value: provider.selectedEvent,
                          items: [
                            DropdownMenuItem(
                                value: "3", child: Text("8 hours shift")),
                            DropdownMenuItem(
                                value: "1", child: Text("12 hours shift")),
                            DropdownMenuItem(
                                value: "2", child: Text("24 hours shift"))
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(color: AppColor.skyBlueColor),
                        padding: EdgeInsets.all(10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Start Date & Time",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(provider.startTimeController.text),
                                  ]),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () {
                                  provider.showDatePopUp(
                                      provider.startTimeController, false);
                                },
                              )
                            ]),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(color: AppColor.skyBlueColor),
                        padding: EdgeInsets.all(10),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "End Date & Time",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Text(provider.endTimeController.text),
                                  ]),
                              Spacer(),
                              IconButton(
                                icon: Icon(Icons.access_time),
                                onPressed: () {
                                  provider.showDatePopUp(
                                      provider.endTimeController, true);
                                },
                              )
                            ]),
                      ),

                      SizedBox(
                        height: 20,
                      ),
                      if (provider.managerId != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Manager Name",
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                                width: AppHelper.getDeviceWidth(context),
                                padding: EdgeInsets.all(10),
                                height: 50,
                                decoration: BoxDecoration(
                                    color: AppColor.skyBlueColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(children: [
                                  Expanded(
                                    child: Text(
                                      provider.managerName,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        provider.managerId = null;
                                        provider.managerName = null;
                                      });
                                    },
                                  )
                                ]))
                          ],
                        ),
                      if (provider.managerId == null)
                        GestureDetector(
                          child: Container(
                            width: AppHelper.getDeviceWidth(context),
                            height: 50,
                            margin: EdgeInsets.symmetric(horizontal: 20),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: AppColor.lightSkyBlueColor),
                            alignment: Alignment.center,
                            child: Text(
                              "Add Schedular Manager",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () async {
                            final value = await Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider<
                                            SchedulingManagerController>(
                                        create: (context) =>
                                            SchedulingManagerController(),
                                        child: SchedulingManagerListScreen())));
                            provider.managerId = value[0];
                            provider.managerName = value[1];
                          },
                        ),
                      // SizedBox(
                      //   height: 300,
                      //   child: SfCalendar(
                      //     dataSource: MeetingDataSource(widget.meetings),
                      //     initialSelectedDate: DateTime.now(),
                      //     selectionDecoration: BoxDecoration(
                      //         border: Border.all(color: Colors.orange)),
                      //     minDate: DateTime.now(),
                      //     headerStyle:
                      //         CalendarHeaderStyle(textAlign: TextAlign.center),
                      //     onTap: (calendarTapDetails) {
                      //       if (calendarTapDetails.appointments.isEmpty) {
                      //         provider.selectedDate = calendarTapDetails.date;
                      //       } else {
                      //         bool isAvailable = true;
                      //         for (var element
                      //             in calendarTapDetails.appointments) {
                      //           final meet = Meeting.fromMap(element);
                      //           if (meet.status == '1' || meet.status == '0') {
                      //             isAvailable = false;
                      //             break;
                      //           }
                      //         }
                      //         if (isAvailable) {
                      //           provider.selectedDate = calendarTapDetails.date;
                      //         } else {
                      //           provider.selectedDate = null;
                      //           AppHelper.showToastMessage(
                      //               "This date is already scheduled");
                      //         }
                      //       }
                      //     },
                      //     allowAppointmentResize: true,
                      //     view: CalendarView.month,
                      //   ),
                      // ),
                    ]),
                  );
                })));
          } else {
            return Container();
          }
        }));
  }

  pickTime(TextEditingController controller, bool isStart) async {
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
        controller.text = '';
        controller.text += ' ${value.hour}:$minute';
        print(addProvider.endTimeController.text);
        print(addProvider.startTimeController.text);
        if (isStart) {
          if (addProvider.isEndTimeGreaterThanStartTime(
              addProvider.startTimeController.text, controller.text)) {
            setState(() {});
          } else {
            AppHelper.showToastMessage(
                "End Time should be greater than Start Time");
            controller.text = '';
          }
        }
      }
    });
  }

  showDatePopUp() {}
}
