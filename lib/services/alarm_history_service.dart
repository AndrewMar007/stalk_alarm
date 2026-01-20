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
      final response = await client.get("${ApiConfig.alarmsHistory}$oblastId?days=$days");
      final data = response.data['alerts'];
      return _convertMapToList(data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerException();
      } else {
        throw InternetException();
      }
    }
  }
}
