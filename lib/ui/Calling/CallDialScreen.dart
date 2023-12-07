// import 'package:flutter/material.dart';

// import 'package:names/custom_widget/custom_widget.dart';
// import 'package:names/helper/AppHelper.dart';

// class CallDialScreen extends StatefulWidget {
//   final String name;
//   final String profilePicture;

//   const CallDialScreen({Key key, this.name, this.profilePicture})
//       : super(key: key);

//   @override
//   State<CallDialScreen> createState() => _CallDialScreenState();
// }

// class _CallDialScreenState extends State<CallDialScreen> {
//   _appBarWidget(BuildContext context) {
//     return Row(
//       children: [
//         Container(
//           child: IconButton(
//             icon: Image.asset(
//               "assets/icons/back_arrow.png",
//               height: 20,
//               width: 20,
//             ),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppHelper.appBar(context, _appBarWidget(context),
//           LinearGradient(colors: [Colors.black, Colors.black])),
//       backgroundColor: Colors.black,
//       body: Container(
//         padding: EdgeInsets.all(20),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
//           Container(
//             height: 100,
//             width: 100,
//             child: CustomWidget.imageView(
//               widget.profilePicture,
//               fit: BoxFit.cover,
//               height: 100,
//               width: 100,
//               circle: true,
//               forProfileImage: true,
//             ),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Text(
//             widget.name,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//                 color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//           ),
//           SizedBox(
//             height: 20,
//           ),
//           Text(
//             "Calling",
//             style: TextStyle(color: Colors.white, fontSize: 16),
//           ),
//           Spacer(),
//           Align(
//             alignment: Alignment.center,
//             child: Container(
//                 margin: EdgeInsets.only(bottom: 20),
//                 height: 60,
//                 width: 60,
//                 decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(30), color: Colors.red),
//                 child: Icon(
//                   Icons.call_end,
//                   color: Colors.white,
//                 )),
//           )
//         ]),
//       ),
//     );
//   }
// }
