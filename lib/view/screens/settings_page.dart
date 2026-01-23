import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stalc_alarm/view/widgets/custom_tick_mark_shape.dart';
import 'package:stalc_alarm/view/widgets/gradient_outline_border_button.dart';

const MethodChannel _alarmNative = MethodChannel('stalk_alarm/alarm');

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

const bottomGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(72, 232, 136, 27),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(66, 232, 136, 27),
  ],
  stops: [0.02, 0.4, 0.8, 1.0],
);

const bottomButtonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(169, 248, 138, 41),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(169, 248, 138, 41),
  ],
  stops: [0.02, 0.4, 0.9, 1.0],
);

const topButtonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color.fromARGB(169, 248, 138, 41),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(4, 249, 189, 25),
    Color.fromARGB(169, 248, 138, 41),
  ],
  stops: [0.02, 0.6, 0.8, 1.0],
);

class _SettingsPageState extends State<SettingsPage>
    with WidgetsBindingObserver {
  int _cur = 0; // поточний крок
  int _max = 1; // максимум кроків STREAM_ALARM
  bool _dndGranted = false;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  Future<void> _checkNotifications() async {
    final status = await Permission.notification.status;
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = status.isGranted;
    });
  }

  Future<void> _openNotificationSettings() async {
    await AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNotifications();
    }
  }

  Future<void> _load() async {
    try {
      final steps = await _alarmNative.invokeMethod<Map>('getAlarmVolumeSteps');
      final dnd =
          await _alarmNative.invokeMethod<bool>('hasDndAccess') ?? false;

      final cur = (steps?['cur'] as int?) ?? 0;
      final max = (steps?['max'] as int?) ?? 1;

      if (!mounted) return;
      setState(() {
        _max = max > 0 ? max : 1;
        _cur = cur.clamp(0, _max);
        _dndGranted = dnd;
      });

      await _checkNotifications();
    } catch (_) {
      if (!mounted) return;
    }
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }

  Future<void> _setStep(double v) async {
    final step = v.round().clamp(0, _max);
    setState(() => _cur = step);

    try {
      await _alarmNative.invokeMethod('setAlarmVolumeSteps', {'step': step});
    } catch (_) {}

    if (step == 0) {
      try {
        await _alarmNative.invokeMethod('stopAlarmSound');
      } catch (_) {}
    }
  }

  int _percent() {
    if (_max <= 0) return 0;
    return ((_cur / _max) * 100).round();
  }

  Future<void> _playTest(String sound) async {
    if (_cur == 0) {
      _toast('Гучність = 0% → звук вимкнено');
      return;
    }
    try {
      await _alarmNative.invokeMethod('playAlarmSound', {'sound': sound});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color.fromRGBO(23, 13, 2, 1);
    const accent = Color.fromARGB(255, 248, 137, 41);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        centerTitle: true,
        title: const Text(
          'Налаштування',
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19, // можна теж адаптивити, але AppBar часто ок з фіксом
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          // Скейлер від ширини: стабільний для phone/tablet/web
          double ui(double base, {double min = 0, double max = 9999}) {
            final v = base * (w / 390.0);
            return v.clamp(min, max).toDouble();
          }

          // Часто корисно: "залежить від ширини, але не виходить за межі"
          double fromW(double factor, {double min = 0, double max = 9999}) {
            return (w * factor).clamp(min, max).toDouble();
          }

          // Висотні речі — тільки там, де воно реально висотне (і h не infinity)
          double fromH(double factor, {double min = 0, double max = 9999}) {
            return (h * factor).clamp(min, max).toDouble();
          }

          final headerH = fromH(
            0.22,
            min: ui(150, min: 130, max: 210),
            max: ui(240, min: 190, max: 280),
          );

          final padX = fromW(0.04, min: 12, max: 28);
          final gapXS = ui(8, min: 6, max: 12);
          final gapS = ui(10, min: 8, max: 16);
          final gapM = ui(16, min: 12, max: 22);

          final iconS = ui(22, min: 20, max: 30);
          final iconM = ui(24, min: 22, max: 34);

          final titleSize = ui(15, min: 14, max: 18);
          final smallSize = ui(12, min: 11, max: 14);

          final btnFont = ui(12, min: 11, max: 14);
          final btnPadX = fromW(0.03, min: 10, max: 18);
          final btnPadY = ui(10, min: 8, max: 14);

          final sliderTickH = ui(10, min: 8, max: 12);
          final sliderTickW = ui(2, min: 2, max: 3);

          return Container(
            color: const Color.fromARGB(255, 20, 11, 2),
            width: w,
            height: h,
            child: Stack(
              children: [
                // Фон
                Positioned(
                  left: -50,
                  right: -50,
                  top: -50,
                  bottom: -50,
                  child: const Image(
                    image: AssetImage('assets/back.png'),
                    color: Color.fromARGB(32, 41, 41, 41),
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  left: -350,
                  right: -350,
                  bottom: -250,
                  top: -100,
                  child: const Image(
                    image: AssetImage('assets/radiation.png'),
                    color: Color.fromARGB(15, 54, 27, 6),
                    fit: BoxFit.cover,
                  ),
                ),

                // Верхня лінія
                SizedBox(
                  height: ui(2, min: 2, max: 2),
                  width: double.infinity,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(gradient: bottomGradient),
                  ),
                ),

                // Контент (скрол, щоб не було overflow на малих екранах)
                SafeArea(
                  bottom: false,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: ui(20, min: 16, max: 28)),
                    child: Column(
                      children: [
                        // Header (гучність)
                        Container(
                          color: const Color.fromARGB(4, 249, 189, 25),
                          height: headerH,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(height: fromH(0.02, min: 10, max: 18)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: padX),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.volume_up,
                                      color: accent,
                                      size: iconM,
                                    ),
                                    SizedBox(
                                      width: fromW(0.02, min: 8, max: 14),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Гучність сигналу тривоги',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          color: accent,
                                          fontSize: titleSize,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: gapXS),
                                    Text(
                                      _cur == 0
                                          ? 'Рівень: 0% (вимкнено)'
                                          : 'Рівень: ${_percent()}%',
                                      style: TextStyle(
                                        fontSize: smallSize,
                                        color: accent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: fromH(0.01, min: 8, max: 14)),

                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: const Color.fromARGB(
                                    255,
                                    183,
                                    109,
                                    44,
                                  ),
                                  inactiveTrackColor: const Color.fromARGB(
                                    26,
                                    249,
                                    189,
                                    25,
                                  ),
                                  inactiveTickMarkColor: accent,
                                  activeTickMarkColor: const Color.fromARGB(
                                    255,
                                    0,
                                    0,
                                    0,
                                  ),
                                  tickMarkShape: VerticalLineTickMarkShape(
                                    height: sliderTickH,
                                    width: sliderTickW,
                                  ),
                                ),
                                child: Slider(
                                  value: _cur.toDouble(),
                                  thumbColor: accent,
                                  min: 0,
                                  max: _max.toDouble(),
                                  divisions: _max,
                                  label: _cur == 0 ? '0%' : '${_percent()}%',
                                  onChanged: _setStep,
                                ),
                              ),

                              SizedBox(height: fromH(0.01, min: 8, max: 14)),

                              // Кнопки тесту
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: padX),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    GradientBorderButton(
                                      topGradient: topButtonGradient,
                                      bottomGradient: bottomButtonGradient,
                                      radius: ui(30, min: 22, max: 34),
                                      strokeWidth: 1,
                                      onTap: () => _playTest('alarm'),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: btnPadX,
                                          vertical: btnPadY,
                                        ),
                                        child: Text(
                                          'Початок тривоги',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: btnFont,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: gapXS),
                                    GradientBorderButton(
                                      topGradient: topButtonGradient,
                                      bottomGradient: bottomButtonGradient,
                                      radius: ui(30, min: 22, max: 34),
                                      strokeWidth: 1,
                                      onTap: () => _playTest('alarm_end'),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: btnPadX,
                                          vertical: btnPadY,
                                        ),
                                        child: Text(
                                          'Кінець тривоги',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: btnFont,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: gapXS),
                                    GradientBorderButton(
                                      topGradient: topButtonGradient,
                                      bottomGradient: bottomButtonGradient,
                                      radius: ui(30, min: 22, max: 34),
                                      strokeWidth: 1,
                                      onTap: () async {
                                        try {
                                          await _alarmNative.invokeMethod(
                                            'stopAlarmSound',
                                          );
                                        } catch (_) {}
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: btnPadX,
                                          vertical: btnPadY,
                                        ),
                                        child: Text(
                                          'Зупинити',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: btnFont,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Divider
                        Container(
                          height: ui(2, min: 2, max: 2),
                          decoration: const BoxDecoration(
                            gradient: bottomGradient,
                          ),
                        ),

                        SizedBox(height: gapM),

                        // Notifications card (адаптивні паддінги/шрифти/ікони)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: ui(16, min: 12, max: 24),
                          ),
                          child: Stack(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: ui(16, min: 12, max: 22),
                                  vertical: ui(10, min: 8, max: 14),
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                    ui(14, min: 12, max: 18),
                                  ),
                                  border: const Border(
                                    left: BorderSide(
                                      color: Color.fromARGB(90, 248, 137, 41),
                                      width: 1,
                                    ),
                                    right: BorderSide(
                                      color: Color.fromARGB(90, 248, 137, 41),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notifications,
                                      color: accent,
                                      size: iconS,
                                    ),
                                    SizedBox(width: ui(12, min: 10, max: 16)),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Сповіщення',
                                            style: TextStyle(
                                              color: accent,
                                              fontWeight: FontWeight.w700,
                                              fontSize: titleSize,
                                            ),
                                          ),
                                          SizedBox(
                                            height: ui(2, min: 2, max: 4),
                                          ),
                                          Text(
                                            _notificationsEnabled
                                                ? 'Увімкнені'
                                                : 'Вимкнені',
                                            style: TextStyle(
                                              fontSize: smallSize,
                                              color: const Color.fromARGB(
                                                180,
                                                248,
                                                137,
                                                41,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Switch(
                                      activeTrackColor: const Color.fromARGB(
                                        255,
                                        83,
                                        47,
                                        16,
                                      ),
                                      inactiveTrackColor: const Color.fromARGB(
                                        0,
                                        74,
                                        42,
                                        14,
                                      ),
                                      inactiveThumbColor: accent,
                                      value: _notificationsEnabled,
                                      trackOutlineColor:
                                          WidgetStateProperty.resolveWith((
                                            states,
                                          ) {
                                            if (states.contains(
                                              WidgetState.selected,
                                            )) {
                                              return const Color.fromARGB(
                                                140,
                                                248,
                                                137,
                                                41,
                                              );
                                            }
                                            return const Color.fromARGB(
                                              90,
                                              248,
                                              137,
                                              41,
                                            );
                                          }),
                                      activeThumbColor: accent,
                                      onChanged: (_) async {
                                        await _openNotificationSettings();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                              // Верхній градієнт
                              Positioned(
                                top: 0,
                                left: ui(14, min: 12, max: 18),
                                right: ui(14, min: 12, max: 18),
                                child: Container(
                                  height: ui(1.5, min: 1.2, max: 1.8),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color.fromARGB(4, 249, 189, 25),
                                        Color.fromARGB(169, 248, 138, 41),
                                        Color.fromARGB(4, 249, 189, 25),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Нижній градієнт
                              Positioned(
                                bottom: 0,
                                left: ui(14, min: 12, max: 18),
                                right: ui(14, min: 12, max: 18),
                                child: Container(
                                  height: ui(1.5, min: 1.2, max: 1.8),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color.fromARGB(4, 249, 189, 25),
                                        Color.fromARGB(169, 248, 138, 41),
                                        Color.fromARGB(4, 249, 189, 25),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: gapS),

                        // (Поки не використовуєш) _dndGranted — лишив як є, щоб не ламати логіку
                        // Можеш потім додати таким же стилем, якщо треба:
                        // SizedBox(height: gapS),
                        // ...
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
