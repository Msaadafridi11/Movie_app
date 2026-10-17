import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';
import 'package:movie_app/features/movies/presentation/screens/favorites_screen.dart';
import 'package:movie_app/features/movies/presentation/screens/home_screen.dart';
import 'package:movie_app/features/movies/presentation/screens/search_screen.dart';
import 'package:movie_app/features/movies/presentation/screens/settings_screen.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/app_drawer.dart';

/// Main navigation shell with 4-tab bottom navigation bar and accessible 48dp touch targets
class MainNavScreen extends StatelessWidget {
  const MainNavScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navViewModel = context.watch<NavigationViewModel>();
    final currentIndex = navViewModel.currentIndex;

    return Scaffold(
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.space8,
              vertical: AppDimens.space6,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'Home',
                  isSelected: currentIndex == 0,
                  onTap: () => navViewModel.setIndex(0),
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.search_rounded,
                  label: 'Search',
                  isSelected: currentIndex == 1,
                  onTap: () => navViewModel.setIndex(1),
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.favorite_rounded,
                  label: 'Favorites',
                  isSelected: currentIndex == 2,
                  onTap: () => navViewModel.setIndex(2),
                  isDark: isDark,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  isSelected: currentIndex == 3,
                  onTap: () => navViewModel.setIndex(3),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Semantics(
      label: '$label tab',
      selected: isSelected,
      button: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppDimens.minTouchTarget,
          minHeight: AppDimens.minTouchTarget,
        ),
        child: InkWell(
          borderRadius: AppDimens.borderRadiusFull,
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? AppDimens.space16 : AppDimens.space12,
              vertical: AppDimens.space8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: AppDimens.borderRadiusFull,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted),
                ),
                if (isSelected) ...[
                  const SizedBox(width: AppDimens.space8),
                  Text(
                    label,
                    style: AppTextStyles.labelMedium(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
