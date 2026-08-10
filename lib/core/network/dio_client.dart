import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/env.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageServiceProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: Env.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ),
  );

  // Logger
  dio.interceptors.add(
    PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ),
  );

  // Authentication & Token Refresh
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.getAccessToken();

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },

      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final refreshToken = await storage.getRefreshToken();

          if (refreshToken != null && refreshToken.isNotEmpty) {
            try {
              final refreshResponse = await dio.post(
                ApiEndpoints.login,
                data: {'refreshToken': refreshToken},
              );

              final newAccessToken =
                  refreshResponse.data['accessToken'] as String?;

              final newRefreshToken =
                  refreshResponse.data['refreshToken'] as String?;

              if (newAccessToken != null && newAccessToken.isNotEmpty) {
                await storage.saveAccessToken(newAccessToken);

                if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
                  await storage.saveRefreshToken(newRefreshToken);
                }

                final requestOptions = error.requestOptions;

                requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';

                final retryResponse = await dio.fetch(requestOptions);

                return handler.resolve(retryResponse);
              }
            } catch (_) {
              await storage.clearTokens();
            }
          }
        }

        handler.next(error);
      },
    ),
  );

  return dio;
});
