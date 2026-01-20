abstract class AlarmHistoryBlocEvent {}

class GetAlarmHistoryBlocEvent extends AlarmHistoryBlocEvent {
  final int oblastId;
  final int days;
  GetAlarmHistoryBlocEvent({required this.oblastId, required this.days});
}
