class AlarmHistoryModel {
  final int id;
  final String locationTitle;
  final String locationType;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final DateTime updatedAt;
  final String alertType;
  final String locationUid;
  final String locationOblast;
  final String locationOblastUid;
  final String? notes;
  final DateTime? deletedAt;
  final bool? calculated;

  AlarmHistoryModel({
    required this.id,
    required this.locationTitle,
    required this.locationType,
    required this.startedAt,
    required this.finishedAt,
    required this.updatedAt,
    required this.alertType,
    required this.locationUid,
    required this.locationOblast,
    required this.locationOblastUid,
    required this.notes,
    required this.deletedAt,
    required this.calculated,
  });

  factory AlarmHistoryModel.fromJson(Map<String, dynamic> json) {
    return AlarmHistoryModel(
      id: json["id"],
      locationTitle: json["location_title"],
      locationType: json["location_type"],
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
      alertType: json["alert_type"],
      locationUid: json["location_uid"],
      locationOblast: json["location_oblast"],
      locationOblastUid: json["location_oblast_uid"].toString(),
      notes: json["notes"],
      deletedAt: json["deleted_at"],
      calculated: json["calculated"],
    );
  }
}
