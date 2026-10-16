import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/utils/page_transitions.dart';
import 'package:movie_app/core/widgets/network_image_with_fallback.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/screens/movie_detail_screen.dart';

/// Modern Netflix/Disney+ style Movie Card with Hero animation and rating badge
class MovieCard extends StatelessWidget {
  final Movie movie;
  final double width;
  final double height;
  final bool showTitle;
  final String? heroTag;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 135,
    this.height = 205,
    this.showTitle = true,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final posterUrl = ApiConstants.posterUrl(movie.posterPath);

    return Container(
      width: width,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            FadeSlidePageRoute(
              page: MovieDetailScreen(
                movie: movie,
                heroTag: heroTag,
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Poster with Hero Animation & Badges
            Stack(
              children: [
                if (heroTag != null)
                  Hero(
                    tag: heroTag!,
                    child: _buildPoster(posterUrl, isDark),
                  )
                else
                  _buildPoster(posterUrl, isDark),

                // Rating Badge (Top Right)
                if (movie.voteAverage > 0)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 13,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            movie.formattedRating,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
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

            // Optional Movie Title
            if (showTitle) ...[
              const SizedBox(height: 8),
              Text(
                movie.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              if (movie.releaseYear != 'N/A')
                Text(
                  movie.releaseYear,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPoster(String posterUrl, bool isDark) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: NetworkImageWithFallback(
        imageUrl: posterUrl,
        width: width,
        height: height,
        borderRadius: 14,
      ),
    );
  }
}
