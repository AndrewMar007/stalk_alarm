import 'package:equatable/equatable.dart';

class AlertModel extends Equatable{
  final int id;
  final String locationTitle;
  final String locationType;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final DateTime updatedAt;
  final String alertType;
  final String locationOblast;
  final String locationUid;
  final String? notes;
  final String? country;
  final DateTime? deletedAt;
  final bool? calculated;
  final int locationOblastUid;

  const AlertModel({
    required this.id,
    required this.locationTitle,
    required this.locationType,
    required this.startedAt,
    this.finishedAt,
    required this.updatedAt,
    required this.alertType,
    required this.locationOblast,
    required this.locationUid,
    this.notes,
    this.country,
    this.deletedAt,
    this.calculated,
    required this.locationOblastUid,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] as int,
      locationTitle: json['location_title'] as String,
      locationType: json['location_type'] as String,
      startedAt: DateTime.parse(json['started_at']),
      finishedAt: json['finished_at'] != null
          ? DateTime.parse(json['finished_at'])
          : null,
      updatedAt: DateTime.parse(json['updated_at']),
      alertType: json['alert_type'] as String,
      locationOblast: json['location_oblast'] as String,
      locationUid: json['location_uid'].toString(),
      notes: json['notes'] as String?,
      country: json['country'] as String?,
      deletedAt: json['deleted_at'] != null
          ? DateTime.parse(json['deleted_at'])
          : null,
      calculated: json['calculated'] as bool?,
      locationOblastUid: json['location_oblast_uid'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'location_title': locationTitle,
      'location_type': locationType,
      'started_at': startedAt.toIso8601String(),
      'finished_at': finishedAt?.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'alert_type': alertType,
      'location_oblast': locationOblast,
      'location_uid': locationUid,
      'notes': notes,
      'country': country,
      'deleted_at': deletedAt?.toIso8601String(),
      'calculated': calculated,
      'location_oblast_uid': locationOblastUid,
    };
  }
  
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
