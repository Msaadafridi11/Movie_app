import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/errors/exceptions.dart';
import 'package:movie_app/core/network/dio_client.dart';
import 'package:movie_app/features/movies/data/models/cast_model.dart';
import 'package:movie_app/features/movies/data/models/movie_model.dart';
import 'package:movie_app/features/movies/data/models/omdb_rating_model.dart';
import 'package:movie_app/features/movies/data/models/video_model.dart';
import 'package:movie_app/features/movies/data/models/watch_provider_model.dart';

abstract class MovieRemoteDataSource {
  Future<List<MovieModel>> getTrendingMovies({int page = 1});
  Future<List<MovieModel>> getPopularMovies({int page = 1});
  Future<List<MovieModel>> getTopRatedMovies({int page = 1});
  Future<List<MovieModel>> getUpcomingMovies({int page = 1});
  Future<List<MovieModel>> getPopularTvShows({int page = 1});
  Future<List<MovieModel>> getDiscoverMovies({int? genreId, int page = 1});
  Future<List<MovieModel>> searchMovies(String query, {int page = 1});
  Future<List<MovieModel>> searchMulti(String query, {int page = 1});
  Future<MovieModel> getMovieDetails(int id, {bool isTv = false});
  Future<List<CastModel>> getMovieCredits(int id, {bool isTv = false});
  Future<List<MovieModel>> getSimilarMovies(int id, {bool isTv = false});
  Future<List<MovieModel>> getMovieRecommendations(int id, {bool isTv = false});
  Future<List<VideoModel>> getMovieTrailers(int id, {bool isTv = false});
  Future<List<WatchProviderModel>> getMovieWatchProviders(int id, {bool isTv = false});
  Future<List<String>> getMovieImages(int id, {bool isTv = false});
  Future<OmdbRatingModel?> getOmdbRatings({String? imdbId, String? title, String? year});
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
  Future<List<MovieModel>> getPopularTvShows({int page = 1}) async {
    final data = await dioClient.get(
      ApiConstants.popularTv,
      queryParameters: {'page': page},
    );
    return _parseMovies(data, isTv: true);
  }

  @override
  Future<List<MovieModel>> getDiscoverMovies({int? genreId, int page = 1}) async {
    final queryParams = <String, dynamic>{'page': page};
    if (genreId != null) {
      queryParams['with_genres'] = genreId;
    }
    final data = await dioClient.get(
      ApiConstants.discoverMovie,
      queryParameters: queryParams,
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
  Future<List<MovieModel>> searchMulti(String query, {int page = 1}) async {
    final data = await dioClient.get(
      ApiConstants.searchMulti,
      queryParameters: {'query': query, 'page': page},
    );
    return _parseMovies(data);
  }

  @override
  Future<MovieModel> getMovieDetails(int id, {bool isTv = false}) async {
    final endpoint = isTv ? ApiConstants.tvDetails : ApiConstants.movieDetails;
    final data = await dioClient.get('$endpoint/$id');
    if (data is Map<String, dynamic>) {
      return MovieModel.fromJson(data, isTv: isTv);
    }
    throw const ServerException('Invalid media details response');
  }

  @override
  Future<List<CastModel>> getMovieCredits(int id, {bool isTv = false}) async {
    final endpoint = isTv ? ApiConstants.tvDetails : ApiConstants.movieDetails;
    final data = await dioClient.get('$endpoint/$id/credits');
    if (data is Map<String, dynamic> && data['cast'] is List) {
      final list = data['cast'] as List;
      return list
          .map((item) => CastModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();
    }
    return [];
  }

  @override
  Future<List<MovieModel>> getSimilarMovies(int id, {bool isTv = false}) async {
    final endpoint = isTv ? ApiConstants.tvDetails : ApiConstants.movieDetails;
    final data = await dioClient.get('$endpoint/$id/similar');
    return _parseMovies(data, isTv: isTv);
  }

  @override
  Future<List<MovieModel>> getMovieRecommendations(int id, {bool isTv = false}) async {
    final endpoint = isTv ? ApiConstants.tvDetails : ApiConstants.movieDetails;
    final data = await dioClient.get('$endpoint/$id/recommendations');
    return _parseMovies(data, isTv: isTv);
  }

  @override
  Future<List<VideoModel>> getMovieTrailers(int id, {bool isTv = false}) async {
    final endpoint = isTv ? ApiConstants.tvDetails : ApiConstants.movieDetails;
    final data = await dioClient.get('$endpoint/$id/videos');
    if (data is Map<String, dynamic> && data['results'] is List) {
      final list = data['results'] as List;
      return list
          .map((item) => VideoModel.fromJson(Map<String, dynamic>.from(item as Map)))
          .where((v) => v.site.toLowerCase() == 'youtube' && v.key.isNotEmpty)
          .toList();
    }
    return [];
  }

  @override
  Future<List<WatchProviderModel>> getMovieWatchProviders(int id, {bool isTv = false}) async {
    final endpoint = isTv ? ApiConstants.tvDetails : ApiConstants.movieDetails;
    final data = await dioClient.get('$endpoint/$id/watch/providers');
    return WatchProviderModel.listFromTmdbResponse(data);
  }

  @override
  Future<List<String>> getMovieImages(int id, {bool isTv = false}) async {
    final endpoint = isTv ? ApiConstants.tvDetails : ApiConstants.movieDetails;
    final data = await dioClient.get('$endpoint/$id/images');
    if (data is Map<String, dynamic>) {
      final List<String> paths = [];
      final backdrops = data['backdrops'];
      if (backdrops is List) {
        for (final item in backdrops.take(8)) {
          if (item is Map && item['file_path'] != null) {
            paths.add(item['file_path'].toString());
          }
        }
      }
      final posters = data['posters'];
      if (posters is List) {
        for (final item in posters.take(8)) {
          if (item is Map && item['file_path'] != null) {
            paths.add(item['file_path'].toString());
          }
        }
      }
      return paths;
    }
    return [];
  }

  @override
  Future<OmdbRatingModel?> getOmdbRatings({String? imdbId, String? title, String? year}) async {
    // Fail silently if no OMDb key or no search parameters
    if (ApiConstants.omdbApiKey.isEmpty || ApiConstants.omdbApiKey == 'YOUR_OMDB_API_KEY_HERE') {
      return null;
    }

    try {
      final queryParams = <String, dynamic>{'apikey': ApiConstants.omdbApiKey};
      if (imdbId != null && imdbId.isNotEmpty) {
        queryParams['i'] = imdbId;
      } else if (title != null && title.isNotEmpty) {
        queryParams['t'] = title;
        if (year != null && year.isNotEmpty && year != 'N/A') {
          queryParams['y'] = year;
        }
      } else {
        return null;
      }

      final data = await dioClient.get(
        ApiConstants.omdbBaseUrl,
        queryParameters: queryParams,
      );

      if (data is Map<String, dynamic> && data['Response'] == 'True') {
        return OmdbRatingModel.fromJson(data);
      }
    } catch (_) {
      // Fail silently per requirement
    }
    return null;
  }

  List<MovieModel> _parseMovies(dynamic data, {bool isTv = false}) {
    if (data is Map<String, dynamic> && data['results'] is List) {
      final list = data['results'] as List;
      return list
          .whereType<Map>()
          .map((item) => MovieModel.fromJson(Map<String, dynamic>.from(item), isTv: isTv))
          .toList();
    }
    return [];
  }
}
