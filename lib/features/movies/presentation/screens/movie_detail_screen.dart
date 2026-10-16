import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/developer_footer.dart';
import 'package:movie_app/core/widgets/network_image_with_fallback.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/movie_detail_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/cast_card.dart';
import 'package:movie_app/features/movies/presentation/widgets/horizontal_movie_list.dart';
import 'package:movie_app/features/movies/presentation/widgets/image_gallery_section.dart';
import 'package:movie_app/features/movies/presentation/widgets/inline_video_player.dart';
import 'package:movie_app/features/movies/presentation/widgets/omdb_rating_badge.dart';
import 'package:movie_app/features/movies/presentation/widgets/video_section.dart';
import 'package:movie_app/features/movies/presentation/widgets/watch_providers_section.dart';
import 'package:movie_app/injection_container.dart';

/// Cinematic Movie Detail Screen featuring inline video player, playlist, ratings, and providers
class MovieDetailScreen extends StatelessWidget {
  final Movie movie;
  final String? heroTag;

  const MovieDetailScreen({
    super.key,
    required this.movie,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MovieDetailViewModel>(
      create: (_) => getIt<MovieDetailViewModel>()..loadMovie(movie),
      child: _MovieDetailContent(
        initialMovie: movie,
        heroTag: heroTag,
      ),
    );
  }
}

class _MovieDetailContent extends StatefulWidget {
  final Movie initialMovie;
  final String? heroTag;

  const _MovieDetailContent({
    required this.initialMovie,
    this.heroTag,
  });

  @override
  State<_MovieDetailContent> createState() => _MovieDetailContentState();
}

class _MovieDetailContentState extends State<_MovieDetailContent>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final ScrollController _scrollController;
  late final AnimationController _heartAnimController;
  late final Animation<double> _heartScale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-pause video when app is backgrounded
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (mounted) {
        context.read<MovieDetailViewModel>().pausePlayer();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    _heartAnimController.dispose();
    super.dispose();
  }

  void _onFavoriteTap(BuildContext context, MovieDetailViewModel vm) {
    _heartAnimController.forward().then((_) => _heartAnimController.reverse());
    vm.toggleFavorite();
    if (vm.movie != null) {
      context.read<FavoritesViewModel>().toggleFavorite(vm.movie!);
    }
  }

  final GlobalKey _playerGlobalKey = GlobalKey();

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

    return OrientationBuilder(
      builder: (context, orientation) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            vm.onOrientationChanged(orientation);
          }
        });

        final isLandscape = orientation == Orientation.landscape;
        final isPlayerActive = vm.isInlinePlayerActive && vm.youtubeController != null;

        // In landscape while playing, expand player to fullscreen without losing controller
        if (isLandscape && isPlayerActive) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              vm.exitFullScreen();
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: SizedBox.expand(
                key: _playerGlobalKey,
                child: InlineVideoPlayer(
                  vm: vm,
                  backdropUrl: backdropUrl,
                  movieTitle: currentMovie.title,
                ),
              ),
            ),
          );
        }

        // Standard Portrait Mode
        return PopScope(
          canPop: !vm.isFullScreen,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (vm.isFullScreen) {
              vm.exitFullScreen();
            }
          },
          child: Scaffold(
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            body: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Sliver App Bar / Inline Video Player
                SliverAppBar(
                  expandedHeight: 250,
                  pinned: true,
                  stretch: true,
                  backgroundColor: isDark ? const Color(0xFF11141A) : Colors.white,
                  leading: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24, width: 0.8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  actions: [
                    // Full-screen trailer button (keeps one controller alive)
                    if (vm.allVideos.isNotEmpty)
                      IconButton(
                        tooltip: 'Full Screen Player',
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (!vm.isInlinePlayerActive) {
                            vm.startVideoPlayback(0);
                          }
                          vm.enterFullScreen();
                        },
                      ),

                    // Animated Favorite Button
                    ScaleTransition(
                      scale: _heartScale,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 0.8),
                          ),
                          child: Icon(
                            vm.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            size: 20,
                            color: vm.isFavorite ? AppColors.primary : Colors.white,
                          ),
                        ),
                        onPressed: () => _onFavoriteTap(context, vm),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: SizedBox(
                      key: _playerGlobalKey,
                      child: InlineVideoPlayer(
                        vm: vm,
                        backdropUrl: backdropUrl,
                        movieTitle: currentMovie.title,
                      ),
                    ),
                  ),
                ),

          // Main Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + Title + Meta row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster with rounded corners & shadow
                      if (widget.heroTag != null)
                        Hero(
                          tag: widget.heroTag!,
                          child: _buildPosterWidget(posterUrl),
                        )
                      else
                        _buildPosterWidget(posterUrl),
                      const SizedBox(width: 16),

                      // Title & Metadata
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentMovie.title,
                              style: GoogleFonts.outfit(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.2,
                              ),
                            ),
                            if (currentMovie.tagline != null &&
                                currentMovie.tagline!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${currentMovie.tagline}"',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),

                            // Release year, runtime, TV badge
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _buildMetaPill(currentMovie.releaseYear, isDark),
                                if (currentMovie.formattedRuntime.isNotEmpty)
                                  _buildMetaPill(currentMovie.formattedRuntime, isDark),
                                if (currentMovie.isTvShow)
                                  _buildMetaPill('TV SERIES', isDark, isHighlight: true),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ratings Row (TMDB, IMDb, Rotten Tomatoes)
                  OmdbRatingBadgeRow(
                    tmdbRating: currentMovie.voteAverage,
                    voteCount: currentMovie.voteCount,
                    omdbRating: vm.omdbRating,
                  ),
                  const SizedBox(height: 16),

                  // Genres Chips
                  if (currentMovie.genres.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: currentMovie.genres.map((g) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E212A) : const Color(0xFFF1F3F8),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isDark ? Colors.white12 : Colors.black12,
                            ),
                          ),
                          child: Text(
                            g,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // Overview / Synopsis
                  Text(
                    'Synopsis',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentMovie.overview.isNotEmpty
                        ? currentMovie.overview
                        : 'No synopsis available for this title.',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legal Watch Providers Section
                  if (vm.watchProviders.isNotEmpty) ...[
                    WatchProvidersSection(providers: vm.watchProviders),
                    const SizedBox(height: 24),
                  ],

                  // Horizontal Categorized Videos (Trailers, Teasers, Clips, BTS)
                  if (vm.allVideos.isNotEmpty) ...[
                    VideoSection(vm: vm),
                    const SizedBox(height: 24),
                  ],

                  // Cast & Crew Section
                  if (vm.castList.isNotEmpty) ...[
                    Row(
                      children: [
                        const Icon(Icons.people_alt_rounded, size: 20, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Top Cast',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 135,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: vm.castList.take(15).length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          return CastCard(cast: vm.castList[index]);
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Photo Gallery Section
                  if (vm.galleryImages.isNotEmpty) ...[
                    ImageGallerySection(imagePaths: vm.galleryImages),
                    const SizedBox(height: 24),
                  ],

                  // Related & Recommended Movies (Related Videos section like Netflix/YouTube)
                  if (vm.recommendations.isNotEmpty) ...[
                    HorizontalMovieList(
                      title: 'More Like This',
                      movies: vm.recommendations,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Similar Movies Section
                  if (vm.similarMovies.isNotEmpty) ...[
                    HorizontalMovieList(
                      title: 'Similar Titles',
                      movies: vm.similarMovies,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Footer
                  const SizedBox(height: 12),
                  const DeveloperFooter(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
},
);
}

  Widget _buildPosterWidget(String posterUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 105,
        height: 155,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: posterUrl.isNotEmpty
            ? NetworkImageWithFallback(
                imageUrl: posterUrl,
                width: 105,
                height: 155,
                fit: BoxFit.cover,
              )
            : Container(
                color: Colors.grey.shade800,
                child: const Icon(Icons.movie_rounded, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildMetaPill(String text, bool isDark, {bool isHighlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isHighlight
            ? AppColors.primary.withValues(alpha: 0.2)
            : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isHighlight
              ? AppColors.primary
              : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
    );
  }
}
