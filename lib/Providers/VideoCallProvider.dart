import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hmssdk_flutter/hmssdk_flutter.dart';
import 'package:names/helper/AppHelper.dart';
import 'package:names/helper/FirebaseHelper.dart';
import 'package:names/model/CallStatusModel.dart';

import '../constants/firebaseKey.dart';
import '../main.dart';

class VideoCallProvider extends ChangeNotifier
    with HMSUpdateListener, HMSActionResultListener {
  bool isAudioOn = true;
  bool isVideoOn = true;
  String authToken;
  BuildContext context;
  //String otherUserId;
  int otherUserId;
  String otherUserName,otherUserProfilePic;
  // Variables required for joining a room

  HMSPeer localPeer, remotePeer;
  HMSVideoTrack localPeerVideoTrack, remotePeerVideoTrack;
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
    isVideoOn = true;
    authToken = null;
    localPeer = null;
    remotePeer = null;
    localPeerVideoTrack = null;
    remotePeerVideoTrack = null;
    hmsSDK = null;
    onCall = false;
  }

  void endRoom() {
    print("-------------------------ending room--------------------------");

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
        if (peer.videoTrack != null) {
          localPeerVideoTrack = peer.videoTrack;

          notifyListeners();
        }
      }
    });
  }

  // Called when there's a peer update - use to update local & remote peer variables
  @override
  void onPeerUpdate({HMSPeer peer, HMSPeerUpdate update}) {
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
    if (track.kind == HMSTrackKind.kHMSTrackKindVideo) {
      if (trackUpdate == HMSTrackUpdate.trackRemoved) {
        print("------------------track is removed-------------------------");
        peer.isLocal ? localPeerVideoTrack = null : remotePeerVideoTrack = null;

        notifyListeners();
      } else if (trackUpdate == HMSTrackUpdate.trackAdded) {
        peer.isLocal
            ? localPeerVideoTrack = track as HMSVideoTrack
            : remotePeerVideoTrack = track as HMSVideoTrack;
        if (peer.isLocal) {
          isVideoOn = !localPeerVideoTrack.isMute;
        }
        print(
            "-------------------------track is added-----------------------------");

        notifyListeners();
      } else if (trackUpdate == HMSTrackUpdate.trackUnMuted) {
        if (!peer.isLocal) {
          remotePeerVideoTrack = track;
          notifyListeners();
        }

        print(
            "----------------------------track is changed------------------------");
      } else if (trackUpdate == HMSTrackUpdate.trackMuted) {
        if (!peer.isLocal) {
          remotePeerVideoTrack = track;
          notifyListeners();
        }
      }
    } else if (track.kind == HMSTrackKind.kHMSTrackKindAudio) {
      if (peer.isLocal) {
        isAudioOn = !track.isMute;
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
    AppHelper.showToastMessage(error.message.toString());
    print("--------------------error------------------------");
    print(error.toString());
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
    print(
        "----------------------exception in ending room---------------------");
    // TODO: implement onException
  }
}
