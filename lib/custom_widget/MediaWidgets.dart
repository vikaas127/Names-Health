import 'package:flutter/material.dart';
import 'package:names/custom_widget/video_widget.dart';
import 'package:names/model/FeedModel.dart';

import '../helper/AppHelper.dart';
import 'image_slider.dart';

class MediaWidgets extends StatelessWidget {
  List<Medias> medias;
  List<Medias> imageMedias = [];
  Medias videoMedia = null;
  MediaWidgets({Key key, this.medias}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _sortList();
    return Column(
      children: [
        videoMedia != null
            ? Container(
                height: AppHelper.getDeviceWidth(context) / 2,
                child: VideoWidget(
                  Uri.parse(videoMedia.media).toString(),videoMedia.id.toString(),
                ),
              )
            : Container(),
        if (imageMedias.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 10),
            child: ImageSlider(imageMedias, ""),
          )
        else
          Container()
      ],
    );
  }

  void _sortList() {
    imageMedias.clear();
    for (var items in medias) {
      if (items.mediaType.toString() == "2") {
        videoMedia = items;
      } else {
        imageMedias.add(items);
      }
    }
  }
}
