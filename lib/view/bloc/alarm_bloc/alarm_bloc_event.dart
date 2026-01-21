abstract class AlarmBlocEvent {}

class GetCurrentAlarmEvent extends AlarmBlocEvent {}

class StartAlarmPollingEvent extends AlarmBlocEvent {
  final int intervalMs;
  StartAlarmPollingEvent({this.intervalMs = 15000});
}

class StopAlarmPollingEvent extends AlarmBlocEvent {}

class SoftRefreshAlarmEvent extends AlarmBlocEvent {}

/// ✅ PUSH з FCM (громада / район / область)
class PushAlarmEvent extends AlarmBlocEvent {
  final String type;   // ALARM_START / ALARM_END
  final String level;  // hromada / raion / oblast
  final String name;   // назва
  final String uid;    // topic: hromada_..., raion_...

  PushAlarmEvent({
    required this.type,
    required this.level,
    required this.name,
    required this.uid,
  });
}
