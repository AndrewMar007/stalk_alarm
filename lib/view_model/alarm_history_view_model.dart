
import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import '../core/exceptions/failure_mapper.dart';
import '../core/exceptions/failures.dart';
import '../core/network/network_info.dart';
import '../models/oblast_history_with_risk_response.dart';
import '../services/alarm_history_service.dart';

abstract class AlarmHistoryViewModel {
  Future<Either<Failure, OblastHistoryWithRiskResponse>>
  getAlarmHistoryWithRisk({required int oblastId, required int days});
}

class AlarmHistoryViewModelImpl implements AlarmHistoryViewModel {
  final NetworkInfo networkInfo;
  final AlarmHistoryService service;

  AlarmHistoryViewModelImpl({required this.networkInfo, required this.service});

  @override
  Future<Either<Failure, OblastHistoryWithRiskResponse>>
  getAlarmHistoryWithRisk({required int oblastId, required int days}) async {
    try {
      // ✅ На мобілці — перевірка інтернету, на WEB можна пропустити (як було у тебе)
      if (!kIsWeb) {
        final connected = await networkInfo.isConnected();
        if (!connected) return const Left(InternetFailure());
      }

      final data = await service.getAlarmHistoryWithRisk(
        oblastId: oblastId,
        days: days,
      );

      return Right(data);
    } catch (e) {
      return Left(mapExceptionToFailure(e));
    }
  }
}
