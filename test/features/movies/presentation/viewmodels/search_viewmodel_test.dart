import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/errors/failures.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/search_movies.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/search_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';
import '../../../../helpers/test_mock_repository.dart';

void main() {
  late TestMockMovieRepository repo;
  late SearchViewModel viewModel;

  final tMovie = const Movie(
    id: 101,
    title: 'Inception',
    overview: 'A thief who steals corporate secrets through dream-sharing technology.',
    posterPath: '/inception.jpg',
    backdropPath: '/inception_back.jpg',
    voteAverage: 8.8,
    releaseDate: '2010-07-16',
    genreIds: [28, 878], // Action, Sci-Fi
  );

  setUp(() {
    repo = TestMockMovieRepository();
    viewModel = SearchViewModel(searchMovies: SearchMovies(repo));
  });

  tearDown(() {
    viewModel.dispose();
  });

  test('initial state should be ViewState.initial and movies list empty', () {
    expect(viewModel.state, ViewState.initial);
    expect(viewModel.query, isEmpty);
    expect(viewModel.movies, isEmpty);
    expect(viewModel.hasMore, true);
    expect(viewModel.isLoading, false);
  });

  test('onQueryChanged with empty string should reset to initial state', () {
    viewModel.onQueryChanged('   ');
    expect(viewModel.state, ViewState.initial);
    expect(viewModel.query, isEmpty);
    expect(viewModel.movies, isEmpty);
  });

  test('onQueryChanged should trigger debounced search and update state to success', () async {
    repo.searchResults = [tMovie];

    viewModel.onQueryChanged('Inception');
    expect(viewModel.state, ViewState.loading);

    // Wait for debouncer (450ms)
    await Future.delayed(const Duration(milliseconds: 550));

    expect(viewModel.state, ViewState.success);
    expect(viewModel.movies.length, 1);
    expect(viewModel.movies.first.title, 'Inception');
    expect(viewModel.isSuccess, true);
  });

  test('onQueryChanged should update state to empty when search returns no movies', () async {
    repo.searchResults = [];

    viewModel.onQueryChanged('UnknownTitle123456');

    await Future.delayed(const Duration(milliseconds: 550));

    expect(viewModel.state, ViewState.empty);
    expect(viewModel.movies, isEmpty);
    expect(viewModel.isEmpty, true);
  });

  test('selectGenre should filter movies in search results', () async {
    repo.searchResults = [tMovie];
    viewModel.onQueryChanged('Inception');
    await Future.delayed(const Duration(milliseconds: 550));

    // Filter by matching genre (28)
    viewModel.selectGenre(28);
    expect(viewModel.movies.length, 1);

    // Filter by non-matching genre (35)
    viewModel.selectGenre(35);
    expect(viewModel.movies, isEmpty);

    // Toggle off filter
    viewModel.selectGenre(35);
    expect(viewModel.movies.length, 1);
  });

  test('clearSearch should reset all query, filter and state parameters', () async {
    repo.searchResults = [tMovie];
    viewModel.onQueryChanged('Inception');
    await Future.delayed(const Duration(milliseconds: 550));
    expect(viewModel.movies.length, 1);

    viewModel.clearSearch();
    expect(viewModel.query, isEmpty);
    expect(viewModel.movies, isEmpty);
    expect(viewModel.selectedGenreId, isNull);
    expect(viewModel.state, ViewState.initial);
  });

  test('onQueryChanged should transition to error state on failure', () async {
    repo.failure = const ConnectionFailure('No internet connection');

    viewModel.onQueryChanged('Batman');
    await Future.delayed(const Duration(milliseconds: 550));

    expect(viewModel.state, ViewState.error);
    expect(viewModel.errorMessage, 'No internet connection');
    expect(viewModel.hasError, true);
  });
}
