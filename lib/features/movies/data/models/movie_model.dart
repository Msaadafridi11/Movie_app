import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// Data model representing Movie, extending domain entity with serialization logic
class MovieModel extends Movie {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    super.voteAverage = 0.0,
    super.voteCount = 0,
    super.releaseDate,
    super.genreIds = const [],
    super.genres = const [],
    super.runtime,
    super.popularity = 0.0,
    super.tagline,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    // Parse genre IDs
    final rawGenreIds = json['genre_ids'];
    List<int> parsedGenreIds = [];
    if (rawGenreIds is List) {
      parsedGenreIds = rawGenreIds.map((e) => (e as num).toInt()).toList();
    }

    // Parse genres if available (e.g., from movie details or map from genreIds)
    List<String> parsedGenres = [];
    if (json['genres'] is List) {
      parsedGenres = (json['genres'] as List)
          .map((e) => e is Map && e['name'] != null ? e['name'].toString() : '')
          .where((name) => name.isNotEmpty)
          .toList();
    } else if (parsedGenreIds.isNotEmpty) {
      parsedGenres = parsedGenreIds
          .map((id) => AppConstants.genreMap[id])
          .where((name) => name != null)
          .cast<String>()
          .toList();
    }

    return MovieModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? json['original_title'] as String? ?? 'Untitled',
      overview: json['overview'] as String? ?? 'No overview available.',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: json['release_date'] as String?,
      genreIds: parsedGenreIds,
      genres: parsedGenres,
      runtime: (json['runtime'] as num?)?.toInt(),
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      tagline: json['tagline'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'vote_count': voteCount,
      'release_date': releaseDate,
      'genre_ids': genreIds,
      'genres': genres.map((name) => {'name': name}).toList(),
      'runtime': runtime,
      'popularity': popularity,
      'tagline': tagline,
    };
  }

  factory MovieModel.fromEntity(Movie entity) {
    return MovieModel(
      id: entity.id,
      title: entity.title,
      overview: entity.overview,
      posterPath: entity.posterPath,
      backdropPath: entity.backdropPath,
      voteAverage: entity.voteAverage,
      voteCount: entity.voteCount,
      releaseDate: entity.releaseDate,
      genreIds: entity.genreIds,
      genres: entity.genres,
      runtime: entity.runtime,
      popularity: entity.popularity,
      tagline: entity.tagline,
    );
  }
}
