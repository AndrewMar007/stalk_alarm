import 'alarm_history_model.dart';
import 'risk_region_model.dart';

class OblastHistoryWithRiskResponse {
  final List<AlarmHistoryModel> alerts;
  final OblastRiskResponse? risk;
  final DateTime? updatedAt;
  final DateTime? historyUpdatedAt;

  OblastHistoryWithRiskResponse({
    required this.alerts,
    required this.risk,
    required this.updatedAt,
    required this.historyUpdatedAt,
  });

  factory OblastHistoryWithRiskResponse.fromJson(Map<String, dynamic> json) {
    final alertsRaw = json['alerts'];
    final List<AlarmHistoryModel> list = (alertsRaw is List)
        ? alertsRaw.map((e) => AlarmHistoryModel.fromJson(e)).toList()
        : <AlarmHistoryModel>[];

    final riskRaw = json['risk'];
    final OblastRiskResponse? risk =
        (riskRaw is Map<String, dynamic>)
            ? OblastRiskResponse.fromJson(riskRaw)
            : null;

    return OblastHistoryWithRiskResponse(
      alerts: list,
      risk: risk,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      historyUpdatedAt: json['historyUpdatedAt'] != null
          ? DateTime.tryParse(json['historyUpdatedAt'].toString())
          : null,
    );
  }
}