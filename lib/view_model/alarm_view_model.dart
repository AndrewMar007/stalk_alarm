import 'package:fpdart/fpdart.dart';
import 'package:stalc_alarm/core/exceptions/exceptions.dart';
import 'package:stalc_alarm/core/exceptions/failures.dart';
import 'package:stalc_alarm/core/network/network_info.dart';
import 'package:stalc_alarm/models/alert_model.dart';
import 'package:stalc_alarm/services/alarm_service.dart';


abstract class AlarmViewModel {
  Future<Either<Failure, List<AlertModel>>> getCurrentAlarm();
}

class AlarmViewModelImpl implements AlarmViewModel {
  final NetworkInfo networkInfo;
  final AlarmService service;
  AlarmViewModelImpl({required this.networkInfo, required this.service});

  @override
  Future<Either<Failure, List<AlertModel>>> getCurrentAlarm() async {
    if (await networkInfo.isConnected()) {
      try {
        final data = await service.getCurrentAlerts();
        return Right(data);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      return Left(InternetFailure());
    }
  }
}
