import 'package:movie_app/features/movies/domain/entities/cast.dart';

/// CastModel extending domain Cast entity with TMDB JSON parsing
class CastModel extends Cast {
  const CastModel({
    required super.id,
    required super.name,
    required super.character,
    super.profilePath,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      character: json['character'] as String? ?? '',
      profilePath: json['profile_path'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'character': character,
      'profile_path': profilePath,
    };
  }
}
