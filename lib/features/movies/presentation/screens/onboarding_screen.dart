import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';
import 'package:movie_app/core/utils/page_transitions.dart';
import 'package:movie_app/features/movies/presentation/screens/main_nav_screen.dart';

/// Cinematic 3-step onboarding flow presented only on the user's first launch
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingItem> _items = [
    _OnboardingItem(
      icon: Icons.movie_filter_rounded,
      title: 'Discover Great Cinema',
      subtitle:
          'Explore thousands of trending movies, top-rated classics, and popular TV series updated directly from TMDB.',
      gradientColors: [Color(0xFFE50914), Color(0xFFFF5252)],
    ),
    _OnboardingItem(
      icon: Icons.play_circle_fill_rounded,
      title: 'Official HD Trailers',
      subtitle:
          'Stream promotional trailers and teasers with rich playback controls, subtitles, and speed options.',
      gradientColors: [Color(0xFF7928CA), Color(0xFFFF0080)],
    ),
    _OnboardingItem(
      icon: Icons.favorite_rounded,
      title: 'Curate Your Watchlist',
      subtitle:
          'Save must-watch titles to your personal favorites and discover legal streaming platforms with JustWatch.',
      gradientColors: [Color(0xFF0070F3), Color(0xFF00DFD8)],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingCompletedKey, true);
    } catch (_) {}

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      FadeSlidePageRoute(page: const MainNavScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == _items.length - 1;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with App branding and Skip button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space20,
                vertical: AppDimens.space12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimens.space8,
                          vertical: AppDimens.space4,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: AppDimens.borderRadiusSm,
                        ),
                        child: Text(
                          'CINE',
                          style: AppTextStyles.labelLarge(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: AppDimens.space4),
                      Text(
                        'FLIX',
                        style: AppTextStyles.labelLarge(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  if (!isLastPage)
                    TextButton(
                      style: TextButton.styleFrom(
                        minimumSize: const Size(60, AppDimens.minTouchTarget),
                      ),
                      onPressed: _completeOnboarding,
                      child: Text(
                        'Skip',
                        style: AppTextStyles.titleSmall(
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: AppDimens.minTouchTarget),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _items.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space32,
                      vertical: AppDimens.space20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Cinematic Icon Box with soft shadow
                        Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: item.gradientColors,
                            ),
                            borderRadius: AppDimens.borderRadius2Xl,
                            boxShadow: [
                              BoxShadow(
                                color: item.gradientColors.first.withValues(alpha: 0.4),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              item.icon,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppDimens.space40),

                        // Title
                        Text(
                          item.title,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineLarge(
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: AppDimens.space14),

                        // Subtitle
                        Text(
                          item.subtitle,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area (Indicators + Button)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimens.space24,
                vertical: AppDimens.space24,
              ),
              child: Column(
                children: [
                  // Page Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: AppDimens.space4),
                        width: _currentPage == i ? 26 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppColors.primary
                              : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                          borderRadius: AppDimens.borderRadiusFull,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimens.space24),

                  // Next / Get Started Button
                  SizedBox(
                    width: double.infinity,
                    height: AppDimens.minTouchTarget + 4,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppDimens.borderRadiusMd,
                        ),
                      ),
                      onPressed: () {
                        if (isLastPage) {
                          _completeOnboarding();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage ? 'Get Started' : 'Next',
                            style: AppTextStyles.labelLarge(color: Colors.white),
                          ),
                          const SizedBox(width: AppDimens.space8),
                          Icon(
                            isLastPage ? Icons.check_circle_rounded : Icons.arrow_forward_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ],
                      ),
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
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}
