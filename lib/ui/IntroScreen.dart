import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/route/routes.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key key}) : super(key: key);

  @override
  _IntroScreenState createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  int seletedIndex = 0;

  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [
      Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Networking Platform".toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Roboto_Bold", fontSize: 26),
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/images/slider1.png",
              height: AppHelper.getDeviceWidth(context) / 1.5,
              width: AppHelper.getDeviceWidth(context),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Create, share, and stay up to date with colleagues, organizations, and industry trends",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Roboto_Regular",
                  fontSize: 16,
                  color: AppColor.textGrayColor),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Professional Record Storage".toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Roboto_Bold", fontSize: 26),
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/images/slider2.png",
              height: AppHelper.getDeviceWidth(context) / 1.5,
              width: AppHelper.getDeviceWidth(context),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Safe and secure storage of your most important professional documents.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Roboto_Regular",
                  fontSize: 16,
                  color: AppColor.textGrayColor),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Building connections\nIn Healthcare".toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: "Roboto_Bold", fontSize: 26),
            ),
            SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/images/slider3.png",
              height: AppHelper.getDeviceWidth(context) / 1.5,
              width: AppHelper.getDeviceWidth(context),
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Creating Healthy and productive work environments begins with connecting the right healthcare professionals with the right organization",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: "Roboto_Regular",
                  fontSize: 16,
                  color: AppColor.textGrayColor),
            )
          ],
        ),
      ),
    ];
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
      statusBarColor: AppColor.skyBlueColor,
    ));

    return Scaffold(
      backgroundColor: AppColor.skyBlueColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    itemBuilder: (ctx, index) {
                      return list[index];
                    },
                    controller: pageController,
                    onPageChanged: (index) {
                      setState(() {
                        seletedIndex = index;
                      });
                    },
                    itemCount: list.length,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  height: 10,
                  alignment: Alignment.center,
                  child: Center(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (ctx, index) {
                        return Container(
                          height: 10,
                          width: seletedIndex == index ? 30 : 10,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            color: seletedIndex == index
                                ? AppColor.blueColor
                                : Colors.grey,
                          ),
                        );
                      },
                      scrollDirection: Axis.horizontal,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: list.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 5,
                          width: 5,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                child: Container(
                  margin: EdgeInsets.all(20),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                        fontSize: 16,
                        color: AppColor.lightSkyBlueColor,
                        fontFamily: "Lato_Bold"),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      Routes.LoginScreen, (route) => false);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
