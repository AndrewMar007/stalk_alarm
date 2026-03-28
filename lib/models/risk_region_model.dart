enum RiskLevel { low, medium, high, unknown }

RiskLevel riskLevelFromString(String? s) {
  switch ((s ?? '').toUpperCase()) {
    case 'LOW':
      return RiskLevel.low;
    case 'MEDIUM':
      return RiskLevel.medium;
    case 'HIGH':
      return RiskLevel.high;
    default:
      return RiskLevel.unknown;
  }
}

String riskLevelToUiLabel(RiskLevel level) {
  switch (level) {
    case RiskLevel.low:
      return '🟢 Низький ризик';
    case RiskLevel.medium:
      return '🟡 Середній ризик';
    case RiskLevel.high:
      return '🔴 Високий ризик';
    case RiskLevel.unknown:
      return '⚪ Невідомо';
  }
}

String riskLevelToLocalizedLabel(
  RiskLevel level, {
  required bool isEnglish,
  bool withEmoji = true,
}) {
  final prefix = withEmoji
      ? switch (level) {
          RiskLevel.low => '🟢 ',
          RiskLevel.medium => '🟡 ',
          RiskLevel.high => '🔴 ',
          RiskLevel.unknown => '⚪ ',
        }
      : '';

  if (isEnglish) {
    switch (level) {
      case RiskLevel.low:
        return '${prefix}Low risk';
      case RiskLevel.medium:
        return '${prefix}Medium risk';
      case RiskLevel.high:
        return '${prefix}High risk';
      case RiskLevel.unknown:
        return '${prefix}Unknown';
    }
  }

  switch (level) {
    case RiskLevel.low:
      return '${prefix}Низький ризик';
    case RiskLevel.medium:
      return '${prefix}Середній ризик';
    case RiskLevel.high:
      return '${prefix}Високий ризик';
    case RiskLevel.unknown:
      return '${prefix}Невідомо';
  }
}

class RiskComponents {
  final int count7d;
  final int avgDurationMin;
  final bool isActiveNow;

  final double normCount;
  final double normDuration;
  final int activeBonus;

  const RiskComponents({
    required this.count7d,
    required this.avgDurationMin,
    required this.isActiveNow,
    required this.normCount,
    required this.normDuration,
    required this.activeBonus,
  });

  factory RiskComponents.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v, [int def = 0]) =>
        (v is num) ? v.round() : int.tryParse('$v') ?? def;

    double asDouble(dynamic v, [double def = 0]) =>
        (v is num) ? v.toDouble() : double.tryParse('$v') ?? def;

    bool asBool(dynamic v, [bool def = false]) {
      if (v is bool) return v;
      final s = ('$v').toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
      return def;
    }

    return RiskComponents(
      count7d: asInt(json['count7d']),
      avgDurationMin: asInt(json['avgDurationMin']),
      isActiveNow: asBool(json['isActiveNow']),
      normCount: asDouble(json['normCount']),
      normDuration: asDouble(json['normDuration']),
      activeBonus: asInt(json['activeBonus']),
    );
  }
}

class OblastRiskResponse {
  final bool ok;

  final String oblastUid;
  final String oblastName;

  final int days;
  final String period;

  /// 0..100
  final int score;

  final RiskLevel level;

  /// server-friendly label, may come in server language
  final String label;

  final RiskComponents? components;

  final DateTime? updatedAt;

  const OblastRiskResponse({
    required this.ok,
    required this.oblastUid,
    required this.oblastName,
    required this.days,
    required this.period,
    required this.score,
    required this.level,
    required this.label,
    required this.components,
    required this.updatedAt,
  });

  factory OblastRiskResponse.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v, [int def = 0]) =>
        (v is num) ? v.round() : int.tryParse('$v') ?? def;

    String asString(dynamic v, [String def = '']) =>
        (v == null) ? def : v.toString();

    bool asBool(dynamic v, [bool def = false]) {
      if (v is bool) return v;
      final s = ('$v').toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
      return def;
    }

    DateTime? asDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      return DateTime.tryParse(s);
    }

    final lvl = riskLevelFromString(asString(json['level']));
    final lbl = asString(json['label'], riskLevelToUiLabel(lvl));

    return OblastRiskResponse(
      ok: asBool(json['ok']),
      oblastUid: asString(json['oblastUid']),
      oblastName: asString(json['oblastName']),
      days: asInt(json['days'], 7),
      period: asString(json['period'], 'month_ago'),
      score: asInt(json['score']),
      level: lvl,
      label: lbl,
      components: (json['components'] is Map<String, dynamic>)
          ? RiskComponents.fromJson(json['components'] as Map<String, dynamic>)
          : null,
      updatedAt: asDate(json['updatedAt']),
    );
  }

  String get scoreText => '$score/100';

  String get badgeEmoji {
    switch (level) {
      case RiskLevel.low:
        return '🟢';
      case RiskLevel.medium:
        return '🟡';
      case RiskLevel.high:
        return '🔴';
      case RiskLevel.unknown:
        return '⚪';
    }
  }

  String get uiTitle => oblastName.isNotEmpty ? oblastName : 'Область $oblastUid';

  String localizedLabel({
    required bool isEnglish,
    bool withEmoji = true,
  }) {
    return riskLevelToLocalizedLabel(
      level,
      isEnglish: isEnglish,
      withEmoji: withEmoji,
    );
  }
}