import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:stalc_alarm/core/api_config/api_config.dart';
import 'package:stalc_alarm/core/network/network_info.dart';
import 'package:stalc_alarm/services/alarm_service.dart';
import 'package:stalc_alarm/use_cases/get_current_alarm.dart';
import 'package:stalc_alarm/view_model/alarm_view_model.dart';


final sl = GetIt.instance;
Future<void> init() async {
  //! Use Cases
  sl.registerLazySingleton(() => GetCurrentAlarm(alarmViewModel: sl()));
  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  //! Service
  sl.registerLazySingleton<AlarmService>(() => AlarmServiceImpl(client: sl()));
  //! ViewModel
  sl.registerLazySingleton<AlarmViewModel>(
    () => AlarmViewModelImpl(networkInfo: sl(), service: sl()),
  );

  //! Dio settings
  sl.registerLazySingleton(
    () => Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {"X-Client-Key": ApiConfig.clientKey},
      ),
    ),
  );
}
