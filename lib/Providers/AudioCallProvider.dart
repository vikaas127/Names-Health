import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/main.dart';

import '../constants/firebaseKey.dart';

class AudioCallProvider extends ChangeNotifier
    with HMSUpdateListener, HMSActionResultListener {
  bool isAudioOn = true;
  String authToken;
  BuildContext context;
  bool enableRoomEnd = false;
  String otherUserName,otherUserProfilePic;
  int otherUserId;
  bool isConnecting = true;

  // Variables required for joining a room

  HMSPeer localPeer, remotePeer;
  HMSSDK hmsSDK;
  bool isDisposed = false;
  bool onCall = false;
  @override
  void notifyListeners() {
    if (!isDisposed) {
      super.notifyListeners();
    }
  }
Future<void> getinitdata() async {
 final data = await FirebaseFirestore.instance
        .collection(FirebaseKey.usersCallStatus)
         .doc(appUserSession.value.id.toString())
         .get();

 authToken=data.data()['token'];
 otherUserId=data.data()['callerId'];
 otherUserName=data.data()['callFrom'];
 otherUserProfilePic=data.data()['callerPhoto'];
 notifyListeners();
 initHMSSDK();
}
  void initHMSSDK() async {
    print('-----------------------jdkfglkjg--------------------');
    if (!onCall) {
      print("------------------------onncall---------------------------");
      print(authToken);

      hmsSDK = HMSSDK();
      await hmsSDK.build(); // ensure to await while invoking the `build` method
      hmsSDK.addUpdateListener(listener: this);
      HMSConfig config = HMSConfig(
          authToken:
              authToken, // client-side token generated from your token service
          userName:
              appUserSession.value.firstName ?? appUserSession.value.name);
      hmsSDK.join(config: config);

      onCall = true;
    }
  }

  void resetData() {
    isAudioOn = true;
    authToken = null;
    localPeer = null;
    remotePeer = null;
    hmsSDK = null;
    onCall = false;
    enableRoomEnd = false;
    isConnecting = true;
  }

  void endRoom() {
    hmsSDK.endRoom(
        lock: true, reason: "call ended", hmsActionResultListener: this);
    hmsSDK.removeUpdateListener(listener: this);
    FirebaseHelper.resetUserCallStatus(appUserSession.value.id.toString());
    resetData();
    if (!isDisposed) {
      Navigator.of(context).pop();
    }
  }

  // Called when peer joined the room - get current state of room by using HMSRoom obj
  @override
  void onJoin({HMSRoom room}) {
    print("---------------------join------------------------------");
    room.peers?.forEach((peer) {
      if (peer.isLocal) {
        localPeer = peer;
        print(localPeer.toString());
        print(localPeer.audioTrack.isMute);
      }
    });
  }

  // Called when there's a peer update - use to update local & remote peer variables
  @override
  void onPeerUpdate({HMSPeer peer, HMSPeerUpdate update}) {
    print("------------------------peer left-----------------------------");
    print(update);

    switch (update) {
      case HMSPeerUpdate.peerJoined:
        if (!peer.isLocal) {
          remotePeer = peer;
          notifyListeners();
        }
        break;
      case HMSPeerUpdate.peerLeft:
        if (!peer.isLocal) {
          remotePeer = null;

          notifyListeners();
        }
        break;
      case HMSPeerUpdate.networkQualityUpdated:
        return;
      default:
        localPeer = null;
        notifyListeners();
    }
  }

  // Called when there's a track update - use to update local & remote track variables
  @override
  void onTrackUpdate(
      {HMSTrack track, HMSTrackUpdate trackUpdate, HMSPeer peer}) {
    print("---------------------track update------------------------");
    print(track.kind);
    Future.delayed(Duration(seconds: 2), () {
      enableRoomEnd = true;
      notifyListeners();
    });
    if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
      if (peer.isLocal) {
        isAudioOn = !track.isMute;
        isConnecting = false;
        notifyListeners();
      }
    }
  }

  // More callbacks - no need to implement for quickstart
  @override
  void onAudioDeviceChanged(
      {HMSAudioDevice currentAudioDevice,
      List<HMSAudioDevice> availableAudioDevice}) {}

  @override
  void onChangeTrackStateRequest(
      {HMSTrackChangeRequest hmsTrackChangeRequest}) {}

  @override
  void onHMSError({HMSException error}) {
    print("--------------------error------------------------");
    print(error.toString());
    print(error.message.toString());
    print(error.toMap());
    AppHelper.showToastMessage(error.message);
    endRoom();
  }

  @override
  void onSuccess(
      {HMSActionResultListenerMethod methodType,
      Map<String, dynamic> arguments}) {
    switch (methodType) {
      case HMSActionResultListenerMethod.endRoom:
        print(
            "-----------------------------Rooom is ended------------------------------");
        break;
      default:
        print("leaveing-----------------------------");

        print("-----------------------Room ended successfully");
    }
  }

  @override
  void onMessage({HMSMessage message}) {}

  @override
  void onReconnected() {
    AppHelper.showToastMessage("Reconnected after connection is lost.");
  }

  @override
  void onReconnecting() {
    AppHelper.showToastMessage("Reconnecting please wait.");
  }

  @override
  void onRemovedFromRoom({HMSPeerRemovedFromPeer hmsPeerRemovedFromPeer}) {
    print(
        "------------------------removed from room--------------------------");
    if (hmsPeerRemovedFromPeer.roomWasEnded) {
      hmsSDK.removeUpdateListener(listener: this);
      FirebaseHelper.resetUserCallStatus(appUserSession.value.id.toString());
      print("---------------------room was ended-------------------------");
      resetData();
      if (!isDisposed) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void onRoleChangeRequest({HMSRoleChangeRequest roleChangeRequest}) {}

  @override
  void onRoomUpdate({HMSRoom room, HMSRoomUpdate update}) {}

  @override
  void onUpdateSpeakers({List<HMSSpeaker> updateSpeakers}) {}

  @override
  void onException(
      {HMSActionResultListenerMethod methodType,
      Map<String, dynamic> arguments,
      HMSException hmsException}) {
    print(hmsException.message);
    print(
        "----------------------exception in ending room---------------------");
    // TODO: implement onException
  }
}
