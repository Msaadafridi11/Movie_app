import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';

/// Domain repository contract defining all movie and TV operations
abstract class MovieRepository {
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1});
  Future<Either<Failure, List<Movie>>> getPopularTvShows({int page = 1});
  Future<Either<Failure, List<Movie>>> getDiscoverMovies({int? genreId, int page = 1});
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1});
  Future<Either<Failure, List<Movie>>> searchMulti(String query, {int page = 1});
  Future<Either<Failure, Movie>> getMovieDetails(int id, {bool isTv = false});
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id, {bool isTv = false});
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id, {bool isTv = false});
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id, {bool isTv = false});
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id, {bool isTv = false});
  Future<Either<Failure, List<WatchProvider>>> getMovieWatchProviders(int id, {bool isTv = false});
  Future<Either<Failure, List<String>>> getMovieImages(int id, {bool isTv = false});
  Future<Either<Failure, OmdbRating?>> getOmdbRatings({String? imdbId, String? title, String? year});

  // Local Favorites
  Future<Either<Failure, List<Movie>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(Movie movie);
  Future<Either<Failure, void>> removeFavorite(int movieId);
  Future<Either<Failure, bool>> isFavorite(int movieId);
}
