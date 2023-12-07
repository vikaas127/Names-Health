import 'dart:io';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/Url.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/model/FeedModel.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:flutter_mute/flutter_mute.dart';

import '../api/ApiCallBackListener.dart';
import '../api/HttpMethods.dart';
import '../model/view_count_model.dart';

class VideoWidget extends StatefulWidget {
  String url;
  String dairyId;
  bool isLocalVideo;

  VideoWidget(this.url,this.dairyId, {this.isLocalVideo: false});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> with ApiCallBackListener{
  FlickManager flickManager;
  RingerModeStatus _soundMode = RingerModeStatus.unknown;
  String _permissionStatus;
  bool isView = false;
  ViewCountModel viewCountModel;
  FeedModel feedModel;
  Future<FeedModel> future;

  @override
  void initState() {
    if (mounted) {
      // _getCurrentSoundMode();
      _getCurrentRingerMode();
    }
    // _getPermissionStatus();

    if (widget.isLocalVideo) {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.file(File(widget.url)),
          autoPlay: false,
          autoInitialize: true);
    } else {
      flickManager = FlickManager(
          videoPlayerController: VideoPlayerController.network(widget.url),
          autoPlay: false,
          autoInitialize: true);
    }
    flickManager.flickVideoManager.addListener(() {
      if(flickManager.flickVideoManager.isPlaying && !isView){
       isView = true;
        print("view api is calling");
        if(widget.dairyId != ""){
          addViewCount().whenComplete(() =>
              Future.delayed(const Duration(seconds: 2), () {
            setState(() {
              getFeedAPI();
            });
          }));
          setState(() {});
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (flickManager != null) {
      if (flickManager.flickVideoManager.isPlaying) {
        flickManager.flickControlManager.pause();

      }
      flickManager.flickVideoManager.removeListener(() {});
      flickManager.dispose();
      flickManager = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.url),
      onVisibilityChanged: (VisibilityInfo info) {
        double visiblePercentage = info.visibleFraction * 100;
        if (visiblePercentage < 75) {
          if (flickManager != null) {
            // flickManager.flickControlManager.mute();
            flickManager.flickControlManager.pause();
          }
        }
      },
      child: Container(
        color: Colors.white,
        child: FlickVideoPlayer(
          flickManager: flickManager,
          wakelockEnabled: true,
          flickVideoWithControlsFullscreen: FlickVideoWithControls(
            controls: FlickPortraitControls(),
            videoFit: BoxFit.scaleDown,
            willVideoPlayerControllerChange: true,
            playerLoadingFallback: Positioned.fill(
              child: Image.asset(
                "assets/images/video_placeholder.jpeg",
                fit: BoxFit.cover,
                width: double.maxFinite,
                height: double.maxFinite,
              ),
            ),
          ),
          flickVideoWithControls: Container(
            constraints: BoxConstraints(
                maxHeight: AppHelper.getDeviceWidth(context) / 2,
                maxWidth: AppHelper.getDeviceWidth(context)),
            child: FlickVideoWithControls(
              controls: FlickPortraitControls(),
              videoFit: BoxFit.contain,
              willVideoPlayerControllerChange: true,
              playerLoadingFallback: Positioned.fill(
                child: Image.asset(
                  "assets/images/video_placeholder.jpeg",
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                  height: double.maxFinite,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getCurrentSoundMode() async {
    RingerModeStatus ringerStatus = RingerModeStatus.unknown;

    Future.delayed(const Duration(seconds: 1), () async {
      try {
        ringerStatus = await SoundMode.ringerModeStatus;
      } catch (err) {
        ringerStatus = RingerModeStatus.unknown;
      }

      setState(() {
        _soundMode = ringerStatus;
        if (flickManager != null && flickManager.flickControlManager != null) {
          if (_soundMode == RingerModeStatus.silent ||
              _soundMode == RingerModeStatus.vibrate) {
            flickManager.flickControlManager.mute();
          } else {
            flickManager.flickControlManager.unmute();
          }
        }
      });
    });
  }

  Future<RingerMode> _getCurrentRingerMode() async {
    RingerMode ringerMode = await FlutterMute.getRingerMode();

    setState(() {
      if (flickManager != null && flickManager.flickControlManager != null) {
        if (ringerMode == RingerMode.Vibrate ||
            ringerMode == RingerMode.Silent) {
          flickManager.flickControlManager.mute();
        } else {
          flickManager.flickControlManager.unmute();
        }
      }
    });
  }

  Future<void> _getPermissionStatus() async {
    bool permissionStatus = false;
    try {
      permissionStatus = await PermissionHandler.permissionsGranted;
      print(permissionStatus);
    } catch (err) {
      print(err);
    }

    setState(() {
      _permissionStatus =
          permissionStatus ? "Permissions Enabled" : "Permissions not granted";
    });
  }

  Future<void> addViewCount() async{
    Map<String, String> map = {};
    map['diary_id'] = widget.dairyId;

    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: true,
      httpType: HttpMethods.POST,
      url: Url.addViewCount,
      body: map,
      apiAction: ApiAction.addViewCount,
    );
  }

  getFeedAPI() {
    ApiRequest(
      context: context,
      apiCallBackListener: this,
      showLoader: false,
      httpType: HttpMethods.POST,
      url: Url.dashboardFeeds,
      apiAction: ApiAction.dashboardFeeds,
    );
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.addViewCount) {
      print("view api call");
      viewCountModel = ViewCountModel.fromJson(result);
      getFeedAPI();
     //  if ("postCommentModel.success") {
     //
     //  } else {
     //    AppHelper.showToastMessage(postCommentModel.message);
     //  }
    }else  if (action == ApiAction.dashboardFeeds) {
      feedModel = FeedModel.fromJson(result);
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
