abstract class AlarmBlocEvent {}

class GetCurrentAlarmEvent extends AlarmBlocEvent {}

class StartPollingEvent extends AlarmBlocEvent {
  final Duration interval;
  StartPollingEvent({required this.interval});
}

class StopPollingEvent extends AlarmBlocEvent {}
