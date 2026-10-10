/// Pure Dart Video entity representing a trailer, teaser, clip, or featurette
class Video {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final int size;
  final bool official;
  final String? publishedAt;

  const Video({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.size = 1080,
    this.official = true,
    this.publishedAt,
  });

  bool get isYouTube => site.toLowerCase() == 'youtube';
  bool get isTrailer => type.toLowerCase() == 'trailer';
  bool get isTeaser => type.toLowerCase() == 'teaser';
  bool get isClip => type.toLowerCase() == 'clip';
  bool get isBehindTheScenes =>
      type.toLowerCase().contains('behind the scenes') ||
      type.toLowerCase().contains('behind');
  bool get isFeaturette => type.toLowerCase() == 'featurette';

  String get thumbnailUrl => 'https://img.youtube.com/vi/$key/hqdefault.jpg';
  String get maxResThumbnailUrl => 'https://img.youtube.com/vi/$key/maxresdefault.jpg';

  /// Standard category display badge
  String get categoryBadge {
    if (isTrailer) return 'TRAILER';
    if (isTeaser) return 'TEASER';
    if (isClip) return 'CLIP';
    if (isBehindTheScenes) return 'BTS';
    if (isFeaturette) return 'FEATURETTE';
    return type.isEmpty ? 'VIDEO' : type.toUpperCase();
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Video && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
