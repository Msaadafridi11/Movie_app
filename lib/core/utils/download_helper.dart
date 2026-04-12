import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/data/repositories/movie_repository.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;
import 'package:path_provider/path_provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class DownloadHelper {
  static Future<void> downloadVideo(BuildContext context, Results movie) async {
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
}
