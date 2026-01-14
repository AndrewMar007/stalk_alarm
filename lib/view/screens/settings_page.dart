import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const MethodChannel _alarmNative = MethodChannel('stalk_alarm/alarm');

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

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
      final dnd = await _alarmNative.invokeMethod<bool>('hasDndAccess') ?? false;

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
      SnackBar(content: Text(text), duration: const Duration(milliseconds: 900)),
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Гучність тривоги (ALARM stream)',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            _cur == 0
                ? 'ALARM: 0% (вимкнено)'
                : 'ALARM: ${_percent()}%  •  крок $_cur / $_max',
            style: const TextStyle(fontSize: 12),
          ),
          Slider(
            value: _cur.toDouble(),
            min: 0,
            max: _max.toDouble(),
            divisions: _max,
            label: _cur == 0 ? '0%' : '${_percent()}%',
            onChanged: _setStep,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  _dndGranted
                      ? 'Доступ до “Не турбувати”: надано ✅'
                      : 'Доступ до “Не турбувати”: НЕ надано ❗',
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await _alarmNative.invokeMethod('openDndAccessSettings');
                  } catch (_) {}
                  await Future.delayed(const Duration(milliseconds: 700));
                  await _load();
                },
                child: const Text('Надати'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: _load,
            child: const Text('Оновити значення'),
          ),
          const Divider(height: 24),
          OutlinedButton(
            onPressed: () => _playTest('alarm'),
            child: const Text('▶️ Тест START (alarm)'),
          ),
          OutlinedButton(
            onPressed: () => _playTest('alarm_end'),
            child: const Text('▶️ Тест END (alarm_end)'),
          ),
          OutlinedButton(
            onPressed: () async {
              try {
                await _alarmNative.invokeMethod('stopAlarmSound');
              } catch (_) {}
            },
            child: const Text('⏹️ Stop'),
          ),
        ],
      ),
    );
  }
}
