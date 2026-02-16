import '../values/lists.dart';
import '../ua_hromadas_dart_files/agregator/agregator.dart';

class RegionNameResolver {
  static String _norm(String s) => s
      .trim()
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll('`', "'")
      .replaceAll('ʼ', "'")
      .replaceAll(RegExp(r'\s+'), ' ');

  static final Map<String, String> _oblastUkToEn = {
    for (final o in ListsOfAdministrativeUnits.oblasts)
      if ((o.title ?? '').trim().isNotEmpty &&
          (o.titleEng ?? '').trim().isNotEmpty)
        _norm(o.title!): o.titleEng!.trim(),
  };

  static final Map<String, String> _raionUkToEn = {
    for (final r in ListsOfAdministrativeUnits.raions)
      if ((r.title ?? '').trim().isNotEmpty &&
          (r.titleEng ?? '').trim().isNotEmpty)
        _norm(r.title!): r.titleEng!.trim(),
  };

  static final Map<String, String> _hromadaUkToEn = {
    for (final h in RaionsAgregator.allHromadas)
      if ((h.title ?? '').trim().isNotEmpty &&
          (h.titleEng ?? '').trim().isNotEmpty)
        _norm(h.title!): h.titleEng!.trim(),
  };

  /// level: 'oblast' | 'raion' | 'hromada' (якщо сервер дає)
  static String localizeTitle({
    required bool isEnglish,
    required String ukTitleFromServer,
    String? level,
  }) {
    if (!isEnglish) return ukTitleFromServer;

    final key = _norm(ukTitleFromServer);

    if (level == 'oblast') return _oblastUkToEn[key] ?? ukTitleFromServer;
    if (level == 'raion') return _raionUkToEn[key] ?? ukTitleFromServer;
    if (level == 'hromada') return _hromadaUkToEn[key] ?? ukTitleFromServer;

    // якщо level нема — пробуємо по черзі
    return _hromadaUkToEn[key] ??
        _raionUkToEn[key] ??
        _oblastUkToEn[key] ??
        ukTitleFromServer;
  }
}
