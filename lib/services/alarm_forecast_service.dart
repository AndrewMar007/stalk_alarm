import 'package:dio/dio.dart';

import '../core/api_config/api_config.dart';
import '../core/exceptions/exceptions.dart';
import '../models/forecast_model.dart';

abstract class AlarmForecastService {
  Future<OblastForecastResponse> getForecast({
    required int oblastId,
  });
}

class AlarmForecastServiceImpl extends AlarmForecastService {
  final Dio client;

  AlarmForecastServiceImpl({required this.client});

  @override
  Future<OblastForecastResponse> getForecast({
    required int oblastId,
  }) async {
    try {
      final response = await client.get(
        "${ApiConfig.alarmsForecast}$oblastId",
      );

      return OblastForecastResponse.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;

      if (status == 429) {
        int retryAfter = 5;
        final data = e.response?.data;

        if (data is Map && data['retryAfterSec'] is num) {
          retryAfter = (data['retryAfterSec'] as num).toInt();
        }

        final raHeader = e.response?.headers.value('retry-after');
        final raParsed = int.tryParse(raHeader ?? '');
        if (raParsed != null && raParsed > 0) {
          retryAfter = raParsed;
        }

        throw RateLimitException(retryAfter);
      }

      if (status == 503) {
        throw ServerException();
      }

      if (status != null) {
        throw ServerException();
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          throw ServerException();

        case DioExceptionType.badCertificate:
        case DioExceptionType.badResponse:
        case DioExceptionType.cancel:
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          final message = (e.message ?? '').toLowerCase();

          if (message.contains('failed host lookup') ||
              message.contains('network is unreachable')) {
            throw InternetException();
          }

          throw ServerException();
      }
    } catch (_) {
      throw ServerException();
    }
  }
}