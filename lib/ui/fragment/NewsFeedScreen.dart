import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/model/NewsFeedModel.dart';
import 'package:names/ui/fragment/NewsFeedInService.dart';
import 'package:names/ui/fragment/NewsFeedPublic.dart';
import 'package:names/ui/fragment/NewsFeedYourNetwork.dart';

class NewsFeedScreen extends StatefulWidget {
  const NewsFeedScreen({Key key}) : super(key: key);

  @override
  _NewsFeedScreenState createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  List<NewsFeedModel> feedList = [];

  ScrollController feedController = ScrollController();
  bool networkSelected = true;
  bool publicSelected = false;
  bool inserviceSelected = false;

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
                      decoration: BoxDecoration(
                          color: networkSelected
                              ? AppColor.blueColor
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "YOUR NETWORK",
                        softWrap: true,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: networkSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
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
                          fontWeight: FontWeight.bold,
                          color: publicSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
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
                          fontWeight: FontWeight.bold,
                          color:
                              inserviceSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        networkSelected = false;
                        publicSelected = false;
                        inserviceSelected = true;
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Builder(builder: (ctx) {
                if (networkSelected) {
                  return NewsFeedYourNetwork();
                } else if (publicSelected) {
                  return NewsFeedPublic();
                } else if (inserviceSelected) {
                  return NewsFeedInServiceScreen();
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
    for (int i = 0; i < 20; i++) {
      if (i == 3) {
        feedList.add(NewsFeedModel(
            userProfile: "assets/images/person.jpeg",
            userName: "Robert F. Guard",
            location: "Allentown, New Mexico",
            title: "Health Benefits",
            file:
                "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
            type: "VIDEO",
            likeCount: (i * 20).toString(),
            description:
                "The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states.",
            time: "28 April"));
      }
      if (i == 5) {
        feedList.add(NewsFeedModel(
            userProfile: "assets/images/person.jpeg",
            userName: "Robert F. Guard",
            location: "Allentown, New Mexico",
            title: "Health Benefits",
            file:
                "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            type: "VIDEO",
            likeCount: (i * 20).toString(),
            description:
                "The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states.",
            time: "28 April"));
      }
      if (i == 4) {
        feedList.add(NewsFeedModel(
            userProfile: "assets/images/person.jpeg",
            userName: "Robert F. Guard",
            location: "Allentown, New Mexico",
            title: "Health Benefits",
            type: "IMAGE",
            likeCount: (i * 20).toString(),
            description:
                "The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states.",
            time: "28 April"));
      }
      feedList.add(NewsFeedModel(
          userProfile: "assets/images/person.jpeg",
          userName: "Robert F. Guard",
          location: "Allentown, New Mexico",
          title: "Health Benefits",
          file: "assets/images/feed_image.png",
          type: "IMAGE",
          likeCount: (i * 20).toString(),
          description:
              "The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states The Medical Content department is comprised of top medical writers and editors with in-depth experience in a broad range of disease states.",
          time: "28 April"));
    }
    super.initState();
  }

  void showDeleteDialog(int index) {
    showDialog(
      context: context,
      useSafeArea: true,
      builder: (BuildContext ctx) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            content: Wrap(
              children: [
                Container(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Align(
                            alignment: Alignment.topRight,
                            child: GestureDetector(
                              child: Image.asset(
                                "assets/icons/close.png",
                                height: 16,
                                width: 16,
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Are you sure to delete\nthe post?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            child: Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: Colors.red,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "YES",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                            },
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            child: Container(
                              height: 30,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                color: AppColor.lightSkyBlueColor,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                "NO",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ));
      },
    );
  }
}
