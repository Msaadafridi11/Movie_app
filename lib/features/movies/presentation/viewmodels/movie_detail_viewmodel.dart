import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  }) {
    _initConnectivity();
    _loadSavedPlaybackSpeed();
  }

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

  // Session-wide registry of video IDs that cannot be embedded or are deleted
  static final Set<String> sessionFailedVideoKeys = {};

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

  bool _isBuffering = false;
  bool get isBuffering => _isBuffering;

  bool _isLooping = false;
  bool get isLooping => _isLooping;

  bool _isCaptionsEnabled = false;
  bool get isCaptionsEnabled => _isCaptionsEnabled;

  bool _isFullScreen = false;
  bool get isFullScreen => _isFullScreen;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  bool _hasPlaybackError = false;
  bool get hasPlaybackError => _hasPlaybackError;

  String _playbackErrorMessage = '';
  String get playbackErrorMessage => _playbackErrorMessage;

  Duration _currentPosition = Duration.zero;
  Duration get currentPosition => _currentPosition;

  Duration _totalDuration = Duration.zero;
  Duration get totalDuration => _totalDuration;

  double _bufferedFraction = 0.0;
  double get bufferedFraction => _bufferedFraction;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String get currentQualityDisplay {
    final raw = _youtubeController?.value.playbackQuality;
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'auto') {
      return 'Auto';
    }
    final clean = raw.toLowerCase().replaceAll('hd', '');
    if (clean == '1080' || clean == '720' || clean == '480' || clean == '360') {
      return '${clean}p';
    }
    return raw;
  }

  void _initConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConn = results.any((r) => r != ConnectivityResult.none);
      final wasOffline = _isOffline;
      _isOffline = !hasConn;
      if (wasOffline && hasConn && _isInlinePlayerActive && _youtubeController != null) {
        // Automatically recover when connection restores
        _youtubeController?.reload();
      }
      notifyListeners();
    });
  }

  Future<void> _loadSavedPlaybackSpeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _playbackSpeed = prefs.getDouble('pref_video_playback_speed') ?? 1.0;
    } catch (_) {}
  }

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
    _hasPlaybackError = false;
    _playbackErrorMessage = '';
    _disposePlayer();
    notifyListeners();

    final isTv = initialMovie.isTvShow;

    // Check favorite status
    try {
      final favRes = await isFavoriteUseCase(initialMovie.id);
      favRes.fold((_) => _isFavorite = false, (fav) => _isFavorite = fav);
    } catch (_) {
      _isFavorite = false;
    }

    // Fetch movie data in parallel
    try {
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
          final list = (videos as List<Video>);
          const allowedTypes = {'trailer', 'teaser', 'clip', 'featurette'};
          final seenKeys = <String>{};
          final filtered = <Video>[];

          for (final v in list) {
            final key = v.key.trim();
            final type = v.type.toLowerCase().trim();
            final site = v.site.toLowerCase().trim();

            if (site == 'youtube' &&
                key.isNotEmpty &&
                allowedTypes.contains(type) &&
                !seenKeys.contains(key)) {
              seenKeys.add(key);
              filtered.add(v);
            }
          }

          filtered.sort((a, b) {
            if (a.official != b.official) {
              return a.official ? -1 : 1;
            }
            int priority(Video v) {
              final t = v.type.toLowerCase().trim();
              if (t == 'trailer') return 0;
              if (t == 'teaser') return 1;
              if (t == 'clip') return 2;
              if (t == 'featurette') return 3;
              return 4;
            }
            return priority(a).compareTo(priority(b));
          });

          _allVideos = filtered;
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

      _fetchOmdbRating();
    } catch (e) {
      _errorMessage = e.toString();
      _state = ViewState.error;
      notifyListeners();
    }
  }

  Future<void> _fetchOmdbRating() async {
    final current = _movie;
    if (current == null) return;
    try {
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
    } catch (_) {}
  }

  /// Start playing video at specific index, skipping any known failed keys
  void startVideoPlayback(int index) {
    if (_allVideos.isEmpty || index < 0 || index >= _allVideos.length) return;
    _currentVideoIndex = index;
    final video = _allVideos[index];

    _isInlinePlayerActive = true;
    _hasPlaybackError = false;
    _playbackErrorMessage = '';

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
        enableCaption: _isCaptionsEnabled,
        hideControls: true, // Netflix/YouTube style custom overlay
      ),
    )..addListener(_playerListener);

    _isPlaying = true;
    _hasPlaybackError = false;
    _playbackErrorMessage = '';
  }

  void _playerListener() {
    final controller = _youtubeController;
    if (controller == null) return;

    final value = controller.value;

    // Handle YouTube error codes: 2, 5, 100, 101, 150
    const youtubeErrorCodes = {2, 5, 100, 101, 150};
    if (youtubeErrorCodes.contains(value.errorCode)) {
      debugPrint('YouTube Player Error Code ${value.errorCode} encountered for video $currentVideo');
      _handlePlayerError(value.errorCode);
      return;
    }

    _isPlaying = value.isPlaying;
    _isBuffering = value.playerState == PlayerState.buffering;
    _currentPosition = value.position;
    _totalDuration = value.metaData.duration;
    _bufferedFraction = value.buffered;

    // Keep screen awake while playing
    _setWakelock(_isPlaying);

    // Auto play next video on ended (or loop if looping)
    if (value.playerState == PlayerState.ended) {
      if (_isLooping) {
        seekTo(Duration.zero);
        controller.play();
      } else {
        playNextVideo();
      }
    }
    notifyListeners();
  }

  @visibleForTesting
  void handlePlayerError(int errorCode) => _handlePlayerError(errorCode);

  void _handlePlayerError(int errorCode) {
    final failedVideo = currentVideo;
    if (failedVideo != null) {
      sessionFailedVideoKeys.add(failedVideo.key);
      debugPrint('Marked video ${failedVideo.key} (${failedVideo.name}) as failed for session.');
    }

    // Attempt to automatically fallback to the next un-failed video
    final nextValidIndex = _findNextPlayableIndex(_currentVideoIndex + 1);
    if (nextValidIndex != null) {
      debugPrint('Auto-fallback: Playing next available video at index $nextValidIndex');
      startVideoPlayback(nextValidIndex);
    } else {
      // Check from beginning of list
      final fallbackIndex = _findNextPlayableIndex(0);
      if (fallbackIndex != null && fallbackIndex != _currentVideoIndex) {
        debugPrint('Auto-fallback: Playing alternative available video at index $fallbackIndex');
        startVideoPlayback(fallbackIndex);
      } else {
        // All videos failed or restricted
        _hasPlaybackError = true;
        _playbackErrorMessage = _getErrorMessageForCode(errorCode);
        _disposePlayer();
        notifyListeners();
      }
    }
  }

  int? _findNextPlayableIndex(int startIndex) {
    if (_allVideos.isEmpty) return null;
    for (int i = startIndex; i < _allVideos.length; i++) {
      if (!sessionFailedVideoKeys.contains(_allVideos[i].key)) {
        return i;
      }
    }
    return null;
  }

  String _getErrorMessageForCode(int errorCode) {
    switch (errorCode) {
      case 101:
      case 150:
        return 'The content owner has disabled playback in third-party embedded apps.';
      case 100:
        return 'This trailer was removed from YouTube or marked as private.';
      case 2:
        return 'The trailer link or video ID is invalid.';
      case 5:
        return 'The video format cannot be played by the HTML5 player.';
      default:
        return "This promotional video can't be played in-app.";
    }
  }

  void retryPlayback() {
    final current = currentVideo;
    if (current != null) {
      sessionFailedVideoKeys.remove(current.key);
    }
    _hasPlaybackError = false;
    _playbackErrorMessage = '';
    startVideoPlayback(_currentVideoIndex);
  }

  void playNextVideo() {
    if (_allVideos.isEmpty) return;
    final nextIdx = _findNextPlayableIndex(_currentVideoIndex + 1);
    if (nextIdx != null) {
      startVideoPlayback(nextIdx);
    } else {
      final firstIdx = _findNextPlayableIndex(0);
      if (firstIdx != null) {
        startVideoPlayback(firstIdx);
      }
    }
  }

  void playPreviousVideo() {
    if (_allVideos.isEmpty) return;
    for (int i = _currentVideoIndex - 1; i >= 0; i--) {
      if (!sessionFailedVideoKeys.contains(_allVideos[i].key)) {
        startVideoPlayback(i);
        return;
      }
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

  void toggleLoop() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  void toggleCaptions() {
    _isCaptionsEnabled = !_isCaptionsEnabled;
    notifyListeners();
  }

  void seekTo(Duration position) {
    _youtubeController?.seekTo(position);
  }

  void seekRelative(int seconds) {
    final current = _currentPosition;
    final target = current + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _totalDuration ? _totalDuration : target);
    seekTo(clamped);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    _youtubeController?.setPlaybackRate(speed);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('pref_video_playback_speed', speed);
    } catch (_) {}
  }

  void _setWakelock(bool enable) {
    try {
      if (enable) {
        WakelockPlus.enable().catchError((_) {});
      } else {
        WakelockPlus.disable().catchError((_) {});
      }
    } catch (_) {}
  }

  void enterFullScreen() {
    _isFullScreen = true;
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } catch (_) {}
    notifyListeners();
  }

  void exitFullScreen() {
    _isFullScreen = false;
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (_) {}
    notifyListeners();
  }

  void toggleFullScreen() {
    if (_isFullScreen) {
      exitFullScreen();
    } else {
      enterFullScreen();
    }
  }

  void onOrientationChanged(Orientation orientation) {
    if (orientation == Orientation.landscape && !_isFullScreen) {
      _isFullScreen = true;
      try {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } catch (_) {}
      notifyListeners();
    } else if (orientation == Orientation.portrait && _isFullScreen) {
      _isFullScreen = false;
      try {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } catch (_) {}
      notifyListeners();
    }
  }

  void pausePlayer() {
    _youtubeController?.pause();
    _isPlaying = false;
    _setWakelock(false);
    notifyListeners();
  }

  void resumePlayer() {
    if (_isInlinePlayerActive && !_hasPlaybackError) {
      _youtubeController?.play();
      _isPlaying = true;
      _setWakelock(true);
      notifyListeners();
    }
  }

  void closeInlinePlayer() {
    _isInlinePlayerActive = false;
    _hasPlaybackError = false;
    _disposePlayer();
    exitFullScreen();
    notifyListeners();
  }

  void _disposePlayer() {
    _setWakelock(false);
    if (_youtubeController != null) {
      _youtubeController!.removeListener(_playerListener);
      _youtubeController!.dispose();
      _youtubeController = null;
    }
    _isPlaying = false;
    _isBuffering = false;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    _bufferedFraction = 0.0;
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
    _connectivitySub?.cancel();
    _disposePlayer();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
}
