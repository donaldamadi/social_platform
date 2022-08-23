import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mentions/flutter_mentions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:get/get.dart';
// import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:student_paddy_mobile/provider/controlModel.dart';
import 'package:student_paddy_mobile/provider/getXController.dart';
import 'package:student_paddy_mobile/provider/notificationManager.dart';
import 'package:student_paddy_mobile/provider/notificationProvider.dart';
import 'package:student_paddy_mobile/provider/quickProfileModel.dart';
import 'package:student_paddy_mobile/provider/userModel.dart';
import 'package:student_paddy_mobile/provider/userOnBoardModel.dart';
import 'package:student_paddy_mobile/screens/auth_screens/forgot_password_screen.dart';
import 'package:student_paddy_mobile/screens/auth_screens/login_screen.dart';
import 'package:student_paddy_mobile/screens/auth_screens/sign_up_screen.dart';
import 'package:student_paddy_mobile/screens/navigator_screens/navigatorPage.dart';
import 'package:student_paddy_mobile/screens/onboarding_screens/onboarding_screen.dart';
import 'package:student_paddy_mobile/screens/onboarding_screens/splash_screen.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  //  print('Handling a Background Message Data: ${message.data}');
  NotificationManager notificationManager = NotificationManager();
  if (Platform.isAndroid)
    notificationManager.showNotification(message.data["title"].toString(),
        message.data["body"].toString(), message.data);
  //  print("Notification shown");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase?.initializeApp(
      // options: FirebaseOptions(
      //   apiKey: "AIzaSyCus3D8Myvd2dkMoHgaEjgr6fuYrmIttc8",
      //   appId: "1:420685507600:android:17a8718f76bcc2f6422e95",
      //   messagingSenderId: "420685507600",
      //   projectId: "student-paddy-mobile",
      // ),
      );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationChannel channel;
  final NotificationAppLaunchDetails? notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  String? payload = notificationAppLaunchDetails?.payload;
  // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Firebase.initializeApp(
      // options: FirebaseOptions(
      //   apiKey: "AIzaSyCus3D8Myvd2dkMoHgaEjgr6fuYrmIttc8",
      //   appId: "1:420685507600:android:17a8718f76bcc2f6422e95",
      //   messagingSenderId: "420685507600",
      //   projectId: "student-paddy-mobile",
      // ),
      );

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    // badge: true,
    sound: true,
  );

  // final notificationProvider = ref.wa 


  // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  // // Get any initial links
  // final PendingDynamicLinkData? initialLink =
  //     await FirebaseDynamicLinks.instance.getInitialLink();
  // // debugPrint("==========================> ${initialLink?.link}");

  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    final CounterController counterController = Get.put(CounterController());
    if (Platform.isIOS) {
      payload = event.notification?.bodyLocKey ?? "";
    }

    counterController
        .setNotificationData(jsonDecode(event.notification?.bodyLocKey ?? ""));
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //  print("Got a message whilst in the foreground");
    //  print("Message data: ${message.data}");
    //  print(message.notification?.body);

    final CounterController counterController = Get.put(CounterController());

    // counterController.setNotificationData(message);

    //  print(counterController.notifCount);
    counterController.increment();

    if (message.notification != null) {
      //  print("Message also contained a notification: ${message.notification}");
    }
  });

  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  //  print("User Granted Permission: ${settings.authorizationStatus}");

  channel = const AndroidNotificationChannel(
    'paddy_notifs',
    'Student Paddy Notifications',
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  // GestureBinding.instance!.resamplingEnabled = true;
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark));
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final FirebaseMessaging fcm = FirebaseMessaging.instance;
  String? fcmToken = await fcm.getToken();
  //  print(fcmToken);
  //  print(payload);
  runApp(
    riverpod.ProviderScope(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider<QuickProfileChangeNotifierModel>(
              create: (context) => QuickProfileChangeNotifierModel()),
          ChangeNotifierProvider<UserOnBoardChangeNotifierModel>(
              create: (context) => UserOnBoardChangeNotifierModel()),
          ChangeNotifierProvider<UserChangeNotifierModel>(
              create: (context) => UserChangeNotifierModel()),
          ChangeNotifierProvider<ControlChangeNotifierModel>(
              create: (context) => ControlChangeNotifierModel()),
        ],
        child: /* DevicePreview(
          builder: (context) =>  */
            MyApp(payload: jsonDecode(payload ?? "{}")),
        // ),
      ),
    ),
  );
}

class MyApp extends riverpod.ConsumerStatefulWidget {
  static GlobalKey<NavigatorState> navigatorKey =
      new GlobalKey<NavigatorState>();
  static String dynamicScreen = "/";
  static String loginScreen = 'login_screen';
  static String forgotPasswordScreen = 'forgot_password_screen';
  static String splashScreen = 'splash_screen';
  static String mainScreen = 'main_Screen';
  static String signUpScreen = 'sign_up_screen';
  static String onboardingScreen = 'onboarding_screen';
  static String navigatorScreen = 'navigator_screen';
  final Map<String, dynamic>? payload;

  MyApp({this.payload});

  @override
  riverpod.ConsumerState<riverpod.ConsumerStatefulWidget> createState() => _MyAppState();
}

class _MyAppState extends riverpod.ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    PushNotificationService().initialise(ref);
    ControlChangeNotifierModel controlModel =
        Provider.of<ControlChangeNotifierModel>(context, listen: false);
    Future.delayed(Duration.zero, () {
      controlModel.setNotificationDetails(widget.payload ?? {});
    });
    // controlModel.setNotificationDetails(widget.payload ?? {});
  }

  @override
  Widget build(BuildContext context) {
    // UserOnBoardChangeNotifierModel userOnBoardModel = Provider.of<UserOnBoardChangeNotifierModel>(context, listen: false);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Portal(
      child: GestureDetector(
        onTap: () {
          //close the keypad whenever the user taps on an inactive widget
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus &&
              currentFocus.focusedChild != null) {
            FocusManager.instance.primaryFocus?.unfocus();
          }
        },
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: MyApp.splashScreen,
          routes: {
            MyApp.dynamicScreen: (context) => SplashScreen(),
            MyApp.loginScreen: (context) => LoginScreen(),
            MyApp.splashScreen: (context) => SplashScreen(),
            MyApp.forgotPasswordScreen: (context) => ForgotPasswordScreen1(),
            MyApp.signUpScreen: (context) => SignUp(),
            MyApp.onboardingScreen: (context) => OnboardingPage(),
            MyApp.navigatorScreen: (context) => NavigatorPage(),
          },
          theme: ThemeData(
            primarySwatch: Colors.teal,
            appBarTheme: AppBarTheme(
              elevation: 0,
              color: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
            ),
            textTheme: Theme.of(context).textTheme.apply(
                  fontFamily: 'Avenir',
                ),
          ),
        ),
      ),
    );
  }
}
