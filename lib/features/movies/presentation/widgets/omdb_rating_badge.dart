import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';

/// Rating row showing TMDB rating, IMDb score, and Rotten Tomatoes score
class OmdbRatingBadgeRow extends StatelessWidget {
  final double tmdbRating;
  final int voteCount;
  final OmdbRating? omdbRating;

  const OmdbRatingBadgeRow({
    super.key,
    required this.tmdbRating,
    required this.voteCount,
    this.omdbRating,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        // TMDB Score Badge
        _buildBadge(
          context,
          icon: Icons.star_rounded,
          iconColor: Colors.amber,
          label: 'TMDB',
          value: tmdbRating > 0 ? tmdbRating.toStringAsFixed(1) : 'NR',
          subtitle: voteCount > 0 ? '($voteCount)' : null,
          isDark: isDark,
        ),

        // IMDb Rating Badge (if available)
        if (omdbRating?.imdbRating != null &&
            omdbRating!.imdbRating != 'N/A' &&
            omdbRating!.imdbRating!.isNotEmpty)
          _buildBadge(
            context,
            icon: Icons.movie_filter_rounded,
            iconColor: const Color(0xFFF5C518), // IMDb Yellow
            label: 'IMDb',
            value: omdbRating!.imdbRating!,
            isDark: isDark,
          ),

        // Rotten Tomatoes Badge (if available)
        if (omdbRating?.rottenTomatoesRating != null &&
            omdbRating!.rottenTomatoesRating != 'N/A' &&
            omdbRating!.rottenTomatoesRating!.isNotEmpty)
          _buildBadge(
            context,
            icon: Icons.local_fire_department_rounded,
            iconColor: const Color(0xFFFA320A), // RT Red
            label: 'Rotten Tomatoes',
            value: omdbRating!.rottenTomatoesRating!,
            isDark: isDark,
          ),

        // Metascore (if available)
        if (omdbRating?.metascore != null &&
            omdbRating!.metascore != 'N/A' &&
            omdbRating!.metascore!.isNotEmpty)
          _buildBadge(
            context,
            icon: Icons.speed_rounded,
            iconColor: const Color(0xFF66CC33), // Metacritic Green
            label: 'Metascore',
            value: omdbRating!.metascore!,
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? subtitle,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E212A) : const Color(0xFFF1F3F8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 3),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

