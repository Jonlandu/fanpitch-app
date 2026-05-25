class Profile {
  final String displayName;
  final String? avatarUrl;
  final String? bio;
  final String? country;
  final int? favoriteTeamId;
  final int points;
  final int level;
  final int followerCount;
  final int followingCount;

  Profile({
    required this.displayName,
    this.avatarUrl,
    this.bio,
    this.country,
    this.favoriteTeamId,
    this.points = 0,
    this.level = 1,
    this.followerCount = 0,
    this.followingCount = 0,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
    displayName: (j['display_name'] ?? '') as String,
    avatarUrl: j['avatar_url'] as String?,
    bio: j['bio'] as String?,
    country: j['country'] as String?,
    favoriteTeamId: j['favorite_team'] as int?,
    points: (j['points'] ?? 0) as int,
    level: (j['level'] ?? 1) as int,
    followerCount: (j['follower_count'] ?? 0) as int,
    followingCount: (j['following_count'] ?? 0) as int,
  );
}

class AppUser {
  final int id;
  final String username;
  final String email;
  final Profile profile;
  final bool isMe;
  final bool isFollowing;

  AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.profile,
    this.isMe = false,
    this.isFollowing = false,
  });

  AppUser copyWith({bool? isFollowing, Profile? profile}) => AppUser(
    id: id,
    username: username,
    email: email,
    profile: profile ?? this.profile,
    isMe: isMe,
    isFollowing: isFollowing ?? this.isFollowing,
  );

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    id: j['id'] as int,
    username: j['username'] as String,
    email: (j['email'] ?? '') as String,
    profile: Profile.fromJson(
      (j['profile'] as Map<String, dynamic>?) ?? const {},
    ),
    isMe: (j['is_me'] ?? false) as bool,
    isFollowing: (j['is_following'] ?? false) as bool,
  );
}

class AuthTokens {
  final String access;
  final String refresh;
  AuthTokens(this.access, this.refresh);

  factory AuthTokens.fromJson(Map<String, dynamic> j) =>
      AuthTokens(j['access'] as String, j['refresh'] as String);
}
