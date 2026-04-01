import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/data/services/movie_api_service.dart';

class MovieRepository {
  final MovieApiService api;

  MovieRepository(this.api);

  Future<List<Results>> fetchPopularMovies() async => await api.getPopularMovies();
  Future<List<Results>> fetchTrendingMovies() async => await api.getTrendingMovies();
  Future<List<Results>> fetchNowPlayingMovies() async => await api.getNowPlayingMovies();
  Future<List<Results>> fetchSimilarMovies(int id) async => await api.getSimilarMovies(id);
  Future<List<Results>> searchMovies(String query) async => await api.searchMovies(query);
}