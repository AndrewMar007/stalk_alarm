import 'package:dio/dio.dart';
import 'package:stalc_alarm/core/exceptions/exceptions.dart';
import 'package:stalc_alarm/models/alarm_history_model.dart';

import '../core/api_config/api_config.dart';

abstract class AlarmHistoryService {
  Future<List<AlarmHistoryModel>> getAlarmHistory({
    required int oblastId,
    required int days,
  });
}

class AlarmHistoryServiceImpl extends AlarmHistoryService {
  final Dio client;
  AlarmHistoryServiceImpl({required this.client});
  List<AlarmHistoryModel> _convertMapToList(Object data) {
    List<AlarmHistoryModel> list = (data as List)
        .map((e) => AlarmHistoryModel.fromJson(e))
        .toList();
    return list;
  }

  @override
  Future<List<AlarmHistoryModel>> getAlarmHistory({
    required int oblastId,
    required int days,
  }) async {
    try {
           // final response = await client.get('/this-endpoint-does-not-exist');
      final response = await client.get(
        "${ApiConfig.alarmsHistory}$oblastId?days=$days",
      );
      final data = response.data['alerts'];
      return _convertMapToList(data);
    } on DioException catch (e) {
      // 1) Нема response -> інтернет/таймаут тощо
      if (e.response == null) {
        throw InternetException();
      }

      final status = e.response?.statusCode;

      // 2) 429 -> дістаємо retryAfterSec
      if (status == 429) {
        int retryAfter = 45; // fallback

        // a) з JSON (твій сервер віддає retryAfterSec)
        final data = e.response?.data;
        if (data is Map && data['retryAfterSec'] is num) {
          retryAfter = (data['retryAfterSec'] as num).toInt();
        }

        // b) або з header Retry-After
        final raHeader = e.response?.headers.value('retry-after');
        final raParsed = int.tryParse(raHeader ?? '');
        if (raParsed != null && raParsed > 0) {
          retryAfter = raParsed;
        }

        throw RateLimitException(retryAfter);
      }

      // 3) інші відповіді сервера
      throw ServerException();
    }
  }
}
