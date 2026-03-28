import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/exceptions/failures.dart';
import '../../../models/forecast_model.dart';
import '../../../use_cases/get_alarm_forecast.dart';
import 'alarm_forecast_bloc_event.dart';
import 'alarm_forecast_bloc_state.dart';

class AlarmForecastBloc
    extends Bloc<AlarmForecastBlocEvent, AlarmForecastBlocState> {
  final GetAlarmForecastUseCase getAlarmForecastUseCase;

  AlarmForecastBloc({required this.getAlarmForecastUseCase})
    : super(const AlarmForecastInitState()) {
    on<AlarmGetForecastEvent>(_onGetForecast);
  }

  Future<void> _onGetForecast(
    AlarmGetForecastEvent event,
    Emitter<AlarmForecastBlocState> emit,
  ) async {
    print("BLOC: loading oblast=${event.oblastId}");
    emit(AlarmForecastLoadingState(oblastId: event.oblastId));

    final Either<Failure, OblastForecastResponse> result =
        await getAlarmForecastUseCase(
          AlarmForecastParams(oblastId: event.oblastId),
        );

    result.match(
      (failure) {
        if (failure is RateLimitFailure) {
          print("BLOC: failure $failure");
          emit(
            AlarmForecastRateLimitedState(
              oblastId: event.oblastId,
              retryAfterSec: failure.retryAfterSec,
            ),
          );
          return;
        }

        emit(
          AlarmForecastErrorState(oblastId: event.oblastId, failure: failure),
        );
      },
      (data) {
        print("BLOC: loaded periods=${data.periods.length}");
        emit(AlarmForecastLoadedState(oblastId: event.oblastId, data: data));
      },
    );
  }
}
