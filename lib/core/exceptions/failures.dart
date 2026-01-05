import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure() : super('Server Failure');
  @override
  List<Object?> get props => [];
}

class InternetFailure extends Failure {
  const InternetFailure() : super('Internet Failure');
  @override
  List<Object?> get props => [];
}
