class UserProfile {
  final String id;
  final String? name; // display name
  final String? username; // custom username unik aplikasi
  final String? email;
  final String? photoUrl;
  final bool darkMode;

  const UserProfile({
    required this.id,
    this.name,
    this.username,
    this.email,
    this.photoUrl,
    this.darkMode = false,
  });

  UserProfile copyWith({
    String? name,
    String? username,
    String? email,
    String? photoUrl,
    bool? darkMode,
  }) => UserProfile(
    id: id,
    name: name ?? this.name,
    username: username ?? this.username,
    email: email ?? this.email,
    photoUrl: photoUrl ?? this.photoUrl,
    darkMode: darkMode ?? this.darkMode,
  );
}
