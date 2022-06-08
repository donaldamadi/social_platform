import 'package:flutter/material.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/dubs_filter.dart';

class UserChangeNotifierModel extends ChangeNotifier {
  bool showQuickAction = false;
  String? resourceId;
  Sort? questionSort;
  Sort? resourceSort;
  List<String> questionFilter = [];
  List<String> resourceFilter = [];
  bool isQuestionSelected = false;
  String questionFilterString = "";
  String resourceFilterString = "";
  bool canShowUpdate = true;
  String questionTopicId = "";
  String resourceTopicId = "";

  void setCanShowUpdate(bool canShowUpdate) {
    this.canShowUpdate = canShowUpdate;
    notifyListeners();
  }

  void setQuickActionType(bool showQuickAction) {
    this.showQuickAction = showQuickAction;
    notifyListeners();
  }

  void setQuickActionId(String resourceId) {
    this.resourceId = resourceId;
    notifyListeners();
  }

  void resetUserModeDetails() {
    showQuickAction = true;
  }

  ///Dubs Filter Provider

  void setQuestionTopicId(String topicId) {
    this.questionTopicId = topicId;
    notifyListeners();
  }

  void setResourceTopicId(String topicId) {
    this.resourceTopicId = topicId;
    notifyListeners();
  }

  void setQuestionSort(Sort questionSort) {
    this.questionSort = questionSort;
    notifyListeners();
  }

  void setResourceSort(Sort resourceSort) {
    this.resourceSort = resourceSort;
    notifyListeners();
  }

  void setQuestionFilter(List<String> questionFilter) {
    this.questionFilter = questionFilter;
    notifyListeners();
  }

  void setResourceFilter(List<String> resourceFilter) {
    this.resourceFilter = resourceFilter;
    notifyListeners();
  }

  void setQuestionSelected(bool isQuestionSelected) {
    this.isQuestionSelected = isQuestionSelected;
    notifyListeners();
  }

  void clear() {
    this.questionFilter = [];
    this.resourceFilter = [];
    this.resourceId = null;
    this.showQuickAction = false;
    this.resourceSort = null;
    this.questionSort = null;
    this.isQuestionSelected = true;
    this.canShowUpdate = false;
    this.questionFilterString = "";
    this.resourceFilterString = "";
  }
}
