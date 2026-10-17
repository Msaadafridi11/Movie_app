import 'package:dartz/dartz.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';

/// Reusable mock repository for all domain and presentation unit tests
class TestMockMovieRepository implements MovieRepository {
  List<Movie> trendingMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> topRatedMovies = [];
  List<Movie> upcomingMovies = [];
  List<Movie> popularTvShows = [];
  List<Movie> searchResults = [];
  List<Movie> multiSearchResults = [];
  List<Movie> favoriteMovies = [];
  Movie? singleMovie;
  List<Cast> credits = [];
  List<Movie> similarMovies = [];
  List<Movie> recommendations = [];
  List<Video> trailers = [];
  List<WatchProvider> watchProviders = [];
  List<String> images = [];
  OmdbRating? omdbRating;
  Failure? failure;

  int? lastRequestedId;
  bool? lastRequestedIsTv;

  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1}) async =>
      failure != null ? Left(failure!) : Right(trendingMovies);

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async =>
      failure != null ? Left(failure!) : Right(popularMovies);

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async =>
      failure != null ? Left(failure!) : Right(topRatedMovies);

  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1}) async =>
      failure != null ? Left(failure!) : Right(upcomingMovies);

  @override
  Future<Either<Failure, List<Movie>>> getPopularTvShows({int page = 1}) async =>
      failure != null ? Left(failure!) : Right(popularTvShows);

  @override
  Future<Either<Failure, List<Movie>>> getDiscoverMovies({int? genreId, int page = 1}) async =>
      failure != null ? Left(failure!) : Right(trendingMovies);

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1}) async =>
      failure != null ? Left(failure!) : Right(searchResults);

  @override
  Future<Either<Failure, List<Movie>>> searchMulti(String query, {int page = 1}) async =>
      failure != null ? Left(failure!) : Right(multiSearchResults.isNotEmpty ? multiSearchResults : searchResults);

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int id, {bool isTv = false}) async {
    lastRequestedId = id;
    lastRequestedIsTv = isTv;
    if (failure != null) return Left(failure!);
    return Right(singleMovie ?? (trendingMovies.isNotEmpty ? trendingMovies.first : Movie(id: id, title: 'Test Movie', overview: 'Overview')));
  }

  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id, {bool isTv = false}) async =>
      failure != null ? Left(failure!) : Right(credits);

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id, {bool isTv = false}) async =>
      failure != null ? Left(failure!) : Right(similarMovies);

  @override
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id, {bool isTv = false}) async =>
      failure != null ? Left(failure!) : Right(recommendations);

  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id, {bool isTv = false}) async =>
      failure != null ? Left(failure!) : Right(trailers);

  @override
  Future<Either<Failure, List<WatchProvider>>> getMovieWatchProviders(int id, {bool isTv = false}) async =>
      failure != null ? Left(failure!) : Right(watchProviders);

  @override
  Future<Either<Failure, List<String>>> getMovieImages(int id, {bool isTv = false}) async =>
      failure != null ? Left(failure!) : Right(images);

  @override
  Future<Either<Failure, OmdbRating?>> getOmdbRatings({String? imdbId, String? title, String? year}) async =>
      failure != null ? Left(failure!) : Right(omdbRating);

  @override
  Future<Either<Failure, List<Movie>>> getFavorites() async =>
      failure != null ? Left(failure!) : Right(favoriteMovies);

  @override
  Future<Either<Failure, void>> addFavorite(Movie movie) async {
    if (failure != null) return Left(failure!);
    favoriteMovies.add(movie);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int movieId) async {
    if (failure != null) return Left(failure!);
    favoriteMovies.removeWhere((m) => m.id == movieId);
    return const Right(null);
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async =>
      failure != null ? Left(failure!) : Right(favoriteMovies.any((m) => m.id == movieId));
}
