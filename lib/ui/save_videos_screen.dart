import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/custom_widget/carousel_image_element.dart';
import 'package:names/custom_widget/image_slider.dart';
import 'package:names/custom_widget/imge_slider_element.dart';
import 'package:names/custom_widget/video_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/save_video_model.dart';

import '../api/ApiCallBackListener.dart';
import '../api/Url.dart';
import '../constants/app_color.dart';
import '../helper/ProgressDialog.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class SaveVideoScreen extends StatefulWidget {
  String title = null;
  SaveVideoScreen({Key key,  this.title}) : super(key: key);

  @override
  State<SaveVideoScreen> createState() => _SaveVideoScreenState();
}

class _SaveVideoScreenState extends State<SaveVideoScreen> with ApiCallBackListener{

  _appBarWidget(BuildContext context) {
    return Row(
      children: [
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
            widget.title,
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
      ],
    );
  }
  ScrollController _scrollController = ScrollController();
  SaveVideoModel feedModel;
  Future<SaveVideoModel> future;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size(200, 60),
          child: Column(
            children: [
              AppHelper.appBar(
                  context,
                  _appBarWidget(context),
                  LinearGradient(colors: [
                    AppColor.skyBlueColor,
                    AppColor.skyBlueColor
                  ])),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          child: FutureBuilder<SaveVideoModel>(
              future: future, // async work
              builder: (BuildContext context, AsyncSnapshot<SaveVideoModel> snapshot) {
                if (snapshot.hasData) {
                  return feedModel.data.length > 0
                      ?  ListView.builder(
                    itemCount: feedModel.data.length,
                    shrinkWrap: true,
                    physics: ClampingScrollPhysics(),
                    controller: _scrollController,
                    itemBuilder: (ctx, index) {
                      // MediasData feed = feedModel.data.feedList[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 20),
                        width: AppHelper.getDeviceWidth(context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 0),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: GestureDetector(
                                onDoubleTap: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => CarouselImageElement(
                                        imagesList: feedModel.data,
                                      )));
                                },
                                child: Container(
                                  height: AppHelper.getDeviceWidth(context) / 2,
                                  child: VideoWidget(
                                      Uri.parse(feedModel.data[index].media).toString(),""
                                     // widget.imagesList[index].id.toString()
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  )
                      : SizedBox();
                }
                return ProgressDialog.getCircularProgressIndicator();
              }),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState(); // Call super.initState() first

    if (mounted) {
      getSaveVideo(); // Call the function without extra parentheses
    }
  }
  getSaveVideo() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: Url.listSaveVideo,
      apiAction: ApiAction.listSaveVideo,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.listSaveVideo) {
      feedModel = SaveVideoModel.fromJson(result);
      if (feedModel.success) {
        future = Future.delayed(Duration(seconds: 0), () {
          if (mounted) {
            setState(() {});
          }
          return feedModel;
        });
      } else {
        AppHelper.showToastMessage(feedModel.message);
      }
    }
  }
}
