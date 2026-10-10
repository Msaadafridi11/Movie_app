/// Global Application Constants
class AppConstants {
  static const String appName = 'CineStream';
  static const String appTagline = 'Your Gateway to Cinematic Universe';
  static const String appVersion = '1.0.0';
  
  // Developer Credit
  static const String developerName = 'Saad Afridi';
  static const String developerCreditText = 'Developed by Saad Afridi';
  static const String developerFooter = 'Developed by Saad Afridi ❤️ in Flutter';

  // Local Storage Keys
  static const String favoritesStorageKey = 'cine_favorite_movies_cache_v1';
  static const String themeStorageKey = 'cine_theme_mode_v1';
  static const String cachedFeedKey = 'cine_feed_cache_v1';

  // TMDB Genre Map (Id to Name)
  static const Map<int, String> genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Sci-Fi',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };
}
