import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/custom_shimmer.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/offline_widget.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/home_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/featured_carousel.dart';
import 'package:movie_app/features/movies/presentation/widgets/genre_chips.dart';
import 'package:movie_app/features/movies/presentation/widgets/horizontal_movie_list.dart';

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
              appBar: _buildAppBar(context, isDark),
              body: OfflineWidget(
                onRetry: () => vm.refreshAll(),
              ),
            );
          }
          return Scaffold(
            appBar: _buildAppBar(context, isDark),
            body: ErrorView(
              message: vm.errorMessage,
              onRetry: () => vm.refreshAll(),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: _buildAppBar(context, isDark),
          body: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            onRefresh: () => vm.refreshAll(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Top Banner Carousel or Shimmer
                  if (vm.isLoading && vm.trendingMovies.isEmpty)
                    const ShimmerBanner()
                  else if (vm.bannerMovies.isNotEmpty)
                    FeaturedCarousel(movies: vm.bannerMovies),

                  const SizedBox(height: 16),

                  // Genre Filter Chips Bar
                  GenreChips(
                    selectedGenreId: vm.selectedGenreId,
                    onGenreSelected: (id) => vm.selectGenre(id),
                  ),

                  const SizedBox(height: 12),

                  // Section 1: Trending Now
                  HorizontalMovieList(
                    title: 'Trending Now',
                    icon: Icons.local_fire_department_rounded,
                    movies: vm.trendingMovies,
                    isLoading: vm.isLoading && vm.trendingMovies.isEmpty,
                  ),

                  const SizedBox(height: 8),

                  // Section 2: Popular Movies
                  HorizontalMovieList(
                    title: 'Popular on CineStream',
                    icon: Icons.trending_up_rounded,
                    movies: vm.popularMovies,
                    isLoading: vm.isLoading && vm.popularMovies.isEmpty,
                  ),

                  const SizedBox(height: 8),

                  // Section 3: Top Rated
                  HorizontalMovieList(
                    title: 'Critically Acclaimed',
                    icon: Icons.star_rounded,
                    movies: vm.topRatedMovies,
                    isLoading: vm.isLoading && vm.topRatedMovies.isEmpty,
                  ),

                  const SizedBox(height: 8),

                  // Section 4: Upcoming Releases
                  HorizontalMovieList(
                    title: 'Coming Soon to Theaters',
                    icon: Icons.calendar_today_rounded,
                    movies: vm.upcomingMovies,
                    isLoading: vm.isLoading && vm.upcomingMovies.isEmpty,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, size: 26),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            AppConstants.appName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, size: 24),
          onPressed: () {
            context.read<NavigationViewModel>().setIndex(1); // Switch to search
          },
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (isDark ? Colors.black : Colors.white).withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}
