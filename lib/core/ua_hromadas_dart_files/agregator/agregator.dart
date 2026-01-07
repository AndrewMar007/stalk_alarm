import 'package:stalc_alarm/core/ua_hromadas_dart_files/cherkaska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/chernihivska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/chernivetska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/dnipropetrovska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/donetska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/ivano_frankivska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/kharkivska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/khersonska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/khmelnytska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/kirovohradska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/kyyivska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/luhanska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/lvivska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/mykolayivska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/odeska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/poltavska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/rivnenska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/sumska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/ternopilska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/vinnytska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/volynska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/zakarpatska_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/zaporizka_oblast_hromadas.dart';
import 'package:stalc_alarm/core/ua_hromadas_dart_files/zhytomyrska_oblast_hromadas.dart';

import '../../../models/admin_units.dart';

class RaionsAgregator {
  static const List<Hromada> allHromadas = [
    ...vinnytskaOblastHromadas,
    ...volynskaOblastHromadas,
    ...dnipropetrovskaOblastHromadas,
    ...donetskaOblastHromadas,
    ...zhytomyrskaOblastHromadas,
    ...zakarpatskaOblastHromadas,
    ...zaporizkaOblastHromadas,
    ...ivanoFrankivskaOblastHromadas,
    ...kyivskaOblastHromadas,
    ...kirovohradskaOblastHromadas,
    ...luhanskaOblastHromadas,
    ...lvivskaOblastHromadas,
    ...mykolayivskaOblastHromadas,
    ...odeskaOblastHromadas,
    ...poltavskaOblastHromadas,
    ...rivnenskaOblastHromadas,
    ...sumskaOblastHromadas,
    ...ternopilskaOblastHromadas,
    ...kharkivskaOblastHromadas,
    ...khersonskaOblastHromadas,
    ...khmelnytskaOblastHromadas,
    ...cherkaskaOblastHromadas,
    ...chernivetskaOblastHromadas,
    ...chernihivskaOblastHromadas,
  ];

  // 2) індекс: raionUid -> громади
  static Map<String, List<Hromada>> hromadasByRaionUid = _indexByRaion(
    allHromadas,
  );

  static Map<String, List<Hromada>> _indexByRaion(List<Hromada> list) {
    final map = <String, List<Hromada>>{};
    for (final h in list) {
      (map[h.raionUid!] ??= <Hromada>[]).add(h);
    }
    return map;
  }

  // 3) зручний хелпер
  static List<Hromada> getHromadasByRaionUid(String raionUid) =>
      hromadasByRaionUid[raionUid] ?? const [];
}
