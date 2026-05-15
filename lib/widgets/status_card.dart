import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/status_post.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({super.key, required this.status});
  final StatusPost status;

  @override
  Widget build(BuildContext context) {
    final p = status.author.profile;
    final ts = DateFormat('d MMM • HH:mm').format(status.createdAt.toLocal());
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(
                    (p.displayName.isNotEmpty
                            ? p.displayName.substring(0, 1)
                            : status.author.username.substring(0, 1))
                        .toUpperCase(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.displayName.isEmpty
                              ? status.author.username
                              : p.displayName,
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)),
                      Text(ts,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const Icon(Icons.access_time, size: 14),
                const SizedBox(width: 4),
                Text(
                  _expiresIn(status.expiresAt),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            if (status.bodyText.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(status.bodyText, style: const TextStyle(fontSize: 15)),
            ],
            if (status.media?.cdnUrl != null) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: status.media!.cdnUrl!,
                  fit: BoxFit.cover,
                  height: 220, width: double.infinity,
                  placeholder: (_, __) => Container(
                    height: 220,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                ),
              ),
            ],
            if (status.media?.aiCaption != null &&
                status.media!.aiCaption!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('"${status.media!.aiCaption}"',
                        style: const TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 13)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _expiresIn(DateTime t) {
    final d = t.difference(DateTime.now());
    if (d.isNegative) return 'expired';
    if (d.inDays >= 1) return '${d.inDays}d';
    if (d.inHours >= 1) return '${d.inHours}h';
    return '${d.inMinutes}m';
  }
}
