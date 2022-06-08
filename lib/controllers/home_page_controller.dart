import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  ScrollController scrollController = ScrollController();

  void scrollUp() {
  scrollController.animateTo(
    scrollController.position.minScrollExtent,
    duration: Duration(seconds: 2),
    curve: Curves.fastOutSlowIn,
  );
}
}
