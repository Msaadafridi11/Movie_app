import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieImages {
  final MovieRepository repository;

  GetMovieImages(this.repository);

  Future<Either<Failure, List<String>>> call(int id, {bool isTv = false}) async {
    return await repository.getMovieImages(id, isTv: isTv);
  }
}
