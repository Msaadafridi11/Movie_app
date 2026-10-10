import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetUpcomingMovies {
  final MovieRepository repository;

  GetUpcomingMovies(this.repository);

  Future<Either<Failure, List<Movie>>> call({int page = 1}) async {
    return await repository.getUpcomingMovies(page: page);
  }
}
