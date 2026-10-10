import 'package:flutter/foundation.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_credits.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_details.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_images.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_recommendations.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_trailers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_movie_watch_providers.dart';
import 'package:movie_app/features/movies/domain/usecases/get_omdb_ratings.dart';
import 'package:movie_app/features/movies/domain/usecases/get_similar_movies.dart';
import 'package:movie_app/features/movies/domain/usecases/manage_favorites.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/view_state.dart';

class MovieDetailViewModel extends ChangeNotifier {
  final GetMovieDetails getMovieDetails;
  final GetMovieCredits getMovieCredits;
  final GetSimilarMovies getSimilarMovies;
  final GetMovieRecommendations getMovieRecommendations;
  final GetMovieTrailers getMovieTrailers;
  final GetMovieWatchProviders getMovieWatchProviders;
  final GetMovieImages getMovieImages;
  final GetOmdbRatings getOmdbRatings;
  final IsFavorite isFavoriteUseCase;
  final AddFavorite addFavoriteUseCase;
  final RemoveFavorite removeFavoriteUseCase;

  MovieDetailViewModel({
    required this.getMovieDetails,
    required this.getMovieCredits,
    required this.getSimilarMovies,
    required this.getMovieRecommendations,
    required this.getMovieTrailers,
    required this.getMovieWatchProviders,
    required this.getMovieImages,
    required this.getOmdbRatings,
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

  List<Movie> _recommendations = [];
  List<Movie> get recommendations => _recommendations;

  List<Video> _allVideos = [];
  List<Video> get allVideos => _allVideos;

  List<WatchProvider> _watchProviders = [];
  List<WatchProvider> get watchProviders => _watchProviders;

  List<String> _galleryImages = [];
  List<String> get galleryImages => _galleryImages;

  OmdbRating? _omdbRating;
  OmdbRating? get omdbRating => _omdbRating;

  bool _isFavorite = false;
  bool get isFavorite => _isFavorite;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == ViewState.loading;
  bool get hasError => _state == ViewState.error;

  // Video playback state
  int _currentVideoIndex = 0;
  int get currentVideoIndex => _currentVideoIndex;

  Video? get currentVideo {
    if (_allVideos.isEmpty) return null;
    if (_currentVideoIndex >= 0 && _currentVideoIndex < _allVideos.length) {
      return _allVideos[_currentVideoIndex];
    }
    return _allVideos.first;
  }

  YoutubePlayerController? _youtubeController;
  YoutubePlayerController? get youtubeController => _youtubeController;

  bool _isInlinePlayerActive = false;
  bool get isInlinePlayerActive => _isInlinePlayerActive;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;

  Future<void> loadMovie(Movie initialMovie) async {
    _movie = initialMovie;
    _state = ViewState.loading;
    _errorMessage = '';
    _castList = [];
    _similarMovies = [];
    _recommendations = [];
    _allVideos = [];
    _watchProviders = [];
    _galleryImages = [];
    _omdbRating = null;
    _currentVideoIndex = 0;
    _isInlinePlayerActive = false;
    _disposePlayer();
    notifyListeners();

    final isTv = initialMovie.isTvShow;

    // Check favorite status
    final favRes = await isFavoriteUseCase(initialMovie.id);
    favRes.fold((_) => _isFavorite = false, (fav) => _isFavorite = fav);

    // Fetch details, credits, similar, recommendations, trailers, watch providers, images in parallel
    final results = await Future.wait([
      getMovieDetails(initialMovie.id, isTv: isTv),
      getMovieCredits(initialMovie.id, isTv: isTv),
      getSimilarMovies(initialMovie.id, isTv: isTv),
      getMovieRecommendations(initialMovie.id, isTv: isTv),
      getMovieTrailers(initialMovie.id, isTv: isTv),
      getMovieWatchProviders(initialMovie.id, isTv: isTv),
      getMovieImages(initialMovie.id, isTv: isTv),
    ]);

    final detailsRes = results[0];
    final creditsRes = results[1];
    final similarRes = results[2];
    final recsRes = results[3];
    final trailersRes = results[4];
    final providersRes = results[5];
    final imagesRes = results[6];

    detailsRes.fold(
      (_) => _movie = initialMovie,
      (detailed) => _movie = detailed as Movie,
    );

    creditsRes.fold(
      (_) => _castList = [],
      (credits) => _castList = credits as List<Cast>,
    );

    similarRes.fold(
      (_) => _similarMovies = [],
      (similar) => _similarMovies = similar as List<Movie>,
    );

    recsRes.fold(
      (_) => _recommendations = [],
      (recs) => _recommendations = recs as List<Movie>,
    );

    trailersRes.fold(
      (_) => _allVideos = [],
      (videos) {
        final list = (videos as List<Video>)
            .where((v) => v.isYouTube && v.key.isNotEmpty)
            .toList();

        // Sort: Trailers first, then Teasers, Clips, BTS
        list.sort((a, b) {
          int priority(Video v) {
            if (v.isTrailer) return 0;
            if (v.isTeaser) return 1;
            if (v.isClip) return 2;
            if (v.isBehindTheScenes) return 3;
            return 4;
          }
          return priority(a).compareTo(priority(b));
        });

        _allVideos = list;
      },
    );

    providersRes.fold(
      (_) => _watchProviders = [],
      (providers) => _watchProviders = providers as List<WatchProvider>,
    );

    imagesRes.fold(
      (_) => _galleryImages = [],
      (images) => _galleryImages = images as List<String>,
    );

    _state = ViewState.success;
    notifyListeners();

    // Fetch OMDb in background (fail silently)
    _fetchOmdbRating();
  }

  Future<void> _fetchOmdbRating() async {
    final current = _movie;
    if (current == null) return;
    final res = await getOmdbRatings(
      imdbId: current.imdbId,
      title: current.title,
      year: current.releaseYear,
    );
    res.fold(
      (_) => _omdbRating = null,
      (rating) {
        _omdbRating = rating;
        notifyListeners();
      },
    );
  }

  /// Start playing video at specific index
  void startVideoPlayback(int index) {
    if (_allVideos.isEmpty || index < 0 || index >= _allVideos.length) return;
    _currentVideoIndex = index;
    final video = _allVideos[index];

    _isInlinePlayerActive = true;

    if (_youtubeController == null) {
      _initPlayer(video.key);
    } else {
      _youtubeController?.load(video.key);
      _isPlaying = true;
    }
    notifyListeners();
  }

  void playVideoByEntity(Video video) {
    final idx = _allVideos.indexWhere((v) => v.key == video.key);
    if (idx != -1) {
      startVideoPlayback(idx);
    } else {
      _allVideos.insert(0, video);
      startVideoPlayback(0);
    }
  }

  void _initPlayer(String videoKey) {
    _disposePlayer();
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoKey,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: _isMuted,
        isLive: false,
        forceHD: false,
        enableCaption: false,
        hideControls: false,
      ),
    )..addListener(_playerListener);
    _isPlaying = true;
  }

  void _playerListener() {
    final controller = _youtubeController;
    if (controller == null) return;

    final value = controller.value;
    _isPlaying = value.isPlaying;
    _currentPosition = value.position;
    _totalDuration = value.metaData.duration;

    // Auto play next video on ended
    if (value.playerState == PlayerState.ended) {
      playNextVideo();
    }
    notifyListeners();
  }

  void playNextVideo() {
    if (_allVideos.isEmpty) return;
    if (_currentVideoIndex < _allVideos.length - 1) {
      startVideoPlayback(_currentVideoIndex + 1);
    } else {
      // Loop back to start or pause
      startVideoPlayback(0);
    }
  }

  void playPreviousVideo() {
    if (_allVideos.isEmpty) return;
    if (_currentVideoIndex > 0) {
      startVideoPlayback(_currentVideoIndex - 1);
    }
  }

  void togglePlayPause() {
    final controller = _youtubeController;
    if (controller == null) return;
    if (_isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    final controller = _youtubeController;
    if (controller != null) {
      if (_isMuted) {
        controller.mute();
      } else {
        controller.unMute();
      }
    }
    notifyListeners();
  }

  void seekTo(Duration position) {
    _youtubeController?.seekTo(position);
  }

  void pausePlayer() {
    _youtubeController?.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resumePlayer() {
    if (_isInlinePlayerActive) {
      _youtubeController?.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

  void closeInlinePlayer() {
    _isInlinePlayerActive = false;
    _disposePlayer();
    notifyListeners();
  }

  void _disposePlayer() {
    if (_youtubeController != null) {
      _youtubeController!.removeListener(_playerListener);
      _youtubeController!.dispose();
      _youtubeController = null;
    }
    _isPlaying = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
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

  @override
  void dispose() {
    _disposePlayer();
    super.dispose();
  }
}
