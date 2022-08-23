import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class NotificationState {}

class NotificationAbsent extends NotificationState {}

class NotificationPresent extends NotificationState {
  final Map notificationData;

  NotificationPresent(this.notificationData);
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier(this.ref) : super(NotificationAbsent());

  Ref ref;

  void setNotificationData(Map<String, dynamic> data) {
    state = NotificationPresent(data);
  }
}

final pushNotificationProvider = StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => NotificationNotifier(ref));

class PushNotificationService {
  final fcm = FirebaseMessaging.instance;

  Future initialise(WidgetRef ref) async {
    print('initialising push notification service...');

    /// foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
     // Use ref.read here -> ref.read();
    });

    /// handler if the app has been opened from a background state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onMessageOpenedApp: $message');
    });

  }
}