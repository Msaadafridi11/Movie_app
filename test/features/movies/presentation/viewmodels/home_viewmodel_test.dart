import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/get_discover_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_trailers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_tv_shows.dart';
import 'package:movie_app/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_trending_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_upcoming_movies.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/home_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';
import '../../../../helpers/test_mock_repository.dart';

void main() {
  late TestMockMovieRepository repo;
  late HomeViewModel viewModel;

  final tMovieAction = const Movie(
    id: 1,
    title: 'Action Movie',
    overview: 'An action movie overview',
    posterPath: '/action.jpg',
    backdropPath: '/action_back.jpg',
    voteAverage: 8.5,
    releaseDate: '2025-01-01',
    genreIds: [28], // Action
  );

  final tMovieComedy = const Movie(
    id: 2,
    title: 'Comedy Movie',
    overview: 'A comedy movie overview',
    posterPath: '/comedy.jpg',
    backdropPath: '/comedy_back.jpg',
    voteAverage: 7.0,
    releaseDate: '2025-02-01',
    genreIds: [35], // Comedy
  );

  setUp(() {
    repo = TestMockMovieRepository();
    repo.trendingMovies = [tMovieAction, tMovieComedy];
    repo.popularMovies = [tMovieAction];
    repo.topRatedMovies = [tMovieAction];
    repo.upcomingMovies = [tMovieComedy];
    repo.popularTvShows = [tMovieAction];

    viewModel = HomeViewModel(
      getTrendingMovies: GetTrendingMovies(repo),
      getPopularMovies: GetPopularMovies(repo),
      getTopRatedMovies: GetTopRatedMovies(repo),
      getUpcomingMovies: GetUpcomingMovies(repo),
      getPopularTvShows: GetPopularTvShows(repo),
      getDiscoverMovies: GetDiscoverMovies(repo),
      getMovieTrailers: GetMovieTrailers(repo),
    );
  });

  test('initial state should be ViewState.initial with default settings', () {
    expect(viewModel.state, ViewState.initial);
    expect(viewModel.isTvMode, false);
    expect(viewModel.selectedGenreId, isNull);
    expect(viewModel.isCarouselAutoplayMuted, true);
    expect(viewModel.isCarouselPreviewEnabled, false);
    expect(viewModel.trendingMovies, isEmpty);
  });

  test('fetchAllSections should populate movies and set state to success', () async {
    await viewModel.fetchAllSections();

    expect(viewModel.state, ViewState.success);
    expect(viewModel.trendingMovies.length, 2);
    expect(viewModel.popularMovies.length, 1);
    expect(viewModel.topRatedMovies.length, 1);
    expect(viewModel.upcomingMovies.length, 1);
    expect(viewModel.bannerMovies.length, 2);
  });

  test('selectGenre should filter movies by genre and toggle off when re-selected', () async {
    await viewModel.fetchAllSections();

    // Select Action genre (28)
    viewModel.selectGenre(28);
    expect(viewModel.selectedGenreId, 28);
    expect(viewModel.trendingMovies.length, 1);
    expect(viewModel.trendingMovies.first.id, 1);

    // Toggle off Action genre
    viewModel.selectGenre(28);
    expect(viewModel.selectedGenreId, isNull);
    expect(viewModel.trendingMovies.length, 2);
  });

  test('toggleTvMode should switch media tab and clear selected genre', () {
    viewModel.selectGenre(28);
    expect(viewModel.selectedGenreId, 28);

    viewModel.toggleTvMode(true);
    expect(viewModel.isTvMode, true);
    expect(viewModel.selectedGenreId, isNull);
  });

  test('toggleCarouselMute and toggleCarouselPreview should toggle flags', () {
    expect(viewModel.isCarouselAutoplayMuted, true);
    viewModel.toggleCarouselMute();
    expect(viewModel.isCarouselAutoplayMuted, false);

    expect(viewModel.isCarouselPreviewEnabled, false);
    viewModel.toggleCarouselPreview();
    expect(viewModel.isCarouselPreviewEnabled, true);
  });

  test('fetchAllSections should handle failure properly', () async {
    repo.failure = const ServerFailure('Failed to load server data');

    await viewModel.fetchAllSections();

    expect(viewModel.state, ViewState.error);
    expect(viewModel.errorMessage, 'Failed to load server data');
    expect(viewModel.hasError, true);
  });
}
