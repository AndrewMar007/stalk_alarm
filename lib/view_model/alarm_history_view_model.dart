import 'package:fpdart/fpdart.dart';
import 'package:stalc_alarm/core/exceptions/exceptions.dart';
import 'package:stalc_alarm/core/exceptions/failures.dart';
import 'package:stalc_alarm/core/network/network_info.dart';
import 'package:stalc_alarm/models/alarm_history_model.dart';
import 'package:stalc_alarm/services/alarm_history_service.dart';

abstract class AlarmHistoryViewModel {
  Future<Either<Failure, List<AlarmHistoryModel>>> getAlarmHistory({
    required int oblastId,
    required int days,
  });
}

class AlarmHistoryViewModelImpl implements AlarmHistoryViewModel {
  final NetworkInfo networkInfo;
  final AlarmHistoryService service;
  AlarmHistoryViewModelImpl({required this.networkInfo, required this.service});
  @override
  Future<Either<Failure, List<AlarmHistoryModel>>> getAlarmHistory({
    required int oblastId,
    required int days,
  }) async {
    if (await networkInfo.isConnected()) {
      try {
        final data = await service.getAlarmHistory(
          oblastId: oblastId,
          days: days,
        );
        return Right(data);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetFailure());
    }
  }
}
