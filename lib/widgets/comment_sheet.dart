import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../services/api_client.dart';

/// Bottom-sheet comments. Loads on open, supports posting.
class CommentSheet extends ConsumerStatefulWidget {
  const CommentSheet({
    super.key,
    required this.targetType,
    required this.targetId,
    required this.onPosted,
  });

  final String targetType;
  final int targetId;
  final VoidCallback onPosted;

  @override
  ConsumerState<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends ConsumerState<CommentSheet> {
  final _ctrl = TextEditingController();
  List<Map<String, dynamic>> _items = const [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await ref.read(apiClientProvider).listComments(
        targetType: widget.targetType, targetId: widget.targetId,
      );
      if (mounted) setState(() => _items = list);
    } catch (_) {
      // ignore — show empty state
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final body = _ctrl.text.trim();
    if (body.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await ref.read(apiClientProvider).postComment(
        targetType: widget.targetType, targetId: widget.targetId,
        body: body,
      );
      _ctrl.clear();
      widget.onPosted();
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Comment failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text('${_items.length} comments',
                      style: Theme.of(context).textTheme.titleMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _items.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text('Be the first to react. Cook 🔥'),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _items.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 2),
                          itemBuilder: (_, i) => _CommentTile(c: _items[i]),
                        ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      maxLines: 3,
                      minLines: 1,
                      maxLength: 500,
                      decoration: const InputDecoration(
                        hintText: 'Drop a line…',
                        border: OutlineInputBorder(),
                        counterText: '',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 14, height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.send, size: 16),
                    label: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({required this.c});
  final Map<String, dynamic> c;

  @override
  Widget build(BuildContext context) {
    final body = (c['body'] ?? '') as String;
    final author = c['author'];
    final name = author is Map
        ? (author['username'] ?? 'user').toString()
        : 'user $author';
    final ts = c['created_at'] != null
        ? DateFormat('d MMM HH:mm').format(
            DateTime.parse(c['created_at'] as String).toLocal())
        : '';
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        child: Text(name.substring(0, 1).toUpperCase()),
      ),
      title: Row(
        children: [
          Text('@$name', style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text(ts,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
      subtitle: Text(body),
    );
  }
}
