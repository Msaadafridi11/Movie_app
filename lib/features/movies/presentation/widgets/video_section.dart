import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';

/// Horizontal "Videos" section with filter tabs and video cards
class VideoSection extends StatefulWidget {
  final MovieDetailViewModel vm;

  const VideoSection({super.key, required this.vm});

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final allVideos = widget.vm.allVideos;
    if (allVideos.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Filter videos by category
    final filteredVideos = allVideos.where((v) {
      if (_selectedFilter == 'All') return true;
      if (_selectedFilter == 'Trailers') return v.isTrailer;
      if (_selectedFilter == 'Teasers') return v.isTeaser;
      if (_selectedFilter == 'Clips') return v.isClip;
      if (_selectedFilter == 'BTS') return v.isBehindTheScenes || v.isFeaturette;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.play_circle_outline_rounded,
                    size: 22, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Videos & Trailers',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            Text(
              '${allVideos.length} Available',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Category filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildFilterChip('All', isDark),
              _buildFilterChip('Trailers', isDark),
              _buildFilterChip('Teasers', isDark),
              _buildFilterChip('Clips', isDark),
              _buildFilterChip('BTS', isDark),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Horizontal video card list
        SizedBox(
          height: 170,
          child: filteredVideos.isEmpty
              ? Center(
                  child: Text(
                    'No videos in this category.',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredVideos.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final video = filteredVideos[index];
                    final isCurrentPlaying = widget.vm.isInlinePlayerActive &&
                        widget.vm.currentVideo?.key == video.key;

                    return GestureDetector(
                      onTap: () => widget.vm.playVideoByEntity(video),
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E212A)
                              : const Color(0xFFF1F3F8),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isCurrentPlaying
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.06)),
                            width: isCurrentPlaying ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Video Thumbnail with badge & play icon
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(13),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: video.thumbnailUrl,
                                    width: 220,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      height: 110,
                                      color: isDark
                                          ? const Color(0xFF15171E)
                                          : Colors.grey.shade300,
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      height: 110,
                                      color: isDark
                                          ? const Color(0xFF15171E)
                                          : Colors.grey.shade300,
                                      child: const Icon(
                                        Icons.video_library_rounded,
                                        color: Colors.white24,
                                        size: 32,
                                      ),
                                    ),
                                  ),
                                ),

                                // Dark overlay on thumbnail
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(13),
                                      ),
                                      color: Colors.black.withValues(alpha: 0.25),
                                    ),
                                  ),
                                ),

                                // Play button overlay
                                Positioned.fill(
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isCurrentPlaying
                                          ? AppColors.primary
                                          : Colors.black54,
                                      child: Icon(
                                        isCurrentPlaying && widget.vm.isPlaying
                                            ? Icons.pause_rounded
                                            : Icons.play_arrow_rounded,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),

                                // Video Category Badge
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.7),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      video.categoryBadge,
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: isCurrentPlaying
                                            ? AppColors.primary
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                                // Now Playing badge
                                if (isCurrentPlaying)
                                  Positioned(
                                    bottom: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.equalizer_rounded,
                                              size: 12, color: Colors.white),
                                          const SizedBox(width: 3),
                                          Text(
                                            'PLAYING',
                                            style: GoogleFonts.outfit(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Video Title
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                video.name,
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: isCurrentPlaying
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isCurrentPlaying
                                      ? AppColors.primary
                                      : (isDark ? Colors.white : Colors.black87),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF1E212A) : const Color(0xFFF1F3F8)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
