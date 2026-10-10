import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/errors/exceptions.dart';

/// Production-ready Dio client configured with TMDB headers, timeouts, and error interceptors
class DioClient {
  late final Dio dio;

  DioClient({Dio? customDio}) {
    dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Auto inject TMDB api_key if missing from queryParameters
          final currentQuery = Map<String, dynamic>.from(options.queryParameters);
          if (!currentQuery.containsKey('api_key') || currentQuery['api_key'] == null) {
            currentQuery['api_key'] = ApiConstants.apiKey;
          }
          options.queryParameters = currentQuery;
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (kDebugMode) {
            debugPrint('[Dio Error] [${e.requestOptions.path}] => ${e.message}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  /// Helper to unwrap GET calls and transform DioException into app exceptions
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw const ConnectionException('Network timeout or connection lost');
      } else if (e.response != null) {
        final message = e.response?.data is Map && e.response?.data['status_message'] != null
            ? e.response?.data['status_message'].toString()
            : 'Server error: ${e.response?.statusCode}';
        throw ServerException(message ?? 'Server error', e.response?.statusCode);
      } else {
        throw ServerException(e.message ?? 'Unknown network failure');
      }
    } catch (e) {
      if (e is ServerException || e is ConnectionException) rethrow;
      throw ServerException(e.toString());
    }
  }
}