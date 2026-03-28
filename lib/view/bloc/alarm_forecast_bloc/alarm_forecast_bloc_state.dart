
import '../../../core/exceptions/failures.dart';
import '../../../models/forecast_model.dart';

abstract class AlarmForecastBlocState {
  const AlarmForecastBlocState();
}

class AlarmForecastInitState extends AlarmForecastBlocState {
  const AlarmForecastInitState();
}

class AlarmForecastLoadingState extends AlarmForecastBlocState {
  final int oblastId;
  const AlarmForecastLoadingState({required this.oblastId});
}

class AlarmForecastLoadedState extends AlarmForecastBlocState {
  final int oblastId;
  final OblastForecastResponse data;
  const AlarmForecastLoadedState({
    required this.oblastId,
    required this.data,
  });
}

class AlarmForecastRateLimitedState extends AlarmForecastBlocState {
  final int oblastId;
  final int retryAfterSec;
  const AlarmForecastRateLimitedState({
    required this.oblastId,
    required this.retryAfterSec,
  });
}

class AlarmForecastErrorState extends AlarmForecastBlocState {
  final int oblastId;
  final Failure failure;
  const AlarmForecastErrorState({
    required this.oblastId,
    required this.failure,
  });
}