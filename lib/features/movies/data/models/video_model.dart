import 'package:movie_app/features/movies/domain/entities/video.dart';

/// VideoModel extending domain Video entity with TMDB JSON parsing
class VideoModel extends Video {
  const VideoModel({
    required super.id,
    required super.key,
    required super.name,
    required super.site,
    required super.type,
    super.size = 1080,
    super.official = true,
    super.publishedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String? ?? '',
      key: json['key'] as String? ?? '',
      name: json['name'] as String? ?? '',
      site: json['site'] as String? ?? '',
      type: json['type'] as String? ?? '',
      size: (json['size'] as num?)?.toInt() ?? 1080,
      official: json['official'] as bool? ?? true,
      publishedAt: json['published_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'site': site,
      'type': type,
      'size': size,
      'official': official,
      'published_at': publishedAt,
    };
  }
}
