/// Pure Dart Movie entity representing a movie in the domain layer
class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<int> genreIds;
  final List<String> genres;
  final int? runtime;
  final double popularity;
  final String? tagline;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.releaseDate,
    this.genreIds = const [],
    this.genres = const [],
    this.runtime,
    this.popularity = 0.0,
    this.tagline,
  });

  /// Formatted release year (e.g., '2024')
  String get releaseYear {
    if (releaseDate == null || releaseDate!.isEmpty) return 'N/A';
    try {
      return releaseDate!.split('-').first;
    } catch (_) {
      return 'N/A';
    }
  }

  /// Formatted runtime string (e.g., '2h 15m')
  String get formattedRuntime {
    if (runtime == null || runtime! <= 0) return '';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  /// Formatted rating out of 10 with 1 decimal place (e.g., '8.4')
  String get formattedRating => voteAverage.toStringAsFixed(1);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Movie && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
