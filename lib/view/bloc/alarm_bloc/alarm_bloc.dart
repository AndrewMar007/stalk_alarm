import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:stalc_alarm/core/usecases/use_case.dart';
import 'alarm_bloc_event.dart';
import 'alarm_bloc_state.dart';
import '../../../use_cases/get_current_alarm.dart';

class AlarmBloc extends Bloc<AlarmBlocEvent, AlarmBlocState> {
  final GetCurrentAlarm getCurrentAlarmUseCase;

  Timer? _timer;

  /// кеш push-даних
  String? _pushType;
  String? _pushLevel;
  String? _pushName;
  String? _pushUid;

  /// активні громади
  final Map<String, String> _activeHromadas = {};

  AlarmBloc({required this.getCurrentAlarmUseCase}) : super(InitState()) {
    on<GetCurrentAlarmEvent>(_onGetCurrentAlarmHard);
    on<SoftRefreshAlarmEvent>(_onGetCurrentAlarmSoft);
    on<StartAlarmPollingEvent>(_onStartPolling);
    on<StopAlarmPollingEvent>(_onStopPolling);
    on<PushAlarmEvent>(_onPushAlarm);
  }

  Future<void> _onGetCurrentAlarmHard(
    GetCurrentAlarmEvent event,
    Emitter<AlarmBlocState> emit,
  ) async {
    final data = await getCurrentAlarmUseCase.call(NoParams());
    data.fold(
      (failure) => emit(ErrorState(failure: failure)),
      (alarm) => emit(
        LoadedState(
          alarmList: alarm,
          pushType: _pushType,
          pushLevel: _pushLevel,
          pushName: _pushName,
          pushUid: _pushUid,
          activeHromadas: Map.from(_activeHromadas),
        ),
      ),
    );
  }

  Future<void> _onGetCurrentAlarmSoft(
    SoftRefreshAlarmEvent event,
    Emitter<AlarmBlocState> emit,
  ) async {
    final data = await getCurrentAlarmUseCase.call(NoParams());

    data.fold(
      (failure) {
        if (state is LoadedState) return;
        emit(ErrorState(failure: failure));
      },
      (alarm) {
        emit(
          LoadedState(
            alarmList: alarm,
            pushType: _pushType,
            pushLevel: _pushLevel,
            pushName: _pushName,
            pushUid: _pushUid,
            activeHromadas: Map.from(_activeHromadas),
          ),
        );
      },
    );
  }

  void _onStartPolling(
    StartAlarmPollingEvent event,
    Emitter<AlarmBlocState> emit,
  ) {
    _timer?.cancel();
    add(SoftRefreshAlarmEvent());

    _timer = Timer.periodic(
      Duration(milliseconds: event.intervalMs),
      (_) => add(SoftRefreshAlarmEvent()),
    );
  }

  void _onStopPolling(
    StopAlarmPollingEvent event,
    Emitter<AlarmBlocState> emit,
  ) {
    _timer?.cancel();
    _timer = null;
  }

  /// ===== ГОЛОВНЕ: START / END ГРОМАД =====
  void _onPushAlarm(
    PushAlarmEvent event,
    Emitter<AlarmBlocState> emit,
  ) {
    _pushType = event.type;
    _pushLevel = event.level;
    _pushName = event.name;
    _pushUid = event.uid;

    if (event.level == 'hromada') {
      if (event.type == 'ALARM_START') {
        _activeHromadas[event.uid] = event.name;
      } else if (event.type == 'ALARM_END') {
        _activeHromadas.remove(event.uid);
      }
    }

    if (state is LoadedState) {
      emit(
        (state as LoadedState).copyWith(
          pushType: _pushType,
          pushLevel: _pushLevel,
          pushName: _pushName,
          pushUid: _pushUid,
          activeHromadas: Map.from(_activeHromadas),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
