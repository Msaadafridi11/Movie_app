import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/data/services/movie_api_service.dart';

class MovieRepository {
  final MovieApiService api;

  MovieRepository(this.api);

  Future<List<Results>> fetchMovies() async {
    return await api.getMovie();
  }
}