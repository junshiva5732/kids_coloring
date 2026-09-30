import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../art/palette.dart';
import '../art/pictures.dart';
import '../l10n/strings.dart';
import '../services/coloring_store.dart';
import '../widgets/picture_painter.dart';

/// 색칠 화면: 색을 고르고 그림의 칸을 탭하면 칠해진다. 두 손가락으로 확대 가능.
/// 광고 없음 (아이가 실수로 누르지 않도록).
class ColoringScreen extends StatefulWidget {
  final ColoringStore store;
  final Picture picture;
  const ColoringScreen({super.key, required this.store, required this.picture});

  @override
  State<ColoringScreen> createState() => _ColoringScreenState();
}

class _ColoringScreenState extends State<ColoringScreen> with SingleTickerProviderStateMixin {
  Color _color = palette[0];

  /// 되돌리기: (영역, 이전 색)
  final _history = <(int, int)>[];

  late final AnimationController _party = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  Picture get picture => widget.picture;
  ColoringStore get store => widget.store;

  @override
  void dispose() {
    _party.dispose();
    super.dispose();
  }

  void _onTap(TapUpDetails d, Size size) {
    final p = Offset(d.localPosition.dx * 1000 / size.width, d.localPosition.dy * 1000 / size.height);
    final region = picture.regionAt(p);
    final argb = _color.toARGB32();
    if (store.fillsOf(picture)[region] == argb) return;
    final wasComplete = store.isComplete(picture);
    final prev = store.paint(picture, region, argb);
    _history.add((region, prev));
    HapticFeedback.lightImpact();
    if (!wasComplete && store.isComplete(picture)) {
      HapticFeedback.mediumImpact();
      _party.forward(from: 0);
    }
  }

  void _undo() {
    if (_history.isEmpty) return;
    final (region, prev) = _history.removeLast();
    store.paint(picture, region, prev);
  }

  Future<void> _startOver() async {
    final s = S.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.cleaning_services_rounded, size: 36),
        title: Text(s.startOverAsk),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.no)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(s.yes)),
        ],
      ),
    );
    if (ok == true) {
      store.clear(picture);
      _history.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.pictureName(picture.id), style: const TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(tooltip: s.undo, icon: const Icon(Icons.undo_rounded, size: 30), onPressed: _undo),
          IconButton(
            tooltip: s.startOver,
            icon: const Icon(Icons.delete_sweep_rounded, size: 30),
            onPressed: _startOver,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 4)),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InteractiveViewer(
                              maxScale: 4,
                              child: LayoutBuilder(
                                builder: (context, box) {
                                  final size = Size(box.maxWidth, box.maxHeight);
                                  return GestureDetector(
                                    onTapUp: (d) => _onTap(d, size),
                                    child: ListenableBuilder(
                                      listenable: store,
                                      builder: (context, _) => CustomPaint(
                                        size: size,
                                        painter: PicturePainter(picture, store.fillsOf(picture)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _Celebration(animation: _party, text: s.wellDone),
                    ),
                  ),
                ],
              ),
            ),
            _Palette(selected: _color, onPick: (c) => setState(() => _color = c)),
          ],
        ),
      ),
    );
  }
}

/// 크레파스 팔레트: 2줄 x 9칸. 고른 색은 크게, 흰 테두리.
class _Palette extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onPick;
  const _Palette({required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          // 항상 9개씩 2줄. 태블릿에서는 칸을 키운다(최대 72).
          const perRow = 9, gap = 8.0;
          final d = math.min(72.0, (box.maxWidth - gap * (perRow - 1)) / perRow - 2);
          return Center(
            child: SizedBox(
              width: perRow * d + (perRow - 1) * gap + 1,
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: gap,
                runSpacing: 10,
                children: [
                  for (final c in palette)
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onPick(c);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: d,
                        height: d,
                        transform: Matrix4.diagonal3Values(c == selected ? 1.15 : 1, c == selected ? 1.15 : 1, 1),
                        transformAlignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: c == selected ? Colors.white : Colors.black26,
                            width: c == selected ? 4 : 1.5,
                          ),
                          boxShadow: c == selected
                              ? const [BoxShadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2))]
                              : null,
                        ),
                        child: c == selected
                            ? Icon(
                                Icons.brush_rounded,
                                size: d * 0.5,
                                color: c.computeLuminance() > 0.6 ? Colors.black54 : Colors.white,
                              )
                            : null,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 그림을 다 칠하면: 색종이가 쏟아지고 "참 잘했어요!".
class _Celebration extends StatelessWidget {
  final Animation<double> animation;
  final String text;
  const _Celebration({required this.animation, required this.text});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value;
        if (t == 0 || t == 1) return const SizedBox.shrink();
        final pop = Curves.elasticOut.transform((t * 3).clamp(0.0, 1.0));
        final fade = t > 0.8 ? (1 - t) / 0.2 : 1.0;
        return Opacity(
          opacity: fade,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _ConfettiPainter(t))),
              Center(
                child: Transform.scale(
                  scale: pop,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 16)],
                    ),
                    child: Text(
                      '⭐ $text ⭐',
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFFFB8C00)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  _ConfettiPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.Random(7); // 매 프레임 같은 조각 배치
    final paint = Paint();
    for (var i = 0; i < 70; i++) {
      final x0 = r.nextDouble() * size.width;
      final speed = 0.6 + r.nextDouble() * 0.8;
      final y = -30 + (size.height + 60) * ((t * speed + r.nextDouble() * 0.3) % 1.2);
      final x = x0 + math.sin(t * 10 + i) * 20;
      paint.color = palette[i % 11];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * 12 + i);
      canvas.drawRect(const Rect.fromLTWH(-7, -4, 14, 8), paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}
