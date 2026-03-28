import 'package:fpdart/fpdart.dart';
import 'package:stalc_alarm/core/network/network_info.dart';

import '../core/exceptions/failure_mapper.dart';
import '../core/exceptions/failures.dart';
import '../models/forecast_model.dart';
import '../services/alarm_forecast_service.dart';

abstract class AlarmForecastViewModel {
  Future<Either<Failure, OblastForecastResponse>> getForecast({
    required int oblastId,
  });
}

class AlarmForecastViewModelImpl implements AlarmForecastViewModel {
  final NetworkInfo networkInfo;
  final AlarmForecastService service;
  AlarmForecastViewModelImpl({required this.service, required this.networkInfo});

  @override
  Future<Either<Failure, OblastForecastResponse>> getForecast({
    required int oblastId,
  }) async {
    try {
      final connected = await networkInfo.isConnected();
      if (!connected) return const Left(InternetFailure());
      final data = await service.getForecast(oblastId: oblastId);
      return Right(data);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
