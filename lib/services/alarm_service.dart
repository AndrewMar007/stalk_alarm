import 'package:dio/dio.dart';
import '../core/api_config/api_config.dart';
import '../core/exceptions/exceptions.dart';
import '../models/alert_model.dart';

abstract class AlarmService {
  Future<List<AlertModel>> getCurrentAlerts();
}

class AlarmServiceImpl extends AlarmService {
  final Dio client;
  AlarmServiceImpl({required this.client});

  List<AlertModel> _convertMapToList(Object data) {
    List<AlertModel> list = (data as List)
        .map((e) => AlertModel.fromJson(e))
        .toList();
    return list;
  }

  @override
  Future<List<AlertModel>> getCurrentAlerts() async {
    try {
      final response = await client.get(ApiConfig.alarms);
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
