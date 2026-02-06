// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:stalc_alarm/models/admin_units.dart';

// class RaionsStorage {
//   static const _key = 'subscriptions';

//   Future<List<Map<String, dynamic>>> loadRaw() async {
//     final sp = await SharedPreferences.getInstance();
//     final s = sp.getString(_key);
//     if (s == null) return [];
//     final decoded = jsonDecode(s) as List;
//     return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
//   }

//   Future<void> saveRaw(Oblast oblast, Raion raion, Hromada hromada) async {
//     final model = SavedAdminUnit(oblastUid: oblast.uid, oblastTitle: oblast.title, raionTitle: raion.title, raionUid: raion.uid, hromadaTitle: hromada.title);
//     final sp = await SharedPreferences.getInstance();
//     await sp.setString(_key, jsonEncode(model));
//   }

//   /// ✅ Додати район (якщо вже є такий raionUid — не дублюємо, а оновлюємо дані)
//   Future<void> upsertRaion(Map<String, dynamic> raion) async {
//     final raionUid = raion['raionUid'];
//     if (raionUid == null) {
//       throw ArgumentError('raion map must contain "raionUid"');
//     }

//     final list = await loadRaw();
//     final index = list.indexWhere((e) => e['raionUid'] == raionUid);

//     if (index == -1) {
//       list.add(raion);
//     } else {
//       list[index] = raion; // оновили дані
//     }

//     await saveRaw(list);
//   }

//   /// ✅ Видалити район по raionUid
//   Future<bool> removeByRaionUid(dynamic raionUid) async {
//     final list = await loadRaw();
//     final before = list.length;
//     list.removeWhere((e) => e['raionUid'] == raionUid);
//     await saveRaw(list);
//     return list.length != before; // true якщо щось видалили
//   }

//   /// ✅ Очистити всі підписки
//   Future<void> clear() async {
//     final sp = await SharedPreferences.getInstance();
//     await sp.remove(_key);
//   }

//   /// ✅ Перевірити чи район уже збережений
//   Future<bool> containsRaion(dynamic raionUid) async {
//     final list = await loadRaw();
//     return list.any((e) => e['raionUid'] == raionUid);
//   }
// }

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/admin_units.dart';

class SavedAdminUnit {
  final String? oblastUid;
  final String? oblastTitle;
  final String? oblastEngTitle;
  final String? raionEngTitle;
  final String? raionTitle;
  final String? raionUid;
  final String? hromadaTitle;
  final String? hromadaUid;
  final String? hromadaEngTitle;

  const SavedAdminUnit({
    required this.oblastUid,
    required this.oblastTitle,
    required this.oblastEngTitle,
    required this.raionTitle,
    required this.raionEngTitle,
    required this.raionUid,
    required this.hromadaTitle,
    required this.hromadaUid,
    required this.hromadaEngTitle,
  });

  /// Унікальний ключ запису (щоб не було дублів і було легко видаляти)
  String get key => '$oblastUid|$raionUid|$hromadaTitle';

  Map<String, dynamic> toJson() => {
    'oblastUid': oblastUid,
    'oblastTitle': oblastTitle,
    'oblastEngTitle': oblastEngTitle,
    'raionTitle': raionTitle,
    'raionUid': raionUid,
    'raionEngTitle': raionEngTitle,
    'hromadaTitle': hromadaTitle,
    'hromadaUid': hromadaUid,
    'hromadaEngTitle': hromadaEngTitle
  };

  factory SavedAdminUnit.fromJson(Map<String, dynamic> json) {
    return SavedAdminUnit(
      oblastUid: json['oblastUid'],
      oblastTitle: json['oblastTitle'],
      oblastEngTitle: json['oblastEngTitle'],
      raionTitle: json['raionTitle'],
      raionUid: json['raionUid'],
      raionEngTitle: json['raionEngTitle'],
      hromadaTitle: json['hromadaTitle'],
      hromadaUid: json['hromadaUid'],
      hromadaEngTitle: json['hromadaEngTitle'],
    );
  }
}

class SavedAdminUnitsStorage {
  static const _key = 'saved_admin_units';

  Future<List<SavedAdminUnit>> loadAll() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_key);
    if (s == null) return [];

    final decoded = jsonDecode(s) as List;
    return decoded
        .map(
          (e) => SavedAdminUnit.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
  }

  Future<void> _saveAll(List<SavedAdminUnit> list) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, jsonEncode(list.map((e) => e.toJson()).toList()));
  }

  /// ➕ Додати запис (Tile). Якщо такий вже є — не дублюємо.
  Future<void> add(Oblast oblast, Raion raion, Hromada hromada) async {
    final unit = SavedAdminUnit(
      oblastUid: oblast.uid,
      oblastTitle: oblast.title,
      oblastEngTitle: oblast.titleEng,
      raionTitle: raion.title,
      raionUid: raion.uid,
      raionEngTitle: raion.titleEng,
      hromadaTitle: hromada.title,
      hromadaUid: hromada.uid,
      hromadaEngTitle: hromada.titleEng,
    );
    final list = await loadAll();
    final exists = list.any((e) => e.key == unit.key);
    if (!exists) {
      list.add(unit);
      await _saveAll(list);
    }
  }

  /// ➖ Видалити запис саме по SavedAdminUnit (по key)
  Future<bool> remove(SavedAdminUnit unit) async {
    final list = await loadAll();
    final before = list.length;

    list.removeWhere((e) => e.key == unit.key);
    await _saveAll(list);

    return list.length != before;
  }

  /// ✅ Перевірити чи вже є такий запис
  Future<bool> contains(SavedAdminUnit unit) async {
    final list = await loadAll();
    return list.any((e) => e.key == unit.key);
  }

  /// 🧹 Очистити все
  Future<void> clear() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_key);
  }
}
