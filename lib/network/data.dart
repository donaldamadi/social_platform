class NetworkData {
  // static final baseUrl = "https://api.studentpaddy.com/v1/";
  static final baseUrl = "https://studentpaddy-staging.herokuapp.com/v1/";

  Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  Map<String, String> setHeader(
      {bool userBearer = false,
      bool userJson = false,
      String? token,
      String? body}) {
    final Map<String, String> newHeaders = headers;
    if (userBearer) newHeaders["Authorization"] = "Bearer $token";
    if (userJson) newHeaders["Content-Type"] = "application/json";
    if (userJson) newHeaders["accept"] = "application/json";
    return newHeaders;
  }

  static final registerUrl = baseUrl + "auth/signup";
  static final loginUrl = baseUrl + "auth/login";
  static final verifyUserUrl = baseUrl + "auth/verify/";
  static final resendVerificationMailUrl = baseUrl + "auth/requestVerify";
  static final userProfileUrl = baseUrl + "users/me";
  static final logoutUrl = baseUrl + "auth/logout";
  static final logoutAllUrl = baseUrl + "users/logoutall";
  static final googleLoginUrl = baseUrl + "auth/google/login";
  static final appleLoginUrl = baseUrl + "auth/apple/login";
  static final passwordResetUrl = baseUrl + "auth/requestPasswordReset";
  static final topicsUrl = baseUrl + "topics";
  static final communityUrl = baseUrl + "community/";
  static final searchUrl = baseUrl + "search";
  static final makePostUrl = baseUrl + "paddy/make-a-post";
  static final askQuestionUrl = baseUrl + "paddy/ask-a-question";
  static final addResourceUrl = baseUrl + "paddy/add-a-resource";
  static final addLinkUrl = baseUrl + "paddy/add-a-link";
  static final profileUrl = baseUrl + "profile/";
  static final settingsUrl = baseUrl + "settings/";
  static final dubsUrl = baseUrl + "dubs";
  static final notificationsUrl = baseUrl + "notifications/";
  static final notificationCountUrl = baseUrl + "users/notifications";
  static final commentsUrl = baseUrl + "comments/";
  static final questionUrl = baseUrl + "question/";
  static final schoolsUrl = baseUrl + "schools";
  static final findUsername = baseUrl + "users/find-username";
  static final chatUrl = baseUrl + "chat";
  static final previewLinkUrl = baseUrl + "paddy/get-preview";
  static final autoCompleteUrl = baseUrl + "users/autocomplete";
  static final paddyUrl = baseUrl + "paddy/";
  static final activationUrl = baseUrl + "auth/account-activation";
  static final updateFirebaseUrl = baseUrl + "notifications/update/firebase";
  static final skillSearchUrl = baseUrl + "profile/skillset/search";
  static final deleteUrl = baseUrl + "settings/delete";
  static final blockUrl = baseUrl + "users/blacklist-user/";
  static final unreadMessagesUrl = baseUrl + "chat/unread-messages";
  static final autoCompleteUser = baseUrl + "users/autocomplete";
  static final bookmarkUrl = baseUrl + "paddy/bookmark";
}

final networkData = NetworkData();
const userToken = "userToken";
const userEmail = "userEmail";
const baseUrl = "https://studentpaddy.com";
