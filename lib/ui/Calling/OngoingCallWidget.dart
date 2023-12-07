// import 'package:flutter/material.dart';
// import 'package:names/Providers/FirebaseCallDataProvider.dart';
// import 'package:names/main.dart';
// import 'package:names/ui/Calling/MeetingScreen.dart';
// import 'package:provider/provider.dart';

// class OngoingCallWidget extends StatefulWidget {
//   const OngoingCallWidget({Key key}) : super(key: key);

//   @override
//   State<OngoingCallWidget> createState() => _OngoingCallWidgetState();
// }

// class _OngoingCallWidgetState extends State<OngoingCallWidget> {
//   FirebaseCallDataProvider _firebaseCallDataProvider;
//   void initState() {
//     _firebaseCallDataProvider =
//         Provider.of<FirebaseCallDataProvider>(context, listen: false);
//     _firebaseCallDataProvider
//         .getuserCallStatus(appUserSession.value.id.toString());
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body:
//         Consumer<FirebaseCallDataProvider>(builder: (context, value, child) {
//       if (value.callStatus != null) {
//         return value.callStatus.onCall
//             ? GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => MeetingScreen(
//                                 authToken: value.callStatus.token,
//                                 otherUsername: value.callStatus.callFrom,
//                               )));
//                 },
//                 child: Container(
//                   height: 100,
//                   padding: EdgeInsets.only(left: 20, right: 20, top: 50),
//                   decoration: BoxDecoration(
//                     color: Colors.green,
//                   ),
//                   child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             "ongoing call",
//                             style: TextStyle(color: Colors.white, fontSize: 18),
//                           ),
//                         ),
//                         Icon(
//                           Icons.call,
//                           color: Colors.white,
//                         )
//                       ]),
//                 ),
//               )
//             : Container(
//                 height: 0,
//               );
//       } else {
//         return Container(
//           height: 0,
//         );
//       }
//     }));
//   }
// }
