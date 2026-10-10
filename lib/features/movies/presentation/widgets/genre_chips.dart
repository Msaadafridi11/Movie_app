import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';

/// Horizontal list of genre filter chips
class GenreChips extends StatelessWidget {
  final int? selectedGenreId;
  final ValueChanged<int?> onGenreSelected;

  const GenreChips({
    super.key,
    required this.selectedGenreId,
    required this.onGenreSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final genres = AppConstants.genreMap.entries.toList();

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length + 1, // +1 for "All"
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedGenreId == null;
            return _buildChip(
              context: context,
              label: 'All Genres',
              isSelected: isSelected,
              onTap: () => onGenreSelected(null),
              isDark: isDark,
            );
          }

          final entry = genres[index - 1];
          final isSelected = selectedGenreId == entry.key;

          return _buildChip(
            context: context,
            label: entry.value,
            isSelected: isSelected,
            onTap: () => onGenreSelected(entry.key),
            isDark: isDark,
          );
        },
      ),
    );
  }

  Widget _buildChip({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.darkCard : AppColors.lightCardElevated),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
