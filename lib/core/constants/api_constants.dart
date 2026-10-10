import 'api_keys.dart';

/// API Constants for The Movie Database (TMDB) and Open Movie Database (OMDb)
class ApiConstants {
  // TMDB Base URL
  static const String baseUrl = 'https://api.themoviedb.org/3';

  // OMDb Base URL
  static const String omdbBaseUrl = 'https://www.omdbapi.com';

  /// TMDB v3 API Key (loaded from git-ignored api_keys.dart or dart-define)
  static const String apiKey = String.fromEnvironment(
    'TMDB_API_KEY',
    defaultValue: ApiKeys.tmdbApiKey,
  );

  /// OMDb API Key (optional, for IMDb / Rotten Tomatoes scores)
  static const String omdbApiKey = String.fromEnvironment(
    'OMDB_API_KEY',
    defaultValue: ApiKeys.omdbApiKey,
  );

  // Image base URLs
  static const String imageBaseUrlW92 = 'https://image.tmdb.org/t/p/w92';
  static const String imageBaseUrlW154 = 'https://image.tmdb.org/t/p/w154';
  static const String imageBaseUrlW200 = 'https://image.tmdb.org/t/p/w200';
  static const String imageBaseUrlW500 = 'https://image.tmdb.org/t/p/w500';
  static const String imageBaseUrlOriginal = 'https://image.tmdb.org/t/p/original';

  // TMDB Movie Endpoints
  static const String trendingMovies = '/trending/movie/day';
  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovie = '/search/movie';
  static const String searchMulti = '/search/multi';
  static const String movieDetails = '/movie';
  static const String genres = '/genre/movie/list';
  static const String discoverMovie = '/discover/movie';

  // TMDB TV Show Endpoints
  static const String trendingTv = '/trending/tv/day';
  static const String popularTv = '/tv/popular';
  static const String topRatedTv = '/tv/top_rated';
  static const String tvDetails = '/tv';

  // Required TMDB Attribution
  static const String tmdbAttributionText =
      'This product uses the TMDB API but is not endorsed or certified by TMDB.';
  static const String tmdbLogoUrl =
      'https://www.themoviedb.org/assets/2/v4/logos/v2/blue_square_2-d537fb228cf3ded904ef09b136fe3fec72548ebc1fea3fbbd1ad9e36364db38b.png';

  // Helpers
  static String posterUrl(String? path, {bool highRes = false}) {
    if (path == null || path.isEmpty) return '';
    return highRes ? '$imageBaseUrlW500$path' : '$imageBaseUrlW200$path';
  }

  static String backdropUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrlOriginal$path';
  }

  static String watchProviderLogo(String? logoPath) {
    if (logoPath == null || logoPath.isEmpty) return '';
    return '$imageBaseUrlW92$logoPath';
  }

  static String youtubeThumbnail(String videoKey, {bool highRes = false}) {
    if (highRes) {
      return 'https://img.youtube.com/vi/$videoKey/maxresdefault.jpg';
    }
    return 'https://img.youtube.com/vi/$videoKey/hqdefault.jpg';
  }
}
