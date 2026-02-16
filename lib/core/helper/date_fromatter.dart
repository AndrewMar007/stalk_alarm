import 'package:intl/intl.dart';

class AlarmUiFormat {
  static int _daysDiff(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return da.difference(db).inDays;
  }

  static String dateRangeLabel(
    DateTime startedAt,
    DateTime? finishedAt, {
    String localeCode = 'uk',
  }) {
    final isEn = localeCode == 'en';
    final locale = isEn ? 'en_US' : 'uk_UA';

    // ✅ ГОЛОВНЕ: формат часу
    final timeFmt = isEn
        ? DateFormat.jm(locale) // 2:30 PM
        : DateFormat('HH:mm', locale); // 14:30

    final dayMonth = DateFormat('d MMMM', locale);
    final fullDate = DateFormat('d MMMM yyyy', locale);

    final start = startedAt.toLocal();
    final end = finishedAt?.toLocal();
    final now = DateTime.now();

    final diffDays = _daysDiff(start, now);

    late final String dayLabel;
    if (diffDays == 0) {
      dayLabel = isEn ? 'Today' : 'Сьогодні';
    } else if (diffDays == -1 || diffDays == -2) {
      dayLabel = dayMonth.format(start);
    } else {
      dayLabel = fullDate.format(start);
    }

    final startStr = timeFmt.format(start);
    final endStr = end == null
        ? (isEn ? 'ongoing' : 'триває')
        : timeFmt.format(end);

    return '$dayLabel, $startStr – $endStr';
  }

  static String durationLabel(
    DateTime startedAt,
    DateTime? finishedAt, {
    String localeCode = 'uk',
  }) {
    final isEn = localeCode == 'en';

    if (finishedAt == null) {
      return isEn ? 'Ongoing' : 'Триває';
    }

    final start = startedAt.toLocal();
    final end = finishedAt.toLocal();

    final diff = end.difference(start);
    final minutes = diff.inMinutes;

    if (minutes < 1) {
      return isEn ? 'Duration < 1 min' : 'Тривалість < 1 хв';
    }

    final h = minutes ~/ 60;
    final m = minutes % 60;

    if (h == 0) return isEn ? 'Duration $m min' : 'Тривалість $m хв';
    if (m == 0) return isEn ? 'Duration $h h' : 'Тривалість $h год';
    return isEn
        ? 'Duration $h h $m min'
        : 'Тривалість $h год $m хв';
  }
}
