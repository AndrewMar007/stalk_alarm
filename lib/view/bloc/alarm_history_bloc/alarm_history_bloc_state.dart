import 'package:stalc_alarm/models/alarm_history_model.dart';

import '../../../core/exceptions/failures.dart';

class AlarmHistoryBlocState {}

class InitState extends AlarmHistoryBlocState {}

class LoadingState extends AlarmHistoryBlocState {}

class LoadedState extends AlarmHistoryBlocState {
  final List<AlarmHistoryModel> listOfModel;
  LoadedState({required this.listOfModel});
}

class ErrorState extends AlarmHistoryBlocState {
  final Failure failure;
  ErrorState({required this.failure});
}
