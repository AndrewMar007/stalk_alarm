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
    on<GetCurrentAlarmEvent>(_onGetCurrentAlarm);
    on<StartAlarmPollingEvent>(_onStartPolling);
    on<StopAlarmPollingEvent>(_onStopPolling);
  }

  Future<void> _onGetCurrentAlarm(
    GetCurrentAlarmEvent event,
    Emitter<AlarmBlocState> emit,
  ) async {
    // Якщо не хочеш миготіння Loading кожні 15с — не емить Loading при background poll
    final data = await getCurrentAlarmUseCase.call(NoParams());
    data.fold(
      (failure) => emit(ErrorState(failure: failure)),
      (alarm) => emit(LoadedState(alarmList: alarm)),
    );
  }

  void _onStartPolling(
    StartAlarmPollingEvent event,
    Emitter<AlarmBlocState> emit,
  ) {
    _timer?.cancel();

    // одразу перший запит
    add(GetCurrentAlarmEvent());

    _timer = Timer.periodic(Duration(milliseconds: event.intervalMs), (_) {
      add(GetCurrentAlarmEvent());
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
