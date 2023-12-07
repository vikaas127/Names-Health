import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:names/Providers/VideoPreviewProvider.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';
import '../../main.dart';

class PreviewScreen extends StatefulWidget {
  final String username;
  final String apntoken;
  final String devicetype;
  final String otherUserName;
  final String otherUserId;
  const PreviewScreen(
      {Key key, this.username, this.otherUserName, this.otherUserId, this.apntoken, this.devicetype})
      : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPreviewProvider _videoPreviewProvider;
  @override
  void initState() {
    init();
    _videoPreviewProvider = Provider.of<VideoPreviewProvider>(context, listen: false);
    print("-------------------i nit ccalled------------");
    print(widget.apntoken);
    _videoPreviewProvider.context = context;
    _videoPreviewProvider.username = widget.username;
    _videoPreviewProvider.otherUserId = widget.otherUserId;
    _videoPreviewProvider.devicetype = widget.devicetype;
    _videoPreviewProvider.apntoken = widget.apntoken;
    _videoPreviewProvider.otherUsername = widget.otherUserName;
    _videoPreviewProvider.isDisposed = false;
    _videoPreviewProvider.generate100msTokenAPI();

    super.initState();
  }

  Future<void> init() async {
    await Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    print("-------------------------------build called---------------------");
    var size = MediaQuery.of(context).size;
    final double itemHeight = size.height;
    final double itemWidth = size.width;

    return WillPopScope(
        onWillPop: () async {
          _videoPreviewProvider.addMissedCallChat();
          FirebaseHelper.resetUserCallStatus(
              appUserSession.value.id.toString());
          FirebaseHelper.resetUserCallStatus(widget.otherUserId);
          _videoPreviewProvider.leaveMeeting();

          return true;
        },
        child: Scaffold(
          body: Consumer<VideoPreviewProvider>(
            builder: ((context, value, child) => Container(
                  height: AppHelper.getDeviceHeight(context),
                  child: value.localTracks.isNotEmpty
                      ? SizedBox(
                          height: itemHeight,
                          width: itemWidth,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              HMSVideoView(
                                track: value.localTracks[0],
                                scaleType: ScaleType.SCALE_ASPECT_FILL,
                                setMirror: true,
                              ),
                              Positioned(
                                top: 160,
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.otherUserName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        !value.isAvailable
                                            ? "is on another call"
                                            : "Calling",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 18),
                                      ),
                                    ]),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 30),
                                  child: RawMaterialButton(
                                    onPressed: () async {
                                      value.addMissedCallChat();
                                      FirebaseHelper.resetUserCallStatus(
                                          appUserSession.value.id.toString());
                                      FirebaseHelper.resetUserCallStatus(
                                          widget.otherUserId);
                                      value.leaveMeeting();

                                      Navigator.pop(context);
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
                              ),
                            ],
                          ),
                        )
                      : SizedBox(
                          height: itemHeight / 1.3,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                )),
          ),
        ));
  }

  @override
  void dispose() {
    print("-------------------dispose called----------------------");
    _videoPreviewProvider.isDisposed = true;
    _videoPreviewProvider.resetData();
    super.dispose();
  }
}
