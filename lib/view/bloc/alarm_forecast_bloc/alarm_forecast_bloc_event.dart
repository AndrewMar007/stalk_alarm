abstract class AlarmForecastBlocEvent {
  const AlarmForecastBlocEvent();
}

class AlarmGetForecastEvent extends AlarmForecastBlocEvent {
  final int oblastId;
  const AlarmGetForecastEvent({required this.oblastId});
}