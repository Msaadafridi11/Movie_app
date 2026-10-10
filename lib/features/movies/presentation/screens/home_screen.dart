import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/custom_shimmer.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/offline_widget.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/home_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/featured_carousel.dart';
import 'package:movie_app/features/movies/presentation/widgets/genre_chips.dart';
import 'package:movie_app/features/movies/presentation/widgets/horizontal_movie_list.dart';
import 'package:movie_app/features/movies/presentation/widgets/latest_trailers_section.dart';

/// Production-ready Home Screen with featured banner, categories, genre filters, and offline fallback
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().initHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<HomeViewModel>(
      builder: (context, vm, child) {
        // Full screen Offline / Error state if no data could be loaded
        if (vm.hasError && vm.trendingMovies.isEmpty && vm.popularMovies.isEmpty) {
          if (vm.isOffline) {
            return Scaffold(
              appBar: _buildAppBar(context, isDark, vm),
              body: OfflineWidget(
                onRetry: () => vm.fetchAllSections(),
              ),
            );
          }
          return Scaffold(
            appBar: _buildAppBar(context, isDark, vm),
            body: ErrorView(
              message: vm.errorMessage,
              onRetry: () => vm.fetchAllSections(),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, isDark, vm),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            onRefresh: () => vm.fetchAllSections(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Top Banner Carousel or Shimmer
                  if (vm.isLoading && vm.bannerMovies.isEmpty)
                    const ShimmerBanner()
                  else if (vm.bannerMovies.isNotEmpty)
                    FeaturedCarousel(movies: vm.bannerMovies),

                  const SizedBox(height: 16),

                  // Movies vs TV Shows Segment Toggle Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildMediaTypePill(
                          title: 'Movies',
                          icon: Icons.movie_rounded,
                          isSelected: !vm.isTvMode,
                          onTap: () => vm.toggleTvMode(false),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildMediaTypePill(
                          title: 'TV Shows',
                          icon: Icons.tv_rounded,
                          isSelected: vm.isTvMode,
                          onTap: () => vm.toggleTvMode(true),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Genre Filter Chips Bar
                  GenreChips(
                    selectedGenreId: vm.selectedGenreId,
                    onGenreSelected: (id) => vm.selectGenre(id),
                  ),

                  const SizedBox(height: 16),

                  // Latest Trailers Section
                  if (vm.latestTrailers.isNotEmpty) ...[
                    LatestTrailersSection(
                      movies: vm.latestTrailers,
                      trailerMap: vm.trailerMap,
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Feed Sections
                  if (!vm.isTvMode) ...[
                    // Movies Mode Sections
                    if (vm.trendingMovies.isNotEmpty) ...[
                      HorizontalMovieList(
                        title: 'Trending Today',
                        movies: vm.trendingMovies,
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (vm.popularMovies.isNotEmpty) ...[
                      HorizontalMovieList(
                        title: 'Popular on CineFlix',
                        movies: vm.popularMovies,
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (vm.topRatedMovies.isNotEmpty) ...[
                      HorizontalMovieList(
                        title: 'Top Rated Classics',
                        movies: vm.topRatedMovies,
                      ),
                      const SizedBox(height: 20),
                    ],

                    if (vm.upcomingMovies.isNotEmpty) ...[
                      HorizontalMovieList(
                        title: 'Coming Soon to Theaters',
                        movies: vm.upcomingMovies,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ] else ...[
                    // TV Shows Mode Sections
                    if (vm.popularTv.isNotEmpty) ...[
                      HorizontalMovieList(
                        title: 'Popular TV Series',
                        movies: vm.popularTv,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ],

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaTypePill({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? const Color(0xFF1E212A) : const Color(0xFFF1F3F8)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.black12),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark, HomeViewModel vm) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFFFF5252)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'CINE',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'FLIX',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1.5,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.black38,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 0.8),
            ),
            child: const Icon(Icons.search_rounded, size: 20, color: Colors.white),
          ),
          onPressed: () {
            context.read<NavigationViewModel>().setIndex(1);
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
