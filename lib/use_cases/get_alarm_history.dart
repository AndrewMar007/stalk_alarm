import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../core/exceptions/failures.dart';
import '../core/usecases/use_case.dart';
import '../models/oblast_history_with_risk_response.dart';
import '../view_model/alarm_history_view_model.dart';

class GetAlarmHistory
    extends UseCase<OblastHistoryWithRiskResponse, AlarmHistoryParams> {
  final AlarmHistoryViewModel alarmHistoryViewModel;
  GetAlarmHistory({required this.alarmHistoryViewModel});
  @override
  Future<Either<Failure, OblastHistoryWithRiskResponse>> call(
    AlarmHistoryParams params,
  ) async {
    return await alarmHistoryViewModel.getAlarmHistoryWithRisk(
      oblastId: params.oblastId,
      days: params.days,
    );
  }
}

class AlarmHistoryParams extends Equatable{
  final int oblastId;
  final int days;
  const AlarmHistoryParams({required this.oblastId, required this.days});
  
  @override
  List<Object?> get props => [oblastId, days];
}
