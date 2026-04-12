import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/viewmodel/movie_viewmodel.dart';
import 'package:movie_app/viewmodel/main_viewmodel.dart';
import 'package:movie_app/viewmodel/video_viewmodel.dart';
import 'package:movie_app/viewmodel/favorite_viewmodel.dart';
import 'package:movie_app/views/widgets/movie_card.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/views/screens/detail_screen.dart';
import 'package:movie_app/views/screens/video_screen.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/core/utils/download_helper.dart';

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
      context.read<MovieViewModel>().fetchAllMovies();
    });
  }

  void _navigateToDetail(BuildContext context, Results movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailScreen(movie: movie)),
    );
  }

  void _navigateToVideo(BuildContext context, Results movie) {
    context.read<VideoViewModel>().playMovie(movie);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VideoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF141414),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'MOVIE',
          style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              context.read<MainViewModel>().setIndex(1); // Navigates to Search Tab
            },
          ),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 14,
            backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=User&background=random'),
            backgroundColor: Colors.redAccent,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Consumer<MovieViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.redAccent));
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Text('Error: ${viewModel.errorMessage}', style: const TextStyle(color: Colors.white)),
            );
          }

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (viewModel.trendingMovies.isNotEmpty)
                  _buildFeaturedBanner(viewModel.trendingMovies.first),
                const SizedBox(height: 24),
                _buildHorizontalList('Trending Movies', viewModel.trendingMovies),
                const SizedBox(height: 24),
                _buildHorizontalList('Popular Movies', viewModel.popularMovies),
                const SizedBox(height: 24),
                _buildHorizontalList('New Releases', viewModel.nowPlayingMovies),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedBanner(Results movie) {
    return Container(
      height: 500,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            movie.posterPath != null 
                ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' 
                : ApiConstants.imageBaseUrl,
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF141414).withAlpha(255),
              const Color(0xFF141414).withAlpha(51),
              const Color(0xFF141414).withAlpha(204),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  movie.title ?? 'No Title',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '98% Match',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    movie.releaseDate?.split('-').first ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const Text('HD', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Consumer<FavoriteViewModel>(
                    builder: (context, favVM, child) {
                      final isFav = favVM.isFavorite(movie);
                      return GestureDetector(
                        onTap: () => favVM.toggleFavorite(movie),
                        child: Column(
                          children: [
                            Icon(isFav ? Icons.check : Icons.add, color: Colors.white),
                            const SizedBox(height: 4),
                            const Text('My List', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToVideo(context, movie),
                    icon: const Icon(Icons.play_arrow, color: Colors.black, size: 24),
                    label: const Text(
                      'Play',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToDetail(context, movie),
                    child: Column(
                      children: const [
                        Icon(Icons.info_outline, color: Colors.white),
                        SizedBox(height: 4),
                        Text('Info', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => DownloadHelper.downloadVideo(context, movie),
                    child: Column(
                      children: const [
                        Icon(Icons.download, color: Colors.white),
                        SizedBox(height: 4),
                        Text('Download', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalList(String title, List<Results> movies) {
    if (movies.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240, // Match the height in the original + spacing
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return MovieCard(movie: movies[index]);
            },
          ),
        ),
      ],
    );
  }
}
