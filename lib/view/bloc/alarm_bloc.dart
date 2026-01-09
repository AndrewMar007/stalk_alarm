import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stalc_alarm/core/usecases/use_case.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc_event.dart';
import 'package:stalc_alarm/view/bloc/alarm_bloc_state.dart';
import '../../use_cases/get_current_alarm.dart';

class AlarmBloc extends Bloc<AlarmBlocEvent, AlarmBlocState> {
  final GetCurrentAlarm getCurrentAlarmUseCase;

  Timer? _timer;

  AlarmBloc({required this.getCurrentAlarmUseCase}) : super(InitState()) {
    on<GetCurrentAlarmEvent>(_onGetCurrentAlarmHard);
    on<SoftRefreshAlarmEvent>(_onGetCurrentAlarmSoft);
    on<StartAlarmPollingEvent>(_onStartPolling);
    on<StopAlarmPollingEvent>(_onStopPolling);
  }

  // ✅ HARD: якщо треба примусово показати помилку
  Future<void> _onGetCurrentAlarmHard(
    GetCurrentAlarmEvent event,
    Emitter<AlarmBlocState> emit,
  ) async {
    final data = await getCurrentAlarmUseCase.call(NoParams());
    data.fold(
      (failure) => emit(ErrorState(failure: failure)),
      (alarm) => emit(LoadedState(alarmList: alarm)),
    );
  }

  // ✅ SOFT: якщо впав інтернет, але дані вже були — не ламаємо UI
  Future<void> _onGetCurrentAlarmSoft(
    SoftRefreshAlarmEvent event,
    Emitter<AlarmBlocState> emit,
  ) async {
    final data = await getCurrentAlarmUseCase.call(NoParams());

    data.fold(
      (failure) {
        // якщо дані вже були — не емитимо Error
        if (state is LoadedState) return;
        emit(ErrorState(failure: failure));
      },
      (alarm) => emit(LoadedState(alarmList: alarm)),
    );
  }

  void _onStartPolling(
    StartAlarmPollingEvent event,
    Emitter<AlarmBlocState> emit,
  ) {
    _timer?.cancel();

    // перший запит одразу (soft)
    add(SoftRefreshAlarmEvent());

    _timer = Timer.periodic(Duration(milliseconds: event.intervalMs), (_) {
      add(SoftRefreshAlarmEvent());
    });
  }

  void _onStopPolling(
    StopAlarmPollingEvent event,
    Emitter<AlarmBlocState> emit,
  ) {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
