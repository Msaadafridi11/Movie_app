import 'package:movie_app/features/movies/domain/entities/omdb_rating.dart';

/// Data model representing OMDb response parsing
class OmdbRatingModel extends OmdbRating {
  const OmdbRatingModel({
    super.imdbRating,
    super.imdbVotes,
    super.rottenTomatoesRating,
    super.metascore,
    super.rated,
    super.awards,
    super.boxOffice,
  });

  factory OmdbRatingModel.fromJson(Map<String, dynamic> json) {
    String? rottenTomatoes;
    final ratings = json['Ratings'];
    if (ratings is List) {
      for (final item in ratings) {
        if (item is Map &&
            item['Source']?.toString().toLowerCase().contains('rotten') == true) {
          rottenTomatoes = item['Value']?.toString();
          break;
        }
      }
    }

    return OmdbRatingModel(
      imdbRating: json['imdbRating']?.toString(),
      imdbVotes: json['imdbVotes']?.toString(),
      rottenTomatoesRating: rottenTomatoes,
      metascore: json['Metascore']?.toString(),
      rated: json['Rated']?.toString(),
      awards: json['Awards']?.toString(),
      boxOffice: json['BoxOffice']?.toString(),
    );
  }
}
