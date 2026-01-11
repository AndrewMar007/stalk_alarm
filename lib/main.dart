import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

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

// ===== MethodChannel to open native AlarmActivity (turn screen on / show when locked) =====
const MethodChannel _alarmNative = MethodChannel('stalk_alarm/alarm');

// ===== Background handler =====
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _showLocalNotification(message);
}

/// Формуємо текст “область або район” з data payload (level/uid/name/type)
Map<String, String> _composeAlarmTexts(RemoteMessage message) {
  final type = (message.data['type'] ?? '').toString(); // ALARM_START / ALARM_END
  final level = (message.data['level'] ?? message.data['scope'] ?? '').toString(); // raion / oblast
  final name = (message.data['name'] ?? '').toString();

  final isStart = type == 'ALARM_START';

  final region = name.isNotEmpty
      ? name
      : (message.data['oblast_title'] ?? message.data['raion_title'] ?? '').toString();

  final title = (message.data['title'] ?? 'Stalk Alarm').toString();

  final body = isStart
      ? 'Увага! Повітряна тривога в "$region"! Залишайтесь в укритті!'
      : 'Відбій в "$region". Будьте обережні!';

  // якщо сервер вже прислав body — беремо його як пріоритет
  final serverBody = (message.data['body'] ?? '').toString();
  final finalBody = serverBody.isNotEmpty ? serverBody : body;

  return {
    'title': title,
    'body': finalBody,
    'type': type,
    'level': level,
    'name': region,
  };
}

Future<void> _showLocalNotification(RemoteMessage message) async {
  // ✅ якщо це notification-пуш (а не data-only) — НЕ показуємо локалку, інакше буде дубль
  if (message.notification != null) return;

  final texts = _composeAlarmTexts(message);

  await fln.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    texts['title'],
    texts['body'],
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
        audioAttributesUsage: AudioAttributesUsage.alarm,
        visibility: NotificationVisibility.public,
      ),
    ),
  );
}

/// ✅ Відкрити native AlarmActivity (тільки коли app у foreground/visible)
Future<void> _openNativeAlarmScreen(RemoteMessage message) async {
  if (message.notification != null) return;

  final texts = _composeAlarmTexts(message);

  try {
    await _alarmNative.invokeMethod('openAlarmScreen', {
      'title': texts['title'],
      'body': texts['body'],
      'type': texts['type'],
      'level': texts['level'],
      'name': texts['name'],
    });
  } catch (_) {
    // якщо канал/Activity не налаштовані — просто ігноруємо (залишиться FLN)
  }
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

  await initializeDateFormatting('uk_UA');

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF170D02),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // ✅ Permissions
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  // ✅ ВАЖЛИВО: BlocProvider має бути ВИЩЕ за AppRootLifecycle
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AlarmBloc(getCurrentAlarmUseCase: di.sl())
            ..add(StartAlarmPollingEvent(intervalMs: 15000)),
        ),
      ],
      child: const AppRootLifecycle(),
    ),
  );
}

/// ✅ Окремий віджет, який “бачить” BlocProvider зверху
class AppRootLifecycle extends StatefulWidget {
  const AppRootLifecycle({super.key});

  @override
  State<AppRootLifecycle> createState() => _AppRootLifecycleState();
}

class _AppRootLifecycleState extends State<AppRootLifecycle> with WidgetsBindingObserver {
  Timer? _resumeDebounce;
  StreamSubscription<RemoteMessage>? _onMsgSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Foreground messages
    _onMsgSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // 1) Спроба відкрити AlarmActivity (коли app активний)
      await _openNativeAlarmScreen(message);
      // 2) Локальна нотифікація зі звуком (data-only)
      await _showLocalNotification(message);
    });

    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // TODO: навігація при тапі на нотифікацію (як захочеш)
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
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
        bloc.add(SoftRefreshAlarmEvent());
        bloc.add(StartAlarmPollingEvent(intervalMs: 15000));
      });
    }
  }

  @override
  void dispose() {
    _resumeDebounce?.cancel();
    _onMsgSub?.cancel();
    _onOpenedSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const MyApp();
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
