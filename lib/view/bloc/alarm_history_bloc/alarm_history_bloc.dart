import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stalc_alarm/use_cases/get_alarm_history.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc_event.dart';
import 'package:stalc_alarm/view/bloc/alarm_history_bloc/alarm_history_bloc_state.dart';

class AlarmHistoryBloc
    extends Bloc<AlarmHistoryBlocEvent, AlarmHistoryBlocState> {
  final GetAlarmHistory getAlarmHistoryUseCase;
  AlarmHistoryBloc({required this.getAlarmHistoryUseCase})
    : super(InitState()) {
    on<GetAlarmHistoryBlocEvent>(_getAlarmHistory);
  }

  Future<void> _getAlarmHistory(
    GetAlarmHistoryBlocEvent event,
    Emitter<AlarmHistoryBlocState> emit,
  ) async {
    emit(LoadingState());
    final data = await getAlarmHistoryUseCase.call(
      AlarmHistoryParams(oblastId: event.oblastId, days: event.days),
    );
    data.fold(
      (failure) => emit(ErrorState(failure: failure)),
      (list) => emit(LoadedState(listOfModel: list)),
    );
  }
}
