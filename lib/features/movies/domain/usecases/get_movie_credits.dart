import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieCredits {
  final MovieRepository repository;

  GetMovieCredits(this.repository);

  Future<Either<Failure, List<Cast>>> call(int id) async {
    return await repository.getMovieCredits(id);
  }
}
