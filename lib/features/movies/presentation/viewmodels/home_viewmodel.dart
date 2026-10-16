import 'package:flutter/foundation.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/usecases/get_discover_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_trailers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_popular_tv_shows.dart';
import 'package:movie_app/features/movies/domain/usecases/get_top_rated_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_trending_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/get_upcoming_movies.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class HomeViewModel extends ChangeNotifier {
  final GetTrendingMovies getTrendingMovies;
  final GetPopularMovies getPopularMovies;
  final GetTopRatedMovies getTopRatedMovies;
  final GetUpcomingMovies getUpcomingMovies;
  final GetPopularTvShows getPopularTvShows;
  final GetDiscoverMovies getDiscoverMovies;
  final GetMovieTrailers getMovieTrailers;

  HomeViewModel({
    required this.getTrendingMovies,
    required this.getPopularMovies,
    required this.getTopRatedMovies,
    required this.getUpcomingMovies,
    required this.getPopularTvShows,
    required this.getDiscoverMovies,
    required this.getMovieTrailers,
  });

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  // Media Tab: Movies vs TV Shows
  bool _isTvMode = false;
  bool get isTvMode => _isTvMode;

  List<Movie> _trendingMovies = [];
  List<Movie> get trendingMovies => _filterByGenre(_trendingMovies);

  List<Movie> _popularMovies = [];
  List<Movie> get popularMovies => _filterByGenre(_popularMovies);

  List<Movie> _topRatedMovies = [];
  List<Movie> get topRatedMovies => _filterByGenre(_topRatedMovies);

  List<Movie> _upcomingMovies = [];
  List<Movie> get upcomingMovies => _filterByGenre(_upcomingMovies);

  List<Movie> _popularTv = [];
  List<Movie> get popularTv => _filterByGenre(_popularTv);

  // Latest Trailers section
  final Map<int, Video> _trailerMap = {};
  Map<int, Video> get trailerMap => _trailerMap;

  List<Movie> get latestTrailers {
    final list = _isTvMode ? _popularTv : _trendingMovies;
    return list.where((m) => _trailerMap.containsKey(m.id)).toList();
  }

  // Genre Filtering
  int? _selectedGenreId;
  int? get selectedGenreId => _selectedGenreId;

  // Carousel controls
  bool _isCarouselAutoplayMuted = true;
  bool get isCarouselAutoplayMuted => _isCarouselAutoplayMuted;

  bool _isCarouselPreviewEnabled = false;
  bool get isCarouselPreviewEnabled => _isCarouselPreviewEnabled;

  // Banner Movies for Hero Carousel (Top 6)
  List<Movie> get bannerMovies {
    final source = _isTvMode ? _popularTv : _trendingMovies;
    return source.take(6).toList();
  }

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;
  bool get isSuccess => _state == ViewState.success;
  bool get isOffline =>
      _errorMessage.toLowerCase().contains('connection') ||
      _errorMessage.toLowerCase().contains('offline');

  void toggleTvMode(bool tvMode) {
    if (_isTvMode == tvMode) return;
    _isTvMode = tvMode;
    _selectedGenreId = null;
    notifyListeners();
    if (_isTvMode && _popularTv.isEmpty) {
      fetchAllSections();
    }
  }

  void toggleCarouselPreview() {
    _isCarouselPreviewEnabled = !_isCarouselPreviewEnabled;
    notifyListeners();
  }

  void toggleCarouselMute() {
    _isCarouselAutoplayMuted = !_isCarouselAutoplayMuted;
    notifyListeners();
  }

  void selectGenre(int? genreId) {
    if (_selectedGenreId == genreId) {
      _selectedGenreId = null;
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
    if (_state == ViewState.success && (_trendingMovies.isNotEmpty || _popularTv.isNotEmpty)) {
      return;
    }
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
      getPopularTvShows(page: 1),
    ]);

    final trendingRes = results[0];
    final popularRes = results[1];
    final topRatedRes = results[2];
    final upcomingRes = results[3];
    final tvRes = results[4];

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
      (_) {},
      (movies) => _topRatedMovies = movies,
    );

    upcomingRes.fold(
      (_) {},
      (movies) => _upcomingMovies = movies,
    );

    tvRes.fold(
      (_) {},
      (tv) {
        _popularTv = tv;
        anySuccess = true;
      },
    );

    if (anySuccess) {
      _state = ViewState.success;
    } else {
      _state = ViewState.error;
    }
    notifyListeners();

    // Fetch trailers for top banner and trending movies in the background
    _loadTrailersForFeatured();
  }

  Future<void> _loadTrailersForFeatured() async {
    final moviesToFetch = _trendingMovies.take(10).toList();
    for (final movie in moviesToFetch) {
      if (!_trailerMap.containsKey(movie.id)) {
        final res = await getMovieTrailers(movie.id, isTv: movie.isTvShow);
        res.fold(
          (_) {},
          (videos) {
            Video? trailer;
            for (final v in videos) {
              if (v.isYouTube &&
                  v.key.isNotEmpty &&
                  !MovieDetailViewModel.sessionFailedVideoKeys.contains(v.key)) {
                if (v.isTrailer) {
                  trailer = v;
                  break;
                } else {
                  trailer ??= v;
                }
              }
            }
            if (trailer != null) {
              _trailerMap[movie.id] = trailer;
            }
          },
        );
      }
    }
    notifyListeners();
  }
}
