import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/feed_provider.dart';
import '../services/api_client.dart';

class CreateStatusScreen extends ConsumerStatefulWidget {
  const CreateStatusScreen({super.key});
  @override
  ConsumerState<CreateStatusScreen> createState() => _CreateStatusScreenState();
}

class _CreateStatusScreenState extends ConsumerState<CreateStatusScreen> {
  final _body = TextEditingController();

  // Stored as bytes so it works on every platform (web included).
  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageMime;

  String? _caption;
  bool _busy = false;
  bool _captionLoading = false;

  @override
  void dispose() {
    _body.dispose();
    super.dispose();
  }

  String _mimeFromName(String p) {
    final lower = p.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final f = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 86,
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageName = f.name.isNotEmpty ? f.name : 'upload.jpg';
      _imageMime = _mimeFromName(f.name);
    });
  }

  Future<void> _aiCaption() async {
    setState(() => _captionLoading = true);
    try {
      final r = await ref
          .read(apiClientProvider)
          .aiCaption(summary: _body.text);
      if (!mounted) return;
      setState(() => _caption = r['caption'] as String?);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('AI caption failed: $e')));
    } finally {
      if (mounted) setState(() => _captionLoading = false);
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() => _busy = true);
    final api = ref.read(apiClientProvider);
    try {
      int? mediaId;
      if (_imageBytes != null) {
        final media = await api.uploadAndRegisterMedia(
          bytes: _imageBytes!,
          filename: _imageName ?? 'upload.jpg',
          contentType: _imageMime ?? 'image/jpeg',
          aiCaption: _caption,
        );
        mediaId = media.id;
      }
      await api.createStatus(
        bodyText:
            _caption != null && _caption!.isNotEmpty && _imageBytes == null
            ? '${_body.text}\n\n$_caption'
            : _body.text,
        mediaId: mediaId,
      );
      await ref.read(feedProvider.notifier).refresh();
      if (mounted) context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Post failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New status'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.go('/'),
        ),
        actions: [
          TextButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _body,
                maxLines: 5,
                maxLength: 280,
                decoration: const InputDecoration(
                  hintText: "What's the vibe? 🔥",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Add image'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _captionLoading ? null : _aiCaption,
                    icon: _captionLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: const Text('AI caption'),
                  ),
                ],
              ),
              if (_caption != null && _caption!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '"$_caption"',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
              if (_imageBytes != null) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  // Image.memory works on every platform (web included).
                  child: Image.memory(
                    _imageBytes!,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Remove image'),
                  onPressed: () => setState(() {
                    _imageBytes = null;
                    _imageName = null;
                    _imageMime = null;
                  }),
                ),
              ],
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Statuses auto-expire after 7 days.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
