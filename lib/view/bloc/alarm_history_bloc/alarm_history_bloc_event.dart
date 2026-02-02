abstract class AlarmHistoryBlocEvent {}

class GetAlarmHistoryBlocEvent extends AlarmHistoryBlocEvent {
  final int oblastId;
  final int days;
  GetAlarmHistoryBlocEvent({required this.oblastId, required this.days});
}

// ✅ INTERNAL: стартуємо countdown
class HistoryRateLimitStart extends AlarmHistoryBlocEvent {
  final int seconds;
  HistoryRateLimitStart(this.seconds);
}

// ✅ INTERNAL: тік countdown
class HistoryRateLimitTick extends AlarmHistoryBlocEvent {
}