/// Custom exceptions thrown by data sources
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  const ServerException([this.message = 'Server Error', this.statusCode]);

  @override
  String toString() => 'ServerException: $message ($statusCode)';
}

class ConnectionException implements Exception {
  final String message;

  const ConnectionException([this.message = 'No Internet Connection']);

  @override
  String toString() => 'ConnectionException: $message';
}

class CacheException implements Exception {
  final String message;

  const CacheException([this.message = 'Cache Error']);

  @override
  String toString() => 'CacheException: $message';
}
