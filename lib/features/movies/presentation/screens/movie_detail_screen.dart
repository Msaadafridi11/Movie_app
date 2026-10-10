import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/network_image_with_fallback.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/cast_card.dart';
import 'package:movie_app/features/movies/presentation/widgets/movie_card.dart';
import 'package:movie_app/injection_container.dart';

/// Cinematic Movie Detail Screen featuring backdrop parallax, trailer launcher, cast & similar movies
class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MovieDetailViewModel>(
      create: (_) => getIt<MovieDetailViewModel>()..loadMovie(movie),
      child: _MovieDetailContent(initialMovie: movie),
    );
  }
}

class _MovieDetailContent extends StatefulWidget {
  final Movie initialMovie;

  const _MovieDetailContent({required this.initialMovie});

  @override
  State<_MovieDetailContent> createState() => _MovieDetailContentState();
}

class _MovieDetailContentState extends State<_MovieDetailContent>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _heartAnimController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.35).animate(
      CurvedAnimation(
        parent: _heartAnimController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  Future<void> _launchTrailer(BuildContext context, String? trailerKey) async {
    if (trailerKey == null || trailerKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No official trailer video found for this movie.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final url = Uri.parse('https://www.youtube.com/watch?v=$trailerKey');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube trailer.')),
        );
      }
    }
  }

  void _onFavoriteTap(BuildContext context, MovieDetailViewModel vm) {
    _heartAnimController.forward().then((_) => _heartAnimController.reverse());
    vm.toggleFavorite();
    // Also notify global favorites viewmodel
    if (vm.movie != null) {
      context.read<FavoritesViewModel>().toggleFavorite(vm.movie!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.watch<MovieDetailViewModel>();
    final currentMovie = vm.movie ?? widget.initialMovie;

    final backdropUrl = ApiConstants.backdropUrl(
      currentMovie.backdropPath ?? currentMovie.posterPath,
    );
    final posterUrl = ApiConstants.posterUrl(
      currentMovie.posterPath,
      highRes: true,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Parallax Backdrop Sliver App Bar
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            stretch: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              ScaleTransition(
                scale: _heartScale,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      vm.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: vm.isFavorite ? AppColors.primary : Colors.white,
                      size: 22,
                    ),
                  ),
                  onPressed: () => _onFavoriteTap(context, vm),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [StretchMode.zoomBackground],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  NetworkImageWithFallback(
                    imageUrl: backdropUrl,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                  // Dark bottom gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                          (isDark ? AppColors.darkBackground : AppColors.lightBackground)
                              .withValues(alpha: 0.85),
                          isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Movie Content Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + Basic Info Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Hero Poster Card
                      Hero(
                        tag: 'movie_poster_${currentMovie.id}',
                        child: Container(
                          width: 110,
                          height: 165,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: NetworkImageWithFallback(
                            imageUrl: posterUrl,
                            width: 110,
                            height: 165,
                            borderRadius: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Title, Year, Rating, Runtime
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentMovie.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                            if (currentMovie.tagline != null && currentMovie.tagline!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${currentMovie.tagline}"',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),

                            // Rating & Runtime Chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                // Rating Pill
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: AppColors.gold.withValues(alpha: 0.6),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.star_rounded, size: 14, color: AppColors.gold),
                                      const SizedBox(width: 4),
                                      Text(
                                        currentMovie.formattedRating,
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.gold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Release Year Pill
                                if (currentMovie.releaseYear != 'N/A')
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppColors.darkCard : AppColors.lightCardElevated),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      currentMovie.releaseYear,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      ),
                                    ),
                                  ),

                                // Runtime Pill
                                if (currentMovie.formattedRuntime.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: (isDark ? AppColors.darkCard : AppColors.lightCardElevated),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      currentMovie.formattedRuntime,
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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

                  const SizedBox(height: 20),

                  // Action Buttons: Play Trailer
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () => _launchTrailer(context, vm.trailerYoutubeKey),
                      icon: const Icon(Icons.play_circle_fill_rounded, size: 24),
                      label: Text(
                        vm.trailerYoutubeKey != null ? 'Watch Official Trailer' : 'Search Trailer on YouTube',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Genres Wrap
                  if (currentMovie.genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentMovie.genres.map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                            ),
                          ),
                          child: Text(
                            g,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Overview Section
                  Text(
                    'Storyline',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentMovie.overview.isNotEmpty
                        ? currentMovie.overview
                        : 'No synopsis available for this title.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      height: 1.6,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Top Cast Section
                  if (vm.castList.isNotEmpty) ...[
                    Text(
                      'Cast & Characters',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: vm.castList.take(15).length,
                        itemBuilder: (context, index) {
                          return CastCard(cast: vm.castList[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Similar Movies Section
                  if (vm.similarMovies.isNotEmpty) ...[
                    Text(
                      'More Like This',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: vm.similarMovies.length,
                        itemBuilder: (context, index) {
                          return MovieCard(movie: vm.similarMovies[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
