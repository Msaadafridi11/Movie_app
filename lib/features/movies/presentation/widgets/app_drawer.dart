import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';
import 'package:movie_app/core/widgets/developer_footer.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';

/// Navigation Drawer with App branding and Developer Credit
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space20,
                vertical: AppDimens.space24,
              ),
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
                      borderRadius: AppDimens.borderRadiusMd,
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
                  const SizedBox(width: AppDimens.space14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appName,
                        style: AppTextStyles.headlineMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        'v${AppConstants.appVersion}',
                        style: AppTextStyles.bodySmall(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppDimens.space12),

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
              icon: Icons.favorite_rounded,
              label: 'Favorites',
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
              margin: const EdgeInsets.all(AppDimens.space16),
              padding: const EdgeInsets.all(AppDimens.space16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: AppDimens.borderRadiusLg,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
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
                  const DeveloperFooter(showHeart: true),
                  const SizedBox(height: AppDimens.space8),
                  Text(
                    'Built with Clean Architecture & MVVM',
                    style: AppTextStyles.labelSmall(
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimens.space12,
        vertical: AppDimens.space4,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: AppDimens.borderRadiusMd,
        ),
        tileColor: isSelected
            ? AppColors.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
        title: Text(
          label,
          style: isSelected
              ? AppTextStyles.titleMedium(color: AppColors.primary)
              : AppTextStyles.bodyMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
        ),
        onTap: onTap,
      ),
    );
  }
}

