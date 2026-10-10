import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieTrailers {
  final MovieRepository repository;

  GetMovieTrailers(this.repository);

  Future<Either<Failure, List<Video>>> call(int id) async {
    return await repository.getMovieTrailers(id);
  }
}
