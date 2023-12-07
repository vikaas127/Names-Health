import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/ui/fragment/InServiceFeedScreen.dart';
import 'package:names/ui/fragment/PrivateFeedScreen.dart';
import 'package:names/ui/fragment/PublicFeedScreen.dart';
import 'package:names/ui/fragment/YourNetworkFeedScreen.dart';

class YourDiaryScreen extends StatefulWidget {
  const YourDiaryScreen({Key key}) : super(key: key);

  @override
  _YourDiaryScreenState createState() => _YourDiaryScreenState();
}

class _YourDiaryScreenState extends State<YourDiaryScreen> {
  ScrollController feedController = ScrollController();
  bool privateSelected = true;
  bool networkSelected = false;
  bool inserviceSelected = false;
  bool publicSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.skyBlueColor,
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.all(5),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  GestureDetector(
                    child: Container(
                      height: double.maxFinite,
                      // width: double.maxFinite,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: privateSelected
                              ? AppColor.blueColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "PRIVATE",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: privateSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        privateSelected = true;
                        networkSelected = false;
                        publicSelected = false;
                        inserviceSelected = false;
                      });
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    child: Container(
                      height: double.maxFinite,
                      // width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: networkSelected
                              ? AppColor.blueColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "NETWORK",
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: networkSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        privateSelected = false;
                        networkSelected = true;
                        publicSelected = false;
                        inserviceSelected = false;
                      });
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    child: Container(
                      height: double.maxFinite,
                      // width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: publicSelected
                              ? AppColor.blueColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        "PUBLIC",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: publicSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        privateSelected = false;
                        networkSelected = false;
                        publicSelected = true;
                        inserviceSelected = false;
                      });
                    },
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    child: Container(
                      height: double.maxFinite,
                      // width: double.maxFinite,
                      decoration: BoxDecoration(
                          color: inserviceSelected
                              ? AppColor.blueColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        "IN-SERVICE",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color:
                              inserviceSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        privateSelected = false;
                        networkSelected = false;
                        publicSelected = false;
                        inserviceSelected = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Builder(builder: (ctx) {
                if (privateSelected) {
                  return PrivateFeedScreen();
                } else if (networkSelected) {
                  return YourNetworkFeedScreen();
                } else if (publicSelected) {
                  return PublicFeedScreen();
                } else if (inserviceSelected) {
                  return InServiceFeedScreen();
                }
                return Container();
              }),
            )
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
