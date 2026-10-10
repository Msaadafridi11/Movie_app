/// Pure Dart Cast entity representing an actor/character
class Cast {
  final int id;
  final String name;
  final String character;
  final String? profilePath;

  const Cast({
    required this.id,
    required this.name,
    required this.character,
    this.profilePath,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Cast && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
