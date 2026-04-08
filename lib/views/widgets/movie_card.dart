import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/views/screens/detail_screen.dart';
import 'package:movie_app/viewmodel/favorite_viewmodel.dart';

class MovieCard extends StatelessWidget {
  final Results movie;
  final double width;
  final double height;
  final bool showRating;
  final EdgeInsetsGeometry? margin;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 130,
    this.height = 190,
    this.showRating = true,
    this.margin = const EdgeInsets.only(right: 16),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
             builder: (_) => DetailScreen(movie: movie),
          )
        );
      },
      child: Container(
        width: width,
        margin: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: movie.posterPath != null
                        ? Image.network(
                            '${ApiConstants.imageBaseUrl}${movie.posterPath}',
                            width: width,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: width,
                            color: Colors.grey.shade900,
                            child: const Icon(Icons.movie, color: Colors.grey),
                          ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Consumer<FavoriteViewModel>(
                      builder: (context, favVM, child) {
                        final isFav = favVM.isFavorite(movie);
                        return GestureDetector(
                          onTap: () => favVM.toggleFavorite(movie),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black45,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? Colors.redAccent : Colors.white,
                              size: 20,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              movie.title ?? 'Unknown',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (showRating)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      (movie.voteAverage ?? 0.0).toStringAsFixed(1),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
