import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:movie_app/viewmodel/video_viewmodel.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/views/widgets/related_video_tile.dart';
import 'package:movie_app/core/utils/download_helper.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onDynamicMovieSwitch(Results movie) {
    context.read<VideoViewModel>().playMovie(movie);
    
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
        child: Consumer<VideoViewModel>(
          builder: (context, viewModel, child) {
            final movie = viewModel.currentMovie;
            final trailerKey = viewModel.currentTrailerKey;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TOP: 16:9 Youtube Player
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      if (trailerKey != null)
                        TrailerPlayerWidget(trailerKey: trailerKey)
                      else
                        Container(
                          color: Colors.black,
                          child: Center(
                            child: viewModel.isLoading
                                ? const CircularProgressIndicator(color: Colors.redAccent)
                                : const Text(
                                    'Trailer Unavailable',
                                    style: TextStyle(color: Colors.white54),
                                  ),
                          ),
                        ),
                      
                      // Back Button Overlay
                      Positioned(
                        top: 16,
                        left: 16,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // MIDDLE & BOTTOM: Movie Info & Related Videos
                Expanded(
                  child: SingleChildScrollView(
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
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: () => DownloadHelper.downloadVideo(context, movie),
                                icon: const Icon(Icons.file_download, color: Colors.white),
                                label: const Text(
                                  'Download Video to Gallery',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white24),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          const Text(
                            'Related Videos',
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
                                return RelatedVideoTile(
                                  movie: related,
                                  onTap: () => _onDynamicMovieSwitch(related),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class TrailerPlayerWidget extends StatefulWidget {
  final String trailerKey;
  const TrailerPlayerWidget({super.key, required this.trailerKey});

  @override
  State<TrailerPlayerWidget> createState() => _TrailerPlayerWidgetState();
}

class _TrailerPlayerWidgetState extends State<TrailerPlayerWidget> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.trailerKey,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        isLive: false,
      ),
    );
  }

  @override
  void didUpdateWidget(TrailerPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trailerKey != widget.trailerKey) {
      _controller.load(widget.trailerKey);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      progressIndicatorColor: Colors.redAccent,
      progressColors: const ProgressBarColors(
        playedColor: Colors.redAccent,
        handleColor: Colors.redAccent,
      ),
    );
  }
}
