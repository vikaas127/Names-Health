import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OpenWebView extends StatefulWidget {
  const OpenWebView({Key key}) : super(key: key);

  @override
  _OpenWebViewState createState() => _OpenWebViewState();
}

class _OpenWebViewState extends State<OpenWebView> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text("Connect Smartcar"),
        // ),
        body: Stack(children: <Widget>[
      WebView(
        initialUrl: "https://names.cmsbox.in/user/business",
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController controller) {
          _controller.complete(controller);
          controller.clearCache();
          final cookieManager = CookieManager();
          cookieManager.clearCookies();
        },
        onProgress: (int progress) {
          print("WebView is loading (progress : $progress%)");
          if (progress == 100 && isLoading) {
            setState(() {
              isLoading = false;
            });
          }
        },
        javascriptChannels: <JavascriptChannel>{
          _toasterJavascriptChannel(context),
        },
        navigationDelegate: (NavigationRequest request) {
          /*print('allowing navigation to $request');
          if (request.url.contains("https://app.carkenny.com/exchange?code=")) {
            getData(request.url);
            return null;
          }*/
          return NavigationDecision.navigate;
        },
        onPageStarted: (String url) {
          print('Page started loading: $url');
        },
        onPageFinished: (String url) async {
          print('Page finished loading: $url');
        },
        gestureNavigationEnabled: true,
      ),
      isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(),
    ]));
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
