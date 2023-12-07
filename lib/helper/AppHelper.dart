import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart' as intl;
import 'package:just_audio/just_audio.dart';
import 'package:link_text/link_text.dart';
import 'package:mime/mime.dart';
import 'package:names/api/DynamicLinkServices.dart';
import 'package:names/constants/app_color.dart';
import 'package:names/custom_widget/CustomDialog.dart';
import 'package:names/model/FeedModel.dart';
import 'package:names/model/UserSession.dart';
import 'package:names/ui/PostAllComments.dart';
import 'package:names/ui/PostSignScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../constants/firebaseKey.dart';
import '../custom_widget/custom_widget.dart';
import '../custom_widget/gradient_app_bar.dart';
import '../custom_widget/image_slider.dart';
import '../main.dart';
import '../model/UsersModel.dart';
import '../ui/PostLikeScreen.dart';
import '../ui/UserProfileScreen.dart';

class AppHelper {
  static AudioPlayer player = AudioPlayer();
  static Future<void> callRingtone() async {
    //await player.setUrl('https://foo.com/bar.mp3');
    await player.setAsset('assets/audio/ringing.wav', preload: true);
   // initialPosition: Duration(seconds: 1));
   // await player.setAsset('assets/audio/ringing.wav', preload: true);
  }

  static playRingtone() async {
    await player.setLoopMode(LoopMode.all);
    await player.seek(Duration(seconds: 0));
    await player.play();
  }

  static stopRingtone() async {
    if (player.playing) {
      await player.pause();
    }
  }

  static const String emailPattern = "[a-zA-Z0-9\+\.\_\%\-\+]{1,256}" +
      "\\@" +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" +
      "(" +
      "\\." +
      "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" +
      ")+";

  static void showToastMessage(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColor.darkBlueColor,
        textColor: Colors.white,
        fontSize: 16.0);
  }

  static bool isPriceValid(String value) {
    for (int i = 0; i < value.length; i++) {
      int n = value.codeUnitAt(i);
      if (n < 48 || n > 57) {
        return false;
      }
    }
    if (int.parse(value) > 0) {
      return true;
    } else {
      return false;
    }
  }

  static bool isPriceValidation(String value) {
    double val = value.isNotEmpty ? double.parse(value) : 0.0;
    if (val > 0) {
      return false;
    }
    return true;
  }

  static bool isValidSeat(String value, String maximumSeat) {
    for (int i = 0; i < value.length; i++) {
      int n = value.codeUnitAt(i);
      if (n < 48 || n > 57) {
        return false;
      }
    }
    int seat = int.parse(value);
    int maximum = int.parse(maximumSeat);
    if (seat > 0) {
      if (seat <= maximum) {
        return true;
      } else {
        return false;
      }
    }
    return false;
  }

  static double getDeviceWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getDeviceHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static void hideKeyBoard(BuildContext context) {
    try {
      FocusScope.of(context).requestFocus(new FocusNode());
    } catch (ex) {}
  }

  /*static List<TextInputFormatter> removeSpaceFormat() {
    return [
      BlacklistingTextInputFormatter(RegExp("[ ]")),
      BlacklistingTextInputFormatter(
        RegExp(
            r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
      ),
    ];
  }

  static List<TextInputFormatter> onlyCharNumFormat() {
    return [
      WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9]")),
    ];
  }
 
  static List<TextInputFormatter> onlyCharSpaceNumFormat() {
    return [
      WhitelistingTextInputFormatter(RegExp("[a-zA-Z0-9 ]")),
    ];
  }

  static List<TextInputFormatter> onlyNumFormat() {
    return [
      WhitelistingTextInputFormatter(RegExp("[0-9]")),
    ];
  }

  static List<TextInputFormatter> blockEmojiFormat() {
    return [
      BlacklistingTextInputFormatter(
        RegExp(
            r'(\u00a9|\u00ae|[\u2000-\u3300]|\ud83c[\ud000-\udfff]|\ud83d[\ud000-\udfff]|\ud83e[\ud000-\udfff])'),
      ),
    ];
  }*/

  static Future<bool> checkInternetConnectivity() async {
    String connectionStatus;
    bool isConnected = false;
    final Connectivity _connectivity = Connectivity();

    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      connectionStatus = (await _connectivity.checkConnectivity()).toString();
      if (await _connectivity.checkConnectivity() ==
          ConnectivityResult.mobile) {
        print("===internetconnected==Mobile" + connectionStatus);
        isConnected = true;
        // I am connected to a mobile network.
      } else if (await _connectivity.checkConnectivity() ==
          ConnectivityResult.wifi) {
        isConnected = true;
        print("===internetconnected==wifi" + connectionStatus);
        // I am connected to a wifi network.
      } else if (await _connectivity.checkConnectivity() ==
          ConnectivityResult.none) {
        isConnected = false;
        print("===internetconnected==not" + connectionStatus);
      }
    } on PlatformException catch (e) {
      print("===internet==not connected" + e.toString());
      connectionStatus = 'Failed to get connectivity.';
    }
    return isConnected;
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
  }

  static Stream<ConnectivityResult> internetConnectivityStream() {
    final Connectivity _connectivity = Connectivity();

    // Platform messages may fail, so we use a try/catch PlatformException.
    return _connectivity.onConnectivityChanged;
  }

  static Future<bool> saveFcmToken(String string) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("fcmToken", string);
    prefs.commit();
    return true;
  }

  static Future<String> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("fcmToken");
  }

  static void showNotification(String message) {
    // showSimpleNotification(
    //     Text(
    //       message,
    //       style: TextStyle(color: Colors.black),
    //     ),
    //     leading: Padding(
    //       padding: const EdgeInsets.all(8.0),
    //       child: Image.asset(
    //         "assets/images/backup_circle.png",
    //         fit: BoxFit.fill,
    //       ),
    //     ),
    //     background: Colors.transparent,
    //     duration: Duration(seconds: 5));
  }

  static Future<UserSession> getUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    String authToken = prefs.getString("userSession");
    if (authToken != null && authToken.isNotEmpty) {
      UserSession userSession = UserSession.fromJson(json.decode(authToken));
      if (userSession != null) {
        return userSession;
      }
    }
    return null;
  }

  static Future<bool> saveUserSession(UserSession userSession) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userSession", json.encode(userSession));
    prefs.commit();
    return true;
  }

  static Future<bool> clearUserSession() async {
    appUserSession.value = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("userSession", "");
    prefs.commit();
    return true;
  }

  static bool isValidEmail(String email) {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(email);
  }

  static bool isDocument(String path) {
    final mimeType = lookupMimeType(path);

    return mimeType == 'application/msword';
  }

  static bool isImage(String path) {
    final mimeType = lookupMimeType(path);
    return mimeType.startsWith('image/');
  }

  static bool isImageExist(String path) {
    final mimeType = lookupMimeType(path);
    if (mimeType != null) {
      bool image = mimeType.startsWith('image/');
      File file = File(path);
      if (file.existsSync() && image) {
        return true;
      }
    }

    return false;
  }

  static bool isFileExist(File file) {
    return file != null && file.existsSync();
  }

  static String setText(dynamic value) {
    if (value != null) {
      if (value is String) {
        return value;
      } else {
        return value.toString();
      }
    }
    return FirebaseKey.nakey;
  }

  static double getPercentage(int percentage) {
    if (percentage != null) {
      double per = double.parse(percentage.toString());
      return per / 100.0;
    }
    return 0.0;
  }

  static String getDateMonth() {
    return formatDate(DateTime.now(), [M, ', ', d]);
  }

  static String getChatID(String userID1, String userID2) {
    Uuid uuid = Uuid();
    String u1 = uuid.v5(Uuid.NAMESPACE_OID, userID1);
    String u2 = uuid.v5(Uuid.NAMESPACE_OID, userID2);

    int num1 = int.parse(userID1);
    int num2 = int.parse(userID2);
    // int sum = num1 + num2;

    if (num2 < num1) {
      return "chat_" + num2.toString() + "_" + num1.toString();
    }

    return "chat_" + num1.toString() + "_" + num2.toString();
  }

  static String timeAgoSinceDate(dynamic dateString,
      {bool numericDates = true}) {
    if (dateString == null) {
      return (intl.DateFormat('hh:mm a').format(DateTime.now())).toLowerCase();
    }
    DateTime datetime = (dateString as Timestamp).toDate().toUtc().toLocal();
    DateTime notificationDate =
        intl.DateFormat("yyyy-MM-dd HH:mm:ss").parse(datetime.toString());
    String strDays = calculateDifference(notificationDate)
        .toString()
        .replaceAll(RegExp('-'), '');
    if (calculateDifference(notificationDate) < -8) {
      return datetime.month.toString() +
          "-" +
          datetime.day.toString() +
          "-" +
          datetime.year.toString();
    } else if (calculateDifference(notificationDate) == -7) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (calculateDifference(notificationDate) <= -2) {
      return '$strDays days ago';
    } else if (calculateDifference(notificationDate) == -1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } else {
      return (intl.DateFormat('hh:mm a').format(datetime)).toLowerCase();
    }
  }

  static String timeOnly(dynamic dateString, {bool numericDates = true}) {
    if (dateString == null) {
      return (intl.DateFormat('hh:mm a').format(DateTime.now())).toLowerCase();
    }

    DateTime datetime = (dateString as Timestamp).toDate().toUtc().toLocal();
    return (intl.DateFormat('hh:mm a').format(datetime)).toLowerCase();
  }

  static String getDatesNumeric(
    dynamic dateString,
  ) {
    if (dateString == null) {
      return "";
    }
    List months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    DateTime datetime = (dateString as Timestamp).toDate().toUtc().toLocal();
    DateTime notificationDate =
        intl.DateFormat("yyyy-MM-dd HH:mm:ss").parse(datetime.toString());

    /*print("dateString="+dateString.toString()+" difference="+difference.toString()+
        "\n serverdate="+notificationDate.toString()+" Cdatetime="+datetime.toString()
        );*/

    if (calculateDifference(notificationDate) == 0) {
      return "Today";
    } else if (calculateDifference(notificationDate) == -1) {
      return 'Yesterday';
    }

    /*if (difference.inDays == 1) {
      return  'Yesterday';
    }else if (difference.inDays == 0) {
      return "Today";
    }*/
    else {
      return months[datetime.month - 1] +
          " " +
          datetime.day.toString() +
          ", " +
          datetime.year.toString();
      // datetime.year.toString().substring(datetime.year.toString().length - 2);
    }
  }

  static int calculateDifference(DateTime date) {
    // Yesterday : calculateDifference(date) == -1.
    // Today : calculateDifference(date) == 0.
    // Tomorrow : calculateDifference(date) == 1.
    DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  static String timeAgoSince(dynamic dateString, {bool numericDates = true}) {
    if (dateString == null) {
      return (intl.DateFormat('hh:mm a').format(DateTime.now())).toLowerCase();
    }
    DateTime notificationDate =
        intl.DateFormat('yyyy-MM-ddTHH:mm:ssZ').parseUtc(dateString).toLocal();
    final date2 = DateTime.now().toLocal();
    final difference = date2.difference(notificationDate);

    if (difference.inDays > 8) {
      return notificationDate.month.toString() +
          "-" +
          notificationDate.day.toString() +
          "-" +
          notificationDate.year.toString();
    } else if ((difference.inDays / 7).floor() >= 1) {
      return (numericDates) ? '1 week ago' : 'Last week';
    } else if (difference.inDays >= 2) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays >= 1) {
      return (numericDates) ? '1 day ago' : 'Yesterday';
    } /*else if (difference.inHours >= 2) {
      return '${difference.inHours} hours ago';
    } else if (difference.inHours >= 1) {
      return (numericDates) ? '1 hour ago' : 'An hour ago';
    } else if (difference.inMinutes >= 2) {
      return '${difference.inMinutes} mint ago';
    } else if (difference.inMinutes >= 1) {
      return (numericDates) ? '1 min ago' : 'A min ago';
    } else if (difference.inSeconds >= 3) {
      return '${difference.inSeconds} sec ago';
    }*/
    else {
      return (intl.DateFormat('hh:mm a').format(notificationDate))
          .toLowerCase();
    }
  }

  static bool isEmpty(String message) {
    if (message != null && message.isEmpty) {
      return true;
    }
    return false;
  }

  static bool isNotEmpty(String message) {
    if (message != null && message.isNotEmpty) {
      return true;
    }
    return false;
  }

  static String getGroupRoomID(String groupName) {
    Uuid uuid = Uuid();
    // String u1 = uuid.v5(Uuid.NAMESPACE_OID, groupName);
    return uuid.v1();
    // return groupName.replaceAll(" ", "").toLowerCase();
  }

  static getReadMore(BuildContext context, String title, String description) {
    TextStyle textStyle = TextStyle(color: Colors.black);
   // TextStyle textStyle = TextStyle(color: AppColor.textGrayColor);
    TextStyle moreTextStyle = TextStyle(
      color: Colors.blue,
    );
    return LayoutBuilder(builder: (context, size) {
      final span = TextSpan(text: description, style: textStyle);
      final tp = TextPainter(
          text: span, maxLines: 3, textDirection: TextDirection.ltr);
      tp.layout(maxWidth: size.maxWidth);

      if (tp.didExceedMaxLines) {
        // The text has more than three lines.
        // TODO: display the prompt message
        var linkSize = tp.size;
        final delimiterSize = tp.size;
        int endIndex;
        if (linkSize.width < size.maxWidth) {
          final readMoreSize = linkSize.width + delimiterSize.width;
          final pos = tp.getPositionForOffset(Offset(
            linkSize.width - readMoreSize,
            linkSize.height,
          ));
          endIndex = tp.getOffsetBefore(pos.offset) ?? 0;
        } else {
          var pos = tp.getPositionForOffset(
            linkSize.bottomRight(Offset.zero),
          );
          endIndex = pos.offset - 12;
          // linkLongerThanLine = true;
        }

        return RichText(
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(children: [
            TextSpan(
              text: description.substring(0, endIndex) + "...",
              style: textStyle,
            ),
            TextSpan(
              text: "Read More",
              style: moreTextStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  readDialog(context, title, description);
                },
            ),
          ]),
        );
      } else {
        return  SizedBox(
          width: MediaQuery.of(context).size.width * 0.89,
          child: LinkText(
            description,
            textAlign: TextAlign.start,
            textStyle: TextStyle(fontSize: 14,color: Colors.black),
            linkStyle: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              letterSpacing: 0,
            ),
            onLinkTap: (link) async {
              final Uri _url = Uri.parse(link);
              await launchUrl(_url, mode: LaunchMode.externalApplication);
            },
          ),
        );
        // return Text(description, style: textStyle);
      }
    });
  }

  static readDialog(
      BuildContext context, String title, String description) async {
    return await showDialog(
      context: context,
      useSafeArea: true,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return AlertDialog(
            contentPadding: const EdgeInsets.fromLTRB(10.0, 20.0, 10.0, 20.0),
            insetPadding: EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: SingleChildScrollView(
              child: Wrap(
                children: [
                  Container(
                    // width: MediaQuery.of(context).size.width,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(
                              title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            )),
                            Align(
                              alignment: Alignment.topRight,
                              child: GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                child: Container(
                                  padding: EdgeInsets.only(right: 10, left: 10),
                                  child: Image.asset(
                                    "assets/icons/close.png",
                                    height: 16,
                                    width: 16,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(ctx);
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.8,
                          child: LinkText(
                            description,
                            textAlign: TextAlign.start,
                            textStyle: TextStyle(fontSize: 14,color: Colors.black),
                            linkStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              letterSpacing: 0,
                            ),
                            onLinkTap: (link) async {
                              final Uri _url = Uri.parse(link);
                              await launchUrl(_url, mode: LaunchMode.externalApplication);
                            },
                          ),
                        ),
                        // Text(
                        //   description,
                        //   textAlign: TextAlign.start,
                        //   style: TextStyle(
                        //       fontSize: 14, color: Colors.black),
                        //      // fontSize: 14, color: AppColor.textGrayColor),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  static countWidget(count) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 5,
      ),
      child: Text(
        count.toString(),
        style: TextStyle(
          fontSize: 14,
          color: AppColor.textGrayColor,
        ),
      ),
    );
  }

  static String timeZoneDateConverter(String date) {
    final value =
        intl.DateFormat('yyyy-MM-ddTHH:mm:ssZ').parseUtc(date).toLocal();
    return intl.DateFormat('MM-dd-yyyy').format(value);
  }

  static String timeZoneDateConverterSchedule(String date) {
    final value = intl.DateFormat('yyyy-MM-dd').parseUtc(date).toLocal();
    return intl.DateFormat('MM-dd-yyyy').format(value);
  }

  static String scheduleDateFormat(String date) {
    print(date);
    final value =
        intl.DateFormat('yyyy-MM-dd HH:mm:ssZ').parseUtc(date).toLocal();
    return intl.DateFormat('HH:mm MMM dd, yyyy').format(value);
  }

  static HartWidget(
    feed,
    Function(Feed feed) likeUnlikeAPI,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Icon(
        Icons.favorite,
        color: feed.liked ? Colors.red : AppColor.textGrayColor,
        size: 20,
      ),
      onTap: () {
        likeUnlikeAPI(feed);
      },
    );
  }

  static signWidget(
    feed,
    Function(Feed feed) likeUnlikeAPI,
  ) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Image.asset(
        "assets/icons/sign.png",
        color: feed.signed ? Colors.red : AppColor.textGrayColor,
        height: 20,
      ),
      onTap: () {
        likeUnlikeAPI(feed);
      },
    );
  }

  static shareWidget(Feed feed) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: Row(
        children: [
          Image.asset(
            "assets/icons/share.png",
            height: 18,
            width: 18,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            "Share",
            style: TextStyle(
              color: AppColor.textGrayColor,
            ),
          ),
        ],
      ),
      onTap: () async {
        String imageUrl = null;
        if (feed.medias != null && feed.medias.length > 0) {
          for (var items in feed.medias) {
            if (items.mediaType.toString() == "2") {
              //videos
              // imageUrl=items.media;
              imageUrl =
                  "https://names.cmsbox.in/web/common/images/video_image.png";
              break;
            } else {
              //image
              imageUrl = items.media;
              break;
            }
          }
        }
        String getLink = await DynamicLinkService().createFirstPostLink(
            appUserSession.value.id.toString(),
            feed.id.toString(),
            feed,
            imageUrl);
        if (getLink != null) {
          Share.share('$getLink');
        }
      },
    );
  }

  static feedWidget(context, Feed feed, likeUnlikeAPI) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      width: AppHelper.getDeviceWidth(context),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    margin: EdgeInsets.all(5),
                    child: ClipRRect(
                      child: CustomWidget.imageView(
                        feed.userProfilePicture,
                        fit: BoxFit.cover,
                        forProfileImage: true,
                      ),
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          feed.userName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: AppColor.textGrayColor,
                            ),
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              AppHelper.timeZoneDateConverter(feed.createdAt)
                                  .toString(),
                              style: TextStyle(
                                  fontSize: 13, color: AppColor.textGrayColor),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "|",
                              style: TextStyle(
                                  fontSize: 9, color: AppColor.textGrayColor),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              feed.location ?? "",
                              style: TextStyle(
                                  fontSize: 13, color: AppColor.textGrayColor),
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation<double> animation,
                        Animation<double> secondaryAnimation) =>
                    UserProfileScreen(
                  usersModel: UsersModel(
                    id: feed.userId,
                    name: feed.userName,
                    profilePicture: feed.userProfilePicture,
                    profession: feed.userProfession,
                    specialist: feed.userSpecialist,
                  ),
                ),
                transitionDuration: Duration(seconds: 0),
              ));
            },
          ),
          feed.medias.isNotEmpty
              ? Container(
                  // child: MediaWidgets(medias:feed.medias),
                  child: ImageSlider(feed.medias,""),
                )
              : SizedBox(),
          SizedBox(
            height: 10,
          ),
          feed.title != null
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: Text(
                    feed.title,
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontFamily: "Lato_Bold"),
                  ),
                )
              : SizedBox(
                  height: 0,
                ),
          SizedBox(
            height: 10,
          ),
          feed.description != null
              ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10,
                  ),
                  child: AppHelper.getReadMore(
                      context, feed.title, feed.description),
                  /*child: ReadMoreText(
                                                feed.description,
                                                trimLines: 3,
                                                colorClickableText: Colors.red,
                                                trimMode: TrimMode.Line,
                                                trimCollapsedText: 'Read more',
                                                trimExpandedText: 'Read less',
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColor.textGrayColor),
                                                moreStyle: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColor
                                                        .lightSkyBlueColor,
                                                    fontFamily: "Lato_Bold"),
                                                lessStyle: TextStyle(
                                                    fontSize: 12,
                                                    color: AppColor
                                                        .lightSkyBlueColor,
                                                    fontFamily: "Lato_Bold"),
                                              ),*/
                )
              : SizedBox(
                  height: 0,
                ),
          SizedBox(
            height: 10,
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
            ),
            color: Colors.transparent,
            child: Row(
              children: [
                if (feed.saveAs == 4) AppHelper.signWidget(feed, likeUnlikeAPI),
                if (feed.saveAs != 4) AppHelper.HartWidget(feed, likeUnlikeAPI),
                SizedBox(
                  width: 5,
                ),
                if (feed.saveAs == 4)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) =>
                            PostSignScreen(
                          feed: feed,
                        ),
                        transitionDuration: Duration(seconds: 0),
                      ));
                    },
                    child: AppHelper.countWidget(feed.signedCount),
                  ),
                if (feed.saveAs != 4)
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (BuildContext context,
                                Animation<double> animation,
                                Animation<double> secondaryAnimation) =>
                            PostLikeScreen(
                          feed: feed,
                        ),
                        transitionDuration: Duration(seconds: 0),
                      ));
                    },
                    child: AppHelper.countWidget(feed.likedCount),
                  ),
                Spacer(),
                if (feed.commentCount != 0)
                  AppHelper.countWidget(feed.commentCount),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => PostAllComments(
                              diaryId: feed.id.toString(),
                            )));
                  },
                  child: Icon(
                    Icons.comment,
                    size: 20,
                    color: AppColor.textGrayColor,
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                if (feed.saveAs != 4) AppHelper.shareWidget(feed),
              ],
            ),
          ),
          SizedBox(
            height: 5,
          ),
        ],
      ),
    );
  }

  static void notificationCounterHelper(int count) {
    Future.delayed(Duration(seconds: 1), () {
      notificationCount.value = count;
    });
  }

  static Widget appBar(context, Widget title, Gradient gradient) {
    return GradientAppBar(
      elevation: 0,
      centerTitle: false,
      showBottomRound: false,
      automaticallyImplyLeading: false,
      title: title,
      brightness: Brightness.light,
      gradient: gradient,
    );
  }

  static bool getVisiblityShild(String licenseExpiryDate) {
    if (licenseExpiryDate != null && licenseExpiryDate.isNotEmpty) {
      try {
        DateTime notificationDate =
            intl.DateFormat("yyyy-MM-dd").parse(licenseExpiryDate);

        if (calculateDifference(notificationDate) >= 0) {
          return true;
        }
        return false;
      } catch (e) {
        print("Exception on expiry date");
        print(e.toString());
        return false;
      }
    } else {
      return false;
    }
  }

  static Widget ShildWidget(
      String licenseExpiryDate, double height, double width) {
    return Visibility(
        visible: getVisiblityShild(licenseExpiryDate),
        child: Image.asset(
          "assets/icons/shield.png",
          height: height,
          width: width,
        ));
  }

  static Widget getNoRecordWidget(BuildContext context, String imageAsset,
      String message, MainAxisAlignment mainAxisAlignment) {
    //"assets/icons/message.png"
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Visibility(
          visible: false,
          child: Image.asset(
            imageAsset ?? "",
            height: 30,
            width: 30,
            // color: AppColor.lightSkyBlueColor,
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 10, bottom: 10), child: Text(message)),
      ],
    );
  }

  static Widget getFeedLocation(context, String feedlocation) {
    return Visibility(
        visible: feedlocation != null && feedlocation.isNotEmpty,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "|",
              style: TextStyle(fontSize: 13, color: AppColor.textGrayColor),
            ),
            SizedBox(
              width: 5,
            ),
            Flexible(
              child: Text(
                feedlocation.toString(),
                style: TextStyle(fontSize: 13, color: AppColor.textGrayColor),
              ),
            ),
          ],
        ));
  }

  static Widget professtionWidget(profession_symbol) {
    return Visibility(
      visible: profession_symbol != null,
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          margin: EdgeInsets.only(left: 12),
          height: 22,
          // width: 22,
          decoration: BoxDecoration(
            color: AppColor.darkBlueColor,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(10)),
          ),
          alignment: Alignment.center,
          child: Text(
            profession_symbol.toString(),
            style: TextStyle(
                fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  static Widget button(context, buttonText,
      {Color backColor, Color textColor, IconData iconData}) {
    if (backColor == null) {
      backColor = AppColor.lightSkyBlueColor;
    }
    if (textColor == null) {
      textColor = Colors.white;
    }

    Widget mainWidget = Text(
      buttonText,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
    );

    if (iconData != null) {
      mainWidget = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            iconData,
            color: textColor,
          ),
          SizedBox(
            width: 10,
          ),
          mainWidget,
        ],
      );
    }

    return Container(
      width: AppHelper.getDeviceWidth(context),
      height: 50,
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100), color: backColor),
      alignment: Alignment.center,
      child: mainWidget,
    );
  }

  static Future<bool> photoPermissionCheck(BuildContext context) async {
    PermissionStatus microphone = await Permission.microphone.status;
    PermissionStatus cameraPermission = await Permission.camera.status;
    PermissionStatus blueTooth = await Permission.bluetoothConnect.status;

    if (Platform.isIOS) {
      if (cameraPermission == PermissionStatus.granted) {
        return true;
      } else if (cameraPermission == PermissionStatus.denied) {
        cameraPermission = await Permission.camera.request();
      }

      if (cameraPermission == PermissionStatus.permanentlyDenied) {
        CustomDialog.openSettingDialog(
            context,
            "We need to activate your camera permissions for Names Health through your phone system setting.",
            () => openAppSettings());
      }
      return cameraPermission == PermissionStatus.granted;
    } else {
      print("-------------android-------------------");
      if (microphone == PermissionStatus.granted &&
          cameraPermission == PermissionStatus.granted &&
          blueTooth == PermissionStatus.granted ) {
        return true;
      } else if (microphone == PermissionStatus.denied ||
          cameraPermission == PermissionStatus.denied ||
          blueTooth == PermissionStatus.denied
      ) {
        cameraPermission = await Permission.camera.request();
        microphone = await Permission.microphone.request();
        blueTooth = await Permission.bluetoothConnect.request();

      }

      if (microphone == PermissionStatus.permanentlyDenied ||
          cameraPermission == PermissionStatus.permanentlyDenied ||
          blueTooth == PermissionStatus.permanentlyDenied
      ) {
        CustomDialog.openSettingDialog(
            context,
            "We need to activate your camera,microphone and bluetooth permissions for Names Health through your phone system setting.",
            () => openAppSettings());
      }

      return microphone == PermissionStatus.granted &&
          cameraPermission == PermissionStatus.granted &&
          blueTooth == PermissionStatus.granted ;
    }
  }
}
