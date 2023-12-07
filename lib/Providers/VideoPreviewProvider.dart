import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkeep/flutter_callkeep.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:names/api/ApiAction.dart';
import 'package:names/api/ApiCallBackListener.dart';
import 'package:names/api/ApiRequest.dart';
import 'package:names/api/HttpMethods.dart';
import 'package:names/api/Url.dart';
import 'package:names/constants/firebaseKey.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';
import 'package:names/model/100msTokenModel.dart';
import 'package:names/model/ApiResponseModel.dart';
import 'package:names/model/CallStatusModel.dart';
import 'package:names/model/ChatModel.dart';
import 'package:names/ui/Calling/MeetingScreen.dart';

class VideoPreviewProvider extends ChangeNotifier implements HMSPreviewListener, ApiCallBackListener {
  String hmsToken;
  String username;
  String otherUserId;
  String apntoken;
  String devicetype;
  String otherUsername;
  BuildContext context;
  bool isDisposed = false;
  bool isAvailable = true;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>> streamSubcription;

  List<HMSVideoTrack> localTracks = <HMSVideoTrack>[];
  Timer timer;

  HMSSDK hmsSdk;
  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }

  addMissedCallChat() async {
    print("------------other userid-------------");
    print(otherUserId);
    String userId = otherUserId;
    Map<String, dynamic> usersCountMap = Map();
    usersCountMap[userId] = FieldValue.increment(1);
    ChatModel chatModel = ChatModel(
        null,
        "Missed Video Call",
        null,
        appUserSession.value.id.toString(),
        otherUserId,
        FieldValue.serverTimestamp(),
        'Call',
        true,
        false,
        [appUserSession.value.id.toString()]);

    await FirebaseFirestore.instance
        .collection(FirebaseKey.chatroom)
        .doc(AppHelper.getChatID(
            appUserSession.value.id.toString(), otherUserId))
        .collection(FirebaseKey.messages)
        .add(chatModel.toJson())
        .then((value) {
      print("-----------------savin message id---------------------");
      print(otherUserId);
      FirebaseFirestore.instance
          .collection(FirebaseKey.chatroom)
          .doc(AppHelper.getChatID(appUserSession.value.id.toString(), userId))
          .collection(FirebaseKey.messages)
          .doc(value.id)
          .update({
        FirebaseKey.messageID: value.id,
      }).then((valuess) {
        // AppHelper.showToastMessage( "id added in db");
        FirebaseFirestore.instance
            .collection(FirebaseKey.chatroom)
            .doc(
                AppHelper.getChatID(appUserSession.value.id.toString(), userId))
            .set({
          FirebaseKey.lastMessage: chatModel.toJsonAddId(value.id),
          FirebaseKey.unreadCount: usersCountMap,
        }, SetOptions(merge: true));
      });
    });
  }

  void initHMSSDK() async {
    print("------------------init---------------------------------");

    // create the Audio Track Settings object
    HMSAudioTrackSetting audioTrackSetting =
        HMSAudioTrackSetting(trackInitialState: HMSTrackInitState.MUTED);
    HMSVideoTrackSetting videoTrackSetting =
        HMSVideoTrackSetting(trackInitialState: HMSTrackInitState.UNMUTED);

// use the above Audio & Video Track Settings object to create HMSTrackSettings
    HMSTrackSetting trackSetting = HMSTrackSetting(
        audioTrackSetting: audioTrackSetting,
        videoTrackSetting: videoTrackSetting);

// Now, pass the Track Settings parameter while contructing the HMSSDK object
    hmsSdk = HMSSDK(hmsTrackSetting: trackSetting);
    hmsSdk.addPreviewListener(listener: this);

    await hmsSdk.build();

    HMSConfig config = HMSConfig(userName: username, authToken: hmsToken);

    hmsSdk.preview(config: config);
    print(
        "--------------------------------play--------------------------------");
    AppHelper.callRingtone();
  }

  void resetData() {
    hmsToken = null;
    username = null;
    otherUserId = null;
    context = null;
    localTracks = <HMSVideoTrack>[];
    hmsSdk = null;
    isAvailable = true;
    timer.cancel();
  }

  void leaveMeeting() {
    AppHelper.stopRingtone();
    if (streamSubcription != null) {
      streamSubcription.cancel();
    }
    hmsSdk.removePreviewListener(listener: this);
    hmsSdk.leave();
  }

  void listenToTheChanges() {
    print('------------------------stream-------------------------');
    timer = Timer.periodic(Duration(seconds: 30), (timer) {
      print("----------------------------future--------------------------");
      if (!isDisposed) {
        FirebaseHelper.callRejected(otherUserId);
        addMissedCallChat();
        FirebaseHelper.resetUserCallStatus(appUserSession.value.id.toString());
        FirebaseHelper.resetUserCallStatus(otherUserId);
      }
    });

    streamSubcription =
        FirebaseHelper.getuserCallStatus(otherUserId).listen((event) {
      if (event.data() != null) {
        print(otherUserId);
        final callModel = CallStatusModel.fromMap(event.data());

        if (callModel.callStatus == "accepted") {
          leaveMeeting();
          FirebaseHelper.callAccepted(appUserSession.value.id.toString());

          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MeetingScreen(

                      )));
        } else if (callModel.callStatus == "rejected") {
          leaveMeeting();
          if (!isDisposed) {
            print("-------------------user available----------------------");
            Navigator.of(context).pop();
          }
        }
      }
    });
  }

  @override
  void onPreview(
      {@required HMSRoom room, @required List<HMSTrack> localTracks}) {
    List<HMSVideoTrack> videoTracks = [];
    print("------------------preview----------------------");
    print(otherUserId);
    print(devicetype);
    print(apntoken);
    FirebaseHelper.isUserAvailable(otherUserId).then(
      (value) async {
        print("-------------------user available----------------------");
        print(value);
        if (value != null && value) {
         // devicetype="IOS";
if(devicetype=="IOS" &&apntoken!=null){

  HttpsCallable callable = FirebaseFunctions.instance.httpsCallable(
    'sendNotification',
    options: HttpsCallableOptions(),
  );

  try {
    final token =apntoken;
    if (token != null) {
      callable.call(<String, dynamic>{
        'id':otherUserId,
        'token': token,
        'callerName':username,
        'isVideo':true,
        'callerId':appUserSession.value.id
      });
      FirebaseHelper.updateUserCallStatusFromNotification(
          appUserSession.value.id.toString(), int.parse(otherUserId),

          token: hmsToken,
          callFrom: otherUsername,
          calltype: 1,
          callerPhoto: "");
      FirebaseHelper.updateUserCallStatusFromNotification(
          otherUserId, appUserSession.value.id,

          token: hmsToken,
          callFrom:
          appUserSession.value.firstName ?? appUserSession.value.name,
          calltype: 1,
          callerPhoto: appUserSession.value.profilePicture);
      listenToTheChanges();
      AppHelper.playRingtone();
      print("${token}");
    }
  } on FirebaseFunctionsException catch (e) {
    print(e.message.toString());
  } catch (e) {
    print(e.toString());

  }
  notifyListeners();
}else if(devicetype!="IOS" &&apntoken!=null){
          sendCallNotificationAPI(room.id, hmsToken);}
        }
        else {
          isAvailable = false;
          notifyListeners();
          Future.delayed(Duration(seconds: 2), (() {
            leaveMeeting();
            if (!isDisposed) {
              print("-------------------user available----------------------");
              Navigator.of(context).pop();
            }
          }));
        }
      },
    );

    for (var track in localTracks) {
      if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
        videoTracks.add(track as HMSVideoTrack);
      }
    }
    this.localTracks.clear();
    this.localTracks.addAll(videoTracks);
    notifyListeners();
  }

  @override
  void onHMSError({@required HMSException error}) {
    print("--------------------------error-------------------------------");
    print(error.message);
  }

  @override
  void onPeerUpdate({@required HMSPeer peer, @required HMSPeerUpdate update}) {
    // TODO: implement onPeerUpdate
  }

  @override
  void onRoomUpdate({@required HMSRoom room, @required HMSRoomUpdate update}) {
    // TODO: implement onRoomUpdate
  }

  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice currentAudioDevice,
      List<HMSAudioDevice> availableAudioDevice}) {
    // TODO: implement onAudioDeviceChanged
  }

  void generate100msTokenAPI() {
    Map<String, String> map = {};
    map['call_type'] = '1';

    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.generate100msToken,
        apiAction: ApiAction.generate100msToken,
        body: map);
  }

  void sendCallNotificationAPI(String roomId, String token) {
    Map<String, String> map = {};
    map['room_id'] = roomId;
    map['user_ids'] = json.encode([otherUserId]);
    map['ms_token'] = token;
    map['call_type'] = '1';
    ApiRequest(
        context: context,
        apiCallBackListener: this,
        showLoader: false,
        httpType: HttpMethods.POST,
        url: Url.sendCallNotification,
        apiAction: ApiAction.sendCallNotification,
        body: map);
  }

  @override
  apiCallBackListener(String action, result) {
    if (action == ApiAction.generate100msToken) {
      HmsTokenDetailModel hmsTokenDetailModel =
          HmsTokenDetailModel.fromMap(result);
      if (hmsTokenDetailModel.success) {
        hmsToken = hmsTokenDetailModel.token;
        initHMSSDK();
      } else {
        AppHelper.showToastMessage(hmsTokenDetailModel.message);
      }
    }
    else if (action == ApiAction.sendCallNotification) {
      ApiResponseModel apiResponseModel = ApiResponseModel.fromJson(result);
      if (apiResponseModel.success) {
        FirebaseHelper.updateUserCallStatusFromNotification(
            appUserSession.value.id.toString(), int.parse(otherUserId),

            token: hmsToken,
            callFrom: otherUsername,
            calltype: 1,
            callerPhoto: "");
        FirebaseHelper.updateUserCallStatusFromNotification(
            otherUserId, appUserSession.value.id,

            token: hmsToken,
            callFrom:
                appUserSession.value.firstName ?? appUserSession.value.name,
            calltype: 1,
            callerPhoto: appUserSession.value.profilePicture);
        listenToTheChanges();
        AppHelper.playRingtone();
      }
    }
  }
}
