import 'package:flutter/material.dart';

/// TikTok-style vertical reaction column on the right edge.
///
/// Pass [counts] (per-emoji breakdown) and [mine] (which emojis the user has
/// already reacted with). `onReact` is called with the emoji string; the parent
/// is responsible for optimistic state + API call.
class SideReactionBar extends StatelessWidget {
  const SideReactionBar({
    super.key,
    required this.counts,
    required this.mine,
    required this.onReact,
    required this.onTapComments,
    required this.commentsCount,
    required this.impressionsCount,
  });

  static const reactions = <String>['❤️', '🤣', '🔥', '😱', '⚽', '🦁'];

  final Map<String, int> counts;
  final List<String> mine;
  final void Function(String emoji) onReact;
  final VoidCallback onTapComments;
  final int commentsCount;
  final int impressionsCount;

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    // Make the column scrollable from the bottom — handles small screens
    // (web at small heights, foldables, landscape) without overflow.
    return SingleChildScrollView(
      reverse: true,
      physics: const ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final emoji in reactions)
            _ReactionButton(
              emoji: emoji,
              count: counts[emoji] ?? 0,
              isActive: mine.contains(emoji),
              onTap: () => onReact(emoji),
              fmt: _fmt,
            ),
          const SizedBox(height: 6),
          _IconButton(
            icon: Icons.mode_comment_outlined,
            label: _fmt(commentsCount),
            onTap: onTapComments,
          ),
          const SizedBox(height: 6),
          _IconButton(
            icon: Icons.visibility_outlined,
            label: _fmt(impressionsCount),
            onTap: null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ReactionButton extends StatefulWidget {
  const _ReactionButton({
    required this.emoji,
    required this.count,
    required this.isActive,
    required this.onTap,
    required this.fmt,
  });

  final String emoji;
  final int count;
  final bool isActive;
  final VoidCallback onTap;
  final String Function(int) fmt;

  @override
  State<_ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<_ReactionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 220),
    lowerBound: 0.85, upperBound: 1.15,
  );

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _pulse() {
    _ctrl.forward(from: 0.85).then((_) => _ctrl.animateTo(1.0));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkResponse(
        onTap: () {
          _pulse();
          widget.onTap();
        },
        radius: 30,
        child: Column(
          children: [
            ScaleTransition(
              scale: _ctrl,
              child: Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive
                      ? Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.35)
                      : Colors.black.withValues(alpha: 0.35),
                ),
                alignment: Alignment.center,
                child: Text(widget.emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.fmt(widget.count),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconButton extends StatelessWidget {
  const _IconButton({
    required this.icon, required this.label, required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 30,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.35),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700,
              shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
            ),
          ),
        ],
      ),
    );
  }
}
