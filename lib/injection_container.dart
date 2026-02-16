import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:stalc_alarm/core/api_config/api_config.dart';
import 'package:stalc_alarm/core/network/network_info.dart';
import 'package:stalc_alarm/services/alarm_history_service.dart';
import 'package:stalc_alarm/services/alarm_service.dart';
import 'package:stalc_alarm/use_cases/get_alarm_history.dart';
import 'package:stalc_alarm/use_cases/get_current_alarm.dart';
import 'package:stalc_alarm/view_model/alarm_history_view_model.dart';
import 'package:stalc_alarm/view_model/alarm_view_model.dart';

import 'core/network/internet_guard.dart';
import 'device_id_provider.dart';

final sl = GetIt.instance;
Future<void> init() async {
  //! Use Cases
  sl.registerLazySingleton(() => GetCurrentAlarm(alarmViewModel: sl()));
  sl.registerLazySingleton(() => GetAlarmHistory(alarmHistoryViewModel: sl()));
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  //! Service
  sl.registerLazySingleton<AlarmService>(() => AlarmServiceImpl(client: sl()));
  sl.registerLazySingleton<AlarmHistoryService>(
    () => AlarmHistoryServiceImpl(client: sl()),
  );
  //! ViewModel
  sl.registerLazySingleton<AlarmViewModel>(
    () => AlarmViewModelImpl(networkInfo: sl(), service: sl()),
  );
  sl.registerLazySingleton<AlarmHistoryViewModel>(
    () => AlarmHistoryViewModelImpl(networkInfo: sl(), service: sl()),
  );

  //! Dio settings
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {"X-Client-Key": ApiConfig.clientKey},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final deviceId = await DeviceIdProvider.get();
          options.headers['X-Device-Id'] = deviceId;
          handler.next(options);
        },
      ),
    );

    return dio;
  });
  //! Internet Guard (singleton)
 sl.registerLazySingleton<InternetGuard>(() => InternetGuard(
  healthUrl: 'https://stalk-alarm-proxy-api.onrender.com/health',
));
}
