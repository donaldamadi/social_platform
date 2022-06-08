import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MyWebView extends StatefulWidget {
  final String selectedUrl;
  final String title;
  final bool close;

  MyWebView({
    required this.title,
    required this.selectedUrl,
    this.close = false,
  });

  @override
  _MyWebViewState createState() => _MyWebViewState();
}

class _MyWebViewState extends State<MyWebView> {
  final Completer<WebViewController> controller =
      Completer<WebViewController>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: colors.blueColorOne,
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebView(
              userAgent: "studentPaddy",
              initialUrl: widget.selectedUrl,
              navigationDelegate: (NavigationRequest request) {
                if (request.url.startsWith('https://studentpaddy.com') &&
                    widget.close) {
                  Navigator.of(context).pop(true);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (val) {
                setState(() {
                  isLoading = false;
                });
                //  print(val);
                if (val.contains('code=')) {
                  UserOnBoardChangeNotifierModel
                      userOnBoardChangeNotifierModel =
                      Provider.of<UserOnBoardChangeNotifierModel>(context,
                          listen: false);
                  userOnBoardChangeNotifierModel
                      .setRedirectUrl(val.split('?')[1]);
                  //  print("val.split('?')[1]");
                  Navigator.of(context).pop(true);
                }
              },
              // onPageStarted: (val) {
              //   //  print(val);
              // },
              // onWebResourceError: (val) {
              //   //  print(val);
              // },
            ),
            isLoading ? Center(child: CircularProgressIndicator()) : SizedBox(),
          ],
        ));
  }
}
