import 'package:intl/intl.dart';

class AlarmUiFormat {
  static final _time = DateFormat('HH:mm', 'uk_UA');
  static final _dayMonth = DateFormat('d MMMM', 'uk_UA');
  static final _fullDate = DateFormat('d MMMM yyyy', 'uk_UA');

  static int _daysDiff(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return da.difference(db).inDays;
  }

  static String dateRangeLabel(DateTime startedAt, DateTime? finishedAt) {
    final start = startedAt.toLocal();
    final end = finishedAt?.toLocal();
    final now = DateTime.now();

    final diffDays = _daysDiff(start, now);

    late final String dayLabel;
    if (diffDays == 0) {
      dayLabel = 'Сьогодні';
    } else if (diffDays == -1 || diffDays == -2) {
      dayLabel = _dayMonth.format(start);
    } else {
      dayLabel = _fullDate.format(start);
    }

    final startStr = _time.format(start);
    final endStr = end == null ? 'триває' : _time.format(end);

    return '$dayLabel, $startStr - $endStr';
  }

  static String durationLabel(DateTime startedAt, DateTime? finishedAt) {
    if (finishedAt == null) {
      return 'Триває';
    }

    final start = startedAt.toLocal();
    final end = finishedAt.toLocal();

    final diff = end.difference(start);
    final minutes = diff.inMinutes;

    if (minutes < 1) return 'Тривалість < 1 хв';

    final h = minutes ~/ 60;
    final m = minutes % 60;

    if (h == 0) return 'Тривалість $m хв';
    if (m == 0) return 'Тривалість $h год';
    return 'Тривалість $h год $m хв';
  }
}
