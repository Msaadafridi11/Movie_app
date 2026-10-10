/// Entity representing a legal streaming/rental/purchase provider (e.g., Netflix, Disney+, Prime Video)
class WatchProvider {
  final int providerId;
  final String providerName;
  final String? logoPath;
  final String type; // 'stream', 'rent', 'buy'
  final int displayPriority;

  const WatchProvider({
    required this.providerId,
    required this.providerName,
    this.logoPath,
    required this.type,
    this.displayPriority = 0,
  });

  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'stream':
      case 'flatrate':
        return 'Stream';
      case 'rent':
        return 'Rent';
      case 'buy':
        return 'Buy';
      default:
        return 'Watch';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchProvider &&
          runtimeType == other.runtimeType &&
          providerId == other.providerId &&
          type == other.type;

  @override
  int get hashCode => providerId.hashCode ^ type.hashCode;
}
