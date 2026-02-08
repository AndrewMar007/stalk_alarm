import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:stalc_alarm/view/bloc/alarm_bloc/alarm_bloc.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc/alarm_bloc_event.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'l10n/app_localizations.dart';
import 'router/route_generator.dart';

import 'core/values/lists.dart';
import 'core/ua_hromadas_dart_files/agregator/agregator.dart';
import 'models/admin_units.dart';

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

/// =========================
/// ✅ Locale controller + persistence
/// =========================
class LocaleController {
  LocaleController._();
  static final LocaleController instance = LocaleController._();

  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  static const _prefsKey = 'app_locale';

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_prefsKey);

    // null => system locale
    if (raw == null || raw.isEmpty) {
      locale.value = null;
      return;
    }

    // "uk" or "en"
    locale.value = Locale(raw);
  }

  Future<void> set(Locale? newLocale) async {
    locale.value = newLocale;

    final sp = await SharedPreferences.getInstance();
    if (newLocale == null) {
      await sp.remove(_prefsKey);
    } else {
      await sp.setString(_prefsKey, newLocale.languageCode);
    }

    final code = newLocale?.languageCode ?? 'uk';
    await initializeDateFormatting(code == 'en' ? 'en_US' : 'uk_UA');
  }
}

/// =========================
/// ✅ Fast indexes for admin units (O(1) lookup)
/// =========================
class AdminIndex {
  static final Map<String, Oblast> oblastByUid = {
    for (final o in ListsOfAdministrativeUnits.oblasts)
      if (o.uid != null) o.uid!: o,
  };

  static final Map<String, Raion> raionByUid = {
    for (final r in ListsOfAdministrativeUnits.raions)
      if (r.uid != null) r.uid!: r,
  };

  static final Map<String, Hromada> hromadaByUid = {
    for (final h in RaionsAgregator.allHromadas)
      if (h.uid != null) h.uid!: h,
  };
}

String _normalizeIncomingUid(String uid, String level) {
  final u = uid.trim();

  // PushPoller шле uid як topic:
  // hromada_UA.... -> UA....
  if (level == 'hromada' && u.startsWith('hromada_')) {
    return u.substring('hromada_'.length);
  }
  return u; // oblast_4 / raion_74 / UA... (якщо сервер вже так шле)
}

Future<bool> _isEnglishFromPrefs() async {
  final sp = await SharedPreferences.getInstance();
  final code = sp.getString('app_locale'); // твій ключ
  return code == 'en';
}

String _resolveRegionTitle({
  required String level, // 'oblast' | 'raion' | 'hromada'
  required String uid, // uid з пуша (topic)
  required bool isEn,
}) {
  final normalized = _normalizeIncomingUid(uid, level);

  switch (level) {
    case 'oblast':
      final o = AdminIndex.oblastByUid[normalized];
      return (isEn ? o?.titleEng : o?.title) ?? normalized;

    case 'raion':
      final r = AdminIndex.raionByUid[normalized];
      return (isEn ? r?.titleEng : r?.title) ?? normalized;

    case 'hromada':
      final h = AdminIndex.hromadaByUid[normalized];
      return (isEn ? h?.titleEng : h?.title) ?? normalized;

    default:
      return normalized;
  }
}

// ===== Background handler =====
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _handleIncomingMessage(message, isForeground: false);
}

/// Формуємо тексти з data payload: type/level/uid (+ fallback), локалізація по SharedPrefs
Future<Map<String, String>> _composeTexts(RemoteMessage message) async {
  final type = (message.data['type'] ?? '').toString(); // ALARM_START / ALARM_END
  final level =
      (message.data['level'] ?? message.data['scope'] ?? '').toString(); // hromada/raion/oblast
  final uid = (message.data['uid'] ?? '').toString();

  final isEn = await _isEnglishFromPrefs();
  final isStart = type == 'ALARM_START';

  // якщо uid/level є — резолвимо назву по локалі
  final region = (uid.isNotEmpty && level.isNotEmpty)
      ? _resolveRegionTitle(level: level, uid: uid, isEn: isEn)
      : (message.data['name'] ?? '').toString();

  // серверні поля лишаємо як fallback (див. нижче “сервер” як зробити правильно)
  final serverTitle = (message.data['title'] ?? '').toString();
  final serverBody = (message.data['body'] ?? '').toString();

  final fallbackTitle = 'Stalk Alarm';
  final fallbackBody = isStart
      ? (isEn
          ? 'Attention! An emission is coming in "$region"! Get to the nearest shelter!'
          : 'Увага! Насувається викид в "$region"! Пройдіть в найближче укриття!')
      : (isEn
          ? 'All clear in "$region". Stay tuned for updates!'
          : 'Відбій в "$region". Слідкуйте за подальшими оновленнями!');

  return {
    'type': type,
    'level': level,
    'uid': uid,
    'name': region,
    'title': serverTitle.isNotEmpty ? serverTitle : fallbackTitle,
    'body': serverBody.isNotEmpty ? serverBody : fallbackBody,
  };
}

/// ✅ Тиха нотифікація (без звуку)
Future<void> _showSilentNotification(RemoteMessage message) async {
  if (message.notification != null) return; // тільки data-only

  final t = await _composeTexts(message);

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
        playSound: false,
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
  final sound = isStart ? 'alarm' : 'alarm_end';

  try {
    await _alarmNative.invokeMethod('playAlarmSound', {'sound': sound});
  } catch (e) {
    debugPrint('playAlarmSound failed: $e');
  }
}

/// ✅ Wake screen (тільки коли app у foreground)
Future<void> _wakeScreenIfForeground(bool isForeground) async {
  if (!isForeground) return;

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

  await _playAlarmSound(message);
  await _wakeScreenIfForeground(isForeground);
  await _showSilentNotification(message);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.init();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await fln.initialize(const InitializationSettings(android: androidInit));

  final androidFln =
      fln.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidFln?.createNotificationChannel(silentInfoChannel);

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // ✅ Ініціалізуємо форматування дат для стартової локалі
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

  // ✅ Підтягуємо збережену мову ДО runApp
  await LocaleController.instance.load();

  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AlarmBloc(getCurrentAlarmUseCase: di.sl())
            ..add(StartAlarmPollingEvent(intervalMs: 15000)),
        ),
        BlocProvider(
          create: (_) => AlarmHistoryBloc(getAlarmHistoryUseCase: di.sl()),
        ),
      ],
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

    _onMsgSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _handleIncomingMessage(message, isForeground: true);

      final t = await _composeTexts(message);
      final type = (t['type'] ?? '').toString();
      final level = (t['level'] ?? '').toString();
      final name = (t['name'] ?? '').toString();
      final uid = (t['uid'] ?? '').toString();

      if (type.isNotEmpty && level.isNotEmpty && name.isNotEmpty) {
        if (!mounted) return;
        context.read<AlarmBloc>().add(
              PushAlarmEvent(
                type: type,
                level: level,
                name: name,
                uid: uid,
              ),
            );
      }
    });

    _onOpenedSub =
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
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
    return ValueListenableBuilder<Locale?>(
      valueListenable: LocaleController.instance.locale,
      builder: (context, locale, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
            useMaterial3: true,
          ),

          // ✅ реальне перемикання мови
          locale: locale,

          onGenerateTitle: (context) =>
              AppLocalizations.of(context)!.appTitle,

          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,

          initialRoute: '/',
          onGenerateRoute: RouteGenerator.generateRoute,
        );
      },
    );
  }
}
