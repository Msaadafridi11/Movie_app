import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/domain/entities/video.dart';
import 'package:movie_app/features/movies/presentation/screens/fullscreen_video_player_page.dart';
import 'package:movie_app/features/movies/presentation/screens/movie_detail_screen.dart';

/// Horizontal section on Home screen showing Latest Trailers
class LatestTrailersSection extends StatelessWidget {
  final List<Movie> movies;
  final Map<int, Video> trailerMap;

  const LatestTrailersSection({
    super.key,
    required this.movies,
    required this.trailerMap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.movie_creation_rounded,
                      size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Latest Trailers',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'HOT',
                  style: GoogleFonts.outfit(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 165,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: movies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final movie = movies[index];
              final trailer = trailerMap[movie.id];
              final thumbnailUrl = trailer != null
                  ? trailer.thumbnailUrl
                  : (movie.backdropPath != null
                      ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}'
                      : '');

              return GestureDetector(
                onTap: () {
                  if (trailer != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FullScreenVideoPlayerPage(
                          videos: [trailer],
                          initialIndex: 0,
                          movieTitle: movie.title,
                        ),
                      ),
                    );
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movie: movie),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E212A) : const Color(0xFFF1F3F8),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.08)
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Video thumbnail
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(13),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: thumbnailUrl,
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
                                  Icons.movie_rounded,
                                  color: Colors.white24,
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                          // Gradient
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(13),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Play button
                          Positioned.fill(
                            child: Center(
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.9),
                                child: const Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ),
                            ),
                          ),
                          // Duration badge
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                trailer != null ? 'TRAILER' : 'HD',
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Movie Title
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          movie.title,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
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
}
