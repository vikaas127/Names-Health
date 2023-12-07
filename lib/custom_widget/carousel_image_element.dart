import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:names/custom_widget/video_widget.dart';
import 'package:photo_view/photo_view.dart';

import '../constants/app_color.dart';
import '../helper/AppHelper.dart';
import '../helper/ProgressDialog.dart';
import '../model/save_video_model.dart';

class CarouselImageElement extends StatefulWidget {
  List<Datum> imagesList = [];
  CarouselImageElement({Key key, this.imagesList}) : super(key: key);

  @override
  State<CarouselImageElement> createState() => _CarouselImageElementState();
}

class _CarouselImageElementState extends State<CarouselImageElement> {
  int current = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Container(
            margin: const EdgeInsets.symmetric(vertical: 45),
            child: Column(children: [
              Container(
                margin: const EdgeInsets.only(left: 20, bottom: 20),
                child: Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.close,
                        size: 30,
                        color: Colors.white,
                      )),
                ),
              ),
              Expanded(
                  child: Column(
                      children: [
                        Expanded(
                          child: CarouselSlider.builder(
                            itemCount: widget.imagesList.length,
                            options: CarouselOptions(
                                autoPlay: false,
                                aspectRatio : 5 / 9,
                                onPageChanged: (int currentIndex,
                                    CarouselPageChangedReason reason) {
                                  setState(() {
                                    current = currentIndex;
                                  });
                                },
                                enlargeCenterPage: true,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: widget.imagesList.length > 2),
                            itemBuilder: (BuildContext context, int index, int realIndex) {
                              // if (widget.imagesList[index].mediaType.toString() ==
                              //     "2") {
                                return Container(
                                  height: AppHelper.getDeviceWidth(context) / 2,
                                  child: InkWell(
                                    onTap: (){
                                      print("view api is calling");
                                      setState(() {

                                      });
                                    },
                                    child: VideoWidget(

                                        Uri.parse(widget.imagesList[index].media)
                                            .toString(),widget.imagesList[index].id.toString()
                                    ),
                                  ),
                                );
                              // } else {
                              //   return Container(
                              //     height: AppHelper.getDeviceWidth(context) / 1,
                              //     width: AppHelper.getDeviceWidth(context) / 1,
                              //     // child: Image.network(widget.imagesList[index].media,
                              //     // )
                              //     child:  PhotoView(
                              //         loadingBuilder: ((context, event) =>
                              //             ProgressDialog.getCircularProgressIndicator()),
                              //         minScale: PhotoViewComputedScale.contained * 0.7,
                              //         maxScale: PhotoViewComputedScale.covered * 9,
                              //         imageProvider:
                              //         NetworkImage(widget.imagesList[index].media,)
                              //     ),
                              //   );
                              // }
                            },
                          ),
                        ),
                        widget.imagesList.length > 1
                            ? SizedBox(
                          height: 10,
                        )
                            : SizedBox(),
                        widget.imagesList.length > 1
                            ? Container(
                          height: 10,
                          alignment: Alignment.center,
                          child: Center(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemBuilder: (ctx, index) {
                                return Container(
                                  height: 10,
                                  width: current == index ? 30 : 10,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                    color: current == index
                                        ? AppColor.blueColor
                                        : Colors.grey,
                                  ),
                                );
                              },
                              scrollDirection: Axis.horizontal,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: widget.imagesList.length,
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Container(
                                  height: 5,
                                  width: 5,
                                );
                              },
                            ),
                          ),
                        )
                            : SizedBox(),
                      ]))
            ])));
  }
}
