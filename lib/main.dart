// main.dart — ✅ просто заміни цим файлом
// ✅ Зміни: звук тепер НЕ через Notification Channel, а через STREAM_ALARM (native service)
// - Локальна нотифікація ТИХА (без звуку)
// - Звук старт/енд запускається через MethodChannel: playAlarmSound(sound: alarm/alarm_end)
// - Wake screen: у foreground завжди, у background НЕ викликаємо (Android часто блокує)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:stalc_alarm/view/bloc/alarm_bloc/alarm_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc/alarm_bloc_event.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc.dart';
import 'package:stalc_alarm/view/screens/router/cupertino_bottom_navigation_bar.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;

// ===== Local notifications plugin =====
final FlutterLocalNotificationsPlugin fln = FlutterLocalNotificationsPlugin();

// ===== MethodChannel (native) =====
const MethodChannel _alarmNative = MethodChannel('stalk_alarm/alarm');

// ✅ ТИХИЙ канал для інфо-нотифікацій (без звуку)
const AndroidNotificationChannel silentInfoChannel = AndroidNotificationChannel(
  'silent_info_channel_v1',
  'Stalk Alarm (Silent)',
  description: 'Silent notifications (sound is played via ALARM stream)',
  importance: Importance.high,
  playSound: false,
);

// ===== Background handler =====
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _handleIncomingMessage(message, isForeground: false);
}

/// Формуємо тексти з data payload: type/level/name/title/body
Map<String, String> _composeTexts(RemoteMessage message) {
  final type = (message.data['type'] ?? '')
      .toString(); // ALARM_START / ALARM_END
  final level = (message.data['level'] ?? message.data['scope'] ?? '')
      .toString(); // raion/oblast
  final name = (message.data['name'] ?? '').toString();

  final title = (message.data['title'] ?? 'Stalk Alarm').toString();
  final serverBody = (message.data['body'] ?? '').toString();

  final isStart = type == 'ALARM_START';

  final region = name.isNotEmpty
      ? name
      : (message.data['oblast_title'] ?? message.data['raion_title'] ?? '')
            .toString();

  final fallbackBody = isStart
      ? 'Увага! Насувається викид в "$region"! Пройдіть в найближче укриття!'
      : 'Відбій в "$region". Слідкуйте за подальшими оновленнями!';

  return {
    'type': type,
    'level': level,
    'name': region,
    'title': title,
    'body': serverBody.isNotEmpty ? serverBody : fallbackBody,
  };
}

/// ✅ Тиха нотифікація (без звуку)
Future<void> _showSilentNotification(RemoteMessage message) async {
  if (message.notification != null) return; // тільки data-only

  final t = _composeTexts(message);

  await fln.show(
    DateTime.now().millisecondsSinceEpoch ~/ 1000,
    t['title'],
    t['body'],
    NotificationDetails(
      android: AndroidNotificationDetails(
        silentInfoChannel.id,
        silentInfoChannel.name,
        channelDescription: silentInfoChannel.description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: false, // ✅ ключове
        enableVibration: true,
        visibility: NotificationVisibility.public,
      ),
    ),
  );
}

/// ✅ Запуск звуку через native service (STREAM_ALARM)
Future<void> _playAlarmSound(RemoteMessage message) async {
  if (message.notification != null) return;

  final type = (message.data['type'] ?? '').toString();
  final isStart = type == 'ALARM_START';
  final sound = isStart
      ? 'alarm'
      : 'alarm_end'; // raw/alarm.mp3, raw/alarm_end.mp3

  try {
    await _alarmNative.invokeMethod('playAlarmSound', {'sound': sound});
  } catch (e) {
    debugPrint('playAlarmSound failed: $e');
  }
}

/// ✅ Wake screen (тільки коли app у foreground)
Future<void> _wakeScreenIfForeground(bool isForeground) async {
  if (!isForeground) return; // у background Android часто блокує

  try {
    await _alarmNative.invokeMethod('wakeScreen');
  } catch (e) {
    debugPrint('wakeScreen failed: $e');
  }
}

/// Загальна обробка повідомлення
Future<void> _handleIncomingMessage(
  RemoteMessage message, {
  required bool isForeground,
}) async {
  if (message.notification != null) return;

  debugPrint('FCM data: ${message.data}');

  // 🔊 звук (ALARM stream)
  await _playAlarmSound(message);

  // 💡 увімкнути екран (лише foreground)
  await _wakeScreenIfForeground(isForeground);

  // 🔕 тиха нотифікація (без звуку)
  await _showSilentNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ DI
  await di.init();

  // ✅ Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // ✅ Local notifications init + create silent channel
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await fln.initialize(const InitializationSettings(android: androidInit));

  final androidFln = fln
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();
  await androidFln?.createNotificationChannel(silentInfoChannel);

  // ✅ Permissions (iOS + Android 13+)
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  // ✅ (не обовʼязково) формат дат
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

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              AlarmBloc(getCurrentAlarmUseCase: di.sl())
                ..add(StartAlarmPollingEvent(intervalMs: 15000)),
        ),
        BlocProvider(
          create: (_) => AlarmHistoryBloc(getAlarmHistoryUseCase: di.sl()),
        ),
      ],
      // ✅ лайфсайкл-обсервер нижче провайдера, щоб context.read<AlarmBloc>() працював
      child: const _AppLifecycleGate(child: MyApp()),
    );
  }
}

class _AppLifecycleGate extends StatefulWidget {
  final Widget child;
  const _AppLifecycleGate({required this.child});

  @override
  State<_AppLifecycleGate> createState() => _AppLifecycleGateState();
}

class _AppLifecycleGateState extends State<_AppLifecycleGate>
    with WidgetsBindingObserver {
  Timer? _resumeDebounce;
  StreamSubscription<RemoteMessage>? _onMsgSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Foreground messages
    _onMsgSub = FirebaseMessaging.onMessage.listen((
      RemoteMessage message,
    ) async {
      await _handleIncomingMessage(message, isForeground: true);
    });

    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp.listen((
      RemoteMessage message,
    ) {
      // TODO: навігація якщо треба
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
  Widget build(BuildContext context) => widget.child;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Stalk Alarm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      home: const CupertinoBottomBar(),
    );
  }
}
