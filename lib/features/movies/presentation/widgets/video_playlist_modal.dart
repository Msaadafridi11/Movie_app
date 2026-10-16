import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';

/// Modal bottom sheet displaying the playlist of videos for current title
class VideoPlaylistModal extends StatelessWidget {
  final List<Video> videos;
  final int currentIndex;
  final Set<String> failedVideoKeys;
  final ValueChanged<int> onSelectVideo;

  const VideoPlaylistModal({
    super.key,
    required this.videos,
    required this.currentIndex,
    required this.failedVideoKeys,
    required this.onSelectVideo,
  });

  static void show({
    required BuildContext context,
    required List<Video> videos,
    required int currentIndex,
    required Set<String> failedVideoKeys,
    required ValueChanged<int> onSelectVideo,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161922),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.65,
        child: VideoPlaylistModal(
          videos: videos,
          currentIndex: currentIndex,
          failedVideoKeys: failedVideoKeys,
          onSelectVideo: onSelectVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.playlist_play_rounded, color: AppColors.primary, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Promotional Videos (${videos.length})',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final video = videos[index];
                final isPlaying = index == currentIndex;
                final isFailed = failedVideoKeys.contains(video.key);

                return InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                    onSelectVideo(index);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isPlaying
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isPlaying
                            ? AppColors.primary
                            : (isFailed ? Colors.red.withValues(alpha: 0.3) : Colors.white10),
                        width: isPlaying ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Thumbnail with badge
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(
                                imageUrl: video.thumbnailUrl,
                                width: 85,
                                height: 50,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) => Container(
                                  width: 85,
                                  height: 50,
                                  color: Colors.black38,
                                  child: const Icon(Icons.movie_rounded, color: Colors.white24, size: 20),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.8),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  video.categoryBadge,
                                  style: GoogleFonts.outfit(
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            if (isPlaying)
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.equalizer_rounded, color: AppColors.primary, size: 20),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Title & Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                video.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
                                  color: isPlaying ? AppColors.primary : Colors.white,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  if (video.official)
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: Colors.white12,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        'OFFICIAL',
                                        style: GoogleFonts.outfit(fontSize: 8, color: Colors.white70),
                                      ),
                                    ),
                                  if (isFailed)
                                    Text(
                                      'Restricted',
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: Colors.redAccent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        if (isPlaying)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Icon(Icons.play_arrow_rounded, color: AppColors.primary),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
