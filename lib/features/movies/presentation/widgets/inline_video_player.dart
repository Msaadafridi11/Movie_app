import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/presentation/screens/fullscreen_video_player_page.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';

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

    final currentVideo = vm.currentVideo;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Embedded YouTube Player
          YoutubePlayer(
            controller: vm.youtubeController!,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.primary,
            progressColors: const ProgressBarColors(
              playedColor: AppColors.primary,
              handleColor: AppColors.primary,
              bufferedColor: Colors.white24,
              backgroundColor: Colors.white12,
            ),
            topActions: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => vm.closeInlinePlayer(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  currentVideo?.name ?? movieTitle,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  vm.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => vm.toggleMute(),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24),
                onPressed: () => _openFullScreen(context),
              ),
            ],
          ),

          // Top close pill button
          Positioned(
            top: 10,
            right: 10,
            child: GestureDetector(
              onTap: () => vm.closeInlinePlayer(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.close_rounded, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Close Video',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
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
                          content: Text('No promotional trailer available for this movie.'),
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
                      style: GoogleFonts.outfit(
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

  void _openFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayerPage(
          videos: vm.allVideos,
          initialIndex: vm.currentVideoIndex,
          movieTitle: movieTitle,
        ),
      ),
    );
  }
}
