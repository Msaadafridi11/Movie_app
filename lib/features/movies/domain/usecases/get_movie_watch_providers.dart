import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetMovieWatchProviders {
  final MovieRepository repository;

  GetMovieWatchProviders(this.repository);

  Future<Either<Failure, List<WatchProvider>>> call(int id, {bool isTv = false}) async {
    return await repository.getMovieWatchProviders(id, isTv: isTv);
  }
}
