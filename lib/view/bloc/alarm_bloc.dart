import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'alarm_bloc_event.dart';
import 'alarm_bloc_state.dart';
import '../../use_cases/get_current_alarm.dart';
import 'package:stalc_alarm/core/usecases/use_case.dart';

class AlarmBloc extends Bloc<AlarmBlocEvent, AlarmBlocState> {
  final GetCurrentAlarm getCurrentAlarmUseCase;

  Timer? _timer;
  bool _fetchInProgress = false;

  AlarmBloc({required this.getCurrentAlarmUseCase}) : super(InitState()) {
    on<GetCurrentAlarmEvent>(_onGetCurrentAlarm);
    on<StartPollingEvent>(_onStartPolling);
    on<StopPollingEvent>(_onStopPolling);
  }

  Future<void> _onStartPolling(StartPollingEvent event, Emitter<AlarmBlocState> emit) async {
    _timer?.cancel();

    add(GetCurrentAlarmEvent()); // одразу перший запит

    _timer = Timer.periodic(event.interval, (_) {
      add(GetCurrentAlarmEvent());
    });
  }

  Future<void> _onStopPolling(StopPollingEvent event, Emitter<AlarmBlocState> emit) async {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _onGetCurrentAlarm(GetCurrentAlarmEvent event, Emitter<AlarmBlocState> emit) async {
    if (_fetchInProgress) return;
    _fetchInProgress = true;

    final data = await getCurrentAlarmUseCase.call(NoParams());
    data.fold(
      (failure) => emit(ErrorState(failure: failure)),
      (alarm) => emit(LoadedState(alarmList: alarm)),
    );

    _fetchInProgress = false;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
