import 'package:dio/dio.dart';

class DioClient{
  final Dio dio = Dio(
      BaseOptions(
        baseUrl: "https://api.themoviedb.org/3",
      )
  );
}