import 'dart:io';

import 'package:flutter/material.dart';
import 'package:names/Providers/AudioCallProvider.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class AudioCallScreen extends StatefulWidget {



  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen> {
  // Initialize variables and join room
  AudioCallProvider _audioCallProvider;
  @override
  void initState() {
    init();
    _audioCallProvider = Provider.of<AudioCallProvider>(context, listen: false);
    _audioCallProvider.context = context;
 //   _audioCallProvider.authToken = widget.token;
    _audioCallProvider.isDisposed = false;
  //  _audioCallProvider.otherUserId = widget.otherUserId;

    _audioCallProvider.getinitdata();
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
    _audioCallProvider.isDisposed = true;
    super.dispose();
  }
  _appBarWidget(context) {
    return  Consumer<AudioCallProvider>(
        builder: ((context, value, child) =>
      Row(
      children: [
        Container(
          child: IconButton(
            icon: Image.asset("assets/icons/back_arrow.png",
                height: 20, width: 20, color: Colors.black),
            onPressed: () async {
              if (_audioCallProvider.localPeer != null)
                Navigator.of(context).pop();
            },
          ),
        ),
        Expanded(
          child: Text(
            "${value.otherUserName}" ?? "",
            style: TextStyle(
                fontSize: 20, fontFamily: "Lato_Bold", color: Colors.black),
          ),
        ),
      ],
    )));
  }
  // Widget to render grid of peer tiles and a end button
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        // Used to call "leave room" upon clicking back button [in android]
        onWillPop: () async {
          return true;
        },
        child: Scaffold(
            backgroundColor: Colors.black,
            appBar:
            AppHelper.appBar(
              context,

              _appBarWidget(context),
              LinearGradient(
                  colors: [AppColor.skyBlueColor, AppColor.skyBlueColor]),
            ),
            body: Consumer<AudioCallProvider>(
              builder: ((context, value, child) => Column(children: [
                    SizedBox(
                      height: 20,
                    ),
                    Spacer(),
                    if (value.isConnecting)
                      Text(
                        "Connecting...",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      height: 180,
                      width: 180,
                      child: CustomWidget.imageView(
                        value.otherUserProfilePic,
                        fit: BoxFit.cover,
                        height: 180,
                        width: 180,
                        circle: true,
                        forProfileImage: true,
                      ),
                    ),
                    Spacer(),
                    Container(
                      height: Platform.isAndroid ? 80 : 100,
                      padding:
                          EdgeInsets.only(bottom: Platform.isAndroid ? 10 : 30),
                      decoration: BoxDecoration(color: Colors.grey[800]),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
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
            )));
  }
}
