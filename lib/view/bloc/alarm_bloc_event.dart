abstract class AlarmBlocEvent {}

class GetCurrentAlarmEvent extends AlarmBlocEvent {}

class StartAlarmPollingEvent extends AlarmBlocEvent {
  final int intervalMs;
  StartAlarmPollingEvent({this.intervalMs = 15000});
}

class StopAlarmPollingEvent extends AlarmBlocEvent {}
