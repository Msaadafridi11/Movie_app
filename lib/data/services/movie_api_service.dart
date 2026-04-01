import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/core/constants/api_constants.dart';

class MovieApiService {

  final DioClient client = DioClient();

  Future<List<Results>> getMovie() async {
    final response = await client.dio.get(
      "/movie/popular",
      queryParameters: {
        "api_key": ApiConstants.apiKey,
      },
    );
    return (response.data['results'] as List)
        .map((e) => Results.fromJson(e))
        .toList();
  }
}
