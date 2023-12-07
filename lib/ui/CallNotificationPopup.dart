import 'dart:io';

import 'package:flutter/material.dart';
import 'package:names/Providers/FirebaseCallDataProvider.dart';

import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/ui/Calling/AudioCallScreen.dart';
import 'package:names/ui/Calling/MeetingScreen.dart';
import 'package:provider/provider.dart';

class CallNotificationPopup extends StatefulWidget {
  const CallNotificationPopup({Key key}) : super(key: key);

  @override
  State<CallNotificationPopup> createState() => _CallNotificationPopupState();
}
class _CallNotificationPopupState extends State<CallNotificationPopup> {
  FirebaseCallDataProvider _firebaseCallDataProvider;
  void initState() {
    _firebaseCallDataProvider =
        Provider.of<FirebaseCallDataProvider>(context, listen: false);
    _firebaseCallDataProvider
        .getuserCallStatus(appUserSession.value.id.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FirebaseCallDataProvider>(builder: (context, value, child) {
      if (value.callStatus != null) {
        return (value.callStatus.callStatus == "ringing" && Platform.isAndroid)
            ? SafeArea(
                child: Container(
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColor.blueColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(children: [
                            if (value.callStatus.callType == 1)
                              Icon(
                                Icons.videocam,
                                color: Colors.white,
                              ),
                            Text(
                              value.callStatus.callFrom,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ]),
                        ),
                        Text(
                          value.callStatus.callType == 1
                              ? "Incoming video call"
                              : "Incoming audio call",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () {
                                  AppHelper.stopRingtone();
                                  FirebaseHelper.callRejected(
                                      appUserSession.value.id.toString());
                                  Future.delayed(Duration(seconds: 2), () {
                                    FirebaseHelper.resetUserCallStatus(
                                        appUserSession.value.id.toString());
                                  });
                                },
                                child: Text(
                                  "Decline",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )),
                            TextButton(
                                onPressed: () async {
                                  final perm =
                                      await AppHelper.photoPermissionCheck(
                                          context);
                                  print(
                                      "------------------------------permission------------------");
                                  print(perm);

                                  if (perm) {
                                    AppHelper.stopRingtone();
                                    await FirebaseHelper.callAccepted(
                                        appUserSession.value.id.toString());

                                    if (value.callStatus.callType == 1) {
                                      Navigator.push(
                                          navigatorKey.currentContext,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MeetingScreen(

                                                  )));
                                    } else if (value.callStatus.callType == 2) {
                                      print(
                                          '-----------------------aduio------------ call---------------');
                                      Navigator.push(
                                          navigatorKey.currentContext,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AudioCallScreen(

                                                  )));
                                    }
                                  }
                                },
                                child: Text(
                                  "Accept",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                )),
                          ],
                        )
                      ]),
                ),
              )
            : value.callStatus.onCall
                ? GestureDetector(
                    onTap: () {
                      if (value.callStatus.callType == 1) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MeetingScreen(
                                     // authToken: value.callStatus.token,
                                    //  otherUsername: value.callStatus.callFrom,

                                    )));
                      } else if (value.callStatus.callType == 2) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AudioCallScreen(
                                   )));
                      }
                    },
                    child: Container(
                      height: 100,
                      padding: EdgeInsets.only(left: 20, right: 20, top: 50),
                      decoration: BoxDecoration(
                        color: Colors.green,
                      ),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                "Ongoing call",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                            ),
                            Icon(
                              Icons.call,
                              color: Colors.white,
                            )
                          ]),
                    ),
                  )
                : Container(
                    height: 0,
                  );
      } else {
        return Container(
          height: 0,
        );
      }
    });
  }
}
