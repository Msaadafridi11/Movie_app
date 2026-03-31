

import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/data/models/movie_model.dart';

class MovieApiService {

  final DioClient client = DioClient();

  Future<List<Movie>> getMovie()async{
    final responce = await client.dio.get(
      "/movie/popular",
      queryParameters: {
        "api_key": "3515b162a118a2f065ef8001ad281b27",
      },
    );
    return (responce.data['results'] as List)th
        .map((e) => Movie.fromJson(e))
        .toList();
  }
}