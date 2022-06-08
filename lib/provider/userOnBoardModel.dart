import 'package:flutter/material.dart';

class UserOnBoardChangeNotifierModel extends ChangeNotifier {
  String? token;
  Map<String, dynamic>? userData;
  String? id;
  String? url;
  String? appBarTitle;
  List<Map<String, dynamic>> topics = [];
  List<Map<String, dynamic>> communities = [];
  List<dynamic> homeFeed = [];
  bool updatedResult = false;
  String? redirectUrl;
  String? pic;

  void setUpdatedResult(bool result) {
    this.updatedResult = result;
    notifyListeners();
  }

  void setRedirectUrl(String url) {
    this.redirectUrl = url;
    notifyListeners();
  }

  void addToHomeFeed(List<dynamic> homeFeed) {
    this.homeFeed.addAll(homeFeed);
    notifyListeners();
  }

  void setHomeFeed(List<dynamic> homeFeed) {
    this.homeFeed = homeFeed;
    notifyListeners();
  }

  void setCommunities(List<Map<String, dynamic>> communities) {
    this.communities = communities;
    notifyListeners();
  }

  void setTopics(List<Map<String, dynamic>> topics) {
    this.topics = topics;
    notifyListeners();
  }

  void setToken(String token) {
    this.token = token;
    notifyListeners();
  }

  void setAppBarTitle(String appBarTitle) {
    this.appBarTitle = appBarTitle;
    notifyListeners();
  }

  void setUrl(String url) {
    this.url = url;
    notifyListeners();
  }

  void setBackgroundPic(String pic) {
    this.pic = pic;
    notifyListeners();
  }

  void setUserId(String id) {
    this.id = id;
    notifyListeners();
  }

  void setUserData(Map<String, dynamic> userData) {
    this.userData = userData;
    notifyListeners();
  }

  void resetUserDetails() {
    updatedResult = false;
    token = null;
    userData = null;
    id = null;
    url = null;
    appBarTitle = null;
    communities = [];
    topics = [];
    homeFeed = [];
  }
}
