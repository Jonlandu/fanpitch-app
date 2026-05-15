import 'user.dart';

class MediaPost {
  final int id;
  final String s3Key;
  final String mediaType; // "IMAGE" | "VIDEO"
  final String? cdnUrl;
  final String? aiCaption;

  MediaPost({
    required this.id,
    required this.s3Key,
    required this.mediaType,
    this.cdnUrl,
    this.aiCaption,
  });

  bool get isVideo => mediaType == 'VIDEO';

  factory MediaPost.fromJson(Map<String, dynamic> j) => MediaPost(
    id: j['id'] as int,
    s3Key: j['s3_key'] as String,
    mediaType: j['media_type'] as String,
    cdnUrl: j['cdn_url'] as String?,
    aiCaption: j['ai_caption'] as String?,
  );
}

class StatusPost {
  final int id;
  final AppUser author;
  final String bodyText;
  final MediaPost? media;
  final int? teamId;
  final int impressionsCount;
  final int reactionsCount;
  final int commentsCount;
  final Map<String, int> reactionsBreakdown;
  final List<String> myReactions;
  final DateTime expiresAt;
  final DateTime createdAt;

  StatusPost({
    required this.id,
    required this.author,
    required this.bodyText,
    required this.media,
    required this.teamId,
    required this.impressionsCount,
    required this.reactionsCount,
    required this.commentsCount,
    required this.reactionsBreakdown,
    required this.myReactions,
    required this.expiresAt,
    required this.createdAt,
  });

  bool hasReacted(String emoji) => myReactions.contains(emoji);

  StatusPost withOptimisticReaction(String emoji, {required bool toggle}) {
    final next = List<String>.from(myReactions);
    final brk = Map<String, int>.from(reactionsBreakdown);
    if (toggle && next.contains(emoji)) {
      next.remove(emoji);
      brk[emoji] = ((brk[emoji] ?? 1) - 1).clamp(0, 1 << 30);
      if (brk[emoji] == 0) brk.remove(emoji);
    } else if (!next.contains(emoji)) {
      next.add(emoji);
      brk[emoji] = (brk[emoji] ?? 0) + 1;
    }
    final reactCount = brk.values.fold<int>(0, (a, b) => a + b);
    return StatusPost(
      id: id, author: author, bodyText: bodyText, media: media,
      teamId: teamId,
      impressionsCount: impressionsCount,
      reactionsCount: reactCount,
      commentsCount: commentsCount,
      reactionsBreakdown: brk,
      myReactions: next,
      expiresAt: expiresAt, createdAt: createdAt,
    );
  }

  factory StatusPost.fromJson(Map<String, dynamic> j) => StatusPost(
    id: j['id'] as int,
    author: AppUser.fromJson(j['author'] as Map<String, dynamic>),
    bodyText: (j['body_text'] ?? '') as String,
    media: j['media'] == null
        ? null
        : MediaPost.fromJson(j['media'] as Map<String, dynamic>),
    teamId: j['team'] as int?,
    impressionsCount: (j['impressions_count'] ?? 0) as int,
    reactionsCount: (j['reactions_count'] ?? 0) as int,
    commentsCount: (j['comments_count'] ?? 0) as int,
    reactionsBreakdown: ((j['reactions_breakdown'] ?? const {}) as Map)
        .map((k, v) => MapEntry(k as String, v as int)),
    myReactions: ((j['my_reactions'] ?? const []) as List)
        .map((e) => e as String).toList(),
    expiresAt: DateTime.parse(j['expires_at'] as String),
    createdAt: DateTime.parse(j['created_at'] as String),
  );
}
