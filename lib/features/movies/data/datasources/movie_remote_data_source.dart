import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/errors/exceptions.dart';
import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/features/movies/data/models/cast_model.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/data/models/video_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies({int page = 1});
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> getUpcomingMovies({int page = 1});
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
  Future<MovieModel> getMovieDetails(int id);
  Future<List<CastModel>> getMovieCredits(int id);
  Future<List<MovieModel>> getSimilarMovies(int id);
  Future<List<VideoModel>> getMovieTrailers(int id);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final DioClient dioClient;

  MovieRemoteDataSourceImpl(this.dioClient);

  @override
  Future<List<MovieModel>> getTrendingMovies({int page = 1}) async {
    final data = await dioClient.get(
      ApiConstants.trendingMovies,
      queryParameters: {'page': page},
    );
    return _parseMovies(data);
  }

  @override
  Future<List<MovieModel>> getPopularMovies({int page = 1}) async {
    final data = await dioClient.get(
      ApiConstants.popularMovies,
      queryParameters: {'page': page},
    );
    return _parseMovies(data);
  }

  @override
  Future<List<MovieModel>> getTopRatedMovies({int page = 1}) async {
    final data = await dioClient.get(
      ApiConstants.topRatedMovies,
      queryParameters: {'page': page},
    );
    return _parseMovies(data);
  }

  @override
  Future<List<MovieModel>> getUpcomingMovies({int page = 1}) async {
    final data = await dioClient.get(
      ApiConstants.upcomingMovies,
      queryParameters: {'page': page},
    );
    return _parseMovies(data);
  }

  @override
  Future<List<MovieModel>> searchMovies(String query, {int page = 1}) async {
    final data = await dioClient.get(
      ApiConstants.searchMovie,
      queryParameters: {'query': query, 'page': page},
    );
    return _parseMovies(data);
  }

  @override
  Future<MovieModel> getMovieDetails(int id) async {
    final data = await dioClient.get('${ApiConstants.movieDetails}/$id');
    if (data is Map<String, dynamic>) {
      return MovieModel.fromJson(data);
    }
    throw const ServerException('Invalid movie details response');
  }

  @override
  Future<List<CastModel>> getMovieCredits(int id) async {
    final data = await dioClient.get('${ApiConstants.movieDetails}/$id/credits');
    if (data is Map<String, dynamic> && data['cast'] is List) {
      final list = data['cast'] as List;
      return list
          .map((item) => CastModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  @override
  Future<List<MovieModel>> getSimilarMovies(int id) async {
    final data = await dioClient.get('${ApiConstants.movieDetails}/$id/similar');
    return _parseMovies(data);
  }

  @override
  Future<List<VideoModel>> getMovieTrailers(int id) async {
    final data = await dioClient.get('${ApiConstants.movieDetails}/$id/videos');
    if (data is Map<String, dynamic> && data['results'] is List) {
      final list = data['results'] as List;
      return list
          .map((item) => VideoModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  List<MovieModel> _parseMovies(dynamic data) {
    if (data is Map<String, dynamic> && data['results'] is List) {
      final list = data['results'] as List;
      return list
          .map((item) => MovieModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }
}
