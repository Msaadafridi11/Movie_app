import 'package:flutter/material.dart';
import 'package:movie_app/core/constants/api_constants.dart';
import 'package:movie_app/data/models/movie_model.dart';
import 'package:movie_app/views/screens/detail_screen.dart';

class MovieCard extends StatelessWidget {
  final Results movie;
  final double width;
  final double height;
  final bool showRating;

  const MovieCard({
    super.key,
    required this.movie,
    this.width = 130,
    this.height = 190,
    this.showRating = true,
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
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
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
