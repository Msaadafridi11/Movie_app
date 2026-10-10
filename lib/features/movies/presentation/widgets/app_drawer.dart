import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/developer_footer.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';

/// Navigation Drawer with App info and Developer Credit badge
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navViewModel = context.read<NavigationViewModel>();

    return Drawer(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.movie_creation_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'v${AppConstants.appVersion}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Navigation Items
            _buildDrawerTile(
              context: context,
              icon: Icons.home_rounded,
              label: 'Home',
              isSelected: navViewModel.currentIndex == 0,
              onTap: () {
                navViewModel.setIndex(0);
                Navigator.pop(context);
              },
            ),
            _buildDrawerTile(
              context: context,
              icon: Icons.search_rounded,
              label: 'Search & Explore',
              isSelected: navViewModel.currentIndex == 1,
              onTap: () {
                navViewModel.setIndex(1);
                Navigator.pop(context);
              },
            ),
            _buildDrawerTile(
              context: context,
              icon: Icons.bookmark_rounded,
              label: 'Watchlist / Favorites',
              isSelected: navViewModel.currentIndex == 2,
              onTap: () {
                navViewModel.setIndex(2);
                Navigator.pop(context);
              },
            ),
            _buildDrawerTile(
              context: context,
              icon: Icons.settings_rounded,
              label: 'Settings & About',
              isSelected: navViewModel.currentIndex == 3,
              onTap: () {
                navViewModel.setIndex(3);
                Navigator.pop(context);
              },
            ),

            const Spacer(),

            // Developer Credit Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                        child: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppConstants.developerCreditText,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'Senior Flutter Engineer',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const DeveloperFooter(showHeart: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
        title: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
