// core/exceptions/failure_mapper.dart
import 'exceptions.dart';
import 'failures.dart';

Failure mapExceptionToFailure(Object e) {
  if (e is RateLimitException) return RateLimitFailure(e.retryAfterSec);
  if (e is InternetException) return const InternetFailure();
  if (e is ServerException) return const ServerFailure();
  return const ServerFailure(); // fallback
}