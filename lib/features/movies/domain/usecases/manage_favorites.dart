import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetFavorites {
  final MovieRepository repository;

  GetFavorites(this.repository);

  Future<Either<Failure, List<Movie>>> call() async {
    return await repository.getFavorites();
  }
}

class AddFavorite {
  final MovieRepository repository;

  AddFavorite(this.repository);

  Future<Either<Failure, void>> call(Movie movie) async {
    return await repository.addFavorite(movie);
  }
}

class RemoveFavorite {
  final MovieRepository repository;

  RemoveFavorite(this.repository);

  Future<Either<Failure, void>> call(int movieId) async {
    return await repository.removeFavorite(movieId);
  }
}

class IsFavorite {
  final MovieRepository repository;

  IsFavorite(this.repository);

  Future<Either<Failure, bool>> call(int movieId) async {
    return await repository.isFavorite(movieId);
  }
}
