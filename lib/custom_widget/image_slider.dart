import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/CarouselImageSlider.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/custom_widget/video_widget.dart';
import 'package:names/model/FeedModel.dart';

import '../helper/AppHelper.dart';

class ImageSlider extends StatefulWidget {
  List<Medias> imagesList = [];
  String diaryId;

  ImageSlider(
    this.imagesList,this.diaryId
  );

  @override
  _ImageSliderState createState() => _ImageSliderState();
}

class _ImageSliderState extends State<ImageSlider> {
  int current = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(children: [
      CarouselSlider.builder(
        itemCount: widget.imagesList.length,
        options: CarouselOptions(
            // autoPlay: widget.imagesList.length > 1 ? true : false,
            autoPlay: false,
            onPageChanged:
                (int currentIndex, CarouselPageChangedReason reason) {
              setState(() {
                current = currentIndex;
              });
            },
            enlargeCenterPage: false,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.imagesList.length > 2),
        itemBuilder: (BuildContext context, int index, int realIndex) {
          if (widget.imagesList[index].mediaType.toString() == "2") {
            return GestureDetector(
              onDoubleTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CarouselImage(
                          imagesList: widget.imagesList,
                        )));
              },
              child: Container(
                height: AppHelper.getDeviceWidth(context) / 2,
                child: VideoWidget(
                  Uri.parse(widget.imagesList[index].media).toString(),
                    widget.diaryId
                ),
              ),
            );
          } else {
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => CarouselImage(
                          imagesList: widget.imagesList,
                        )));
              },
              child: CustomWidget.imageView(widget.imagesList[index].media,
                  fit: BoxFit.contain, width: 200, height: 200),
            );
          }
        },
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
                            ? AppColor.darkBlueColor
                            : Colors.grey,
                      ),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: widget.imagesList.length,
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(
                      height: 5,
                      width: 5,
                    );
                  },
                ),
              ),
            )
          : SizedBox(),
    ]));
  }
}
