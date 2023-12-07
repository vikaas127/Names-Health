import 'package:flutter/material.dart';
import 'package:names/model/UsersModel.dart';
import 'package:names/route/routes.dart';
import 'package:names/ui/AddNewPost.dart';
import 'package:names/ui/ChangePassword.dart';
import 'package:names/ui/DashboardScreen.dart';
import 'package:names/ui/ForgotScreen.dart';
import 'package:names/ui/IntroScreen.dart';
import 'package:names/ui/LoginScreen.dart';
import 'package:names/ui/OTPScreen.dart';
import 'package:names/ui/PostLikeScreen.dart';
import 'package:names/ui/RegisterScreen.dart';
import 'package:names/ui/SplashScreen.dart';
import 'package:names/ui/UpdatePost.dart';
import 'package:names/ui/UpdateProfile.dart';
import 'package:upgrader/upgrader.dart';

import '../ui/UserProfileScreen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Getting arguments passed in while calling Navigator.pushNamed
    final appcastURL = 'https://names.health/public/appcast.xml';
    //final appcastURL = 'https://raw.githubusercontent.com/larryaasen/upgrader/master/test/testappcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ['android','ios']);

    String name = settings.name;
    switch (name) {
      case Routes.SplashScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              SplashScreen(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.IntroScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              IntroScreen(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.LoginScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              LoginScreen(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.RegisterScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              RegisterScreen(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.ForgotScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              ForgotScreen(),
          transitionDuration: Duration(seconds: 0),
        );

      case Routes.DashboardScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              UpgradeAlert(
                  upgrader: Upgrader(
                      //willDisplayUpgrade: ,
                      appcastConfig: cfg,
                      dialogStyle: UpgradeDialogStyle.cupertino),
                  child: DashboardScreen()),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.ChangePassword:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              ChangePassword(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.UpdateProfile:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              UpdateProfile(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.OTPScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              OTPScreen(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.AddNewPost:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              AddNewPost(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.UpdatePost:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              UpdatePost(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.PostLikeScreen:
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              PostLikeScreen(),
          transitionDuration: Duration(seconds: 0),
        );
      case Routes.UserProfileScreen:
        UsersModel userModels=settings.arguments as UsersModel;
        return PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              UserProfileScreen(usersModel: userModels,),
          transitionDuration: Duration(seconds: 0),
        );
    }
  }
}
