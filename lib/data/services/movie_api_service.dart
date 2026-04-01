import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/core/constants/api_constants.dart';

class MovieApiService {
  final DioClient client;

  MovieApiService(this.client);

  Future<List<Results>> getPopularMovies() async {
    final response = await client.dio.get(
      "/movie/popular",
      queryParameters: {"api_key": ApiConstants.apiKey},
    );
    return (response.data['results'] as List).map((e) => Results.fromJson(e)).toList();
  }

  Future<List<Results>> getTrendingMovies() async {
    final response = await client.dio.get(
      "/trending/movie/day",
      queryParameters: {"api_key": ApiConstants.apiKey},
    );
    return (response.data['results'] as List).map((e) => Results.fromJson(e)).toList();
  }

  Future<List<Results>> getNowPlayingMovies() async {
    final response = await client.dio.get(
      "/movie/now_playing",
      queryParameters: {"api_key": ApiConstants.apiKey},
    );
    return (response.data['results'] as List).map((e) => Results.fromJson(e)).toList();
  }

  Future<List<Results>> getSimilarMovies(int id) async {
    final response = await client.dio.get(
      "/movie/$id/similar",
      queryParameters: {"api_key": ApiConstants.apiKey},
    );
    return (response.data['results'] as List).map((e) => Results.fromJson(e)).toList();
  }

  Future<List<Results>> searchMovies(String query) async {
    final response = await client.dio.get(
      "/search/movie",
      queryParameters: {
        "api_key": ApiConstants.apiKey,
        "query": query,
      },
    );
    return (response.data['results'] as List).map((e) => Results.fromJson(e)).toList();
  }
}