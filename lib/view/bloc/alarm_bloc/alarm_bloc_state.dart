import 'package:equatable/equatable.dart';
import '../../../core/exceptions/failures.dart';
import '../../../models/alert_model.dart';

abstract class AlarmBlocState extends Equatable {}

class InitState extends AlarmBlocState {
  @override
  List<Object?> get props => [];
}

class LoadingState extends AlarmBlocState {
  @override
  List<Object?> get props => [];
}

class LoadedState extends AlarmBlocState {
  final List<AlertModel> alarmList;

  /// ===== PUSH (для UI у foreground) =====
  final String? pushType;   // ALARM_START / ALARM_END
  final String? pushLevel;  // hromada / raion / oblast
  final String? pushName;   // назва
  final String? pushUid;    // topic

  /// ===== АКТИВНІ ГРОМАДИ =====
  /// topic -> name
  final Map<String, String> activeHromadas;

  LoadedState({
    required this.alarmList,
    this.pushType,
    this.pushLevel,
    this.pushName,
    this.pushUid,
    this.activeHromadas = const {},
  });

  LoadedState copyWith({
    List<AlertModel>? alarmList,
    String? pushType,
    String? pushLevel,
    String? pushName,
    String? pushUid,
    Map<String, String>? activeHromadas,
  }) {
    return LoadedState(
      alarmList: alarmList ?? this.alarmList,
      pushType: pushType ?? this.pushType,
      pushLevel: pushLevel ?? this.pushLevel,
      pushName: pushName ?? this.pushName,
      pushUid: pushUid ?? this.pushUid,
      activeHromadas: activeHromadas ?? this.activeHromadas,
    );
  }

  @override
  List<Object?> get props => [
        alarmList,
        pushType,
        pushLevel,
        pushName,
        pushUid,
        activeHromadas,
      ];
}

class ErrorState extends AlarmBlocState {
  final Failure failure;
  ErrorState({required this.failure});

  @override
  List<Object?> get props => [failure];
}
