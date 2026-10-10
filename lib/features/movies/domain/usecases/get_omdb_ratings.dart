import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

class GetOmdbRatings {
  final MovieRepository repository;

  GetOmdbRatings(this.repository);

  Future<Either<Failure, OmdbRating?>> call({
    String? imdbId,
    String? title,
    String? year,
  }) async {
    return await repository.getOmdbRatings(
      imdbId: imdbId,
      title: title,
      year: year,
    );
  }
}
