import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/viewmodel/video_viewmodel.dart';
import 'package:movie_app/views/screens/video_screen.dart';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:movie_app/data/repositories/movie_repository.dart';

class DetailScreen extends StatelessWidget {
  final Results movie;

  const DetailScreen({super.key, required this.movie});

  void _navigateToVideo(BuildContext context) {
    context.read<VideoViewModel>().playMovie(movie);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoScreen()));
  }

  Future<void> _downloadPoster(BuildContext context) async {
    final imageUrl = movie.posterPath != null 
        ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' 
        : (movie.backdropPath != null 
            ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}' 
            : null);
            
    if (imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No image available to download')),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Downloading...')),
      );

      var status = await Permission.storage.request();
      if (!status.isGranted && !await Permission.photos.request().isGranted) {
        // Continue anyway in case of Android 10+ where writes don't need explicit storage permission if using MediaStore
      }

      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );
      final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: '${movie.title?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}_poster',
      );

      if (context.mounted) {
        if (result['isSuccess'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Downloaded to mobile gallery successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to download image')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _downloadVideo(BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    
    if (movie.id == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('No video available')));
      return;
    }

    scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Fetching video details...')));

    try {
      final repository = context.read<MovieRepository>();
      final trailerKey = await repository.fetchMovieTrailer(movie.id!);

      if (trailerKey == null || trailerKey.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('No video found for this movie')));
        return;
      }
      
      var status = await Permission.storage.request();
      if (!status.isGranted && !await Permission.photos.request().isGranted) {}

      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Downloading video... (this might take a while)')));
      
      final ytExplode = yt.YoutubeExplode();
      final manifest = await ytExplode.videos.streamsClient.getManifest(trailerKey);
      final streamInfo = manifest.muxed.withHighestBitrate();
      
      final dir = await getTemporaryDirectory();
      final sanitizedTitle = movie.title?.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'movie_video';
      final filePath = '${dir.path}/$sanitizedTitle.mp4';
      final file = File(filePath);

      var stream = ytExplode.videos.streamsClient.get(streamInfo);
      var fileStream = file.openWrite();
      await stream.pipe(fileStream);
      await fileStream.flush();
      await fileStream.close();
      ytExplode.close();

      final result = await ImageGallerySaver.saveFile(filePath, name: sanitizedTitle);

      if (result['isSuccess'] == true) {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Video saved to mobile gallery successfully!')));
      } else {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Failed to save video to gallery')));
      }

    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBackdrop(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        (movie.voteAverage ?? 0.0).toStringAsFixed(1),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        movie.releaseDate ?? 'Unknown Year',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('HD', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _navigateToVideo(context),
                          icon: const Icon(Icons.play_arrow, color: Colors.black),
                          label: const Text(
                            'Watch Now',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _navigateToVideo(context), // Trailer also routes to video
                          icon: const Icon(Icons.movie_creation_outlined, color: Colors.white),
                          label: const Text(
                            'Play Trailer',
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
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadPoster(context),
                      icon: const Icon(Icons.image_outlined, color: Colors.white),
                      label: const Text(
                        'Download Poster to Gallery',
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
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _downloadVideo(context),
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
                  const SizedBox(height: 24),
                  Text(
                    movie.overview ?? 'No description available for this movie.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Top Cast',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildMockCast(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            movie.backdropPath != null
                ? 'https://image.tmdb.org/t/p/w500${movie.backdropPath}'
                : (movie.posterPath != null ? 'https://image.tmdb.org/t/p/w500${movie.posterPath}' : ApiConstants.imageBaseUrl),
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF141414).withAlpha(255),
              const Color(0xFF141414).withAlpha(0),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.0, 0.4],
          ),
        ),
      ),
    );
  }

  Widget _buildMockCast() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade800,
                  backgroundImage: const NetworkImage(
                    'https://ui-avatars.com/api/?name=Actor+Name&background=random',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Actor',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
