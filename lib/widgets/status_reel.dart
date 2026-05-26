import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/status_post.dart';
import '../services/api_client.dart';
import 'comment_sheet.dart';
import 'side_reaction_bar.dart';

/// One full-screen "reel" card. Image or video, auto-pauses when not visible.
class StatusReel extends ConsumerStatefulWidget {
  const StatusReel({
    super.key,
    required this.status,
    required this.isActive,
    required this.onChanged,
  });

  final StatusPost status;
  final bool isActive;
  final void Function(StatusPost updated) onChanged;

  @override
  ConsumerState<StatusReel> createState() => _StatusReelState();
}

class _StatusReelState extends ConsumerState<StatusReel> {
  VideoPlayerController? _video;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    final url = widget.status.media?.cdnUrl;
    if (widget.status.media?.isVideo == true && url != null) {
      _video = VideoPlayerController.networkUrl(Uri.parse(url));
      _video!.setLooping(true);
      _video!
          .initialize()
          .then((_) {
            if (!mounted) return;
            setState(() => _videoReady = true);
            if (widget.isActive) _video!.play();
          })
          .catchError((_) {
            /* swallow — fallback to thumbnail */
          });
    }
  }

  @override
  void didUpdateWidget(covariant StatusReel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_video == null || !_videoReady) return;
    if (widget.isActive && !_video!.value.isPlaying) {
      _video!.play();
    } else if (!widget.isActive && _video!.value.isPlaying) {
      _video!.pause();
      _video!.seekTo(Duration.zero);
    }
  }

  @override
  void dispose() {
    _video?.dispose();
    super.dispose();
  }

  Future<void> _toggleReaction(String emoji) async {
    final s = widget.status;
    final had = s.hasReacted(emoji);
    // Optimistic
    final next = s.withOptimisticReaction(emoji, toggle: true);
    widget.onChanged(next);
    try {
      await ref
          .read(apiClientProvider)
          .toggleReaction(
            targetType: 'STATUS',
            targetId: s.id,
            emoji: emoji,
            currentlyOn: had,
          );
    } catch (_) {
      // Revert on failure
      widget.onChanged(s);
    }
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(
        targetType: 'STATUS',
        targetId: widget.status.id,
        onPosted: () {
          widget.onChanged(
            StatusPost(
              id: widget.status.id,
              author: widget.status.author,
              bodyText: widget.status.bodyText,
              media: widget.status.media,
              teamId: widget.status.teamId,
              impressionsCount: widget.status.impressionsCount,
              reactionsCount: widget.status.reactionsCount,
              commentsCount: widget.status.commentsCount + 1,
              reactionsBreakdown: widget.status.reactionsBreakdown,
              myReactions: widget.status.myReactions,
              expiresAt: widget.status.expiresAt,
              createdAt: widget.status.createdAt,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.status;
    final p = s.author.profile;
    final ts = DateFormat('d MMM • HH:mm').format(s.createdAt.toLocal());

    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. background media
        _Background(status: s, video: _video, videoReady: _videoReady),

        // 2. gradient for legibility
        const _BottomScrim(),
        const _TopScrim(),

        // 3. TOP header — author + timestamp always visible above the fold
        Positioned(
          left: 16,
          right: 96,
          top: MediaQuery.of(context).padding.top + 64,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.white,
                child: Text(
                  (p.displayName.isNotEmpty
                          ? p.displayName.substring(0, 1)
                          : s.author.username.substring(0, 1))
                      .toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '@${s.author.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                    Text(
                      ts,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 11,
                        shadows: const [
                          Shadow(blurRadius: 4, color: Colors.black54),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 4. BOTTOM — caption (truncated) + AI caption + comments teaser
        Positioned(
          left: 16,
          right: 96,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (s.bodyText.isNotEmpty)
                Text(
                  s.bodyText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.3,
                    shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                  ),
                ),
              if (s.media?.aiCaption != null &&
                  s.media!.aiCaption!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.auto_awesome,
                      color: Colors.amber,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '"${s.media!.aiCaption}"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (s.commentsCount > 0) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: _openComments,
                  child: Text(
                    AppL10n.of(context).feedSeeComments(s.commentsCount),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(blurRadius: 4, color: Colors.black54),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // 4. right column: reactions / comments / impressions
        Positioned(
          right: 8,
          bottom: 16,
          top: MediaQuery.of(context).padding.top + 80,
          child: SafeArea(
            child: SideReactionBar(
              counts: s.reactionsBreakdown,
              mine: s.myReactions,
              onReact: _toggleReaction,
              onTapComments: _openComments,
              commentsCount: s.commentsCount,
              impressionsCount: s.impressionsCount,
            ),
          ),
        ),
      ],
    );
  }
}

class _Background extends StatelessWidget {
  const _Background({
    required this.status,
    required this.video,
    required this.videoReady,
  });
  final StatusPost status;
  final VideoPlayerController? video;
  final bool videoReady;

  @override
  Widget build(BuildContext context) {
    final media = status.media;
    if (media?.isVideo == true && video != null && videoReady) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: video!.value.size.width,
          height: video!.value.size.height,
          child: VideoPlayer(video!),
        ),
      );
    }
    if (media?.cdnUrl != null) {
      return CachedNetworkImage(
        imageUrl: media!.cdnUrl!,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => _gradient(context),
      );
    }
    return _gradient(context);
  }

  Widget _gradient(BuildContext context) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.tertiary,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
    alignment: Alignment.center,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Text(
        status.bodyText,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopScrim extends StatelessWidget {
  const _TopScrim();
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.center,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
