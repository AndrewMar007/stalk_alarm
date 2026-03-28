class ForecastPeriod {
  final String from;
  final String to;
  final String level;
  final int percent;

  ForecastPeriod({
    required this.from,
    required this.to,
    required this.level,
    required this.percent,
  });

  factory ForecastPeriod.fromJson(Map<String, dynamic> j) {
    final from = (j['from'] ?? '').toString();
    final to = (j['to'] ?? '').toString();
    final level = (j['level'] ?? 'MEDIUM').toString();

    // percent може бути int/double/string/null — нормалізуємо
    final rawPercent = j['percent'];
    final percent = rawPercent is num
        ? rawPercent.round()
        : int.tryParse(rawPercent?.toString() ?? '') ?? 0;

    return ForecastPeriod(
      from: from,
      to: to,
      level: level,
      percent: percent,
    );
  }
}

class OblastForecastResponse {
  final bool ok;
  final String oblastUid;
  final String oblastName;
  final String updatedAt;
  final String tz;
  final int daysBack;
  final List<ForecastPeriod> periods;

  OblastForecastResponse({
    required this.ok,
    required this.oblastUid,
    required this.oblastName,
    required this.updatedAt,
    required this.tz,
    required this.daysBack,
    required this.periods,
  });

  factory OblastForecastResponse.fromJson(Map<String, dynamic> json) {
    final periodsRaw = json['periods'];

    final List<ForecastPeriod> periods = (periodsRaw is List ? periodsRaw : const [])
        .where((e) => e is Map) // тільки Map-елементи
        .map((e) => ForecastPeriod.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();

    return OblastForecastResponse(
      ok: (json['ok'] as bool?) ?? true,
      oblastUid: (json['oblastUid'] ?? '').toString(),
      oblastName: (json['oblastName'] ?? '').toString(),
      updatedAt: (json['updatedAt'] ?? '').toString(),
      tz: (json['tz'] ?? 'Europe/Kyiv').toString(),
      daysBack: (json['daysBack'] is num) ? (json['daysBack'] as num).toInt() : 30,
      periods: periods,
    );
  }
}