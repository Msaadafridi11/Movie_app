import 'package:movie_app/core/constants/app_constants.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';

/// Data model representing Movie or TV Show, extending domain entity with serialization logic
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
    super.isTvShow = false,
    super.imdbId,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json, {bool isTv = false}) {
    // Detect TV show from json or explicit flag
    final isTvShow = isTv || json['first_air_date'] != null || json['name'] != null;

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

    // Determine title
    final title = json['title'] as String? ??
        json['name'] as String? ??
        json['original_title'] as String? ??
        json['original_name'] as String? ??
        'Untitled';

    // Determine release date
    final releaseDate = json['release_date'] as String? ??
        json['first_air_date'] as String?;

    // Determine runtime (movies use 'runtime', TV uses 'episode_run_time')
    int? runtime = (json['runtime'] as num?)?.toInt();
    if (runtime == null && json['episode_run_time'] is List && (json['episode_run_time'] as List).isNotEmpty) {
      runtime = ((json['episode_run_time'] as List).first as num?)?.toInt();
    }

    return MovieModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: title,
      overview: json['overview'] as String? ?? 'No overview available.',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
      releaseDate: releaseDate,
      genreIds: parsedGenreIds,
      genres: parsedGenres,
      runtime: runtime,
      popularity: (json['popularity'] as num?)?.toDouble() ?? 0.0,
      tagline: json['tagline'] as String?,
      isTvShow: isTvShow,
      imdbId: json['imdb_id'] as String?,
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
      'genres': genres,
      'runtime': runtime,
      'popularity': popularity,
      'tagline': tagline,
      'is_tv_show': isTvShow,
      'imdb_id': imdbId,
    };
  }

  factory MovieModel.fromEntity(Movie movie) {
    return MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: movie.releaseDate,
      genreIds: movie.genreIds,
      genres: movie.genres,
      runtime: movie.runtime,
      popularity: movie.popularity,
      tagline: movie.tagline,
      isTvShow: movie.isTvShow,
      imdbId: movie.imdbId,
    );
  }
}
