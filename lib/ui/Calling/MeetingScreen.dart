import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:names/Providers/VideoCallProvider.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class MeetingScreen extends StatefulWidget {

  const MeetingScreen({Key key, })
      : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  VideoCallProvider _videoPreviewProvider;
  // Initialize variables and join room
  @override
  void initState() {
    init();
    _videoPreviewProvider =
        Provider.of<VideoCallProvider>(context, listen: false);
    _videoPreviewProvider.context = context;
   // _videoPreviewProvider.authToken = widget.authToken;
    _videoPreviewProvider.isDisposed = false;
    _videoPreviewProvider.getinitdata();
    super.initState();
  }

  Future<void> init() async {
    await Wakelock.enable();
  }

  // Clear all variables
  @override
  void dispose() {
    print(
        "--------------------------dispose meeting------------------------------");
    _videoPreviewProvider.isDisposed = true;
    super.dispose();
  }

  _appBarWidget(context) {
    return  Consumer<VideoCallProvider>(
        builder: ((context, value, child) =>
      Row(
      children: [
        Container(
          child: IconButton(
            icon: Image.asset("assets/icons/back_arrow.png",
                height: 20, width: 20, color: Colors.black),
            onPressed: () async {
              await _videoPreviewProvider.hmsSDK.switchVideo(isOn: false);
              Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: Text(
            "${value.otherUserName}"??"",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
      ],
    )));
  }
  // Called when peer joined the room - get current state of room by using HMSRoom obj

  // Widget to render a single video tile
  Widget peerTile(Key key, HMSVideoTrack videoTrack, HMSPeer peer) {
    return Container(
      key: key,
      child: (videoTrack != null)
          // Actual widget to render video
          ? HMSVideoView(
              track: videoTrack,
              setMirror: true,
              scaleType: ScaleType.SCALE_ASPECT_FILL,
            )
          : Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(4),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.blue,
                      blurRadius: 20.0,
                      spreadRadius: 5.0,
                    ),
                  ],
                ),
                child: Text(
                  peer != null && peer.name != null
                      ? peer.name.substring(0, 1) ?? "D"
                      : "",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }

  // Widget to render grid of peer tiles and a end button
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppHelper.appBar(
          context,
          _appBarWidget(context),
          LinearGradient(
              colors: [AppColor.skyBlueColor, AppColor.skyBlueColor]),
        ),
        body: Consumer<VideoCallProvider>(
          builder: ((context, value, child) => Column(children: [
                StreamBuilder<ConnectivityResult>(
                    stream: AppHelper.internetConnectivityStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData &&
                              snapshot.data == ConnectivityResult.wifi ||
                          snapshot.data == ConnectivityResult.mobile) {
                        return Expanded(
                          child: Column(children: [
                            if (value.remotePeer != null &&
                                value.remotePeerVideoTrack != null)
                              Expanded(
                                  child: !(value.remotePeerVideoTrack.isMute)
                                      ? peerTile(
                                          Key(value.remotePeerVideoTrack
                                                  ?.trackId ??
                                              "" "mainVideo"),
                                          value.remotePeerVideoTrack,
                                          value.remotePeer)
                                      : Container(
                                          width:
                                              AppHelper.getDeviceWidth(context),
                                          color: Colors.grey,
                                          child: Center(
                                              child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                Icon(
                                                  Icons.videocam_off,
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "Video Paused",
                                                )
                                              ])),
                                        )),
                            Expanded(
                                child: value.isVideoOn
                                    ? peerTile(
                                        Key(value
                                                .localPeerVideoTrack?.trackId ??
                                            "" "mainVideo"),
                                        value.localPeerVideoTrack,
                                        value.localPeer)
                                    : Container(
                                        width:
                                            AppHelper.getDeviceWidth(context),
                                        color: AppColor.skyBlueBoxColor,
                                        child: Center(
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                              Icon(
                                                Icons.videocam_off,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Video Paused (You)",
                                              )
                                            ])),
                                      ))
                          ]),
                        );
                      } else {
                        return Expanded(
                          child: Center(
                            child: Text("No internet connection available."),
                          ),
                        );
                      }
                    }),
                Container(
                  height: Platform.isAndroid ? 80 : 100,
                  padding:
                      EdgeInsets.only(bottom: Platform.isAndroid ? 10 : 30),
                  decoration: BoxDecoration(color: Colors.black),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RawMaterialButton(
                          onPressed: () async {
                            await value.hmsSDK.switchCamera();
                          },
                          elevation: 2.0,
                          fillColor: Colors.grey,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: Icon(
                            Icons.camera_alt,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RawMaterialButton(
                          onPressed: () async {
                            await value.hmsSDK
                                .switchAudio(isOn: value.isAudioOn);
                            setState(() {});
                            value.isAudioOn = !value.isAudioOn;
                          },
                          elevation: 2.0,
                          fillColor: Colors.grey,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: Icon(
                            value.isAudioOn ? Icons.mic : Icons.mic_off,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RawMaterialButton(
                          onPressed: () async {
                            await value.hmsSDK
                                .switchVideo(isOn: value.isVideoOn);
                            setState(() {});

                            value.isVideoOn = !value.isVideoOn;
                          },
                          elevation: 2.0,
                          fillColor: Colors.grey,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: Icon(
                            value.isVideoOn
                                ? Icons.videocam
                                : Icons.videocam_off,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: RawMaterialButton(
                          onPressed: () {
                            value.endRoom();
                          },
                          elevation: 2.0,
                          fillColor: Colors.red,
                          padding: const EdgeInsets.all(15.0),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.call_end,
                            size: 25.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ])),
        ));
  }
}
