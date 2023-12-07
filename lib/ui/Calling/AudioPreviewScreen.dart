import 'package:flutter/material.dart';
import 'package:names/Providers/AudioPreviewProvider.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/custom_widget.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/helper/ProgressDialog.dart';
import 'package:names/main.dart';
import 'package:provider/provider.dart';
import 'package:wakelock/wakelock.dart';

class AudioPreviewScreen extends StatefulWidget {
  final String username;
  final String otherUserName;
  final String apntoken;
  final String devicetype;
  final String otherUserId;
  final String profilePicture;
  const AudioPreviewScreen(
      {Key key,
      this.username,
      this.otherUserName,
      this.otherUserId,
      this.profilePicture, this.apntoken, this.devicetype})
      : super(key: key);

  @override
  State<AudioPreviewScreen> createState() => _AudioPreviewScreenState();
}

class _AudioPreviewScreenState extends State<AudioPreviewScreen> {
  AudioPreviewProvider _audioPreviewProvider;
  @override
  void initState() {
    init();
    _audioPreviewProvider = Provider.of<AudioPreviewProvider>(context, listen: false);
    _audioPreviewProvider.context = context;
    _audioPreviewProvider.otherUserId = widget.otherUserId;
    _audioPreviewProvider.otherUsername = widget.otherUserName;
    _audioPreviewProvider.profilePicture = widget.profilePicture;
    _audioPreviewProvider.username = widget.username;
    _audioPreviewProvider.apntoken = widget.apntoken;
    _audioPreviewProvider.devicetype = widget.devicetype;
    _audioPreviewProvider.isDisposed = false;
    _audioPreviewProvider.generate100msTokenAPI();

    super.initState();
  }

  Future<void> init() async {
    await Wakelock.enable();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          _audioPreviewProvider.addMissedCallChat();
          FirebaseHelper.resetUserCallStatus(
              appUserSession.value.id.toString());
          FirebaseHelper.resetUserCallStatus(widget.otherUserId);
          _audioPreviewProvider.leaveMeeting();

          return true;
        },
        child: Scaffold(
            backgroundColor: AppColor.skyBlueColor,
            body: Consumer<AudioPreviewProvider>(
                builder: (context, value, child) {
              if (value.notificationSend) {
                return Container(
                  color: Colors.black,
                  padding: EdgeInsets.all(40),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          child: CustomWidget.imageView(
                            widget.profilePicture,
                            fit: BoxFit.cover,
                            height: 100,
                            width: 100,
                            circle: true,
                            forProfileImage: true,
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          widget.otherUserName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          !value.isAvailable ? "is on another call" : "Calling",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Spacer(),
                        Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            onTap: () {
                              value.addMissedCallChat();
                              FirebaseHelper.resetUserCallStatus(appUserSession.value.id.toString());
                              FirebaseHelper.resetUserCallStatus(widget.otherUserId);
                              value.leaveMeeting();
                              Navigator.of(context).pop();
                            },
                            child: Container(
                                margin: EdgeInsets.only(bottom: 20),
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    color: Colors.red),
                                child: Icon(
                                  Icons.call_end,
                                  color: Colors.white,
                                )),
                          ),
                        )
                      ]),
                );
              } else {
                return Center(
                  child: ProgressDialog.getCircularProgressIndicator(),
                );
              }
            })));
  }

  @override
  void dispose() {
    print("-------------------dispose called----------------------");
    _audioPreviewProvider.isDisposed = true;
    _audioPreviewProvider.resetData();
    super.dispose();
  }
}
