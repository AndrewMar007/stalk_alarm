import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stalc_alarm/core/exceptions/failures.dart';
import 'package:stalc_alarm/use_cases/get_alarm_history.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc_event.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc_state.dart';

class AlarmHistoryBloc extends Bloc<AlarmHistoryBlocEvent, AlarmHistoryBlocState> {
  final GetAlarmHistory getAlarmHistoryUseCase;

  Timer? _timer;
  int _secondsLeft = 0;

  AlarmHistoryBloc({required this.getAlarmHistoryUseCase}) : super(InitState()) {
    on<GetAlarmHistoryBlocEvent>(_getAlarmHistory);

    // ✅ internal handlers for countdown
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
    // якщо вже активний ліміт — просто показуємо countdown
    if (_secondsLeft > 0) {
      emit(RateLimitedState(secondsLeft: _secondsLeft));
      return;
    }

    emit(LoadingState());

    final data = await getAlarmHistoryUseCase.call(
      AlarmHistoryParams(oblastId: event.oblastId, days: event.days),
    );

    data.fold(
      (failure) {
        if (failure is RateLimitFailure) {
          final seconds = failure.retryAfterSec <= 0 ? 45 : failure.retryAfterSec;
          // ✅ НЕ emit з таймера — запускаємо через подію
          add(HistoryRateLimitStart(seconds));
          return;
        }

        emit(ErrorState(failure: failure));
      },
      (list) {
        _timer?.cancel();
        _secondsLeft = 0;
        emit(LoadedState(listOfModel: list));
      },
    );
  }

  void _onRateLimitStart(
    HistoryRateLimitStart event,
    Emitter<AlarmHistoryBlocState> emit,
  ) {
    _timer?.cancel();
    _secondsLeft = event.seconds;

    emit(RateLimitedState(secondsLeft: _secondsLeft));

    // ✅ timer тільки додає події
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
      emit(InitState());
      return;
    }

    _secondsLeft -= 1;

    if (_secondsLeft <= 0) {
      _timer?.cancel();
      emit(InitState());
    } else {
      emit(RateLimitedState(secondsLeft: _secondsLeft));
    }
  }
}
