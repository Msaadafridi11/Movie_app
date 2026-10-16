import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/theme/app_colors.dart';
import 'package:movie_app/core/widgets/custom_shimmer.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/features/movies/presentation/viewmodels/search_viewmodel.dart';
import 'package:movie_app/features/movies/presentation/widgets/genre_chips.dart';
import 'package:movie_app/features/movies/presentation/widgets/movie_card.dart';

/// Live Search Screen with debounced input, infinite scrolling, and genre filtering
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _textController;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<SearchViewModel>().loadMore();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Explore Movies',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Input Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _textController,
              onChanged: (val) => vm.onQueryChanged(val),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search movies by title, keywords...',
                prefixIcon: const Icon(Icons.search_rounded, size: 22),
                suffixIcon: _textController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _textController.clear();
                          vm.clearSearch();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Genre Filter Bar
          if (vm.movies.isNotEmpty || _textController.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: GenreChips(
                selectedGenreId: vm.selectedGenreId,
                onGenreSelected: (id) => vm.selectGenre(id),
              ),
            ),

          // Search Results Body
          Expanded(
            child: _buildResults(vm, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchViewModel vm, bool isDark) {
    if (vm.isLoading) {
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.58,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemCount: 9,
        itemBuilder: (context, index) => const ShimmerMovieCard(width: 110, height: 160),
      );
    }

    if (vm.hasError) {
      return ErrorView(
        message: vm.errorMessage,
        onRetry: () => vm.onQueryChanged(_textController.text),
      );
    }

    if (vm.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: 'No Movies Found',
        subtitle: 'We couldn\'t find any titles matching "${vm.query}". Try searching another name or genre.',
      );
    }

    if (vm.movies.isEmpty && _textController.text.isEmpty) {
      return const EmptyView(
        icon: Icons.movie_filter_rounded,
        title: 'Find Your Next Favorite',
        subtitle: 'Search millions of movies, blockbusters, and indie titles on CineStream.',
      );
    }

    return NotificationListener<ScrollNotification>(
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.56,
          crossAxisSpacing: 10,
          mainAxisSpacing: 12,
        ),
        itemCount: vm.movies.length + (vm.isLoadingMore ? 3 : 0),
        itemBuilder: (context, index) {
          if (index >= vm.movies.length) {
            return const ShimmerMovieCard(width: 110, height: 160);
          }
          final movie = vm.movies[index];
          return MovieCard(
            movie: movie,
            heroTag: 'search_${movie.id}',
            width: double.infinity,
            height: 160,
          );
        },
      ),
    );
  }
}
