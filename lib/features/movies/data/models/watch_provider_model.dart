import 'package:movie_app/features/movies/domain/entities/watch_provider.dart';

/// Data model representing a legal watch provider from TMDB
class WatchProviderModel extends WatchProvider {
  const WatchProviderModel({
    required super.providerId,
    required super.providerName,
    super.logoPath,
    required super.type,
    super.displayPriority = 0,
  });

  factory WatchProviderModel.fromJson(Map<String, dynamic> json, {required String type}) {
    return WatchProviderModel(
      providerId: (json['provider_id'] as num?)?.toInt() ?? 0,
      providerName: json['provider_name'] as String? ?? 'Unknown Provider',
      logoPath: json['logo_path'] as String?,
      type: type,
      displayPriority: (json['display_priority'] as num?)?.toInt() ?? 0,
    );
  }

  /// Parse the entire TMDB /watch/providers response
  static List<WatchProviderModel> listFromTmdbResponse(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) return [];
    final results = responseData['results'];
    if (results is! Map<String, dynamic>) return [];

    // Prioritize US, otherwise use the first available country code
    final countryData = results['US'] ??
        (results.isNotEmpty ? results.values.first : null);

    if (countryData is! Map) return [];

    final List<WatchProviderModel> providers = [];

    void addCategory(dynamic list, String type) {
      if (list is List) {
        for (final item in list) {
          if (item is Map) {
            providers.add(
              WatchProviderModel.fromJson(
                Map<String, dynamic>.from(item),
                type: type,
              ),
            );
          }
        }
      }
    }

    addCategory(countryData['flatrate'], 'stream');
    addCategory(countryData['rent'], 'rent');
    addCategory(countryData['buy'], 'buy');

    // Sort by display priority
    providers.sort((a, b) => a.displayPriority.compareTo(b.displayPriority));
    return providers;
  }
}
