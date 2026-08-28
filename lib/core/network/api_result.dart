import 'dart:async';

import 'package:dio/dio.dart';

abstract class ApiResult<T> {
  const ApiResult();

  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.failure(ApiFailure failure) = Failure<T>;

  FutureOr<R> when<R>({
    required FutureOr<R> Function(T data) success,
    required FutureOr<R> Function(ApiFailure failure) failure,
  });
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);

  @override
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T data) success,
    required FutureOr<R> Function(ApiFailure failure) failure,
  }) => success(data);

  @override
  String toString() => 'Success($data)';
}

class Failure<T> extends ApiResult<T> {
  final ApiFailure failure;
  const Failure(this.failure);

  @override
  FutureOr<R> when<R>({
    required FutureOr<R> Function(T data) success,
    required FutureOr<R> Function(ApiFailure failure) failure,
  }) => failure(this.failure);

  @override
  String toString() => 'Failure($failure)';
}

/// API failure retaining the backend ApiError fields for callers that need
/// field-level validation or diagnostic information.
class ApiFailure {
  final String message;
  final int? status;
  final String? error;
  final String? errorCode;
  final String? traceId;
  final Map<String, String> fieldErrors;

  const ApiFailure(
    this.message, {
    this.status,
    this.error,
    this.errorCode,
    this.traceId,
    this.fieldErrors = const <String, String>{},
  });

  const factory ApiFailure.server(String message, {
    int? status,
    String? error,
    String? errorCode,
    String? traceId,
    Map<String, String> fieldErrors,
  }) = ServerFailure;
  const factory ApiFailure.network(String message) = NetworkFailure;
  const factory ApiFailure.unauthorized(String message, {
    int? status,
    String? error,
    String? errorCode,
    String? traceId,
    Map<String, String> fieldErrors,
  }) = UnauthorizedFailure;
  const factory ApiFailure.unknown(String message) = UnknownFailure;

  @override
  String toString() => message;
}

class ServerFailure extends ApiFailure {
  const ServerFailure(
    String message, {
    super.status,
    super.error,
    super.errorCode,
    super.traceId,
    super.fieldErrors = const <String, String>{},
  }) : super(message);
}

class NetworkFailure extends ApiFailure {
  const NetworkFailure(String message) : super(message);
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure(
    String message, {
    super.status,
    super.error,
    super.errorCode,
    super.traceId,
    super.fieldErrors = const <String, String>{},
  }) : super(message);
}

class UnknownFailure extends ApiFailure {
  const UnknownFailure(String message) : super(message);
}

class NetworkExceptions {
  NetworkExceptions._();

  static ApiFailure getDioException(DioException exception) {
    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout) {
      return const ApiFailure.network('Request timeout. Please try again.');
    }

    if (exception.type == DioExceptionType.badResponse) {
      final response = exception.response;
      final status = response?.statusCode;
      final body = response?.data;
      final json = body is Map ? Map<String, dynamic>.from(body) : null;
      final fieldErrors = <String, String>{};
      final rawFields = json?['fieldErrors'];
      if (rawFields is Map) {
        rawFields.forEach((key, value) {
          if (value != null) fieldErrors[key.toString()] = value.toString();
        });
      }
      final message = json?['message']?.toString() ??
          response?.statusMessage ??
          'Server error occurred.';
      final details = <String, Object?>{
        'status': status,
        'error': json?['error']?.toString(),
        'errorCode': json?['errorCode']?.toString(),
        'traceId': json?['traceId']?.toString(),
        'fieldErrors': fieldErrors,
      };
      if (status == 401) {
        return UnauthorizedFailure(message,
            status: details['status'] as int?,
            error: details['error'] as String?,
            errorCode: details['errorCode'] as String?,
            traceId: details['traceId'] as String?,
            fieldErrors: fieldErrors);
      }
      return ServerFailure(message,
          status: status,
          error: details['error'] as String?,
          errorCode: details['errorCode'] as String?,
          traceId: details['traceId'] as String?,
          fieldErrors: fieldErrors);
    }

    if (exception.type == DioExceptionType.cancel) {
      return const ApiFailure.network('Request was cancelled.');
    }
    return ApiFailure.unknown(exception.message ?? 'Unexpected error occurred.');
  }
}
