import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/presentation/widgets/custom_video_controls_overlay.dart';
import 'package:movie_app/features/movies/presentation/widgets/friendly_video_error_card.dart';

/// Complete, cinematic player combining YouTube WebView with custom Netflix/YouTube overlay
/// and friendly error fallback card.
class CinematicVideoPlayer extends StatelessWidget {
  final YoutubePlayerController controller;
  final Video? currentVideo;
  final String movieTitle;
  final List<Video> playlist;
  final int currentIndex;
  final Set<String> failedVideoKeys;
  final bool isPlaying;
  final bool isBuffering;
  final bool isMuted;
  final bool isLooping;
  final bool isCaptionsEnabled;
  final bool isFullScreen;
  final bool isOffline;
  final bool hasPlaybackError;
  final String playbackErrorMessage;
  final Duration currentPosition;
  final Duration totalDuration;
  final double bufferedFraction;
  final double playbackSpeed;
  final String playbackQuality;
  final VoidCallback onTogglePlayPause;
  final VoidCallback onToggleMute;
  final VoidCallback onToggleLoop;
  final VoidCallback onToggleCaptions;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onPlayNext;
  final VoidCallback onPlayPrevious;
  final VoidCallback? onClose;
  final VoidCallback onRetry;
  final ValueChanged<Duration> onSeekTo;
  final ValueChanged<int> onSeekRelative;
  final ValueChanged<double> onSpeedChanged;
  final ValueChanged<int> onSelectPlaylistVideo;
  final VoidCallback? onRetryOffline;

  const CinematicVideoPlayer({
    super.key,
    required this.controller,
    required this.currentVideo,
    required this.movieTitle,
    required this.playlist,
    required this.currentIndex,
    required this.failedVideoKeys,
    required this.isPlaying,
    required this.isBuffering,
    required this.isMuted,
    required this.isLooping,
    required this.isCaptionsEnabled,
    required this.isFullScreen,
    required this.isOffline,
    required this.hasPlaybackError,
    required this.playbackErrorMessage,
    required this.currentPosition,
    required this.totalDuration,
    required this.bufferedFraction,
    required this.playbackSpeed,
    required this.playbackQuality,
    required this.onTogglePlayPause,
    required this.onToggleMute,
    required this.onToggleLoop,
    required this.onToggleCaptions,
    required this.onToggleFullScreen,
    required this.onPlayNext,
    required this.onPlayPrevious,
    this.onClose,
    required this.onRetry,
    required this.onSeekTo,
    required this.onSeekRelative,
    required this.onSpeedChanged,
    required this.onSelectPlaylistVideo,
    this.onRetryOffline,
  });

  @override
  Widget build(BuildContext context) {
    if (hasPlaybackError) {
      return FriendlyVideoErrorCard(
        video: currentVideo,
        movieTitle: movieTitle,
        errorMessage: playbackErrorMessage,
        onRetry: onRetry,
        hasNextVideo: playlist.length > 1,
        onTryNext: playlist.length > 1 ? onPlayNext : null,
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Underlying YouTube player WebView
          YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: false,
          ),

          // Custom Netflix/YouTube style overlay
          CustomVideoControlsOverlay(
            currentVideo: currentVideo,
            movieTitle: movieTitle,
            playlist: playlist,
            currentIndex: currentIndex,
            failedVideoKeys: failedVideoKeys,
            isPlaying: isPlaying,
            isBuffering: isBuffering,
            isMuted: isMuted,
            isLooping: isLooping,
            isCaptionsEnabled: isCaptionsEnabled,
            isFullScreen: isFullScreen,
            isOffline: isOffline,
            currentPosition: currentPosition,
            totalDuration: totalDuration,
            bufferedFraction: bufferedFraction,
            playbackSpeed: playbackSpeed,
            playbackQuality: playbackQuality,
            onTogglePlayPause: onTogglePlayPause,
            onToggleMute: onToggleMute,
            onToggleLoop: onToggleLoop,
            onToggleCaptions: onToggleCaptions,
            onToggleFullScreen: onToggleFullScreen,
            onPlayNext: onPlayNext,
            onPlayPrevious: onPlayPrevious,
            onClose: onClose,
            onSeekTo: onSeekTo,
            onSeekRelative: onSeekRelative,
            onSpeedChanged: onSpeedChanged,
            onSelectPlaylistVideo: onSelectPlaylistVideo,
            onRetryOffline: onRetryOffline,
          ),
        ],
      ),
    );
  }
}
