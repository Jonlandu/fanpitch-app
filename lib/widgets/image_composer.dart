import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Mini "meme studio" — given an image, lets the user drop emoji stickers
/// and meme-style text on top, drag/pinch them around, then captures the
/// composed result as PNG bytes.
///
/// Usage:
///   final composed = await Navigator.of(ctx).push<Uint8List>(
///     MaterialPageRoute(builder: (_) => ImageComposerScreen(bytes: original)),
///   );
class ImageComposerScreen extends StatefulWidget {
  const ImageComposerScreen({super.key, required this.bytes});
  final Uint8List bytes;
  @override
  State<ImageComposerScreen> createState() => _ImageComposerScreenState();
}

class _ImageComposerScreenState extends State<ImageComposerScreen> {
  final GlobalKey _boundary = GlobalKey();
  final List<_Overlay> _overlays = [];
  int? _selectedIndex;
  bool _showStickerPanel = false;
  bool _busy = false;

  // Football + meme stickers — chosen to make people laugh.
  static const _stickers = <String>[
    '⚽', '🔥', '🤣', '😱', '🦁', '🏆',
    '🐐', '🤡', '💀', '👀', '😎', '🤯',
    '🥲', '💯', '🎯', '🥶', '🤝', '💪',
    '🇵🇹', '🇨🇩', '🇫🇷', '🇧🇷', '🥇', '❤️',
  ];

  void _addEmoji(String e) {
    setState(() {
      _overlays.add(_Overlay(
        kind: _OverlayKind.emoji, content: e,
        position: const Offset(120, 160), scale: 1.5,
      ));
      _selectedIndex = _overlays.length - 1;
      _showStickerPanel = false;
    });
  }

  Future<void> _addText() async {
    final ctrl = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add meme text'),
        content: TextField(
          controller: ctrl, autofocus: true, maxLength: 60,
          decoration: const InputDecoration(
            hintText: 'POV: tu paries 1-1',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (text == null || text.isEmpty) return;
    setState(() {
      _overlays.add(_Overlay(
        kind: _OverlayKind.text, content: text,
        position: const Offset(60, 80), scale: 1.0,
      ));
      _selectedIndex = _overlays.length - 1;
    });
  }

  void _undo() {
    if (_overlays.isEmpty) return;
    setState(() {
      _overlays.removeLast();
      _selectedIndex = null;
    });
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final bytes = await _capture();
      if (!mounted) return;
      Navigator.of(context).pop(bytes);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Compose failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<Uint8List> _capture() async {
    final boundary = _boundary.currentContext!.findRenderObject()
        as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Meme Studio'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
            onPressed: _overlays.isEmpty ? null : _undo,
          ),
          TextButton.icon(
            onPressed: _busy ? null : _save,
            icon: _busy
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2,
                        color: Colors.white))
                : const Icon(Icons.check, color: Colors.white),
            label: const Text('Done', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: () => setState(() => _selectedIndex = null),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: RepaintBoundary(
                    key: _boundary,
                    child: Container(
                      color: Colors.black,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(widget.bytes, fit: BoxFit.cover),
                          for (int i = 0; i < _overlays.length; i++)
                            _OverlayWidget(
                              overlay: _overlays[i],
                              selected: i == _selectedIndex,
                              onTap: () =>
                                  setState(() => _selectedIndex = i),
                              onMove: (delta) {
                                setState(() {
                                  _overlays[i].position += delta;
                                });
                              },
                              onScale: (f) {
                                setState(() {
                                  _overlays[i].scale =
                                      (_overlays[i].scale * f)
                                          .clamp(0.4, 6.0);
                                });
                              },
                              onRotate: (r) {
                                setState(() {
                                  _overlays[i].rotation += r;
                                });
                              },
                              onDelete: () {
                                setState(() {
                                  _overlays.removeAt(i);
                                  _selectedIndex = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_showStickerPanel) _StickerPanel(onPick: _addEmoji),
          _Toolbar(
            onSticker: () =>
                setState(() => _showStickerPanel = !_showStickerPanel),
            onText: _addText,
            stickerOpen: _showStickerPanel,
          ),
        ],
      ),
    );
  }
}

enum _OverlayKind { emoji, text }

class _Overlay {
  _Overlay({
    required this.kind,
    required this.content,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  final _OverlayKind kind;
  final String content;
  Offset position;
  double scale;
  double rotation;
}

class _OverlayWidget extends StatelessWidget {
  const _OverlayWidget({
    required this.overlay,
    required this.selected,
    required this.onTap,
    required this.onMove,
    required this.onScale,
    required this.onRotate,
    required this.onDelete,
  });

  final _Overlay overlay;
  final bool selected;
  final VoidCallback onTap;
  final void Function(Offset delta) onMove;
  final void Function(double factor) onScale;
  final void Function(double rotation) onRotate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final child = overlay.kind == _OverlayKind.emoji
        ? Text(overlay.content,
            style: TextStyle(fontSize: 36 * overlay.scale))
        : _MemeText(text: overlay.content, scale: overlay.scale);

    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: (d) => onMove(d.delta),
        onScaleUpdate: (d) {
          if (d.scale != 1.0) onScale(d.scale);
          if (d.rotation != 0.0) onRotate(d.rotation);
        },
        child: Transform.rotate(
          angle: overlay.rotation,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected ? Colors.white : Colors.transparent,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: child,
              ),
              if (selected)
                Positioned(
                  right: -10, top: -10,
                  child: GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.redAccent,
                      ),
                      child: const Icon(Icons.close,
                          size: 14, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemeText extends StatelessWidget {
  const _MemeText({required this.text, required this.scale});
  final String text;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 22.0 * scale;
    // White text with thick black stroke — classic meme style.
    return Stack(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = Colors.black,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _StickerPanel extends StatelessWidget {
  const _StickerPanel({required this.onPick});
  final void Function(String emoji) onPick;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: GridView.count(
        crossAxisCount: 8,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: [
          for (final e in _ImageComposerScreenState._stickers)
            InkResponse(
              onTap: () => onPick(e),
              child: Center(
                child: Text(e, style: const TextStyle(fontSize: 28)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.onSticker,
    required this.onText,
    required this.stickerOpen,
  });
  final VoidCallback onSticker;
  final VoidCallback onText;
  final bool stickerOpen;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ToolButton(
              icon: Icons.emoji_emotions_outlined,
              label: 'Stickers',
              active: stickerOpen,
              onTap: onSticker,
            ),
            _ToolButton(
              icon: Icons.text_fields,
              label: 'Text',
              active: false,
              onTap: onText,
            ),
            const _Hint(),
          ],
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Theme.of(context).colorScheme.primary : Colors.white;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(color: color, fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.white60, size: 18),
          SizedBox(height: 2),
          Text('Drag • pinch • rotate',
              style: TextStyle(color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}
