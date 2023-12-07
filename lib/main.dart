import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:names/Providers/AudioCallProvider.dart';
import 'package:names/Providers/AudioPreviewProvider.dart';
import 'package:names/Providers/ChatProvider.dart';
import 'package:names/Providers/FirebaseCallDataProvider.dart';
import 'package:names/Providers/GroupChatProvider.dart';
import 'package:names/Providers/ScheduleCalendarProvider.dart';
import 'package:names/Providers/VideoCallProvider.dart';
import 'package:names/Providers/VideoPreviewProvider.dart';
import 'package:names/app/FirebasePushNotification.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/firebase_options.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/ProfileModel.dart';
import 'package:names/model/UserSession.dart';
import 'package:names/route/routegenerator.dart';
import 'package:names/ui/Calling/AudioCallScreen.dart';
import 'package:names/ui/Calling/MeetingScreen.dart';
import 'package:names/ui/SplashScreen.dart';
import 'package:provider/provider.dart';
import 'package:upgrader/upgrader.dart';
import 'package:wakelock/wakelock.dart';
import 'api/DynamicLinkServices.dart';
import 'constants/firebaseKey.dart';
import 'helper/FirebaseHelper.dart';

ValueNotifier<UserSession> appUserSession = ValueNotifier(UserSession());
ValueNotifier<ProfileModel> appProfileModel = ValueNotifier(ProfileModel());
ValueNotifier<int> notificationCount = ValueNotifier(0);
ValueNotifier<int> messageCount = ValueNotifier(0);
GlobalKey<NavigatorState> navigatorKey = GlobalKey();
DynamicLinkService dynamicLinkService = new DynamicLinkService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseFirestore.instance.terminate();
  await FirebaseFirestore.instance.clearPersistence();
  await Wakelock.enable();
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
 // messaging.subscribeToTopic("all");
  await Upgrader.clearSavedSettings();

  if (Platform.isIOS) {
    CallKeep.instance.onEvent.listen((event) async {
      final data = event.data as CallKeepCallData;
      print(event.type.toString());
      print("----------------event------------------------------");
      print(event.data.toString());
      // print(event.type);
      // FirebaseHelper.getuserCallStatus(callData.userId).listen((event) {
      //   if (event.data() != null) {
      //     print("---------------------------event------------------------------");
      //     CallStatusModel status = CallStatusModel.fromMap(event.data());
      //     print(status.toJson());
      //     if (status.token == '') {
      //       print(
      //           "---------------------------------calling-----------------------------");
      //       CallKeep.instance.endAllCalls();
      //     }
      //   }
      // });
      // if (event == null) return;
      switch (event.type) {
        case CallKeepEventType.callAccept:
          CallKeep.instance.endCall(event.data.uuid);
          print("-------------------update user-------------------------");
          print(event.data.toString());
          await FirebaseHelper.callAccepted(appUserSession.value.id.toString());
          final per = await AppHelper.photoPermissionCheck(navigatorKey.currentContext);
          if (per) {
            if (data.hasVideo != true) {
              //print();
              Navigator.push(navigatorKey.currentContext,
                  MaterialPageRoute(builder: (context) => AudioCallScreen()));
            } else {
              Navigator.push(navigatorKey.currentContext,
                  MaterialPageRoute(builder: (context) => MeetingScreen()));
            }
          }
          break;
        case CallKeepEventType.callDecline:
          FirebaseHelper.callRejected(data.extra['otheruserId'].toString())
              .then((value) {
            FirebaseHelper.resetUserCallStatus(
                data.extra['otheruserId'].toString());
          });
          break;
        case CallKeepEventType.callTimedOut:

        /*FirebaseHelper.callRejected(appUserSession.value.id.toString()).then((value) {

         FirebaseHelper.resetUserCallStatus(appUserSession.value.id.toString());
       });*/

          break;
        case CallKeepEventType.callEnded:
        /* FirebaseHelper.callRejected(appUserSession.value.id.toString()).then((value) {
          FirebaseHelper.resetUserCallStatus(appUserSession.value.id.toString());
        });
            CallKeep.instance.endCall(event.data.uuid);*/
          break;

        default:
          break;
      }
    });
  }
  // await dynamicLinkService.handleDynamicLinks();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) async {
    appUserSession.value = await AppHelper.getUserSession();
    runApp(MultiProvider(providers: [
      ChangeNotifierProvider<GroupChatProvider>(
          create: (context) => GroupChatProvider()),
      ChangeNotifierProvider<ChatProvider>(create: (context) => ChatProvider()),
      ChangeNotifierProvider<VideoCallProvider>(
          create: (context) => VideoCallProvider()),
      ChangeNotifierProvider<VideoPreviewProvider>(
          create: (context) => VideoPreviewProvider()),
      ChangeNotifierProvider<FirebaseCallDataProvider>(
          create: (context) => FirebaseCallDataProvider()),
      ChangeNotifierProvider<AudioPreviewProvider>(
          create: (context) => AudioPreviewProvider()),
      ChangeNotifierProvider<ScheduleCalendarProvider>(
          create: (context) => ScheduleCalendarProvider()),
      ChangeNotifierProvider<AudioCallProvider>(
          create: (context) => AudioCallProvider()),
    ], child: MyApp()));
  });
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppLifecycleState appLifecycleState;
  Timer _timerLink;
  @override
  Widget build(BuildContext context) {
    /*SystemUiOverlayStyle(
      // For Android.
      // Use [light] for white status bar and [dark] for black status bar.
      statusBarIconBrightness: Brightness.light,
      // For iOS.
      // Use [dark] for white status bar and [light] for black status bar.
      statusBarBrightness: Brightness.dark,
    );*/
    //is work only android
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Names',
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              backwardsCompatibility: false,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              brightness: Brightness.dark),
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: AppColor.skyBlueColor,
          fontFamily: "Lato_Regular"),
      onGenerateRoute: RouteGenerator.generateRoute,
      navigatorKey: navigatorKey,
      home: SplashScreen(),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (mounted) {
      FirebasePushNotification.instance();
      dynamicLinkService.handleDynamicLinks();
    }
  }

  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    print("data==" + data.toString());
    print("initDynamicLinks");
    if (data != null) {
      dynamicLinkService.handleDeepLink(data);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timerLink != null) {
      _timerLink.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (appUserSession.value != null) {
          FirebaseFirestore.instance
              .collection(FirebaseKey.usersStatus)
              .doc(appUserSession.value.id.toString())
              .set({
            FirebaseKey.isOnline: true,
            FirebaseKey.onlineTime: FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }
        /* _timerLink = new Timer(const Duration(milliseconds: 850), () {
          dynamicLinkService.handleDynamicLinks();
        });*/

        break;
      default:
        {
          if (appUserSession.value != null) {
            FirebaseFirestore.instance
                .collection(FirebaseKey.usersStatus)
                .doc(appUserSession.value.id.toString())
                .set({
              FirebaseKey.isOnline: false,
              FirebaseKey.offlineTime: FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
          }

          break;
        }
    }
  }
}
