import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/exceptions/failures.dart';
import '../../../use_cases/get_alarm_history.dart';
import 'alarm_history_bloc_event.dart';
import 'alarm_history_bloc_state.dart';

class AlarmHistoryBloc extends Bloc<AlarmHistoryBlocEvent, AlarmHistoryBlocState> {
  final GetAlarmHistory getAlarmHistoryUseCase;

  Timer? _timer;
  int _secondsLeft = 0;

  AlarmHistoryBloc({required this.getAlarmHistoryUseCase}) : super(InitHistoryState()) {
    on<GetAlarmHistoryBlocEvent>(_getAlarmHistory);

    on<HistoryRateLimitStart>(_onRateLimitStart);
    on<HistoryRateLimitTick>(_onRateLimitTick);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  Future<void> _getAlarmHistory(
    GetAlarmHistoryBlocEvent event,
    Emitter<AlarmHistoryBlocState> emit,
  ) async {
    if (_secondsLeft > 0) {
      emit(RateHistoryLimitedState(secondsLeft: _secondsLeft));
      return;
    }

    emit(LoadingHistoryState());

    final data = await getAlarmHistoryUseCase.call(
      AlarmHistoryParams(oblastId: event.oblastId, days: event.days),
    );

    data.fold(
      (failure) {
        if (failure is RateLimitFailure) {
          final seconds = failure.retryAfterSec <= 0 ? 5 : failure.retryAfterSec;
          add(HistoryRateLimitStart(seconds));
          return;
        }

        emit(ErrorHistoryState(failure: failure));
      },
      (resp) {
        _timer?.cancel();
        _secondsLeft = 0;

        emit(
          LoadedHistoryState(
            listOfModel: resp.alerts,
            risk: resp.risk,
            updatedAt: resp.updatedAt,
            historyUpdatedAt: resp.historyUpdatedAt,
          ),
        );
      },
    );
  }

  void _onRateLimitStart(
    HistoryRateLimitStart event,
    Emitter<AlarmHistoryBlocState> emit,
  ) {
    _timer?.cancel();
    _secondsLeft = event.seconds;

    emit(RateHistoryLimitedState(secondsLeft: _secondsLeft));

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      add(HistoryRateLimitTick());
    });
  }

  void _onRateLimitTick(
    HistoryRateLimitTick event,
    Emitter<AlarmHistoryBlocState> emit,
  ) {
    if (_secondsLeft <= 0) {
      _timer?.cancel();
      emit(InitHistoryState());
      return;
    }

    _secondsLeft -= 1;

    if (_secondsLeft <= 0) {
      _timer?.cancel();
      emit(InitHistoryState());
    } else {
      emit(RateHistoryLimitedState(secondsLeft: _secondsLeft));
    }
  }
}