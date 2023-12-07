// import 'package:flutter/material.dart';
// import 'package:hmssdk_flutter/hmssdk_flutter.dart';
// import 'package:names/Providers/VideoPreviewProvider.dart';
// import 'package:names/helper/AppHelper.dart';
// import 'package:names/helper/FirebaseHelper.dart';
// import 'package:names/helper/ProgressDialog.dart';
// import 'package:names/main.dart';
// import 'package:names/ui/Calling/MeetingScreen.dart';
// import 'package:provider/provider.dart';

// class OtherUserPreviewScreen extends StatefulWidget {
//   final String token;
//   final String name;

//   const OtherUserPreviewScreen({Key key, this.token, this.name})
//       : super(key: key);

//   @override
//   State<OtherUserPreviewScreen> createState() => _OtherUserPreviewScreenState();
// }

// class _OtherUserPreviewScreenState extends State<OtherUserPreviewScreen> {
//   VideoPreviewProvider _videoPreviewProvider;
//   @override
//   void initState() {
//     _videoPreviewProvider =
//         Provider.of<VideoPreviewProvider>(context, listen: false);
//     print("-------------------i nit ccalled------------");
//     _videoPreviewProvider.context = context;
//     _videoPreviewProvider.username = widget.name;
//     _videoPreviewProvider.hmsToken = widget.token;
//     _videoPreviewProvider.fromPreview = false;
//     _videoPreviewProvider.initHMSSDK();

//     super.initState();
//   }

//   @override
//   void dispose() {
//     _videoPreviewProvider.resetData();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     final double itemHeight = size.height;
//     final double itemWidth = size.width;

//     return WillPopScope(
//         onWillPop: () async {
//           FirebaseHelper.callRejected(appUserSession.value.id.toString())
//               .then((value) {
//             _videoPreviewProvider.leaveMeeting();

//             FirebaseHelper.resetUserCallStatus(
//                 appUserSession.value.id.toString());
//           });
//           return true;
//         },
//         child: Scaffold(
//           body: Consumer<VideoPreviewProvider>(
//               builder: ((context, value, child) => Container(
//                     height: AppHelper.getDeviceHeight(context),
//                     child: value.localTracks.isNotEmpty
//                         ? SizedBox(
//                             height: itemHeight,
//                             width: itemWidth,
//                             child: Stack(
//                               children: [
//                                 HMSVideoView(
//                                   track: value.localTracks[0],
//                                   setMirror: true,
//                                   scaleType: ScaleType.SCALE_ASPECT_FILL,
//                                 ),
//                                 Positioned(
//                                   top: 180,
//                                   left: 20,
//                                   child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.center,
//                                       children: [
//                                         Text(
//                                           widget.name,
//                                           textAlign: TextAlign.center,
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 20),
//                                         ),
//                                         SizedBox(
//                                           height: 20,
//                                         ),
//                                         Text(
//                                           "Calling",
//                                           style: TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 18),
//                                         ),
//                                       ]),
//                                 ),
//                                 Align(
//                                   alignment: Alignment.bottomCenter,
//                                   child: Container(
//                                     height: 100,
//                                     padding: EdgeInsets.only(bottom: 30),
//                                     decoration:
//                                         BoxDecoration(color: Colors.black),
//                                     child: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceAround,
//                                       children: [
//                                         Align(
//                                           alignment: Alignment.bottomCenter,
//                                           child: RawMaterialButton(
//                                             onPressed: () {
//                                               value.leaveMeeting();

//                                               FirebaseHelper.callRejected(
//                                                       appUserSession.value.id
//                                                           .toString())
//                                                   .then((value) {
//                                                 FirebaseHelper
//                                                     .resetUserCallStatus(
//                                                         appUserSession.value.id
//                                                             .toString());
//                                                 Navigator.pop(context);
//                                               });
//                                             },
//                                             elevation: 2.0,
//                                             fillColor: Colors.red,
//                                             padding: const EdgeInsets.all(15.0),
//                                             shape: const CircleBorder(),
//                                             child: const Icon(
//                                               Icons.call_end,
//                                               size: 25.0,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                         Align(
//                                           alignment: Alignment.bottomCenter,
//                                           child: RawMaterialButton(
//                                             onPressed: () {
//                                               value.leaveMeeting();

//                                               FirebaseHelper.callAccepted(
//                                                       appUserSession.value.id
//                                                           .toString())
//                                                   .then((value) {
//                                                 Navigator.pushReplacement(
//                                                     context,
//                                                     MaterialPageRoute(
//                                                         builder: (context) =>
//                                                             MeetingScreen(
//                                                                 authToken:
//                                                                     widget
//                                                                         .token,
//                                                                 otherUsername:
//                                                                     widget
//                                                                         .name)));
//                                               });
//                                             },
//                                             elevation: 2.0,
//                                             fillColor: Colors.green,
//                                             padding: const EdgeInsets.all(15.0),
//                                             shape: const CircleBorder(),
//                                             child: const Icon(
//                                               Icons.call,
//                                               size: 25.0,
//                                               color: Colors.white,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : Center(
//                             child:
//                                 ProgressDialog.getCircularProgressIndicator(),
//                           ),
//                   ))),
//         ));
//   }
// }
