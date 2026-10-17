import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/theme/app_dimens.dart';
import 'package:movie_app/core/theme/app_text_styles.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/favorites_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/movie_card.dart';

/// Favorites screen with clean grid layout, animated removal, and actionable empty state
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesViewModel>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorites',
          style: AppTextStyles.headlineMedium(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (vm.favorites.isEmpty) {
            return EmptyView(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Yet',
              subtitle:
                  'Save movies you love by tapping the heart icon on any title to easily find them here.',
              buttonText: 'Explore Trending Movies',
              onButtonPressed: () {
                context.read<NavigationViewModel>().setIndex(0); // Switch to Home tab
              },
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              // Responsive column count for phones vs tablets/landscape
              final crossAxisCount = constraints.maxWidth > 900
                  ? 5
                  : (constraints.maxWidth > 600 ? 4 : 3);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimens.space16,
                      vertical: AppDimens.space8,
                    ),
                    child: Text(
                      '${vm.favorites.length} ${vm.favorites.length == 1 ? 'Movie' : 'Movies'} Saved',
                      style: AppTextStyles.titleSmall(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.space16,
                        vertical: AppDimens.space8,
                      ),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.56,
                        crossAxisSpacing: AppDimens.space10,
                        mainAxisSpacing: AppDimens.space12,
                      ),
                      itemCount: vm.favorites.length,
                      itemBuilder: (context, index) {
                        final movie = vm.favorites[index];
                        return Stack(
                          children: [
                            MovieCard(
                              movie: movie,
                              heroTag: 'fav_${movie.id}',
                              width: double.infinity,
                              height: 160,
                            ),
                            // Quick remove badge with accessible touch target
                            Positioned(
                              top: 4,
                              left: 4,
                              child: Semantics(
                                label: 'Remove ${movie.title} from favorites',
                                button: true,
                                child: InkWell(
                                  onTap: () {
                                    vm.removeFavorite(movie.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Removed "${movie.title}" from favorites'),
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        action: SnackBarAction(
                                          label: 'Undo',
                                          textColor: AppColors.primaryLight,
                                          onPressed: () {
                                            vm.addFavorite(movie);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
