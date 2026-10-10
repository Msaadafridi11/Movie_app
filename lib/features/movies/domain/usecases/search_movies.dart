import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class SearchMovies {
  final MovieRepository repository;

  SearchMovies(this.repository);

  Future<Either<Failure, List<Movie>>> call(
    String query, {
    int page = 1,
    bool multi = true,
  }) async {
    if (multi) {
      return await repository.searchMulti(query, page: page);
    }
    return await repository.searchMovies(query, page: page);
  }
}
