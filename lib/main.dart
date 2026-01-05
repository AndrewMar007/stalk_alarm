import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:stalc_alarm/view/bloc/alarm_bloc.dart';
import 'package:stalc_alarm/view/screens/main_screen.dart';
import 'package:stalc_alarm/view/screens/router/cupertino_bottom_navigation_bar.dart';
import 'firebase_options.dart';

import 'injection_container.dart' as di;

// ===== Local notifications plugin =====
final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

// ===== Android channel with custom sound (android/app/src/main/res/raw/alarm.mp3) =====
const AndroidNotificationChannel alarmChannel = AndroidNotificationChannel(
  'air_alarm_channel',
  'Air Alarm',
  description: 'Air alarm notifications',
  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound('alarm'), // alarm.mp3 -> 'alarm'
);

// ===== Background handler (works for data-only pushes) =====
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM TOKEN = $token");

  // For data-only messages: show local notification here.
  // If you send "notification" payload, Android may show it automatically,
  // but this keeps behavior consistent.
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  final title =
      message.data['title'] ?? message.notification?.title ?? 'Тривога';
  final body =
      message.data['body'] ?? message.notification?.body ?? 'Повітряна тривога';

  await fln.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        alarmChannel.id,
        alarmChannel.name,
        channelDescription: alarmChannel.description,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: const RawResourceAndroidNotificationSound('alarm'),
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true
      ),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // ✅ init DI first (GetIt registrations)
  await di.init();

  // ✅ Firebase init
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final tok = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM TOKEN = $tok");
  // ✅ Background messages
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Local notifications init + create Android channel
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await fln.initialize(const InitializationSettings(android: androidInit));

  await fln
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >()
      ?.createNotificationChannel(alarmChannel);

  // ✅ Ask permission (iOS + Android 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  final token = await FirebaseMessaging.instance.getToken();
  debugPrint("FCM TOKEN: $token");
  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  @override
  void initState() {
    super.initState();

    // Foreground: when message arrives while app is open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
    });

    // When user taps the notification and opens the app
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: you can navigate to a specific screen if needed
      // Example: Navigator.of(context).push(...)
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AlarmBloc(getCurrentAlarmUseCase: di.sl())),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
    
      title: 'Stalc Alarm',
      theme: ThemeData(
        
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const CupertinoBottomBar(),
    );
  }
}
