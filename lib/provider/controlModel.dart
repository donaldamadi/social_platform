import 'dart:io';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:student_paddy_mobile/network/data.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

import '../network/requestHandler.dart';
import '../utils/helpers.dart';

class ControlChangeNotifierModel extends ChangeNotifier {
  Map<String, dynamic>? actionStream;
  bool actionUpdate = false;
  List<AssetEntity> answerAssetList = [];
  HtmlEditorController? answerController;
  String? answerText;
  bool commentOrAnswerUpdate = false;
  String commentOrAnswerpaddyId = '';
  bool deletePaddy = false;
  Map<String, dynamic> deletedPaddyData = {};
  bool getMessages = false;
  bool goToFeedTop = false;
  bool isLoadingNotifications = false;
  bool isRead = false;
  Map<String, dynamic>? notificationDetails = {};
  List<AssetEntity> postAssetList = [];
  HtmlEditorController? postController;
  String? postText;
  List<AssetEntity> questionAssetList = [];
  HtmlEditorController? questionController;
  String? questionText;
  bool showMessageBadge = false;
  bool fetchParentValue = true;
  // socket.onConnect((data) => //  print("Connected"));
  //   socket.on("connect", (data) => {});
  IO.Socket socket = IO.io(NetworkData.baseUrl.replaceAll("/v1/", ""), <String, dynamic>{
    'transports': ['websocket'],
    'autoConnect': false,
  });
  EventBus eventBus = EventBus();
  // ScrollController commentScrollController = ScrollController();

  void fetchParent() {
    if (fetchParentValue == true) {
      eventBus.fire(true);
      // fetchParentValue = false;
    }
  }

  bool updateTopicList = false;

  // void setParentPaddy(bool )

  void setUpdateTopicList(bool value) {
    updateTopicList = value;
    notifyListeners();
  }

  void setPostAssetList(List<AssetEntity> value) {
    postAssetList = value;
    notifyListeners();
  }

  void setQuestionAssetList(List<AssetEntity> value) {
    questionAssetList = value;
    notifyListeners();
  }

  void setAnswerAssetList(List<AssetEntity> value) {
    answerAssetList = value;
    notifyListeners();
  }

  void clearPostAssetList() {
    postAssetList = [];
    notifyListeners();
  }

  void clearQuestionAssetList() {
    questionAssetList = [];
    notifyListeners();
  }

  void clearAnswerAssetList() {
    answerAssetList = [];
    notifyListeners();
  }

  makePost(bool addTopic, TextEditingController titleController, String topic, List<String> communitiesPicked) async {
    Navigator.pop(Get.context!);
    toastMessage("Adding Post...", Get.context!);
    List<String> tempAssets = [];
    for (var i in postAssetList) {
      File? file = await i.file;
      File compressedFile = await compressFile(file!);
      String path = compressedFile.path;
      tempAssets.add(path);
    }
    print(tempAssets);
    bool res = await makePostModified(
        Get.context!,
        tempAssets,
        addTopic
            ? {"body": postText ?? "", "title": titleController.text, "topic": topic, "community": communitiesPicked.join(",")}
            : {
                "body": postText ?? "",
                "title": titleController.text,
                "topic": topic,
              });
    if (res) {
      toastSuccess("Your post has been added", Get.context!);
      UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(Get.context!, listen: false);
      userModel.setUpdatedResult(true);
      clearPostText();
      clearPostAssetList();
      setUpdateTopicList(true);
      // Navigator.pop(Get.context!);
    }
  }

  askQuestion(bool addTopic, TextEditingController titleController, String topic, List<String> communitiesPicked) async {
    Navigator.pop(Get.context!);
    toastMessage("Asking Question...", Get.context!);
    List<String> tempAssets = [];
    for (var i in questionAssetList) {
      File? file = await i.file;
      File compressedFile = await compressFile(file!);
      String path = compressedFile.path;
      tempAssets.add(path);
    }
    print(tempAssets);
    bool res = await askQuestionModified(
        Get.context!,
        tempAssets,
        addTopic
            ? {"body": postText ?? "", "title": titleController.text, "topic": topic, "community": communitiesPicked.join(",")}
            : {
                "body": postText ?? "",
                "title": titleController.text,
                "topic": topic,
              });
    if (res) {
      toastSuccess("Your question has been asked", Get.context!);
      UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(Get.context!, listen: false);
      userModel.setUpdatedResult(true);
      clearQuestionText();
      clearQuestionAssetList();
      setUpdateTopicList(true);
      // Navigator.pop(Get.context!);
    }
  }

  answerQuestion(String id) async {
    Navigator.pop(Get.context!);
    toastMessage("Answering Question...", Get.context!);
    List<String> tempAssets = [];
    for (var i in answerAssetList) {
      File? file = await i.file;
      File compressedFile = await compressFile(file!);
      String path = compressedFile.path;
      tempAssets.add(path);
    }
    print(tempAssets);
    bool res = await answerQuestionModified(Get.context!, tempAssets, {
      "questionId": id,
      "body": answerText ?? "",
    });
    if (res) {
      toastSuccess("Answer Sent", Get.context!);
      UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(Get.context!, listen: false);
      userModel.setUpdatedResult(true);
      userModel.setUpdatedResult(true);
      setCommentOrPaddyId(id);
      setCommentOrAnswerMade(true);
      clearAnswerText();

      clearAnswerAssetList();
      // Navigator.pop(Get.context!);
    }
  }

  void setCommentOrPaddyId(String id) {
    commentOrAnswerpaddyId = id;
    notifyListeners();
  }

  void setGetMessages(bool value) {
    getMessages = value;
    notifyListeners();
  }

  void setLoadingNotifications(bool value) {
    isLoadingNotifications = value;
    notifyListeners();
  }

  void setCommentOrAnswerMade(bool value) {
    commentOrAnswerUpdate = value;
    notifyListeners();
  }

  void setPostController(HtmlEditorController controller) {
    postController = controller;
    notifyListeners();
  }

  void setIsNotRead(bool isRead) {
    this.isRead = isRead;
    notifyListeners();
  }

  void setMessageBadge(bool show) {
    showMessageBadge = show;
    notifyListeners();
  }

  void setDeletedPaddyData(Map<String, dynamic> data) {
    deletedPaddyData = data;
    notifyListeners();
  }

  void setDeletePaddy(bool deletePaddy) {
    this.deletePaddy = deletePaddy;
    notifyListeners();
  }

  void setAnswerController(HtmlEditorController controller) {
    answerController = controller;
    notifyListeners();
  }

  void setQuestionController(HtmlEditorController controller) {
    questionController = controller;
    notifyListeners();
  }

  void setGoToFeedTop(bool value) {
    this.goToFeedTop = value;
    notifyListeners();
  }

  void setPostText(String postText) {
    this.postText = postText;
    notifyListeners();
  }

  void setQuestionText(String questionText) {
    this.questionText = questionText;
    notifyListeners();
  }

  void setAnswerText(String answerText) {
    this.answerText = answerText;
    notifyListeners();
  }

  void clearPostText() {
    this.postText = null;
    notifyListeners();
  }

  void clearQuestionText() {
    this.questionText = null;
    notifyListeners();
  }

  void clearAnswerText() {
    this.answerText = null;
    notifyListeners();
  }

  void setNotificationDetails(Map<String, dynamic> value) {
    this.notificationDetails = value;
    notifyListeners();
  }

  void clearNotificationDetails() {
    this.notificationDetails = {};
    notifyListeners();
  }

  void setActionStream(Map<String, dynamic> value) {
    this.actionStream = value;
    notifyListeners();
  }

  void setActionUpdate(bool value) {
    this.actionUpdate = value;
    notifyListeners();
  }

  void resetControlDetails() {
    goToFeedTop = false;
    notificationDetails = null;
    actionStream = null;
    actionUpdate = false;
    postText = null;
    questionText = null;
    postController = null;
    questionController = null;
    answerController = null;
    deletePaddy = false;
    deletedPaddyData = {};
    showMessageBadge = false;
    answerText = null;
    isRead = false;
    commentOrAnswerUpdate = false;
    commentOrAnswerpaddyId = '';
    getMessages = false;
    isLoadingNotifications = false;
    updateTopicList = false;
    postAssetList = [];
    questionAssetList = [];
    answerAssetList = [];
  }
}
