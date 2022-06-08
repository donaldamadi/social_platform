import 'package:flutter/material.dart';

class DefaultWebView extends StatefulWidget {
  final String selectedUrl;
  final String title;
  final bool close;

  DefaultWebView({
    required this.title,
    required this.selectedUrl,
    this.close = false,
  });

  @override
  _DefaultWebViewState createState() => _DefaultWebViewState();
}

class _DefaultWebViewState extends State<DefaultWebView> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
