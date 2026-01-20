
import 'package:stalc_alarm/core/api_config/env.dart';

class ApiConfig{
  static String get baseUrl => Env.baseUrl;

  static const alarmsHistory = "/alerts/history/";
  static const alarms = "/alerts/active";
  static const clientKey = "ac18da70d4d01893bc6b1d179363888e403718250bf1e28b8ec890b6ef7517f3";
}