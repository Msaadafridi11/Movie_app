import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/network_image_with_fallback.dart';
import 'package:movie_app/features/movies/domain/entities/cast.dart';

/// Actor/Crew profile card showing avatar, actor name, and character name
class CastCard extends StatelessWidget {
  final Cast cast;

  const CastCard({super.key, required this.cast});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final photoUrl = ApiConstants.posterUrl(cast.profilePath);

    return Container(
      width: 90,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular / Rounded Avatar
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: NetworkImageWithFallback(
                imageUrl: photoUrl,
                width: 76,
                height: 76,
                borderRadius: 40,
                fit: BoxFit.cover,
                errorWidget: Container(
                  color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
                  child: Icon(
                    Icons.person_rounded,
                    size: 38,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Name
          Text(
            cast.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),

          // Character
          if (cast.character.isNotEmpty)
            Text(
              cast.character,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
        ],
      ),
    );
  }
}
