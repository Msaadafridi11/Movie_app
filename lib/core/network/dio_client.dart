import 'package:dio/dio.dart';
import 'package:movie_app/core/constants/api_constants.dart';

class DioClient{
  final Dio dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
      )
  );
}