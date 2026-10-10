import 'package:flutter/foundation.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_credits.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_trailers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_similar_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/manage_favorites.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final GetMovieDetails getMovieDetails;
  final GetMovieCredits getMovieCredits;
  final GetSimilarMovies getSimilarMovies;
  final GetMovieTrailers getMovieTrailers;
  final IsFavorite isFavoriteUseCase;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;

  MovieDetailViewModel({
    required this.getMovieDetails,
    required this.getMovieCredits,
    required this.getSimilarMovies,
    required this.getMovieTrailers,
    required this.isFavoriteUseCase,
    required this.addFavoriteUseCase,
    required this.removeFavoriteUseCase,
  });

  ViewState _state = ViewState.initial;
  ViewState get state => _state;

  Movie? _movie;
  Movie? get movie => _movie;

  List<Cast> _castList = [];
  List<Cast> get castList => _castList;

  List<Movie> _similarMovies = [];
  List<Movie> get similarMovies => _similarMovies;

  String? _trailerYoutubeKey;
  String? get trailerYoutubeKey => _trailerYoutubeKey;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;

  Future<void> loadMovie(Movie initialMovie) async {
    _movie = initialMovie;
    _state = ViewState.loading;
    _errorMessage = '';
    _castList = [];
    _similarMovies = [];
    _trailerYoutubeKey = null;
    notifyListeners();

    // Check favorite status
    final favRes = await isFavoriteUseCase(initialMovie.id);
    favRes.fold((_) => _isFavorite = false, (fav) => _isFavorite = fav);

    // Fetch full details, credits, similar, trailers in parallel
    final results = await Future.wait([
      getMovieDetails(initialMovie.id),
      getMovieCredits(initialMovie.id),
      getSimilarMovies(initialMovie.id),
      getMovieTrailers(initialMovie.id),
    ]);

    final detailsRes = results[0];
    final creditsRes = results[1];
    final similarRes = results[2];
    final trailersRes = results[3];

    detailsRes.fold(
      (failure) {
        // Fall back to initialMovie if detailed fetch failed (e.g. offline)
        _movie = initialMovie;
      },
      (detailedMovie) {
        _movie = detailedMovie as Movie;
      },
    );

    creditsRes.fold(
      (_) => _castList = [],
      (credits) => _castList = credits as List<Cast>,
    );

    similarRes.fold(
      (_) => _similarMovies = [],
      (similar) => _similarMovies = similar as List<Movie>,
    );

    trailersRes.fold(
      (_) => _trailerYoutubeKey = null,
      (trailers) {
        final list = trailers as List;
        final ytTrailer = list.firstWhere(
          (v) => v.isYouTube && v.isTrailer,
          orElse: () => list.isNotEmpty && list.first.isYouTube ? list.first : null,
        );
        _trailerYoutubeKey = ytTrailer?.key;
      },
    );

    _state = ViewState.success;
    notifyListeners();
  }

  Future<void> toggleFavorite() async {
    if (_movie == null) return;
    final targetMovie = _movie!;

    if (_isFavorite) {
      _isFavorite = false;
      notifyListeners();
      await removeFavoriteUseCase(targetMovie.id);
    } else {
      _isFavorite = true;
      notifyListeners();
      await addFavoriteUseCase(targetMovie);
    }
  }
}
