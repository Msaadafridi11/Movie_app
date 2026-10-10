import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetSimilarMovies {
  final MovieRepository repository;

  GetSimilarMovies(this.repository);

  Future<Either<Failure, List<Movie>>> call(int id, {bool isTv = false}) async {
    return await repository.getSimilarMovies(id, isTv: isTv);
  }
}
