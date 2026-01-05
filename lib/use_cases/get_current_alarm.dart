import 'package:fpdart/src/either.dart';

import '../core/exceptions/failures.dart';
import '../core/usecases/use_case.dart';
import '../models/alert_model.dart';
import '../view_model/alarm_view_model.dart';

class GetCurrentAlarm extends UseCase<List<AlertModel>, NoParams> {
  final AlarmViewModel alarmViewModel;
  GetCurrentAlarm({required this.alarmViewModel});
  @override
  Future<Either<Failure, List<AlertModel>>> call(NoParams params) async {
    return await alarmViewModel.getCurrentAlarm();
  }
}
