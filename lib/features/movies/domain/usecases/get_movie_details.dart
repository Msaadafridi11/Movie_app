import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieDetails {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  Future<Either<Failure, Movie>> call(int id, {bool isTv = false}) async {
    return await repository.getMovieDetails(id, isTv: isTv);
  }
}
