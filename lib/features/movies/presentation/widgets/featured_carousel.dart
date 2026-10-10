import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/utils/page_transitions.dart';
import 'package:movie_app/core/widgets/network_image_with_fallback.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/screens/movie_detail_screen.dart';

/// Cinematic Top Hero Carousel banner with auto-scroll and gradient overlays
class FeaturedCarousel extends StatefulWidget {
  final List<Movie> movies;

  const FeaturedCarousel({super.key, required this.movies});

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 1.0);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (!mounted || widget.movies.isEmpty) return;
      final nextPage = (_currentPage + 1) % widget.movies.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final height = MediaQuery.of(context).size.height * 0.52;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        children: [
          // Banner PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.movies.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              final backdropUrl = ApiConstants.backdropUrl(
                movie.backdropPath ?? movie.posterPath,
              );

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    FadeSlidePageRoute(
                      page: MovieDetailScreen(movie: movie),
                    ),
                  );
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Backdrop Image
                    NetworkImageWithFallback(
                      imageUrl: backdropUrl,
                      fit: BoxFit.cover,
                      borderRadius: 0,
                    ),

                    // Cinematic Gradient Scrim
                    Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.heroBannerScrim,
                      ),
                    ),

                    // Movie Info & Quick Buttons
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 40,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Genres pill if available
                          if (movie.genres.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                movie.genres.take(3).join(' • '),
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          const SizedBox(height: 8),

                          // Title
                          Text(
                            movie.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                              shadows: [
                                const Shadow(
                                  color: Colors.black87,
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Action Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    FadeSlidePageRoute(
                                      page: MovieDetailScreen(movie: movie),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                                label: const Text('Play Trailer'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    FadeSlidePageRoute(
                                      page: MovieDetailScreen(movie: movie),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.info_outline_rounded, size: 18),
                                label: const Text('Details'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  side: const BorderSide(color: Colors.white70, width: 1.2),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Page Indicator Dots
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.movies.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? AppColors.primary : Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
