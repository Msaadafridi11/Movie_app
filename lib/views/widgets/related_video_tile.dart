import 'package:flutter/material.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/viewmodel/favorite_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/utils/download_helper.dart';

class RelatedVideoTile extends StatelessWidget {
  final Results movie;
  final VoidCallback onTap;

  const RelatedVideoTile({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent, // Ensures entire row is clickable
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    movie.backdropPath != null
                        ? 'https://image.tmdb.org/t/p/w200${movie.backdropPath}'
                        : (movie.posterPath != null 
                            ? 'https://image.tmdb.org/t/p/w200${movie.posterPath}' 
                            : ApiConstants.imageBaseUrl),
                    width: 140,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 140,
                      height: 80,
                      color: Colors.grey.shade900,
                      child: const Icon(Icons.movie, color: Colors.grey),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black45,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title ?? 'No title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        movie.releaseDate?.split('-').first ?? 'Year',
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            (movie.voteAverage ?? 0.0).toStringAsFixed(1),
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Consumer<FavoriteViewModel>(
                  builder: (context, favVM, child) {
                    final isFav = favVM.isFavorite(movie);
                    return IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border,
                        color: isFav ? Colors.redAccent : Colors.grey,
                      ),
                      onPressed: () => favVM.toggleFavorite(movie),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download, color: Colors.white70),
                  onPressed: () => DownloadHelper.downloadVideo(context, movie),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
