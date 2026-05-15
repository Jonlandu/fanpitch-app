import 'package:flutter/material.dart';

class ReactionBar extends StatelessWidget {
  const ReactionBar({super.key, required this.counts, required this.onReact});

  static const emojis = ['🔥', '👏', '😱', '😂', '⚽', '💀'];

  final Map<String, int> counts;
  final void Function(String emoji) onReact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final e in emojis)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  minimumSize: const Size(48, 32),
                  visualDensity: VisualDensity.compact,
                ),
                onPressed: () => onReact(e),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(e, style: const TextStyle(fontSize: 18)),
                    if ((counts[e] ?? 0) > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text('${counts[e]}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
