import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:movie_app/viewmodel/video_viewmodel.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/views/widgets/movie_card.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  bool _showControls = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    // Standard mock video for all movies (since TMDB doesn't provide raw mp4 streams directly)
    _controller = VideoPlayerController.networkUrl(Uri.parse(
        'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        _isPlaying = true;
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
        _showControls = true;
      } else {
        _controller.play();
        _isPlaying = true;
        _showControls = false; // Auto hide on play
      }
    });
  }

  void _onDynamicMovieSwitch(Results movie) {
    // Dynamically swap the movie in Provider
    context.read<VideoViewModel>().playMovie(movie);
    
    // Simulate Video reloading
    _controller.pause();
    _controller.seekTo(Duration.zero);
    _controller.play();
    setState(() {
      _isPlaying = true;
      _showControls = false;
    });

    // Scroll to top of list
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP: 16:9 Video Player section
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showControls = !_showControls;
                      });
                    },
                    child: Container(
                      color: Colors.black,
                      child: Center(
                        child: _controller.value.isInitialized
                            ? VideoPlayer(_controller)
                            : const CircularProgressIndicator(color: Colors.redAccent),
                      ),
                    ),
                  ),

                  // Overlay Controls
                  if (_showControls)
                    Container(color: Colors.black45),

                  if (_showControls)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 36),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                  if (_showControls && _controller.value.isInitialized)
                    Center(
                      child: IconButton(
                        icon: Icon(
                          _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                          color: Colors.white,
                          size: 64,
                        ),
                        onPressed: _togglePlayPause,
                      ),
                    ),

                  if (_showControls && _controller.value.isInitialized)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: VideoProgressIndicator(
                        _controller,
                        allowScrubbing: true,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        colors: const VideoProgressColors(
                          playedColor: Colors.redAccent,
                          bufferedColor: Colors.white24,
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // MIDDLE & BOTTOM: Movie Info & Related Videos
            Expanded(
              child: Consumer<VideoViewModel>(
                builder: (context, viewModel, child) {
                  final movie = viewModel.currentMovie;

                  return SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (movie != null) ...[
                            Text(
                              movie.title ?? 'No Title',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Text(
                                  '98% Match',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  movie.releaseDate ?? '',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                const SizedBox(width: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade800,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text('HD', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              movie.overview ?? '',
                              style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 32),
                          const Text(
                            'More Like This',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (viewModel.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(color: Colors.redAccent),
                              ),
                            )
                          else if (viewModel.relatedMovies.isEmpty)
                            const Text('No related videos found.', style: TextStyle(color: Colors.white54))
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: viewModel.relatedMovies.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                final related = viewModel.relatedMovies[index];
                                return GestureDetector(
                                  onTap: () => _onDynamicMovieSwitch(related),
                                  child: Container(
                                    color: Colors.transparent, // Ensures entire row is clickable
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            related.backdropPath != null
                                                ? 'https://image.tmdb.org/t/p/w200${related.backdropPath}'
                                                : (related.posterPath != null 
                                                    ? 'https://image.tmdb.org/t/p/w200${related.posterPath}' 
                                                    : ApiConstants.imageBaseUrl),
                                            width: 120,
                                            height: 68,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              width: 120,
                                              height: 68,
                                              color: Colors.grey.shade900,
                                              child: const Icon(Icons.movie, color: Colors.grey),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                related.title ?? 'No title',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                related.releaseDate ?? '',
                                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(top: 16.0),
                                          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 32),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
