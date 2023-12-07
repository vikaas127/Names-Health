import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/CallNotificationDataModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/ui/MeetingScheduling/MyScheduleScreen.dart';

import 'package:names/ui/NotificationScreen.dart';
import 'package:names/ui/UserProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../SinglePostPage.dart';
import '../model/NotificatiionModel.dart';
import '../model/UsersModel.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (message.data["notification_type"] == "Call Notification") {
    CallNotificationDataModel callData =
        CallNotificationDataModel.fromJson(message.data);

    if (Platform.isAndroid) {
      AppHelper.callRingtone();
      showCallkitIncoming(Uuid().v4(), callData);
    }
  }
}

class FirebasePushNotification extends ChangeNotifier {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  AndroidNotificationChannel androidNotificationChannel;
  static FirebasePushNotification firebasePushNotification;
  String firebaseToken;
  BuildContext kcontext;
  static FirebasePushNotification instance() {
    if (firebasePushNotification != null) {
      return firebasePushNotification;
    }
    return FirebasePushNotification();
  }

  FirebasePushNotification() {
    firebasePushNotification = this;
    init();
  }
  void initializing() async {
    // this.kcontext=context;
    InitializationSettings initializationSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/launcher_icon'),
        iOS: DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
          onDidReceiveLocalNotification: onDidReceiveLocalNotification,
        ));
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(body),
      actions: <Widget>[
        CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              print("");
            },
            child: Text("Okay")),
      ],
    );
  }

  init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await FirebaseMessaging.instance.requestPermission();
    if (Platform.isAndroid) {
      androidNotificationChannel = const AndroidNotificationChannel(
        'android_channel_id', // id
        'App Importance Notifications', // title
        playSound: true,
        showBadge: true,
        enableLights: true,
        enableVibration: true,
        description: "default channel is used for app notifications.",
        importance: Importance.high,
      );
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          .createNotificationChannel(androidNotificationChannel);
    }

    firebaseToken = await getFirebaseToken();
    listenFirebaseMessages();

    initializing(); //for local notification
  }

  Future<String> getFirebaseToken() async {
    String token = await FirebaseMessaging.instance.getToken();
    return token;
  }

  Stream<RemoteMessage> listenFirebaseMessages() {
    print("------------------------data -----------------------");
    FirebaseMessaging.onMessage.listen((RemoteMessage remoteMessage) async {
      if (remoteMessage.data['notification_type'] == 'Call Notification') {
        CallNotificationDataModel callData =
            CallNotificationDataModel.fromJson(remoteMessage.data);

        await FirebaseHelper.updateUserCallRingingStatusFromNotification(
            appUserSession.value.id.toString());

        // showCallkitIncoming(Uuid().v4(), callData);
      } else {
        showPushNotification(remoteMessage);
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      print("onMessageOpenedApp");
      print("remoteMessage=" + remoteMessage.toString());
      navigateScreen(remoteMessage);
    });
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  Future<void> showPushNotification(RemoteMessage remoteMessage) {
    print("showNotifcation=" + remoteMessage.toMap().toString());
    notificationCount.value++;
    RemoteNotification notification = remoteMessage.notification;
    AndroidNotification android = remoteMessage.notification.android;
    if (notification != null && android != null && !kIsWeb) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          iOS: DarwinNotificationDetails(),
          android: AndroidNotificationDetails(
            androidNotificationChannel.id,
            androidNotificationChannel.name,
            icon: "@mipmap/launcher_icon",
            fullScreenIntent: true,
            importance: Importance.high,
            priority: Priority.high,
            onlyAlertOnce: true,
          ),
        ),
        payload: _getPayloadString(remoteMessage),
      );
    } else {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            iOS: DarwinNotificationDetails(),
          ),
          payload: _getPayloadString(remoteMessage));
    }
  }

  void getInitialMessage() {
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage remoteMessage) {
      navigateScreen(remoteMessage);
    });
  }

  void navigateScreen(RemoteMessage remoteMessage) {
    if (remoteMessage != null) {
      print("remoteMessage=" + remoteMessage.toMap().toString());
      _navigatePage(navigatorKey.currentContext, remoteMessage);
    }
  }

  void _navigatePage(BuildContext currentContext, RemoteMessage remoteMessage) {
    print("remoteMessage=" + remoteMessage.toMap().toString());
    if (remoteMessage.data != null) {
      Data notificationData = Data.fromJson(remoteMessage.data);
      if (notificationData.clickable == 1) {
        if (notificationData.notification_type != null) {
          if (notificationData.notification_type == 'schedule') {
            Navigator.of(currentContext).push(PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  ChangeNotifierProvider<ScheduleCalendarProvider>(
                      create: (context) => ScheduleCalendarProvider(),
                      child: MyScheduleScreen()),
              transitionDuration: Duration(seconds: 0),
            ));
          } else if (notificationData.notification_type == FirebaseKey.post) {
            Navigator.of(currentContext).push(PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  SinglePostPage(
                      notificationId: notificationData.id.toString(),
                      userId: notificationData.notification_to.toString(),
                      postId: notificationData.event_id.toString(),
                      fromNotification: null),
              transitionDuration: Duration(seconds: 0),
            ));
          } else if (notificationData.notification_type ==
              FirebaseKey.connection) {
            Navigator.of(currentContext).push(PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                      Animation<double> secondaryAnimation) =>
                  UserProfileScreen(
                notificationId: notificationData.id.toString(),
                fromNotification: null,
                usersModel: UsersModel(
                  id: notificationData.notification_from,
                  name: notificationData.user_name,
                  profilePicture: notificationData.profilePicture,
                ),
              ),
              transitionDuration: Duration(seconds: 0),
            ));
          } else {
            _navigateToNoficationScreen(currentContext);
          }
        } else {
          _navigateToNoficationScreen(currentContext);
        }
      } else {
        _navigateToNoficationScreen(currentContext);
      }
    } else {
      _navigateToNoficationScreen(currentContext);
    }
  }

  _navigateToNoficationScreen(currentContext) {
    Navigator.of(currentContext).push(PageRouteBuilder(
      pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) =>
          NotificationScreen(),
      transitionDuration: Duration(seconds: 0),
    ));
  }

  /// This method will be called on tap of notification pushed by flutter_local_notification plugin when app is in foreground
  /// This method will modify the message format of iOS Notification Data

  _getPayloadString(RemoteMessage remoteMessage) {
    String payloadKey = "PUSHNOTIFICATION";
    if (remoteMessage != null && remoteMessage.data != null) {
      Data notificationData = Data.fromJson(remoteMessage.data);
      if (notificationData.clickable == 1) {
        if (notificationData.notification_type != null) {
          if (notificationData.notification_type == FirebaseKey.post) {
            payloadKey = FirebaseKey.post +
                FirebaseKey.notificationConcat +
                notificationData.id.toString() +
                FirebaseKey.notificationConcat +
                notificationData.notification_to.toString() +
                FirebaseKey.notificationConcat +
                notificationData.event_id.toString();
          } else if (notificationData.notification_type ==
              FirebaseKey.connection) {
            payloadKey = FirebaseKey.connection +
                FirebaseKey.notificationConcat +
                notificationData.id.toString() +
                FirebaseKey.notificationConcat +
                notificationData.notification_from.toString() +
                FirebaseKey.notificationConcat +
                notificationData.user_name.toString();
          }
        }
      }
    }
    return payloadKey;
  }
}

showCallkitIncoming(String uuid, CallNotificationDataModel callData) async {
  final config = CallKeepIncomingConfig(
    uuid: uuid,
    callerName: callData.username,
    appName: 'Names Health',
    // avatar: 'https://i.pravatar.cc/100',
    handle: callData.calltype == 1 ? 'Video Call' : 'Audio Call',
    hasVideo: false,
    duration: 30000,
    acceptText: 'Accept',
    declineText: 'Decline',
    missedCallText: 'Missed call',
    callBackText: 'Call back',
    androidConfig: CallKeepAndroidConfig(
        ringtoneFileName: 'system_ringtone_default',
        logo: 'logo',
        accentColor: '#34C7C2',
        showCallBackAction: false,
        showMissedCallNotification: false),
    iosConfig: CallKeepIosConfig(
      iconName: 'Icon',
      maximumCallGroups: 1,
    ),
  );
  await CallKeep.instance.displayIncomingCall(config);
  CallKeep.instance.onEvent.listen((event) async {
    print("callkeeeeeeeppppppp--------------------");
    print(event.type);
    final data = event.data as CallKeepCallData;
    print("----------------event------------------------------");
    print(event.toString());
    print(event.type);
    FirebaseHelper.getuserCallStatus(callData.userId).listen((event) {
      if (event.data() != null) {
        print("---------------------------event------------------------------");
        CallStatusModel status = CallStatusModel.fromMap(event.data());
        print(status.toJson());
        if (status.token == '') {
          print(
              "---------------------------------calling-----------------------------");
          CallKeep.instance.endAllCalls();
        }
      }
    });
    if (event == null) return;
    switch (event.type) {
      case CallKeepEventType.callAccept:
        CallKeep.instance.endCall(event.data.uuid);
        print("-------------------update user-------------------------");
        print(event.data.toString());
        await FirebaseHelper.updateUserCallRingingStatusFromNotification(
            callData.userIds[0].toString());
        /* final per = await AppHelper.photoPermissionCheck(navigatorKey.currentContext);
        if (per) {


        //  await FirebaseHelper.callAccepted(appUserSession.value.id.toString());
        if (data.hasVideo == true) {
          Navigator.push(navigatorKey.currentContext,
              MaterialPageRoute(builder: (context) => MeetingScreen()));
        } else {
          Navigator.push(navigatorKey.currentContext,
              MaterialPageRoute(builder: (context) => AudioCallScreen()));
        }
        }*/

        break;
      case CallKeepEventType.callDecline:
        CallKeep.instance.endCall(callData.userIds[0].toString());
        FirebaseHelper.callRejected(callData.userIds[0].toString().toString())
            .then((value) {
          FirebaseHelper.resetUserCallStatus(callData.userIds[0].toString());
        });

        break;
      case CallKeepEventType.callTimedOut:
        // FirebaseHelper.callRejected(callData.userIds[0]).then((value) {
        //   FirebaseHelper.resetUserCallStatus(callData.userIds[0]);
        // });
        break;
      default:
        break;
    }
  });
}

// Future<void> showCallkitIncoming(
//     String uuid, CallNotificationDataModel callData) async {
//   CallKitParams callKitParams = CallKitParams(
//     id: uuid,
//     nameCaller: callData.username,
//     appName: 'Callkit',
//     avatar: callData.userProfile,
//     handle: callData.calltype == 1 ? 'Video Call' : 'Audio Call',
//     type: 0,
//     textAccept: 'Accept',
//     textDecline: 'Decline',
//     duration: 30000,
//     extra: <String, dynamic>{'userId': '1a2b3c4d'},
//     headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
//     android: const AndroidParams(
//         isCustomNotification: true,
//         isShowLogo: false,
//         isShowCallback: false,
//         isShowMissedCallNotification: true,
//         ringtonePath: 'system_ringtone_default',
//         backgroundColor: '#0955fa',
//         backgroundUrl: 'https://www.names.health/public/mobile/background.jpg',
//         actionColor: '#4CAF50',
//         incomingCallNotificationChannelName: "Incoming Call",
//         missedCallNotificationChannelName: "Missed Call"),
//     ios: IOSParams(
//       iconName: 'CallKitLogo',
//       handleType: 'generic',
//       supportsVideo: true,
//       maximumCallGroups: 2,
//       maximumCallsPerCallGroup: 1,
//       audioSessionMode: 'default',
//       audioSessionActive: true,
//       audioSessionPreferredSampleRate: 44100.0,
//       audioSessionPreferredIOBufferDuration: 0.005,
//       supportsDTMF: true,
//       supportsHolding: true,
//       supportsGrouping: false,
//       supportsUngrouping: false,
//       ringtonePath: 'system_ringtone_default',
//     ),
//   );
//   await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);

//   FlutterCallkitIncoming.onEvent.listen((event) {
//     // print(event.event);
//     // print("-------------------event-----------------------------------");
//     FirebaseHelper.getuserCallStatus(callData.userId).listen((event) {
//       if (event.data() != null) {
//         print("---------------------------event------------------------------");
//         CallStatusModel status = CallStatusModel.fromMap(event.data());
//         print(status.toJson());
//         if (status.token == '') {
//           FlutterCallkitIncoming.endAllCalls();
//         }
//       }
//     });

//     if (event.event == Event.ACTION_CALL_ACCEPT) {
//       FlutterCallkitIncoming.endCall(uuid);
//       print("-------------------update user-------------------------");
//       FirebaseHelper.updateUserCallStatusFromNotification(callData.userIds[0],
//           isRing: "ringing",
//           token: callData.token,
//           callFrom: callData.username,
//           calltype: callData.calltype,
//           callerPhoto: callData.userProfile);
//     } else if (event.event == Event.ACTION_CALL_DECLINE ||
//         event.event == Event.ACTION_CALL_TIMEOUT) {
//       FirebaseHelper.callRejected(callData.userIds[0]).then((value) {
//         FirebaseHelper.resetUserCallStatus(callData.userIds[0]);
//       });
//     }
//   });
// }
