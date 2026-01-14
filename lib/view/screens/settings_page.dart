import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stalc_alarm/view/widgets/custom_tick_mark_shape.dart';
import 'package:stalc_alarm/view/widgets/gradient_container.dart';
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

class _SettingsPageState extends State<SettingsPage> {
  int _cur = 0; // поточний крок
  int _max = 1; // максимум кроків STREAM_ALARM
  bool _dndGranted = false;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
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
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
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

    // ✅ КЛЮЧОВЕ: якщо 0 — одразу зупиняємо звук, щоб була повна тиша
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
    // ✅ якщо гучність 0 — не запускаємо тест (бо все одно буде тиша/або “ледь чутно” на девайсах)
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
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(23, 13, 2, 1),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       await Navigator.of(
        //         context,
        //         rootNavigator: false,
        //       ).push(CupertinoPageRoute(builder: (_) => const OblastsPage()));
        //     },
        //     icon: const Icon(
        //       Icons.add,
        //       color: Color.fromARGB(255, 247, 135, 50),
        //     ),
        //   ),
        // ],
        title: const Text(
          "Налаштування",
          style: TextStyle(
            color: Color.fromARGB(255, 247, 135, 50),
            fontSize: 19,
          ),
        ),
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            color: Color.fromARGB(255, 20, 11, 2),
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: Stack(
              children: [
                Positioned(
                  left: -50,
                  right: -50,
                  top: -50,
                  bottom: -50,
                  child: Image(
                    image: AssetImage("assets/back.png"),
                    color: const Color.fromARGB(32, 41, 41, 41),
                  ),
                ),
                Positioned(
                  left: -350,
                  right: -350,
                  bottom: -250,
                  top: -100,
                  child: Image(
                    image: AssetImage("assets/radiation.png"),
                    color: const Color.fromARGB(17, 55, 27, 6),
                  ),
                ),
                SizedBox(
                  height: 2, // товщина лінії
                  width: double.infinity,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(gradient: bottomGradient),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      color: const Color.fromARGB(4, 249, 189, 25),
                      height: constraints.maxHeight * 0.22,
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          SizedBox(height: constraints.maxHeight * 0.02),
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: constraints.maxWidth * 0.04,
                            ),
                            child: Row(
                              children: [
                                const Text(
                                  'Гучність сигналу тривоги',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color.fromARGB(255, 248, 137, 41),
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  _cur == 0
                                      ? 'Рівень: 0% (вимкнено)'
                                      : 'Рівень: ${_percent()}%  •  крок $_cur / $_max',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color.fromARGB(255, 248, 137, 41),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          SliderTheme(
                            data: SliderThemeData(
                              activeTrackColor: Color.fromARGB(
                                255,
                                183,
                                109,
                                44,
                              ),
                              inactiveTrackColor: Color.fromARGB(
                                26,
                                249,
                                189,
                                25,
                              ),
                              inactiveTickMarkColor: Color.fromARGB(
                                255,
                                248,
                                137,
                                41,
                              ),
                              activeTickMarkColor: Color.fromARGB(255, 0, 0, 0),
                              tickMarkShape: const VerticalLineTickMarkShape(
                                height: 10,
                                width: 2,
                              ),
                            ),
                            child: Slider(
                              value: _cur.toDouble(),
                              thumbColor: Color.fromARGB(255, 248, 137, 41),
                              min: 0,
                              max: _max.toDouble(),
                              divisions: _max,
                              label: _cur == 0 ? '0%' : '${_percent()}%',
                              onChanged: _setStep,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.01),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  GradientBorderButton(
                                    topGradient: topButtonGradient,
                                    bottomGradient: bottomButtonGradient,
                                    radius: 30,
                                    strokeWidth: 1,
                                    onTap: () => _playTest('alarm'),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: constraints.maxWidth * 0.03,
                                        vertical: constraints.maxHeight * 0.01,
                                      ),
                                      child: const Text(
                                        'Початок тривоги',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                            255,
                                            248,
                                            137,
                                            41,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GradientBorderButton(
                                    topGradient: topButtonGradient,
                                    bottomGradient: bottomButtonGradient,
                                    radius: 30,
                                    strokeWidth: 1,
                                    onTap: () => _playTest('alarm_end'),

                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: constraints.maxWidth * 0.03,
                                        vertical: constraints.maxHeight * 0.01,
                                      ),
                                      child: const Text(
                                        'Кінець тривоги',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                            255,
                                            248,
                                            137,
                                            41,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GradientBorderButton(
                                    topGradient: topButtonGradient,
                                    bottomGradient: bottomButtonGradient,
                                    radius: 30,
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
                                        horizontal: constraints.maxWidth * 0.03,
                                        vertical: constraints.maxHeight * 0.01,
                                      ),
                                      child: Text(
                                        'Зупинити',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color.fromARGB(
                                            255,
                                            248,
                                            137,
                                            41,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(gradient: bottomGradient),
                    ),
                    const SizedBox(height: 18),

                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         _dndGranted
                    //             ? 'Доступ до “Не турбувати”: надано ✅'
                    //             : 'Доступ до “Не турбувати”: НЕ надано ❗',
                    //       ),
                    //     ),
                    //     TextButton(
                    //       onPressed: () async {
                    //         try {
                    //           await _alarmNative.invokeMethod(
                    //             'openDndAccessSettings',
                    //           );
                    //         } catch (_) {}
                    //         await Future.delayed(
                    //           const Duration(milliseconds: 700),
                    //         );
                    //         await _load();
                    //       },
                    //       child: const Text('Надати'),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 10),
                    // OutlinedButton(
                    //   onPressed: _load,
                    //   child: const Text('Оновити значення'),
                    // ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
