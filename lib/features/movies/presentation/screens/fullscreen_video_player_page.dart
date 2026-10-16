import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/cinematic_video_player.dart';

/// Immersive Full-Screen YouTube player with playlist auto-play,
/// custom Netflix/YouTube controls, speed memory, and auto error recovery.
class FullScreenVideoPlayerPage extends StatefulWidget {
  final List<Video> videos;
  final int initialIndex;
  final String movieTitle;

  const FullScreenVideoPlayerPage({
    super.key,
    required this.videos,
    this.initialIndex = 0,
    required this.movieTitle,
  });

  @override
  State<FullScreenVideoPlayerPage> createState() => _FullScreenVideoPlayerPageState();
}

class _FullScreenVideoPlayerPageState extends State<FullScreenVideoPlayerPage>
    with WidgetsBindingObserver {
  late int _currentIndex;
  YoutubePlayerController? _controller;
  bool _isMuted = false;
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isLooping = false;
  bool _isCaptionsEnabled = false;
  bool _isFullScreen = true;
  bool _isOffline = false;
  bool _hasPlaybackError = false;
  String _playbackErrorMessage = '';
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _bufferedFraction = 0.0;
  double _playbackSpeed = 1.0;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  String get _currentQualityDisplay {
    final raw = _controller?.value.playbackQuality;
    if (raw == null || raw.isEmpty || raw.toLowerCase() == 'auto') {
      return 'Auto';
    }
    final clean = raw.toLowerCase().replaceAll('hd', '');
    if (clean == '1080' || clean == '720' || clean == '480' || clean == '360') {
      return '${clean}p';
    }
    return raw;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.initialIndex;

    // Set landscape fullscreen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _initConnectivity();
    _loadSavedSpeed();
    _initPlayer();
  }

  void _initConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final hasConn = results.any((r) => r != ConnectivityResult.none);
      final wasOffline = _isOffline;
      if (mounted) {
        setState(() {
          _isOffline = !hasConn;
        });
      }
      if (wasOffline && hasConn && _controller != null) {
        _controller?.reload();
      }
    });
  }

  Future<void> _loadSavedSpeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final speed = prefs.getDouble('pref_video_playback_speed') ?? 1.0;
      if (mounted) {
        setState(() => _playbackSpeed = speed);
        _controller?.setPlaybackRate(speed);
      }
    } catch (_) {}
  }

  void _initPlayer() {
    if (widget.videos.isEmpty) return;
    final video = widget.videos[_currentIndex];

    _controller?.removeListener(_playerListener);
    _controller?.dispose();

    _controller = YoutubePlayerController(
      initialVideoId: video.key,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: _isMuted,
        isLive: false,
        forceHD: false,
        enableCaption: _isCaptionsEnabled,
        hideControls: true,
      ),
    )..addListener(_playerListener);

    setState(() {
      _isPlaying = true;
      _hasPlaybackError = false;
      _playbackErrorMessage = '';
    });
  }

  void _playerListener() {
    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;

    // Handle error codes
    if (value.errorCode != 0) {
      debugPrint('FullScreen player error code: ${value.errorCode}');
      _handlePlayerError(value.errorCode);
      return;
    }

    if (mounted) {
      setState(() {
        _isPlaying = value.isPlaying;
        _isBuffering = value.playerState == PlayerState.buffering;
        _currentPosition = value.position;
        _totalDuration = value.metaData.duration;
        _bufferedFraction = value.buffered;
      });
    }

    if (_isPlaying) {
      WakelockPlus.enable();
    } else {
      WakelockPlus.disable();
    }

    if (value.playerState == PlayerState.ended) {
      if (_isLooping) {
        controller.seekTo(Duration.zero);
        controller.play();
      } else {
        _playNext();
      }
    }
  }

  void _handlePlayerError(int errorCode) {
    if (_currentIndex >= 0 && _currentIndex < widget.videos.length) {
      final failedVideo = widget.videos[_currentIndex];
      MovieDetailViewModel.sessionFailedVideoKeys.add(failedVideo.key);
    }

    // Try finding next playable video
    final nextIdx = _findNextValidIndex(_currentIndex + 1);
    if (nextIdx != null) {
      setState(() {
        _currentIndex = nextIdx;
      });
      _initPlayer();
    } else {
      final fallbackIdx = _findNextValidIndex(0);
      if (fallbackIdx != null && fallbackIdx != _currentIndex) {
        setState(() {
          _currentIndex = fallbackIdx;
        });
        _initPlayer();
      } else {
        setState(() {
          _hasPlaybackError = true;
          _playbackErrorMessage = _getErrorMessageForCode(errorCode);
        });
        WakelockPlus.disable();
      }
    }
  }

  int? _findNextValidIndex(int start) {
    for (int i = start; i < widget.videos.length; i++) {
      if (!MovieDetailViewModel.sessionFailedVideoKeys.contains(widget.videos[i].key)) {
        return i;
      }
    }
    return null;
  }

  String _getErrorMessageForCode(int code) {
    switch (code) {
      case 101:
      case 150:
        return 'The content owner has disabled playback in third-party embedded apps.';
      case 100:
        return 'This trailer was removed from YouTube or marked as private.';
      case 2:
        return 'The trailer link or video ID is invalid.';
      case 5:
        return 'The video format cannot be played by the player.';
      default:
        return "This promotional video can't be played in-app.";
    }
  }

  void _playNext() {
    final next = _findNextValidIndex(_currentIndex + 1);
    if (next != null) {
      setState(() {
        _currentIndex = next;
      });
      _initPlayer();
    } else {
      final first = _findNextValidIndex(0);
      if (first != null) {
        setState(() {
          _currentIndex = first;
        });
        _initPlayer();
      }
    }
  }

  void _playPrevious() {
    for (int i = _currentIndex - 1; i >= 0; i--) {
      if (!MovieDetailViewModel.sessionFailedVideoKeys.contains(widget.videos[i].key)) {
        setState(() {
          _currentIndex = i;
        });
        _initPlayer();
        return;
      }
    }
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    if (_isMuted) {
      _controller?.mute();
    } else {
      _controller?.unMute();
    }
  }

  void _toggleLoop() {
    setState(() => _isLooping = !_isLooping);
  }

  void _toggleCaptions() {
    setState(() => _isCaptionsEnabled = !_isCaptionsEnabled);
  }

  void _seekRelative(int seconds) {
    final target = _currentPosition + Duration(seconds: seconds);
    final clamped = target < Duration.zero
        ? Duration.zero
        : (target > _totalDuration ? _totalDuration : target);
    _controller?.seekTo(clamped);
  }

  Future<void> _setPlaybackSpeed(double speed) async {
    setState(() => _playbackSpeed = speed);
    _controller?.setPlaybackRate(speed);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('pref_video_playback_speed', speed);
    } catch (_) {}
  }

  void _toggleFullScreen() {
    if (_isFullScreen) {
      _isFullScreen = false;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      _isFullScreen = true;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    setState(() {});
  }

  void _retry() {
    if (_currentIndex >= 0 && _currentIndex < widget.videos.length) {
      MovieDetailViewModel.sessionFailedVideoKeys.remove(widget.videos[_currentIndex].key);
    }
    _initPlayer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _controller?.pause();
      WakelockPlus.disable();
    } else if (state == AppLifecycleState.resumed) {
      if (_isPlaying) {
        _controller?.play();
        WakelockPlus.enable();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySub?.cancel();
    WakelockPlus.disable();

    // Reset orientation to portrait and restore edge to edge UI
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _controller?.removeListener(_playerListener);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = widget.videos.isNotEmpty ? widget.videos[_currentIndex] : null;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
          SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: _controller == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : CinematicVideoPlayer(
                controller: _controller!,
                currentVideo: currentVideo,
                movieTitle: widget.movieTitle,
                playlist: widget.videos,
                currentIndex: _currentIndex,
                failedVideoKeys: MovieDetailViewModel.sessionFailedVideoKeys,
                isPlaying: _isPlaying,
                isBuffering: _isBuffering,
                isMuted: _isMuted,
                isLooping: _isLooping,
                isCaptionsEnabled: _isCaptionsEnabled,
                isFullScreen: _isFullScreen,
                isOffline: _isOffline,
                hasPlaybackError: _hasPlaybackError,
                playbackErrorMessage: _playbackErrorMessage,
                currentPosition: _currentPosition,
                totalDuration: _totalDuration,
                bufferedFraction: _bufferedFraction,
                playbackSpeed: _playbackSpeed,
                playbackQuality: _currentQualityDisplay,
                onTogglePlayPause: _togglePlayPause,
                onToggleMute: _toggleMute,
                onToggleLoop: _toggleLoop,
                onToggleCaptions: _toggleCaptions,
                onToggleFullScreen: _toggleFullScreen,
                onPlayNext: _playNext,
                onPlayPrevious: _playPrevious,
                onClose: () => Navigator.of(context).pop(),
                onRetry: _retry,
                onSeekTo: (pos) => _controller?.seekTo(pos),
                onSeekRelative: _seekRelative,
                onSpeedChanged: _setPlaybackSpeed,
                onSelectPlaylistVideo: (idx) {
                  setState(() => _currentIndex = idx);
                  _initPlayer();
                },
                onRetryOffline: () => _controller?.reload(),
              ),
      ),
    );
  }
}
