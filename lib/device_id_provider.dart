import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceIdProvider {
  static const _prefsKey = 'device_id_v1';
  static String? _cached;

  static Future<String> get() async {
    if (_cached != null) return _cached!;

    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_prefsKey);

    if (existing != null && existing.isNotEmpty) {
      _cached = existing;
      return existing;
    }

    final id = const Uuid().v4();
    await prefs.setString(_prefsKey, id);
    _cached = id;
    return id;
  }
}
