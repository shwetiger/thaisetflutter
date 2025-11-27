// @dart=2.9
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:thai2dlive/data/constant.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ApiForDeveloperForMobileScreen extends StatefulWidget {
  const ApiForDeveloperForMobileScreen({Key key}) : super(key: key);

  @override
  State<ApiForDeveloperForMobileScreen> createState() =>
      _ApiForDeveloperForMobileScreenState();
}

WebViewController controllerGlobal;

Future<bool> browserBack(BuildContext context) async {
  String currentUrl = await controllerGlobal.currentUrl();

  if (currentUrl.startsWith(apiUrl)) {
    Navigator.of(context).pop();
  } else if (!currentUrl.startsWith(apiUrl) &&
      await controllerGlobal.canGoBack()) {
    controllerGlobal.goBack();
  } else {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(false);
  }
}

class _ApiForDeveloperForMobileScreenState
    extends State<ApiForDeveloperForMobileScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thai SET 2D API'),
        // This drop down menu demonstrates that Flutter widgets can be shown over the web view.
      ),
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => browserBack(context),
          child: Builder(builder: (BuildContext context) {
            return WebView(
              initialUrl: apiUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                controllerGlobal = webViewController;
                _controller.complete(webViewController);
              },
              onProgress: (int progress) {},
              javascriptChannels: <JavascriptChannel>{
                _toasterJavascriptChannel(context),
              },
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://www.youtube.com/')) {
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
              onPageStarted: (String url) {},
              onPageFinished: (String url) {},
              gestureNavigationEnabled: true,
              backgroundColor: const Color(0x00000000),
            );
          }),
        ),
      ),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
