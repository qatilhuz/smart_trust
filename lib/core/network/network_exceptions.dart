import 'dart:async';

/// Result of an API call:
/// either [Success] or [Failure].
abstract class ApiResult<T> {
  const ApiResult();

  /// Creates a successful API result.
  const factory ApiResult.success(T data) = Success<T>;

  /// Creates a failed API result.
  const factory ApiResult.failure(ApiFailure failure) = Failure<T>;

  /// Pattern-match helper.
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T data) success,
    required FutureOr<R> Function(ApiFailure failure) failure,
  });
}

/// Successful API result.
class Success<T> extends ApiResult<T> {
  final T data;

  const Success(this.data);

  @override
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T data) success,
    required FutureOr<R> Function(ApiFailure failure) failure,
  }) {
    return success(data);
  }

  @override
  String toString() => 'Success($data)';
}

/// Failed API result.
class Failure<T> extends ApiResult<T> {
  final ApiFailure failure;

  const Failure(this.failure);

  @override
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T data) success,
    required FutureOr<R> Function(ApiFailure failure) failure,
  }) {
    return failure(this.failure);
  }

  @override
  String toString() => 'Failure($failure)';
}

/// Generic failure type for API errors.
class ApiFailure {
  final String message;

  const ApiFailure(this.message);

  @override
  String toString() => message;
}

class ServerFailure extends ApiFailure {
  const ServerFailure(String message) : super(message);
}

class NetworkFailure extends ApiFailure {
  const NetworkFailure(String message) : super(message);
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure(String message) : super(message);
}

class UnknownFailure extends ApiFailure {
  const UnknownFailure(String message) : super(message);
}