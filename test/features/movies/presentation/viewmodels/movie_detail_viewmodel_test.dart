import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';
import 'package:movie_app/features/movies/domain/repositories/movie_repository.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_credits.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_images.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_recommendations.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_trailers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_watch_providers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_omdb_ratings.dart';
import 'package:movie_app/features/movies/domain/usecases/get_similar_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/manage_favorites.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class MockMovieRepository implements MovieRepository {
  final Movie testMovie = const Movie(
    id: 101,
    title: 'Interstellar',
    overview: 'A team of explorers travel through a wormhole in space.',
    voteAverage: 8.6,
  );

  final List<Video> testVideos = const [
    Video(
      id: 'v1',
      key: 'zSWdZVtXT7E',
      name: 'Official Trailer 1',
      site: 'YouTube',
      type: 'Trailer',
    ),
    Video(
      id: 'v2',
      key: '2LqzF5WauAw',
      name: 'Teaser',
      site: 'YouTube',
      type: 'Teaser',
    ),
    Video(
      id: 'v3',
      key: 'abc999',
      name: 'Science Behind Interstellar',
      site: 'YouTube',
      type: 'Behind the Scenes',
    ),
    Video(
      id: 'v4',
      key: 'clip123',
      name: 'Docking Scene Clip',
      site: 'YouTube',
      type: 'Clip',
    ),
  ];

  @override
  Future<Either<Failure, Movie>> getMovieDetails(int id, {bool isTv = false}) async =>
      Right(testMovie);

  @override
  Future<Either<Failure, List<Video>>> getMovieTrailers(int id, {bool isTv = false}) async =>
      Right(testVideos);

  @override
  Future<Either<Failure, List<Cast>>> getMovieCredits(int id, {bool isTv = false}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Movie>>> getSimilarMovies(int id, {bool isTv = false}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id, {bool isTv = false}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<WatchProvider>>> getMovieWatchProviders(int id, {bool isTv = false}) async =>
      const Right([]);

  @override
  Future<Either<Failure, List<String>>> getMovieImages(int id, {bool isTv = false}) async =>
      const Right(['https://image.tmdb.org/t/p/w780/interstellar_backdrop.jpg']);

  @override
  Future<Either<Failure, OmdbRating?>> getOmdbRatings({String? imdbId, String? title, String? year}) async =>
      const Right(OmdbRating(imdbRating: '8.7', rottenTomatoesRating: '73%', metascore: '74'));

  @override
  Future<Either<Failure, bool>> isFavorite(int movieId) async => const Right(false);

  @override
  Future<Either<Failure, void>> addFavorite(Movie movie) async => const Right(null);

  @override
  Future<Either<Failure, void>> removeFavorite(int movieId) async => const Right(null);

  @override
  Future<Either<Failure, List<Movie>>> getFavorites() async => const Right([]);
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
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MovieDetailViewModel viewModel;
  late MockMovieRepository repository;

  setUp(() {
    repository = MockMovieRepository();
    viewModel = MovieDetailViewModel(
      getMovieDetails: GetMovieDetails(repository),
      getMovieCredits: GetMovieCredits(repository),
      getSimilarMovies: GetSimilarMovies(repository),
      getMovieRecommendations: GetMovieRecommendations(repository),
      getMovieTrailers: GetMovieTrailers(repository),
      getMovieWatchProviders: GetMovieWatchProviders(repository),
      getMovieImages: GetMovieImages(repository),
      getOmdbRatings: GetOmdbRatings(repository),
      isFavoriteUseCase: IsFavorite(repository),
      addFavoriteUseCase: AddFavorite(repository),
      removeFavoriteUseCase: RemoveFavorite(repository),
    );
  });

  const tMovie = Movie(
    id: 101,
    title: 'Interstellar',
    overview: 'A team of explorers travel through a wormhole in space.',
    voteAverage: 8.6,
  );

  test('initial state should be ViewState.initial and video playlist empty', () {
    expect(viewModel.state, ViewState.initial);
    expect(viewModel.allVideos, isEmpty);
    expect(viewModel.isInlinePlayerActive, isFalse);
    expect(viewModel.isMuted, isFalse);
  });

  test('loadMovie should populate movie, categorize videos, and set success state', () async {
    await viewModel.loadMovie(tMovie);

    expect(viewModel.state, ViewState.success);
    expect(viewModel.movie?.title, 'Interstellar');
    expect(viewModel.allVideos.length, 4);
    expect(viewModel.allVideos.where((v) => v.isTrailer).length, 1);
    expect(viewModel.allVideos.where((v) => v.isTrailer).first.name, 'Official Trailer 1');
    expect(viewModel.allVideos.where((v) => v.isTeaser).length, 1);
    expect(viewModel.allVideos.where((v) => v.isBehindTheScenes).length, 1);
    expect(viewModel.allVideos.where((v) => v.isClip).length, 1);
    expect(viewModel.galleryImages.isNotEmpty, isTrue);
  });

  test('toggleMute should toggle isMuted flag and notify listeners', () {
    expect(viewModel.isMuted, isFalse);
    viewModel.toggleMute();
    expect(viewModel.isMuted, isTrue);
    viewModel.toggleMute();
    expect(viewModel.isMuted, isFalse);
  });

  test('closeInlinePlayer should set isInlinePlayerActive to false', () async {
    await viewModel.loadMovie(tMovie);
    viewModel.startVideoPlayback(0);
    expect(viewModel.isInlinePlayerActive, isTrue);

    viewModel.closeInlinePlayer();
    expect(viewModel.isInlinePlayerActive, isFalse);
  });
}
