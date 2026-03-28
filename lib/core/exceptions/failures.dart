import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  /// 🔑 ключ локалізації
  final String key;

  const Failure(this.key);

  @override
  List<Object?> get props => [key];
}

class ServerFailure extends Failure {
  const ServerFailure() : super('error_server');
}

class InternetFailure extends Failure {
  const InternetFailure() : super('error_no_internet');
}

class RateLimitFailure extends Failure {
  final int retryAfterSec;

  const RateLimitFailure(this.retryAfterSec)
      : super('error_rate_limit');

  @override
  List<Object?> get props => [key, retryAfterSec];
}