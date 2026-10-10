import 'package:flutter/foundation.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_trending_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_upcoming_movies.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class HomeViewModel extends ChangeNotifier {
  final GetTrendingMovies getTrendingMovies;
  final GetPopularMovies getPopularMovies;
  final GetTopRatedMovies getTopRatedMovies;
  final GetUpcomingMovies getUpcomingMovies;

  HomeViewModel({
    required this.getTrendingMovies,
    required this.getPopularMovies,
    required this.getTopRatedMovies,
    required this.getUpcomingMovies,
  });

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<Movie> _trendingMovies = [];
  List<Movie> get trendingMovies => _filterByGenre(_trendingMovies);

  List<Movie> _popularMovies = [];
  List<Movie> get popularMovies => _filterByGenre(_popularMovies);

  List<Movie> _topRatedMovies = [];
  List<Movie> get topRatedMovies => _filterByGenre(_topRatedMovies);

  List<Movie> _upcomingMovies = [];
  List<Movie> get upcomingMovies => _filterByGenre(_upcomingMovies);

  // Genre Filtering
  int? _selectedGenreId;
  int? get selectedGenreId => _selectedGenreId;

  // Banner Movies for Hero Carousel (Top 5 trending)
  List<Movie> get bannerMovies => _trendingMovies.take(5).toList();

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isSuccess => _state == ViewState.success;
  bool get isOffline => _errorMessage.toLowerCase().contains('connection') || _errorMessage.toLowerCase().contains('offline');

  void selectGenre(int? genreId) {
    if (_selectedGenreId == genreId) {
      _selectedGenreId = null; // Toggle off
    } else {
      _selectedGenreId = genreId;
    }
    notifyListeners();
  }

  List<Movie> _filterByGenre(List<Movie> list) {
    if (_selectedGenreId == null) return list;
    return list.where((m) => m.genreIds.contains(_selectedGenreId)).toList();
  }

  Future<void> initHome() async {
    if (_state == ViewState.success && _trendingMovies.isNotEmpty) return;
    await fetchAllSections();
  }

  Future<void> fetchAllSections() async {
    _state = ViewState.loading;
    _errorMessage = '';
    notifyListeners();

    final results = await Future.wait([
      getTrendingMovies(page: 1),
      getPopularMovies(page: 1),
      getTopRatedMovies(page: 1),
      getUpcomingMovies(page: 1),
    ]);

    final trendingRes = results[0];
    final popularRes = results[1];
    final topRatedRes = results[2];
    final upcomingRes = results[3];

    bool anySuccess = false;

    trendingRes.fold(
      (failure) => _errorMessage = failure.message,
      (movies) {
        _trendingMovies = movies;
        anySuccess = true;
      },
    );

    popularRes.fold(
      (failure) => _errorMessage = _errorMessage.isEmpty ? failure.message : _errorMessage,
      (movies) {
        _popularMovies = movies;
        anySuccess = true;
      },
    );

    topRatedRes.fold(
      (failure) {},
      (movies) => _topRatedMovies = movies,
    );

    upcomingRes.fold(
      (failure) {},
      (movies) => _upcomingMovies = movies,
    );

    if (anySuccess) {
      _state = (_trendingMovies.isEmpty && _popularMovies.isEmpty)
          ? ViewState.empty
          : ViewState.success;
    } else {
      _state = ViewState.error;
    }

    notifyListeners();
  }

  Future<void> refreshAll() async {
    await fetchAllSections();
  }
}
