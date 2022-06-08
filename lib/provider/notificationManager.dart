import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:student_paddy_mobile/provider/getXController.dart';
import 'package:student_paddy_mobile/utils/colors.dart';

class NotificationManager {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // String? payload;
  final CounterController counterController = Get.put(CounterController());

  NotificationManager() {
    //  print("This is shown from the onSelect Notification function");
    WidgetsFlutterBinding.ensureInitialized();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: (String? payload) {
      //  print("This is shown from the onSelect Notification function");
      //  print(payload);
      counterController.setNotificationData(jsonDecode(payload ?? ""));
    });
  }

  onSelectNotification(String? payload) {
    counterController.setNotificationData(jsonDecode(payload ?? ""));
  }


  showNotification(String title, String message, Map<String, dynamic> data) async {
    final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(await _getByteArrayFromUrl(data["image"]));

    final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(await _getByteArrayFromUrl('https://via.placeholder.com/400x800'));

    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(bigPicture,
        largeIcon: largeIcon,
        contentTitle: 'overridden <b>big</b> content title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);

    var android = new AndroidNotificationDetails("channelId", "channelName",
        styleInformation: BigTextStyleInformation(""),
        largeIcon: largeIcon,
        importance: Importance.max,
        channelDescription: "notification",
        priority: Priority.high,
        enableLights: true,
        ledColor: colors.paddygreen,
        color: colors.paddygreen,
        visibility: NotificationVisibility.public,
        ledOffMs: 1000,
        ledOnMs: 1000,
        playSound: true);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android: android, iOS: iOS);
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    String? payload = jsonEncode(data);
    //  print("PAYLOADD: $payload");
    final CounterController counterController = Get.put(CounterController());
    counterController.setNotificationData(jsonDecode(payload));
    await flutterLocalNotificationsPlugin.show(Random().nextInt(1000), title, message, platform, payload: payload);
    //  print(notificationAppLaunchDetails?.didNotificationLaunchApp);
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }

  Future<void> showBigPictureNotificationURL() async {
    final ByteArrayAndroidBitmap largeIcon = ByteArrayAndroidBitmap(await _getByteArrayFromUrl('https://via.placeholder.com/48x48'));
    final ByteArrayAndroidBitmap bigPicture = ByteArrayAndroidBitmap(await _getByteArrayFromUrl('https://via.placeholder.com/400x800'));

    final BigPictureStyleInformation bigPictureStyleInformation = BigPictureStyleInformation(bigPicture,
        largeIcon: largeIcon,
        contentTitle: 'overridden <b>big</b> content title',
        htmlFormatContentTitle: true,
        summaryText: 'summary <i>text</i>',
        htmlFormatSummaryText: true);
    final AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails('big text channel id', 'big text channel name',
        channelDescription: 'big text channel description', styleInformation: bigPictureStyleInformation);
    final NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(Random().nextInt(1000), 'big text title', 'silent body', platformChannelSpecifics);
  }
}
