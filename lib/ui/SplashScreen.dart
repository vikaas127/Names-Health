import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/route/routes.dart';
import 'package:upgrader/upgrader.dart';

import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: AppColor.skyBlueColor,
    ));

    return Scaffold(
      backgroundColor: AppColor.skyBlueColor,
      body: Container(
        child: Image.asset(
          "assets/images/splash.png",
          width: AppHelper.getDeviceWidth(context),
          height: AppHelper.getDeviceHeight(context),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  @override
  void initState() {
    Future.delayed(Duration(seconds: 3), () {
      if (appUserSession.value != null && appUserSession.value.token != null) {
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.DashboardScreen, (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.IntroScreen, (route) => false);
      }
    });
    super.initState();
  }
}
