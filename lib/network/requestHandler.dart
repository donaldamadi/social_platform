import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:student_paddy_mobile/network/data.dart';
import 'package:student_paddy_mobile/network/errorHandler.dart';
import 'package:student_paddy_mobile/network/requestManager.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/quickProfileModel.dart';
import 'package:student_paddy_mobile/provider/userModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/login_screen.dart';
import 'package:student_paddy_mobile/screens/auth_screens/quick_profile_setup_0.dart';
import 'package:student_paddy_mobile/screens/auth_screens/sign_up_verification.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/internal_screens/dubs_filter.dart';
import 'package:student_paddy_mobile/utils/helpers.dart';

Future<bool> registerUser(
    BuildContext context, Map<String, dynamic> userData) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.registerUrl,
      body: json.encode(userData),
      headers: networkData.setHeader());
  Response response = await httpRequests.post();
  // debugPrint(response.body);
  Map<String, dynamic> newUserData = json.decode(response.body);
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    userModel.setToken(newUserData["token"]);
    userModel.setUserId(newUserData["data"]["_id"]);
    toastSuccess("Registration Sucessful", context);
    return true;
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> googleLogin(
    BuildContext context, Map<String, dynamic> googleData) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.googleLoginUrl,
      body: json.encode(googleData),
      headers: networkData.setHeader(userJson: true));
  Response response = await httpRequests.post();
  Map<String, dynamic> newUserData = json.decode(response.body);
  // // debugPrint(newUserData);
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? fcmToken = await fcm.getToken();
  if (!errorHandler.hasError) {
    userModel.resetUserDetails();
    userModel.setToken(newUserData["token"]);
    userModel.setUserId(newUserData["data"]["_id"]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool("loggedIn", true);
    prefs.setString(userToken, newUserData["token"]);
    prefs.setString(userEmail, newUserData["data"]["email"]);
    // // debugPrint("NEWWWW $newUserData");
    if (newUserData["data"]["isVerified"] != true) {
      // // debugPrint('not Verified');
      await resendVerificationMail(
          context, {"email": newUserData["data"]["email"]});
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => VerifySignUp()));
      return false;
    } else {
      await updateFirebaseToken(context, {
        "firebaseToken": fcmToken,
        "type": Platform.isIOS ? "ios" : "android"
      });
      bool res =
          await getUserDetails(context, userModel.token!, showError: false);
      if (res) {
        userModel.redirectUrl = "";
        return true;
      } else {
        userModel.redirectUrl = "";
        return false;
      }
    }
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> appleLogin(
    BuildContext context, Map<String, dynamic> appleData) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.appleLoginUrl,
      body: json.encode(appleData),
      headers: networkData.setHeader(userJson: true));
  Response response = await httpRequests.post();
  // debugPrint(response.body);
  Map<String, dynamic> newUserData = json.decode(response.body);
  // debugPrint(newUserData.toString());
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? fcmToken = await fcm.getToken();
  if (!errorHandler.hasError) {
    userModel.resetUserDetails();
    userModel.setToken(newUserData["token"]);
    userModel.setUserId(newUserData["data"]["_id"]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool("loggedIn", true);
    prefs.setString(userToken, newUserData["token"]);
    prefs.setString(userEmail, newUserData["data"]["email"]);
    // debugPrint("NEWWWW $newUserData");
    if (newUserData["data"]["isVerified"] != true) {
      // debugPrint('not Verified');
      await resendVerificationMail(
          context, {"email": newUserData["data"]["email"]});
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => VerifySignUp()));
      return false;
    } else {
      await updateFirebaseToken(context, {
        "firebaseToken": fcmToken,
        "type": Platform.isIOS ? "ios" : "android"
      });
      bool res =
          await getUserDetails(context, userModel.token!, showError: false);
      if (res) {
        userModel.redirectUrl = "";
        return true;
      } else {
        userModel.redirectUrl = "";
        return false;
      }
    }
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> loginUser(
    BuildContext context, Map<String, dynamic> userData) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.loginUrl,
      body: json.encode(userData),
      headers: networkData.setHeader(userJson: true));
  Response response = await httpRequests.post();
  Map<String, dynamic> newUserData = json.decode(response.body);
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? fcmToken = await fcm.getToken();
  if (!errorHandler.hasError) {
    userModel.resetUserDetails();
    userModel.setToken(newUserData["token"]);
    userModel.setUserId(newUserData["data"]["_id"]);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setBool("loggedIn", true);
    prefs.setString(userToken, newUserData["token"]);
    prefs.setString(userEmail, newUserData["data"]["email"]);
    // debugPrint("NEWWWW $newUserData");
    if (newUserData["data"]["isVerified"] != true) {
      // debugPrint('not Verified');
      await resendVerificationMail(
          context, {"email": newUserData["data"]["email"]});
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => VerifySignUp()));
      return false;
    } else {
      await updateFirebaseToken(context, {
        "firebaseToken": fcmToken,
        "type": Platform.isIOS ? "ios" : "android"
      });
      bool res = await getUserDetails(context, userModel.token!);
      if (res) {
        return true;
      } else {
        return false;
      }
    }
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<void> logoutUser(BuildContext context, String token) async {
  GoogleSignIn googleSignIn = GoogleSignIn();
  UserOnBoardChangeNotifierModel useronBoardModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  UserChangeNotifierModel userModel =
      Provider.of<UserChangeNotifierModel>(context, listen: false);
  QuickProfileChangeNotifierModel quickModel =
      Provider.of<QuickProfileChangeNotifierModel>(context, listen: false);
  ControlChangeNotifierModel controlModel =
      Provider.of<ControlChangeNotifierModel>(context, listen: false);
  // final CounterController counterController = Get.put(CounterController());
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? fcmToken = await fcm.getToken();
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.logoutUrl + "?firebaseToken=$fcmToken",
      headers: networkData.setHeader(userBearer: true, token: token));
  // Response response = await httpRequests.get();
  // ErrorHandler errorHandler = new ErrorHandler(response: response);
  useronBoardModel.resetUserDetails();
  userModel.resetUserModeDetails();
  quickModel.resetProfileDetails();
  controlModel.resetControlDetails();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.clear();
  googleSignIn.signOut();
  getx.Get.offAll(() => LoginScreen());
  toastSuccess("You have been logged out", context);
}

Future<bool> getUserDetails(BuildContext context, String token,
    {bool showError = true}) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.userProfileUrl,
      headers: networkData.setHeader(userBearer: true, token: token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  Map<String, dynamic>? newUserData;
  if (!errorHandler.hasError) {
    bool result = true;
    newUserData = json.decode(response.body);
    userModel.setUserData(newUserData!);
    userModel.setUserId(newUserData["data"]["_id"]);
    // debugPrint("usedel.userData: ${userModel.id}");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("loggedIn", true);
    // prefs.setString(userToken, newUserData["data"]["token"]);
    prefs.setString(userEmail, newUserData["data"]["email"]);
    userModel.setToken(prefs.getString(userToken)!);
    if (newUserData["data"]["isVerified"] == null) {
      result = false;
      await resendVerificationMail(context, {"email": prefs.get(userEmail)});
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => VerifySignUp()));
    }
    if (newUserData["data"]["active"] != true) {
      result = false;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => QuickProfileScreenZero()));
    }
    return result;
  } else {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    debugPrint(errorHandler.errorMessage!);
    debugPrint(errorHandler.response!.body);
    debugPrint(errorHandler.response!.statusCode.toString());
    if (showError) {
      // toastError(errorHandler.errorMessage!, context);
    }
    if (errorHandler.response!.statusCode == 401) {
      // debugPrint("New userData: $newageRoute(builder: (context) => VerifySignUp()));
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => QuickProfileScreenZero()));
    }
    return false;
  }
}

Future<bool> quickUserData(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.userProfileUrl,
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  Map<String, dynamic>? newUserData;
  if (!errorHandler.hasError) {
    newUserData = json.decode(response.body);
    userModel.setUserData(newUserData!);
    List<Map<String, dynamic>> communities = await getCommunities(context);
    List<Map<String, dynamic>> topics = await getTopics(context);
    userModel.setCommunities(communities);
    userModel.setTopics(topics);
    return true;
  } else {
    return false;
  }
}

Future<bool> quickTopics(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.userProfileUrl,
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  Map<String, dynamic>? newUserData;
  if (!errorHandler.hasError) {
    newUserData = json.decode(response.body);
    userModel.setUserData(newUserData!);
    List<Map<String, dynamic>> topics = await getTopics(context);
    userModel.setTopics(topics);
    return true;
  } else {
    return false;
  }
}

Future<bool> resendVerificationMail(
    BuildContext context, Map<String, dynamic> userData) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.resendVerificationMailUrl,
      body: json.encode(userData),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    toastSuccess("Verification mail sent", context);
    return true;
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> resetUserPassword(
    BuildContext context, Map<String, dynamic> email) async {
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.passwordResetUrl,
      body: json.encode(email),
      headers: networkData.setHeader(userJson: true));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    toastSuccess("Please check your email to reset your password", context);
    return true;
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> deleteUser(BuildContext context, Map<String, dynamic> data) async {
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.deleteUrl,
      body: json.encode(data),
      headers: networkData.setHeader(userJson: true));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> blockUser(BuildContext context, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.blockUrl + "$id",
      body: json.encode({"action": "blacklist"}),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    // debugPrint(errorHandler.response?.body);
    // debugPrint(errorHandler.response?.reasonPhrase);
    // debugPrint(errorHandler.response?.headers);
    // debugPrint(errorHandler.response?.statusCode);
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> unblockUser(BuildContext context, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.blockUrl + "$id",
      body: json.encode({"action": "undo"}),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

// Future<bool> updateUserDetails(BuildContext context, Map<String, dynamic> userData, String token) async {
//   // debugPrint(token);
//   UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
//   HttpRequests httpRequests = HttpRequests(url: NetworkData.userProfileUrl + userModel.id!, body: json.encode(userData), headers: networkData.setHeader(userBearer: true, token: token));
//   Response response = await httpRequests.patch();
//   // debugPrint(response.body);
//   ErrorHandler errorHandler = new ErrorHandler(response: response);
//   if (!errorHandler.hasError) {
//     Fluttertoast.showToast(msg: "Quick Profile Setup Successful", backgroundColor: colors.paddygreen);
//     return true;
//   } else {
//     Fluttertoast.showToast(msg: errorHandler.errorMessage!, backgroundColor: Colors.red.withOpacity(0.7), textColor: Colors.white);
//     return false;
//   }
// }

Future<bool> updateFirebaseToken(
    BuildContext context, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.updateFirebaseUrl,
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<Map<String, dynamic>> getHomeFeed(BuildContext context, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.baseUrl + "?limit=10&page=$page",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // // debugPrint(response.body);
    // debugPrint("Home Feed gotten");
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    // userModel.setHomeFeed(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    toastError("An error occured, please try again", context);
    return {};
  }
}

Future<Map<String, dynamic>> getComments(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.commentsUrl + "$id?limit=10&page=$page",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    // toastError("An error occured, please try again", context);
    return {};
  }
}

Future<List<Map<String, dynamic>>> getTopics(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.topicsUrl + "?limit=10000&page=1&topic=.",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return List<Map<String, dynamic>>.from(json.decode(response.body)["data"]);
  } else {
    toastError("An error occured while trying to get topics, please try again",
        context);
    return [];
  }
}

Future<List<Map<String, dynamic>>> getCommunities(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.communityUrl,
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return List<Map<String, dynamic>>.from(json.decode(response.body)["data"]);
  } else {
    toastError(
        "An error occured while trying to get communities, please try again",
        context);
    return [];
  }
}

Future<bool> followUnfollowTopic(
    BuildContext context, String topic, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.topicsUrl + "/" + topic + "/" + "follow",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(response.body);
    return true;
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<bool> followUnfollowCommunity(
    BuildContext context, String community, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.communityUrl + "$community/follow",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(response.body);
    return true;
  } else {
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

Future<Map<String, dynamic>> getCommunity(BuildContext context,
    String community, String communityAction, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.communityUrl +
          "$community/$communityAction?limit=10&page=$page",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    toastError("An error occured, please try again", context);
    return {};
  }
}

Future<Map<String, dynamic>> getCommunityDetails(
    BuildContext context, String community) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.communityUrl + "$community",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    toastError("An error occured, please try again", context);
    return {};
  }
}

Future<Map<String, dynamic>> getTopic(
    BuildContext context, String topic, String topicAction, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.topicsUrl + "/$topic/$topicAction?limit=10&page=$page",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getTopicDetails(
    BuildContext context, String topic) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.topicsUrl + "/$topic",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getPostsOrResourcesById(
    BuildContext context, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.paddyUrl + "$id",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(Map<String, dynamic>.from(json.decode(response.body)["data"])
    // .toString());
    return Map<String, dynamic>.from(json.decode(response.body)["data"]);
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getQuestionById(
    BuildContext context, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.questionUrl + "$id",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(Map<String, dynamic>.from(json.decode(response.body)["data"])
    // .toString());
    return Map<String, dynamic>.from(json.decode(response.body)["data"]);
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> search(
    BuildContext context, String keyword) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.searchUrl + "?key=$keyword",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(Map<String, dynamic>.from(json.decode(response.body)["result"])
    // .toString());
    return Map<String, dynamic>.from(json.decode(response.body)["result"]);
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

///Quick Actions endpoints

Future<bool> makePost(BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.makePostUrl,
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> makePostModified(BuildContext context, List<String> filePath,
    Map<String, String> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  Map<String, dynamic> decodedResponse = {};
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${userModel.token}'
  };
  var request = http.MultipartRequest(
      'POST', Uri.parse('${NetworkData.baseUrl}paddy/make-a-post'));
  request.fields.addAll(data);
  for (var i in filePath) {
    request.files.add(await http.MultipartFile.fromPath('extras', '${i}'));
  }
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  print(response.statusCode);

  if (response.statusCode == 200) {
    return true;
  } else {
    debugPrint(response.reasonPhrase);
    return false;
  }
}

Future<bool> askQuestionModified(BuildContext context, List<String> filePath,
    Map<String, String> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  Map<String, dynamic> decodedResponse = {};
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${userModel.token}'
  };
  var request = http.MultipartRequest(
      'POST', Uri.parse('${NetworkData.baseUrl}paddy/ask-a-question'));
  request.fields.addAll(data);
  for (var i in filePath) {
    request.files.add(await http.MultipartFile.fromPath('extras', '${i}'));
  }
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  print(response.statusCode);

  if (response.statusCode == 200) {
    return true;
  } else {
    debugPrint(response.reasonPhrase);
    return false;
  }
}

Future<bool> answerQuestionModified(BuildContext context, List<String> filePath,
    Map<String, String> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  var headers = {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${userModel.token}'
  };
  var request = http.MultipartRequest(
      'POST', Uri.parse('${NetworkData.baseUrl}question/answer'));
  request.fields.addAll(data);
  for (var i in filePath) {
    request.files.add(await http.MultipartFile.fromPath('extras', '${i}'));
  }
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  print(response.statusCode);

  if (response.statusCode == 200) {
    return true;
  } else {
    debugPrint(response.reasonPhrase);
    return false;
  }
}

Future<bool> askQuestion(
    BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.askQuestionUrl,
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(response.body);
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> addBookmark(
    BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.bookmarkUrl,
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(response.body);
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> addResource(
    BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.addResourceUrl,
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(Map<String, dynamic>.from(json.decode(response.body)["data"])
    // .toString());
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> addLink(BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.addLinkUrl,
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(Map<String, dynamic>.from(json.decode(response.body)["data"])
    // .toString());
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> upvote(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.baseUrl + "paddy/$id/upvote",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.patch();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // toastSuccess("Upvoted!", context);
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> downvote(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.baseUrl + "paddy/$id/downvote",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.patch();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> upvoteAnswer(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.questionUrl + "$id/upvote",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // toastSuccess("Upvoted!", context);
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> downvoteAnswer(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.questionUrl + "$id/downvote",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // toastSuccess("Upvoted!", context);
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> tickAnswer(BuildContext context, String questionId,
    String answerId, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.questionUrl + "$questionId/$answerId/tickAnswer",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.patch();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // toastSuccess("Upvoted!", context);
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> repost(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.baseUrl + "paddy/$id/repost",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.patch();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> reask(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.baseUrl + "paddy/$id/reask",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.patch();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> deleteContent(BuildContext context, String id, String type) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.paddyUrl + "$id?type=$type",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.delete();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // // debugPrint(List<Map<String, dynamic>>.from(json.decode(response.body)["data"]));
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

///Profile Endpoints

Future<Map<String, dynamic>> allPosts(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "posts/" + id + "page=$page&limit=10",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> allQuestions(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl +
          "questions/" +
          id /*  + "page=$page&limit=10" */,
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> allAnswers(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url:
          NetworkData.profileUrl + "answers/$id" /*  + "page=$page&limit=10" */,
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<List<Map<String, dynamic>>> autoComplete(
    BuildContext context, String key) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.autoCompleteUrl + "?key=$key",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return List<Map<String, dynamic>>.from(json.decode(response.body)["data"]);
  } else {
    debugPrint(errorHandler.errorMessage);
    return [];
  }
}

Future<Map<String, dynamic>> getQuestionAnswers(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.questionUrl +
          "$id/answers" /*  + "page=$page&limit=10" */,
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> allFollowers(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/followers?page=$page&limit=20",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> allFollowing(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/following?page=$page&limit=20",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> allResources(
    BuildContext context, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl +
          "resources/$id" /*  + "page=$page&limit=10" */,
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getUserById(
    BuildContext context, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "user/$id",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getProfileByUsername(
    BuildContext context, String username) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + username,
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

///Settings Endpoints
Future<bool> updateNotifSettings(
    BuildContext context, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.settingsUrl + "notifications",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> updateContentAndPrivacy(
    BuildContext context, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.settingsUrl + "content-and-privacy",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<Map<String, dynamic>> getLoginAndSecurity(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.settingsUrl + "login-and-security",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<bool> changePassword(
    BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.settingsUrl + "changePassword",
      body: json.encode(data),
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    // debugPrint("error");
    toastError(errorHandler.errorMessage!, context);
    return false;
  }
}

///Dubs Enpoints
Future<Map<String, dynamic>> getDubsByQuestion(
    BuildContext context, bool isAnswered, int page,
    {Sort? sort}) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  UserChangeNotifierModel model =
      Provider.of<UserChangeNotifierModel>(context, listen: false);
  String sortType = "";
  String filter = "";
  String topicFilter = "";
  if (model.questionTopicId.isNotEmpty) {
    // debugPrint("=============================> setting topic filter");
    topicFilter = "&topic=${model.questionTopicId}";
  }
  if (model.questionFilter.isNotEmpty) {
    // debugPrint(model.questionFilter.toString());
    // debugPrint("Getting filter");
    filter =
        "&community=${model.questionFilter.join(',').replaceAll("&", "and")}";
  }
  if (sort != null) {
    sortType =
        "&sort_by=${sort.index == 0 ? "newest" : sort.index == 1 ? "oldest" : "recent"}";
  }
  // debugPrint(filter);
  // debugPrint(topicFilter);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.dubsUrl +
          "?type=Question&isAnswered=${isAnswered ? "true" : "false"}$sortType&desc=true$filter&limit=10&page=$page$topicFilter",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(Map<String, dynamic>.from(json.decode(response.body)).toString(),
    // wrapWidth: 1024);
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    // debugPrint("ERROR!!!");
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getDubsByResource(
    BuildContext context, bool isLink, int page,
    {Sort? sort}) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  UserChangeNotifierModel model =
      Provider.of<UserChangeNotifierModel>(context, listen: false);
  String filter = "";
  String topicFilter = "";
  if (model.resourceTopicId.isNotEmpty) {
    // debugPrint("=============================> setting topic filter");
    topicFilter = "&topic=${model.resourceTopicId}";
  }
  if (model.resourceFilter.isNotEmpty) {
    // debugPrint("Getting filter");
    filter =
        "&community=${model.resourceFilter.join(',').replaceAll("&", "and")}";
  }
  String sortType = "";
  if (sort != null) {
    sortType =
        "&sort_by=${sort.index == 0 ? "newest" : sort.index == 1 ? "oldest" : "recent"}";
  }
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.dubsUrl +
          "?type=Resource&resourceType=${isLink ? "Link" : "File"}$sortType&desc=true$filter&limit=10&page=$page$topicFilter",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    debugPrint(
        Map<String, dynamic>.from(json.decode(response.body)).toString());
    debugPrint("Gotten Data from backend");
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint("ERROR!!!");
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

///Get Notifications
Future<Map<String, dynamic>> getNotifications(
    BuildContext context, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.notificationsUrl + "?limit=10&page=$page",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<int> getNotificationCount(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.notificationCountUrl,
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> result = json.decode(response.body);
    return result["data"];
  } else {
    toastError(errorHandler.errorMessage!, context);
    return 0;
  }
}

Future<bool> markNotification(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.notificationsUrl + id,
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> markAllNotifications(BuildContext context) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.notificationsUrl + "mark-all-read",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<int> getUnreadMessagesCount(BuildContext context) async {
  // // debugPrint("getting new notifs");
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.unreadMessagesUrl,
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> result = json.decode(response.body);
    return result["data"];
  } else {
    debugPrint(errorHandler.errorMessage);
    return 0;
  }
}

Future<Map<String, dynamic>> upload(BuildContext context, var filePath) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  Map<String, dynamic> decodedResponse = {};
  var headers = {'Authorization': 'Bearer ${userModel.token}'};
  var request =
      http.MultipartRequest('POST', Uri.parse('${NetworkData.baseUrl}upload'));
  request.files.add(await http.MultipartFile.fromPath('file', '$filePath'));
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    await response.stream
        .bytesToString()
        .then((value) => decodedResponse = jsonDecode(value));
    return decodedResponse;
  } else {
    // debugPrint(response.reasonPhrase);
    return {};
  }
}

// Future<Map<String, dynamic>> uploadFile(BuildContext context, String filePath) async {
//   var request = http.MultipartRequest('post', Uri.parse(NetworkData.fileUploadUrl));
//   request.files.add(
//       await http.MultipartFile.fromPath(
//           'file',
//           filePath
//       )
//   );
//   UserOnBoardChangeNotifierModel userModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
//   request.headers["authorization"] = "Bearer ${userModel.token}";
//   var res = await request.send();
//   Response response = await http.Response.fromStream(res);
//   ErrorHandler errorHandler = new ErrorHandler(response: response);
//   if(!errorHandler.hasError){
//     return Map<String, dynamic>.from(json.decode(utf8.decode(response.bodyBytes))["results"]);
//   }
//   else{
//     toastError(errorHandler.errorMessage);
//     return null;
//   }

// }

///Profile Endpoints

//You can leave the data as an empty string
Future<Map<String, dynamic>> getUserPosts(BuildContext context,
    Map<String, dynamic> data, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/posts?limit=10&page=$page",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getUserQuestions(BuildContext context,
    Map<String, dynamic> data, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/questions?limit=10&page=$page",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getUserAnswers(
    BuildContext context, Map<String, dynamic> data, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/answers",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getUserFollowers(
    BuildContext context, Map<String, dynamic> data, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/followers",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getFollowedTopics(
    BuildContext context, Map<String, dynamic> data, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/topics",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getFollowedCommunities(
    BuildContext context, /* String name, */ String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/communities",
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getUserResources(BuildContext context,
    Map<String, dynamic> data, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/resources?limit=10&page=$page",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getUserBookmarks(BuildContext context,
    Map<String, dynamic> data, String id, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/bookmarks?limit=10&page=$page",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(Map<String, dynamic>.from(json.decode(response.body)).toString(),
    //     wrapWidth: 1024);
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> followUser(
    BuildContext context, Map<String, dynamic> data, String id) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "$id/follow",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.put();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // debugPrint(
    // Map<String, dynamic>.from(json.decode(response.body)).toString());
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<bool> addComment(
    BuildContext context, Map<String, dynamic> data, String id) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.commentsUrl + "$id",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> answerQuestion(
    BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.questionUrl + "answer",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<bool> updateUserProfile(
    BuildContext context, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "${userModel.id}",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.patch();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> userData = json.decode(response.body);
    // debugPrint(userData.toString());
    userModel.setUserData(userData);
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<void> addSkillSet(
    BuildContext context, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "${userModel.id}/add-skill",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    // return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    // return false;
  }
}

Future<bool> activateAccount(
    BuildContext context, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.activationUrl,
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> userData = json.decode(response.body);
    // debugPrint(userData.toString());
    userModel.setUserData(userData);
    return true;
  } else {
    debugPrint(errorHandler.errorMessage);
    return false;
  }
}

Future<List<dynamic>> getSchools(BuildContext context, String keyword) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.schoolsUrl + "?key=$keyword&limit=5",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> userData = json.decode(response.body);
    return userData["data"];
  } else {
    return [];
  }
}

Future<List<dynamic>> getSkills(BuildContext context, String keyword) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.skillSearchUrl + "?key=$keyword",
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> userData = json.decode(response.body);
    // debugPrint("success");
    // debugPrint(userData.toString());
    return userData["data"];
  } else {
    debugPrint(errorHandler.errorMessage);
    debugPrint(errorHandler.response!.headers.toString());
    debugPrint(errorHandler.response!.statusCode.toString());
    debugPrint(errorHandler.response!.reasonPhrase);
    debugPrint(errorHandler.response!.body);
    return [];
  }
}

Future<Map<String, dynamic>> addSkill(
    BuildContext context, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.profileUrl + "${userModel.id}/add-skill",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> userData = json.decode(response.body);
    // debugPrint("success");
    // debugPrint(userData.toString());
    return userData["data"];
  } else {
    return {};
  }
}

Future<Map<String, dynamic>> checkUsername(
    BuildContext context, String keyword) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.findUsername + "?key=$keyword",
      headers: networkData.setHeader(userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    Map<String, dynamic> userData = json.decode(response.body);
    return userData;
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> initiateChat(
    BuildContext context, Map<String, dynamic> data) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.chatUrl + "/initiate",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    toastError("An error occured, please try again", context);
    return {};
  }
}

Future<Map<String, dynamic>> sendMessage(
    BuildContext context, String id, Map<String, dynamic> data) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.chatUrl + "/$id/send-message",
      body: json.encode(data),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<Map<String, dynamic>> getMessages(BuildContext context) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.chatUrl + "?limit=100&page=1",
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    return {};
  }
}

Future<List<dynamic>> getChatMessages(BuildContext context, String id) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.chatUrl + "/$id?limit=2000&page=1",
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return List<dynamic>.from(json.decode(response.body)["messages"]);
  } else {
    debugPrint(errorHandler.errorMessage);
    return [];
  }
}

Future<Map<String, dynamic>> getPreviewLink(
    BuildContext context, String link) async {
  closeKeyboard();
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.previewLinkUrl,
      body: json.encode({"link": "$link"}),
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.post();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    debugPrint(errorHandler.errorMessage);
    toastError("An error occured, please try again", context);
    return {};
  }
}

Future<List<dynamic>> autoCompleteUser(
    BuildContext context, String keyword) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url: NetworkData.autoCompleteUrl + "?key=$keyword",
      headers: networkData.setHeader(
          userJson: true, userBearer: true, token: userModel.token));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return List<dynamic>.from(json.decode(response.body)["data"]);
  } else {
    debugPrint(errorHandler.errorMessage);
    // toastError("An error occured, please try again", context);
    return [];
  }
}

Future<Map<String, dynamic>> getCommunityFollowers(
    BuildContext context, String community, int page) async {
  UserOnBoardChangeNotifierModel userModel =
      Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
  HttpRequests httpRequests = HttpRequests(
      url:
          NetworkData.communityUrl + "$community/followers?limit=20&page=$page",
      headers: networkData.setHeader(
          userBearer: true, token: userModel.token, userJson: true));
  Response response = await httpRequests.get();
  ErrorHandler errorHandler = new ErrorHandler(response: response);
  if (!errorHandler.hasError) {
    return Map<String, dynamic>.from(json.decode(response.body));
  } else {
    // toastError("An error occured, please try again", context);
    return {};
  }
}
