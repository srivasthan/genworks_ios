import 'package:fieldpro_genworks_healthcare/screens/dashboard.dart';
import 'package:fieldpro_genworks_healthcare/screens/login.dart';
import 'package:fieldpro_genworks_healthcare/utility/shared_preferences.dart';
import 'package:fieldpro_genworks_healthcare/utility/store_strings.dart';
import 'package:fieldpro_genworks_healthcare/utility/tracking.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'package:neat_periodic_task/neat_periodic_task.dart';
import 'package:firebase_performance/firebase_performance.dart';

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

AndroidNotificationChannel? channel;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Create a periodic task that prints 'Hello World' every 30s
  final scheduler = NeatPeriodicTaskScheduler(
      interval: const Duration(minutes: 30),
      name: MyConstants.trackingTask,
      timeout: const Duration(seconds: 5),
      task: () async => technicianTracking(''),
      minCycle: const Duration(minutes: 2));

  scheduler.start();
  //await ProcessSignal.sigterm.watch().first;

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      enableLights: true,
      enableVibration: true,
      playSound: true,
      showBadge: true
    );

    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel!);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  var initializationSettingsAndroid = const AndroidInitializationSettings('logo');
  var initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {});
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin!.initialize(initializationSettings,
      onSelectNotification: (String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  });

  runApp(MaterialApp(home: Splash()));
}

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final FirebaseMessaging? firebaseMessaging = FirebaseMessaging.instance;
  FirebasePerformance performance = FirebasePerformance.instance;

  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        const String groupKey =
            'com.app.kaspon.fieldproservice_v2.genworks_fieldpro_technician';
        const String groupChannelId = 'high_importance_channel';
        const String groupChannelName = 'High Importance Notifications';
        const String groupChannelDescription =
            'This channel is used for important notifications';

        const AndroidNotificationDetails firstNotificationAndroidSpecifics =
            AndroidNotificationDetails(groupChannelId, groupChannelName,
                channelDescription: groupChannelDescription,
                importance: Importance.max,
                priority: Priority.high,
                styleInformation: BigTextStyleInformation(''),
                groupKey: groupKey);
        const NotificationDetails firstNotificationPlatformSpecifics =
            NotificationDetails(android: firstNotificationAndroidSpecifics);
        await flutterLocalNotificationsPlugin!.show(1, 'Alex Faarborg',
            'You will not believe...', firstNotificationPlatformSpecifics);
        const AndroidNotificationDetails secondNotificationAndroidSpecifics =
            AndroidNotificationDetails(groupChannelId, groupChannelName,
                channelDescription: groupChannelDescription,
                importance: Importance.max,
                priority: Priority.high,
                styleInformation: BigTextStyleInformation(''),
                groupKey: groupKey);
        const NotificationDetails secondNotificationPlatformSpecifics =
            NotificationDetails(android: secondNotificationAndroidSpecifics);
        await flutterLocalNotificationsPlugin!.show(0, notification.title,
            notification.body, secondNotificationPlatformSpecifics);

        const List<String> lines = <String>[
          'Alex Faarborg  Check this out',
          'Jeff Chang    Launch Party'
        ];
        // const InboxStyleInformation inboxStyleInformation =
        //     InboxStyleInformation(lines,
        //         contentTitle: '2 messages', summaryText: 'janedoe@example.com');
        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(groupChannelId, groupChannelName,
                channelDescription: groupChannelDescription,
                styleInformation: BigTextStyleInformation(''),
                groupKey: groupKey,
                setAsGroupSummary: true);
        const NotificationDetails platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);
        await flutterLocalNotificationsPlugin!
            .show(1, 'Attention', 'Two messages', platformChannelSpecifics);
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Notification Clicked!');
      }
      //Navigation to page
    });
    PreferenceUtils.init();
    loadPage();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/images/background.png',
              ),
              fit: BoxFit.cover)),
      child: Center(
        child: Image.asset('assets/images/splashscreen_logo.png',
            height: 100, width: 100),
      ),
    );
  }

  void loadPage() {
    Timer(const Duration(seconds: 3), () {
      if (PreferenceUtils.getString(MyConstants.name).isEmpty) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => DashBoard()));
      }
    });
  }
}
