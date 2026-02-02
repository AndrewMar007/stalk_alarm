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
    // NetworkInfo може казати "connected", але інтернету по факту нема — тому catch все одно потрібен
    try {
      final connected = await networkInfo.isConnected();
      if (!connected) return const Left(InternetFailure());

      final data = await service.getCurrentAlerts();
      return Right(data);
    } on InternetException {
      return const Left(InternetFailure());
    } on ServerException {
      return const Left(ServerFailure());
    } catch (_) {
      // будь-які інші неочікувані помилки
      return const Left(ServerFailure());
    }
  }
}