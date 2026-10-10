import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/get_trending_movies.dart';

/// Fake repository for isolated unit testing
class FakeMovieRepository implements MovieRepository {
  List<Movie> trendingMovies = [];
  Failure? failure;

  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1}) async {
    if (failure != null) {
      return Left(failure!);
    }
    return Right(trendingMovies);
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1}) async =>
      const Right([]);

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int id) async =>
      Right(trendingMovies.first);

  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Movie>>> getFavorites() async => const Right([]);

  @override
  Future<Either<Failure, void>> addFavorite(Movie movie) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeFavorite(int movieId) async => const Right(null);

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async => const Right(false);
}

void main() {
  late GetTrendingMovies useCase;
  late FakeMovieRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeMovieRepository();
    useCase = GetTrendingMovies(fakeRepository);
  });

  const tMovie = Movie(
    id: 101,
    title: 'Inception',
    overview: 'A thief who steals corporate secrets through dream-sharing.',
    voteAverage: 8.8,
  );

  test('should return list of movies when repository succeeds', () async {
    // Arrange
    fakeRepository.trendingMovies = [tMovie];

    // Act
    final result = await useCase(page: 1);

    // Assert
    expect(result.isRight(), isTrue);
    result.fold(
      (failure) => fail('Expected Right but got Left($failure)'),
      (movies) => expect(movies, [tMovie]),
    );
  });

  test('should return ServerFailure when repository fails', () async {
    // Arrange
    const tFailure = ServerFailure('Server unreachable', 500);
    fakeRepository.failure = tFailure;

    // Act
    final result = await useCase(page: 1);

    // Assert
    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, tFailure),
      (movies) => fail('Expected Left but got Right($movies)'),
    );
  });
}
