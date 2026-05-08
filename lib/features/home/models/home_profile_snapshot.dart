class HomeProfileSnapshot {
  const HomeProfileSnapshot({
    required this.email,
    required this.displayName,
    required this.isFromCache,
  });

  final String email;
  final String displayName;
  final bool isFromCache;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'display_name': displayName,
    };
  }

  factory HomeProfileSnapshot.fromJson(
    Map<String, dynamic> json, {
    required bool isFromCache,
  }) {
    return HomeProfileSnapshot(
      email: (json['email'] as String?) ?? '',
      displayName: (json['display_name'] as String?) ?? '',
      isFromCache: isFromCache,
    );
  }
}
