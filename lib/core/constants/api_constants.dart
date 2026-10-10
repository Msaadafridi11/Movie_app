import 'api_keys.dart';

/// API Constants for The Movie Database (TMDB)
///
/// HOW TO ADD YOUR OWN TMDB API KEY:
/// 1. Create a free account at https://www.themoviedb.org
/// 2. Go to Settings > API and generate an API key (v3 auth)
/// 3. Provide it via `lib/core/constants/api_keys.dart` (copy from `api_keys.example.dart`)
///    or pass via `--dart-define=TMDB_API_KEY=your_key` during `flutter run` / `flutter build`.
class ApiConstants {
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// TMDB v3 API Key (loaded from git-ignored api_keys.dart or dart-define)
  static const String apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: ApiKeys.tmdbApiKey,
  );

  // Image base URLs
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p/w200';
  static const String imageBaseUrlW200 = 'https://image.tmdb.org/t/p/w200';
  static const String imageBaseUrlW500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseUrlOriginal = 'https://image.tmdb.org/t/p/original';

  // Endpoints
  static const String trendingMovies = '/trending/movie/day';
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovie = '/search/movie';
  static const String movieDetails = '/movie';
  static const String genres = '/genre/movie/list';

  // Helpers
  static String posterUrl(String? path, {bool highRes = false}) {
    if (path == null || path.isEmpty) return '';
    return highRes ? '$imageBaseUrlW500$path' : '$imageBaseUrlW200$path';
  }

  static String backdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrlOriginal$path';
  }

  static String youtubeThumbnail(String videoKey) {
    return 'https://img.youtube.com/vi/$videoKey/hqdefault.jpg';
  }
}
