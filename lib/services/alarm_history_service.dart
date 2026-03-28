import 'package:dio/dio.dart';

import '../core/api_config/api_config.dart';
import '../core/exceptions/exceptions.dart';
import '../models/oblast_history_with_risk_response.dart';

abstract class AlarmHistoryService {
  Future<OblastHistoryWithRiskResponse> getAlarmHistoryWithRisk({
    required int oblastId,
    required int days, // для UI (ти шлеш 3, але сервер і так дасть 3)
  });
}

class AlarmHistoryServiceImpl extends AlarmHistoryService {
  final Dio client;
  AlarmHistoryServiceImpl({required this.client});

  @override
  Future<OblastHistoryWithRiskResponse> getAlarmHistoryWithRisk({
    required int oblastId,
    required int days,
  }) async {
    try {
      final response = await client.get(
        "${ApiConfig.alarmsHistory}$oblastId",
        queryParameters: {"days": days},
      );

      return OblastHistoryWithRiskResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      if (e.response == null) throw InternetException();

      final status = e.response?.statusCode;
      if (status == 429) {
        int retryAfter = 5;
        final data = e.response?.data;
        if (data is Map && data['retryAfterSec'] is num) {
          retryAfter = (data['retryAfterSec'] as num).toInt();
        }

        final raHeader = e.response?.headers.value('retry-after');
        final raParsed = int.tryParse(raHeader ?? '');
        if (raParsed != null && raParsed > 0) retryAfter = raParsed;

        throw RateLimitException(retryAfter);
      }

      throw ServerException();
    }
  }
}