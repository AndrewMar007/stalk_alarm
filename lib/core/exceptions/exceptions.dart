class ServerException implements Exception{}
class InternetException implements Exception{}
class RateLimitException implements Exception {
  final int retryAfterSec;
  RateLimitException(this.retryAfterSec);
}