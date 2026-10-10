import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';

/// Domain repository contract defining all movie operations
abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1});
  Future<Either<Failure, Movie>> getMovieDetails(int id);
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id);
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id);
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id);

  // Local Favorites
  Future<Either<Failure, List<Movie>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(Movie movie);
  Future<Either<Failure, void>> removeFavorite(int movieId);
  Future<Either<Failure, bool>> isFavorite(int movieId);
}
