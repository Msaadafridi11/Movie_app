import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/cinematic_video_player.dart';

/// Cinematic inline video player at top of movie details
class InlineVideoPlayer extends StatelessWidget {
  final MovieDetailViewModel vm;
  final String backdropUrl;
  final String movieTitle;

  const InlineVideoPlayer({
    super.key,
    required this.vm,
    required this.backdropUrl,
    required this.movieTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (!vm.isInlinePlayerActive || vm.youtubeController == null) {
      return _buildBackdropPlaceholder(context);
    }

    return CinematicVideoPlayer(
      controller: vm.youtubeController!,
      currentVideo: vm.currentVideo,
      movieTitle: movieTitle,
      playlist: vm.allVideos,
      currentIndex: vm.currentVideoIndex,
      failedVideoKeys: MovieDetailViewModel.sessionFailedVideoKeys,
      isPlaying: vm.isPlaying,
      isBuffering: vm.isBuffering,
      isMuted: vm.isMuted,
      isLooping: vm.isLooping,
      isCaptionsEnabled: vm.isCaptionsEnabled,
      isFullScreen: vm.isFullScreen,
      isOffline: vm.isOffline,
      hasPlaybackError: vm.hasPlaybackError,
      playbackErrorMessage: vm.playbackErrorMessage,
      currentPosition: vm.currentPosition,
      totalDuration: vm.totalDuration,
      bufferedFraction: vm.bufferedFraction,
      playbackSpeed: vm.playbackSpeed,
      playbackQuality: vm.currentQualityDisplay,
      onTogglePlayPause: vm.togglePlayPause,
      onToggleMute: vm.toggleMute,
      onToggleLoop: vm.toggleLoop,
      onToggleCaptions: vm.toggleCaptions,
      onToggleFullScreen: vm.toggleFullScreen,
      onPlayNext: vm.playNextVideo,
      onPlayPrevious: vm.playPreviousVideo,
      onClose: vm.closeInlinePlayer,
      onRetry: vm.retryPlayback,
      onSeekTo: vm.seekTo,
      onSeekRelative: vm.seekRelative,
      onSpeedChanged: vm.setPlaybackSpeed,
      onSelectPlaylistVideo: vm.startVideoPlayback,
    );
  }

  Widget _buildBackdropPlaceholder(BuildContext context) {
    final hasTrailer = vm.allVideos.isNotEmpty;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Backdrop Image
          if (backdropUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: backdropUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: const Color(0xFF161922)),
              errorWidget: (_, __, ___) => Container(color: const Color(0xFF161922)),
            )
          else
            Container(color: const Color(0xFF161922)),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.85),
                ],
              ),
            ),
          ),

          // Hero Play Trailer Button
          Center(
            child: GestureDetector(
              onTap: hasTrailer
                  ? () => vm.startVideoPlayback(0)
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('No promotional trailer available for this title.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFFFF5252)],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      hasTrailer ? 'Play Official Trailer' : 'Trailer Unavailable',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

