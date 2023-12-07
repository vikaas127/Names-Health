import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:open_file_safe/open_file_safe.dart';
import 'package:path_provider/path_provider.dart';

/* Created by Bholendra Singh  */
class DownloadProgressDialog {
  static OverlayEntry currentLoader;
  static bool isShowing = false;

  static void show(
    BuildContext context,
    String url,
  ) {
    if (!isShowing) {
      currentLoader = new OverlayEntry(
        builder: (context) => Download(url),
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

class Download extends StatefulWidget {
  String url;

  Download(
    this.url,
  );

  @override
  _DownloadState createState() => _DownloadState();
}

class _DownloadState extends State<Download> {
  String progress = "";

  bool isDownloaded = false;

  bool downloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        child: Container(
          color: Colors.transparent,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Container(
              child: Stack(
                children: [
                  SizedBox(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          AppColor.darkBlueColor),
                    ),
                    height: 50,
                    width: 50,
                  ),
                  Center(
                      child: Text(
                    progress,
                    style: TextStyle(color: AppColor.darkBlueColor),
                  ))
                ],
              ),
              width: 60,
              height: 60,
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white,
                  border: Border.all(width: 1, color: AppColor.darkBlueColor)),
            ),
          ),
        ),
        onTap: () {
          // do nothing
          // DownloadProgressDialog.hide();
        },
        onDoubleTap: () {
          DownloadProgressDialog.hide();
        },
      ),
    );
  }

  @override
  void initState() {
    downloadFile();
    super.initState();
  }

  Future<void> downloadFile() async {
    String fileName = widget.url.substring(widget.url.lastIndexOf("/") + 1);
    Directory directory = await getApplicationSupportDirectory();
    Directory appDocDirFolder = Directory('${directory.path}/Names/');
    if (!appDocDirFolder.existsSync()) {
      appDocDirFolder.createSync(recursive: true);
    }
    File file = File(appDocDirFolder.path + fileName);
    if (file.existsSync()) {
      DownloadProgressDialog.hide();
      OpenFile.open(file.path).then((value) => _showErrorMsg(value));
    } else {
      file.createSync(recursive: true);
      Dio().download(
        widget.url,
        file.path,
        onReceiveProgress: (rcv, total) {
          print(
              'received: ${rcv.toStringAsFixed(0)} out of total: ${total.toStringAsFixed(0)}');

          setState(() {
            progress = ((rcv / total) * 100).toStringAsFixed(0);
          });

          if (progress == '100') {
            setState(() {
              isDownloaded = true;
            });
          } else if (double.parse(progress) < 100) {}
        },
        deleteOnError: true,
      ).then((_) {
        setState(() {
          if (progress == '100') {
            isDownloaded = true;
          }

          downloading = false;
        });
      }).catchError((onError) {
        AppHelper.showToastMessage(
            "Something went wrong please try after some time.");
        DownloadProgressDialog.hide();
      }).whenComplete(() {
        if (isDownloaded) {
          // AppHelper.showToastMessage("File downloaded");
          DownloadProgressDialog.hide();
          OpenFile.open(file.path).then((value) => _showErrorMsg(value));
        }
      });
    }
  }

  _showErrorMsg(value) {
    if (value != null) {
      OpenResult openResult = value;

      if (openResult.type != ResultType.done) {
        AppHelper.showToastMessage(openResult.message.toString());
      }
    }
  }
}
