import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:stalc_alarm/view/bloc/alarm_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc_event.dart';
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
  sound: RawResourceAndroidNotificationSound('alarm'),
);

// ===== Background handler =====
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _showLocalNotification(message);
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  // ✅ якщо це notification-пуш (а не data-only) — НЕ показуємо локалку, інакше буде дубль
  if (message.notification != null) return;

  final title = (message.data['title'] ?? 'Stalk Alarm').toString();
  final body  = (message.data['body']  ?? 'Повітряна тривога').toString();

  await fln.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    title,
    body,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'air_alarm_channel',
        'Air Alarm',
        channelDescription: 'Air alarm notifications',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('alarm'),
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
      ),
    ),
  );
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ DI
  await di.init();

  // ✅ Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Local notifications init + channel
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await fln.initialize(const InitializationSettings(android: androidInit));

  await fln
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(alarmChannel);

  // ✅ Permissions
  await FirebaseMessaging.instance.requestPermission(alert: true, badge: true, sound: true);

  runApp(const AppRoot());
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> with WidgetsBindingObserver {
  Timer? _resumeDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: navigate if needed
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Тут ми контролюємо polling, щоб:
    // - не робити запити в background
    // - після resume дати Render 2 сек “прокинутись”
    final bloc = context.read<AlarmBloc>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      bloc.add(StopAlarmPollingEvent());
      return;
    }

    if (state == AppLifecycleState.resumed) {
      bloc.add(StopAlarmPollingEvent());

      _resumeDebounce?.cancel();
      _resumeDebounce = Timer(const Duration(seconds: 2), () {
        bloc.add(SoftRefreshAlarmEvent()); // один м’який refresh без зносу state
        bloc.add(StartAlarmPollingEvent(intervalMs: 15000)); // і назад polling
      });
    }
  }

  @override
  void dispose() {
    _resumeDebounce?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AlarmBloc(getCurrentAlarmUseCase: di.sl())
            ..add(StartAlarmPollingEvent(intervalMs: 15000)),
        ),
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
      title: 'Stalk Alarm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const CupertinoBottomBar(),
    );
  }
}
