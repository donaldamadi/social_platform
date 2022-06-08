import 'dart:io';

import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/components/textControl.dart';
import 'package:student_paddy_mobile/utils/colors.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  WebViewScreen(this.url);

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Enable hybrid composition.
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: textControl("Student Paddy", context, size: 18, color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            child: WebView(
              initialUrl: widget.url,
              javascriptMode: JavascriptMode.unrestricted,
              onPageStarted: (_) {
                setState(() {
                  loading = true;
                });
              },
              onPageFinished: (_) {
                setState(() {
                  loading = false;
                });
              },
            ),
          ),
          loading ? Center(child: CircularProgressIndicator()) : SizedBox()
        ],
      ),
    );
  }
}
