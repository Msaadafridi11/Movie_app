import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';

/// Friendly, elegant fallback card shown when a video cannot be played in-app
/// (e.g. embedding restricted by studio, removed from YouTube, or invalid ID).
class FriendlyVideoErrorCard extends StatelessWidget {
  final Video? video;
  final String movieTitle;
  final String errorMessage;
  final VoidCallback onRetry;
  final VoidCallback? onTryNext;
  final bool hasNextVideo;

  const FriendlyVideoErrorCard({
    super.key,
    required this.video,
    required this.movieTitle,
    required this.errorMessage,
    required this.onRetry,
    this.onTryNext,
    this.hasNextVideo = false,
  });

  Future<void> _launchYouTube(BuildContext context) async {
    final videoKey = video?.key ?? '';
    if (videoKey.isEmpty) return;

    final url = Uri.parse('https://www.youtube.com/watch?v=$videoKey');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch external YouTube app.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = video?.thumbnailUrl ?? '';

    return Container(
      color: const Color(0xFF0D0F14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background blurred thumbnail
          if (thumbnailUrl.isNotEmpty)
            Opacity(
              opacity: 0.35,
              child: CachedNetworkImage(
                imageUrl: thumbnailUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(color: const Color(0xFF141720)),
              ),
            ),

          // Dark gradient vignette
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.75),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon badge
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.play_disabled_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Heading
                  Text(
                    "This video can't be played here",
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),

                  // Friendly explanation
                  Text(
                    errorMessage.isNotEmpty
                        ? errorMessage
                        : 'Playback is restricted by the content owner for embedded players.',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.white70,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      // Watch on YouTube button
                      if (video != null && video!.key.isNotEmpty)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF0000),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                          icon: const Icon(Icons.open_in_new_rounded, size: 16),
                          label: Text(
                            'Watch on YouTube',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => _launchYouTube(context),
                        ),

                      // Try Next Video Button
                      if (hasNextVideo && onTryNext != null)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: const BorderSide(color: Colors.white24),
                            ),
                          ),
                          icon: const Icon(Icons.skip_next_rounded, size: 16),
                          label: Text(
                            'Try Next Video',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          onPressed: onTryNext,
                        ),

                      // Retry button
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white38),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(
                          'Retry',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: onRetry,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
