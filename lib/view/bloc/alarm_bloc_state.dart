import 'package:equatable/equatable.dart';

import '../../core/exceptions/failures.dart';
import '../../models/alert_model.dart';

abstract class AlarmBlocState extends Equatable {}

class InitState extends AlarmBlocState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoadingState extends AlarmBlocState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoadedState extends AlarmBlocState {
  final List<AlertModel> alarmList;
  LoadedState({required this.alarmList});

  @override
  // TODO: implement props
  List<Object?> get props => [alarmList];
}

class ErrorState extends AlarmBlocState {
  final Failure failure;
  ErrorState({required this.failure});
  @override
  // TODO: implement props
  List<Object?> get props => [failure];
}
