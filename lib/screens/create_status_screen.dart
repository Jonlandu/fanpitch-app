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
  final _brief = TextEditingController();

  // Stored as bytes so it works on every platform (web included).
  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageMime;

  String? _caption;
  String _captionLang = 'fr';
  bool _busy = false;
  bool _captionLoading = false;

  // Lang code -> (flag, label) for the picker chips.
  static const _langs = <String, ({String flag, String label})>{
    'fr': (flag: '🇫🇷', label: 'Français'),
    'ln': (flag: '🇨🇩', label: 'Lingala'),
    'sw': (flag: '🇰🇪', label: 'Swahili'),
    'en': (flag: '🇬🇧', label: 'English'),
  };

  @override
  void dispose() {
    _body.dispose();
    _brief.dispose();
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
          .aiCaption(
            summary: _body.text,
            lang: _captionLang,
            brief: _brief.text.trim(),
          );
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
              const SizedBox(height: 16),

              // ── AI Caption Studio ──────────────────────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'AI Caption Studio',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Décris le moment dans ta langue, l\'IA écrit la légende parfaite.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _brief,
                      maxLines: 2,
                      maxLength: 140,
                      decoration: const InputDecoration(
                        hintText:
                            "Ex: les fans congolais qui dansent après le but...",
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: _langs.entries.map((e) {
                        final selected = _captionLang == e.key;
                        return ChoiceChip(
                          selected: selected,
                          label: Text('${e.value.flag} ${e.value.label}'),
                          onSelected: (_) =>
                              setState(() => _captionLang = e.key),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _captionLoading ? null : _aiCaption,
                        icon: _captionLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.bolt),
                        label: const Text('Générer la légende'),
                      ),
                    ),
                  ],
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"$_caption"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _body.text = _caption!;
                                _body.selection = TextSelection.collapsed(
                                  offset: _body.text.length,
                                );
                              });
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Utiliser'),
                          ),
                          TextButton.icon(
                            onPressed: _captionLoading ? null : _aiCaption,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Régénérer'),
                          ),
                        ],
                      ),
                    ],
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
