import 'dart:async';

import 'package:dio/dio.dart';

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

/// Represents an API failure.
class ApiFailure {
  final String message;

  const ApiFailure(this.message);

  const factory ApiFailure.server(String message) = ServerFailure;

  const factory ApiFailure.network(String message) = NetworkFailure;

  const factory ApiFailure.unauthorized(String message) =
      UnauthorizedFailure;

  const factory ApiFailure.unknown(String message) = UnknownFailure;

  @override
  String toString() => message;
}

/// Server/API error.
class ServerFailure extends ApiFailure {
  const ServerFailure(String message) : super(message);
}

/// Network/connection error.
class NetworkFailure extends ApiFailure {
  const NetworkFailure(String message) : super(message);
}

/// Unauthorized/401 error.
class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure(String message) : super(message);
}

/// Unknown/unhandled error.
class UnknownFailure extends ApiFailure {
  const UnknownFailure(String message) : super(message);
}

/// Converts Dio exceptions into our [ApiFailure] types.
class NetworkExceptions {
  NetworkExceptions._();

  static ApiFailure getDioException(DioException exception) {
    // Connection / request timeout
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return const ApiFailure.network(
        'Request timeout. Please try again.',
      );
    }

    // Server returned an HTTP error
    if (exception.type == DioExceptionType.badResponse) {
      final statusCode = exception.response?.statusCode;

      final message = exception.response?.data is Map<String, dynamic>
          ? exception.response?.data['message']?.toString() ??
              exception.response?.statusMessage
          : exception.response?.statusMessage;

      if (statusCode == 401) {
        return ApiFailure.unauthorized(
          message ?? 'Unauthorized access.',
        );
      }

      return ApiFailure.server(
        message ?? 'Server error occurred.',
      );
    }

    // Request cancelled
    if (exception.type == DioExceptionType.cancel) {
      return const ApiFailure.network(
        'Request was cancelled.',
      );
    }

    // Unknown Dio error
    return ApiFailure.unknown(
      exception.message ?? 'Unexpected error occurred.',
    );
  }
}