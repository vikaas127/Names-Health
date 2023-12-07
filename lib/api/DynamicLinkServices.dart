import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:names/main.dart';
import 'package:names/model/FeedModel.dart';

import '../SinglePostPage.dart';

class DynamicLinkService {
  BuildContext context;
  setContext(BuildContext context) {
    this.context = context;
  }

  Future handleDynamicLinks() async {
    // 1. Get the initial dynamic link if the app is opened with a dynamic link
    final PendingDynamicLinkData data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    // 2. handle link that has been retrieved
    handleDeepLink(data);

    // 3. Register a link callback to fire if the app is opened up from the background
    // using a dynamic link.
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      // Navigator.pushNamed(context, dynamicLinkData.link.path);
      // 3a. handle link that has been retrieved
      handleDeepLink(dynamicLinkData);
    }).onError((error) {
      // Handle errors
    });
  }

  void handleDeepLink(PendingDynamicLinkData data) {
    final Uri deepLink = data?.link;

    // AppHelper.showToastMessage(data.toString());
    if (deepLink != null) {
      final queryParams = deepLink.queryParameters;
      if (queryParams.isNotEmpty) {
        String userId = queryParams["userId"];
        String postId = queryParams["postId"];

        if (navigatorKey != null) {}

        Navigator.of(navigatorKey.currentContext).push(PageRouteBuilder(
          pageBuilder: (BuildContext context, Animation<double> animation,
                  Animation<double> secondaryAnimation) =>
              SinglePostPage(
            notificationId: null,
            userId: userId,
            postId: postId,
          ),
          transitionDuration: Duration(seconds: 0),
        ));
      } /*else {
        Navigator.pushNamed(
          context,
          dynamicLinkData.link.path,
        );
    }*/
    }
  }

  Future<String> createFirstPostLink(
      String userId, String postId, Feed feed, String imageUrl) async {
    /*DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: FirebaseKey.kUriPrefix,
      link: Uri.parse(FirebaseKey.kUriPrefix + FirebaseKey.link),
      androidParameters: const AndroidParameters(
        packageName: 'com.example.deeplink',
        minimumVersion: 0,
      ),
    );*/

    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: "https://names.page.link",
      // longDynamicLink: Uri.parse('https://names.cmsbox.in?userId=$userId&&postId=$postId'),
      link: Uri.parse('https://names.health?userId=$userId&&postId=$postId'),
      androidParameters: AndroidParameters(
        packageName: "com.names",
        minimumVersion: 0,
      ),
      // NOT ALL ARE REQUIRED ===== HERE AS AN EXAMPLE =====
      iosParameters: IOSParameters(
        bundleId: 'com.names.io',
        minimumVersion: '0',
        // appStoreId: '123456789',
      ),

      socialMetaTagParameters: SocialMetaTagParameters(
        title: feed.title != null ? feed.title : 'Names',
        description: 'Names official',
        imageUrl: Uri.parse(
          imageUrl != null ? imageUrl : "",
        ),
      ),
    );

    /*Uri url;
    if (short) {
      final ShortDynamicLink shortLink =
      await dynamicLinks.buildShortLink(parameters);
      url = shortLink.shortUrl;
    } else {
      url = await dynamicLinks.buildLink(parameters);
    }*/

    Uri dynamicUrl = await FirebaseDynamicLinks.instance.buildLink(parameters);
    // final Uri dynamicUrl =  parameters.link;

    return dynamicUrl.toString();
  }
}
