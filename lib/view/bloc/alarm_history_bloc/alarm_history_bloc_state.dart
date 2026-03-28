import '../../../core/exceptions/failures.dart';
import '../../../models/alarm_history_model.dart';
import '../../../models/risk_region_model.dart';

class AlarmHistoryBlocState {}

class InitHistoryState extends AlarmHistoryBlocState {}

class LoadingHistoryState extends AlarmHistoryBlocState {}

class LoadedHistoryState extends AlarmHistoryBlocState {
  final List<AlarmHistoryModel> listOfModel;
  final OblastRiskResponse? risk;
  final DateTime? updatedAt;
  final DateTime? historyUpdatedAt;

  LoadedHistoryState({
    required this.listOfModel,
    required this.risk,
    required this.updatedAt,
    required this.historyUpdatedAt,
  });
}

class ErrorHistoryState extends AlarmHistoryBlocState {
  final Failure failure;
  ErrorHistoryState({required this.failure});
}

class RateHistoryLimitedState extends AlarmHistoryBlocState {
  final int secondsLeft;

  RateHistoryLimitedState({required this.secondsLeft});
}