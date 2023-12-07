import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';

/* Created by Bholendra Singh  */
class ProgressDialog {
  static OverlayEntry currentLoader;
  static bool isShowing = false;

  static void show(BuildContext context) {
    if (!isShowing) {
      currentLoader = new OverlayEntry(
        builder: (context) => GestureDetector(
          child: Container(
            color: Colors.transparent,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    child: getCircularProgressIndicator(),
                    width: 50,
                    height: 50,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white,
                        border: Border.all(
                            width: 1, color: AppColor.darkBlueColor)),
                  )
                ],
              ),
            ),
          ),
          onTap: () {
            // do nothing
          },
          onDoubleTap: () {
            ProgressDialog.hide();
          },
        ),
      );
      Overlay.of(context).insert(currentLoader);
      isShowing = true;
    }
  }

  static void hide() {
    if (currentLoader != null) {
      currentLoader?.remove();
      isShowing = false;
      currentLoader = null;
    }
  }

  static getCircularProgressIndicator({double height, double width}) {
    if (height == null) {
      height = 40.0;
    }
    if (width == null) {
      width = 40.0;
    }
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(AppColor.darkBlueColor),
        ),
        height: height,
        width: width,
      ),
    );
  }

  static getErrorWidget() {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        child: Text("Oops! Something went wrong."),
      ),
    );
  }
}
