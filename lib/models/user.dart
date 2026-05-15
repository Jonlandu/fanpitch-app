class Profile {
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final int? favoriteTeamId;
  final int points;
  final int level;

  Profile({
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.country,
    this.favoriteTeamId,
    this.points = 0,
    this.level = 1,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    displayName: (j['display_name'] ?? '') as String,
    avatarUrl: j['avatar_url'] as String?,
    bio: j['bio'] as String?,
    country: j['country'] as String?,
    favoriteTeamId: j['favorite_team'] as int?,
    points: (j['points'] ?? 0) as int,
    level: (j['level'] ?? 1) as int,
  );
}

class AppUser {
  final int id;
  final String username;
  final String email;
  final Profile profile;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.profile,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as int,
    username: j['username'] as String,
    email: (j['email'] ?? '') as String,
    profile: Profile.fromJson(
      (j['profile'] as Map<String, dynamic>?) ?? const {},
    ),
  );
}

class AuthTokens {
  final String access;
  final String refresh;
  AuthTokens(this.access, this.refresh);

  factory AuthTokens.fromJson(Map<String, dynamic> j) =>
      AuthTokens(j['access'] as String, j['refresh'] as String);
}
