import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_trailers.dart';

class FakeVideoRepository implements MovieRepository {
  List<Video> videos = [];
  Failure? failure;
  int? lastCalledId;
  bool? lastCalledIsTv;

  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id, {bool isTv = false}) async {
    lastCalledId = id;
    lastCalledIsTv = isTv;
    if (failure != null) {
      return Left(failure!);
    }
    return Right(videos);
  }

  // Stubs for remaining unused repository methods
  @override
  Future<Either<Failure, List<Movie>>> getTrendingMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getUpcomingMovies({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getPopularTvShows({int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getDiscoverMovies({int? genreId, int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query, {int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> searchMulti(String query, {int page = 1}) async => const Right([]);
  @override
  Future<Either<Failure, Movie>> getMovieDetails(int id, {bool isTv = false}) async =>
      const Right(Movie(id: 1, title: '', overview: ''));
  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id, {bool isTv = false}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id, {bool isTv = false}) async => const Right([]);
  @override
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id, {bool isTv = false}) async => const Right([]);
  @override
  Future<Either<Failure, List<WatchProvider>>> getMovieWatchProviders(int id, {bool isTv = false}) async => const Right([]);
  @override
  Future<Either<Failure, List<String>>> getMovieImages(int id, {bool isTv = false}) async => const Right([]);
  @override
  Future<Either<Failure, OmdbRating?>> getOmdbRatings({String? imdbId, String? title, String? year}) async => const Right(null);
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
  late GetMovieTrailers useCase;
  late FakeVideoRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeVideoRepository();
    useCase = GetMovieTrailers(fakeRepository);
  });

  const tTrailerVideo = Video(
    id: 'vid1',
    key: 'dQw4w9WgXcQ',
    name: 'Official Trailer',
    site: 'YouTube',
    type: 'Trailer',
    official: true,
  );

  const tTeaserVideo = Video(
    id: 'vid2',
    key: 'abc123xyz',
    name: 'Teaser Trailer',
    site: 'YouTube',
    type: 'Teaser',
    official: true,
  );

  test('should return list of official YouTube videos for movie when repository succeeds', () async {
    // Arrange
    fakeRepository.videos = [tTrailerVideo, tTeaserVideo];

    // Act
    final result = await useCase(550, isTv: false);

    // Assert
    expect(result.isRight(), isTrue);
    expect(fakeRepository.lastCalledId, 550);
    expect(fakeRepository.lastCalledIsTv, false);
    result.fold(
      (failure) => fail('Expected Right but got Left($failure)'),
      (videos) {
        expect(videos.length, 2);
        expect(videos[0].isYouTube, isTrue);
        expect(videos[0].categoryBadge, 'TRAILER');
        expect(videos[0].thumbnailUrl, 'https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg');
        expect(videos[1].categoryBadge, 'TEASER');
      },
    );
  });

  test('should forward isTv flag correctly when fetching TV trailers', () async {
    // Arrange
    fakeRepository.videos = [tTrailerVideo];

    // Act
    final result = await useCase(1399, isTv: true);

    // Assert
    expect(result.isRight(), isTrue);
    expect(fakeRepository.lastCalledId, 1399);
    expect(fakeRepository.lastCalledIsTv, true);
  });

  test('should return failure when repository encounters server error', () async {
    // Arrange
    const tFailure = ServerFailure('Network connection failed', 500);
    fakeRepository.failure = tFailure;

    // Act
    final result = await useCase(550);

    // Assert
    expect(result.isLeft(), isTrue);
    result.fold(
      (failure) => expect(failure, tFailure),
      (videos) => fail('Expected Left but got Right($videos)'),
    );
  });
}
