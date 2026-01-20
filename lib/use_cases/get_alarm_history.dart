import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stalc_alarm/models/alarm_history_model.dart';
import 'package:stalc_alarm/view_model/alarm_history_view_model.dart';

import '../core/exceptions/failures.dart';
import '../core/usecases/use_case.dart';

class GetAlarmHistory
    extends UseCase<List<AlarmHistoryModel>, AlarmHistoryParams> {
  final AlarmHistoryViewModel alarmHistoryViewModel;
  GetAlarmHistory({required this.alarmHistoryViewModel});
  @override
  Future<Either<Failure, List<AlarmHistoryModel>>> call(
    AlarmHistoryParams params,
  ) async {
    return await alarmHistoryViewModel.getAlarmHistory(
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
