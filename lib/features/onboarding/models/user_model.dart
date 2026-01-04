class AppUser {
  final String uid;
  final String name;
  final String email;
  final String bio;//todo , can add bio in future
  final String photoUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.bio,
    required this.photoUrl,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> data) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      bio: data['bio'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
    );
  }

  /// Create a copy of this user with optional field overrides
  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? bio,
    String? photoUrl,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
