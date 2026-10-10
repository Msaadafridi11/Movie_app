/// Failure classes for functional error handling with `Either<Failure, T>`
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure &&
          runtimeType == other.runtimeType &&
          message == other.message &&
          statusCode == other.statusCode;

  @override
  int get hashCode => message.hashCode ^ statusCode.hashCode;

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

/// Returned when remote API call fails
class ServerFailure extends Failure {
  const ServerFailure([
    super.message = 'Server encountered an error. Please try again.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// Returned when device is offline or socket connection fails
class ConnectionFailure extends Failure {
  const ConnectionFailure([
    super.message = 'No internet connection. Please check your network and retry.',
  ]);
}

/// Returned when local storage / cache read/write fails
class CacheFailure extends Failure {
  const CacheFailure([
    super.message = 'Failed to load local cache.',
  ]);
}

/// Returned when JSON or data formatting is invalid
class FormatFailure extends Failure {
  const FormatFailure([
    super.message = 'Invalid data received from service.',
  ]);
}
