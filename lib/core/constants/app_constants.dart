/// Global Application Constants
class AppConstants {
  static const String appName = 'CineFlix';
  static const String appTagline = 'Discover Movies, Trailers & TV Shows';
  static const String appVersion = '1.0.0';
  
  // Developer Credit & Legal
  static const String developerName = 'Saad Afridi';
  static const String developerCreditText = 'Developed by Saad Afridi';
  static const String developerFooter = 'Made with ❤️ in Flutter by Saad Afridi';
  static String get copyrightNotice => '© ${DateTime.now().year} $developerName. All rights reserved.';

  // Legal & Attribution Disclaimers
  static const String contentDisclaimer =
      'Movie posters, images, trailers and descriptions belong to their respective owners. Trailers are streamed from YouTube. This app does not host or stream full movies.';
  static const String omdbAttribution =
      'Movie ratings, IMDb scores, and Rotten Tomatoes metrics powered by OMDb API.';
  static const String tmdbWebUrl = 'https://www.themoviedb.org';
  static const String supportEmail = 'msaadafridi42@gmail.com';
  static const String githubUrl = 'https://github.com/Msaadafridi11/Movie_app';
  static const String privacyPolicyUrl =
      'https://msaadafridi11.github.io/Movie_app/privacy_policy.html';
  static const String termsOfUseUrl =
      'https://msaadafridi11.github.io/Movie_app/terms_of_use.html';

  // Local Storage Keys
  static const String favoritesStorageKey = 'cineflix_favorites_v1';
  static const String themeStorageKey = 'cineflix_theme_mode_v1';
  static const String cachedFeedKey = 'cineflix_feed_cache_v1';
  static const String onboardingCompletedKey = 'cineflix_onboarding_completed_v1';

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

  static List<Map<String, dynamic>> get genres => [
        {'id': null, 'name': 'All'},
        {'id': 28, 'name': 'Action'},
        {'id': 12, 'name': 'Adventure'},
        {'id': 16, 'name': 'Animation'},
        {'id': 35, 'name': 'Comedy'},
        {'id': 80, 'name': 'Crime'},
        {'id': 18, 'name': 'Drama'},
        {'id': 14, 'name': 'Fantasy'},
        {'id': 27, 'name': 'Horror'},
        {'id': 9648, 'name': 'Mystery'},
        {'id': 10749, 'name': 'Romance'},
        {'id': 878, 'name': 'Sci-Fi'},
        {'id': 53, 'name': 'Thriller'},
      ];
}
