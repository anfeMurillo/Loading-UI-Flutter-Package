import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A fake "image analysis" scanning loader.
///
/// Renders a noisy placeholder image with a bright scan-line that sweeps
/// top-to-bottom (`repeat(reverse: true)`), as if an AI is processing the
/// image. Built entirely with Flutter primitives — no assets required.
/// Respects [MediaQueryData.disableAnimations].
class AnalyzingImageLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final Duration duration;
  final String? semanticsLabel;

  const AnalyzingImageLoader({
    super.key,
    this.size = 48.0,
    this.color,
    this.backgroundColor,
    this.duration = const Duration(milliseconds: 2500),
    this.semanticsLabel,
  });

  @override
  State<AnalyzingImageLoader> createState() => _AnalyzingImageLoaderState();
}

class _AnalyzingImageLoaderState extends State<AnalyzingImageLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  // times: [0, 0.6, 0.6, 1] with repeatType:mirror + repeatDelay:0.2
  // Simplified to: forward 0→0.6 (wipe out), hold 0.6→1, then reverse (wipe in).
  // AnimationController.repeat(reverse:true) covers the mirror.
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Override to use reverse:true (mirror).
    final reduced = reducedMotionOf(context);
    if (reduced) {
      if (_ctrl.isAnimating) _ctrl.stop();
      _ctrl.value = 0.0;
    } else if (!_ctrl.isAnimating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnalyzingImageLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _ctrl.duration = widget.duration;
      if (_ctrl.isAnimating) _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Easing curve from original: [0.175, 0.885, 0.32, 1].
  static const _ease = Cubic(0.175, 0.885, 0.32, 1);

  // Keyframe mapping: times=[0, 0.6, 0.6, 1].
  // clipRight goes from 0% (fully visible) → 105% (fully wiped) for t in [0,0.6].
  // Holds at 105% for t in [0.6,1].
  double _clipRight(double raw) {
    // raw controller goes 0→1 (forward) or 1→0 (reverse due to mirror).
    final t = raw.clamp(0.0, 1.0);
    if (t <= 0.6) {
      return _ease.transform(t / 0.6) * 1.05;
    }
    return 1.05;
  }

  // Scan bar position: translateX from +1400% to -80% for t in [0,0.6].
  double _scanX(double raw, double totalWidth) {
    final t = raw.clamp(0.0, 1.0);
    if (t <= 0.6) {
      final p = _ease.transform(t / 0.6);
      return totalWidth * (14.0 - 14.8 * p);
    }
    return -totalWidth * 0.8;
  }

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    final bg = widget.backgroundColor ?? Theme.of(context).colorScheme.surface;

    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Analyzing image',
      liveRegion: true,
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, _) {
              final clipRight = _clipRight(_ctrl.value);
              final scanX = _scanX(_ctrl.value, widget.size);
              final barW = widget.size * 0.07;

              return Stack(
                children: [
                  // Layer 1: noisy background icon.
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ImageIconPainter(
                        color: c,
                        noisy: true,
                        viewSize: 24,
                      ),
                    ),
                  ),
                  // Layer 2: clean icon revealed from right by clip.
                  Positioned.fill(
                    child: ClipRect(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        widthFactor: (1.0 - clipRight).clamp(0.0, 1.0),
                        child: OverflowBox(
                          maxWidth: widget.size,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            width: widget.size,
                            height: widget.size,
                            color: bg,
                            child: CustomPaint(
                              painter: _ImageIconPainter(
                                color: c,
                                noisy: false,
                                viewSize: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Layer 3: scan bar.
                  Positioned(
                    left: scanX,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: barW,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(barW / 2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// Paints the image icon SVG path (24×24 viewBox), optionally with noise pixels.
class _ImageIconPainter extends CustomPainter {
  final Color color;
  final bool noisy;
  final double viewSize;

  _ImageIconPainter({
    required this.color,
    required this.noisy,
    required this.viewSize,
  });

  static Path _buildIconPath() {
    return Path()
      // Mountains chevron 1
      ..moveTo(4.272, 20.728)
      ..lineTo(10.869, 14.131)
      ..cubicTo(11.265, 13.735, 11.463, 13.537, 11.691, 13.463)
      ..cubicTo(11.892, 13.398, 12.108, 13.398, 12.309, 13.463)
      ..cubicTo(12.537, 13.537, 12.735, 13.735, 13.131, 14.131)
      ..lineTo(19.684, 20.684)
      // Mountains chevron 2
      ..moveTo(14, 15)
      ..lineTo(16.869, 12.131)
      ..cubicTo(17.265, 11.735, 17.463, 11.537, 17.691, 11.463)
      ..cubicTo(17.892, 11.398, 18.108, 11.398, 18.309, 11.463)
      ..cubicTo(18.537, 11.537, 18.735, 11.735, 19.131, 12.131)
      ..lineTo(22, 15)
      // Sun circle
      ..addOval(Rect.fromCircle(center: const Offset(8, 9), radius: 2))
      // Frame (rounded rectangle, approximate with Path)
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(2, 3, 20, 18),
          const Radius.circular(1.6),
        ),
      );
  }

  // Noise pixels (as small rects in 24×24 space).
  static const _noiseRects = <Rect>[
    Rect.fromLTWH(6, 19, 1, 1),
    Rect.fromLTWH(7, 18, 1, 1),
    Rect.fromLTWH(7, 19, 3, 1),
    Rect.fromLTWH(9, 18, 1, 1),
    Rect.fromLTWH(14, 19, 3, 1),
    Rect.fromLTWH(15, 18, 1, 1),
    Rect.fromLTWH(5, 18, 2, 1),
    Rect.fromLTWH(5, 17, 1, 1),
    Rect.fromLTWH(10, 19, 1, 1),
    Rect.fromLTWH(7, 17, 1, 1),
    Rect.fromLTWH(11, 19, 1, 1),
    Rect.fromLTWH(10, 18, 1, 1),
    Rect.fromLTWH(17, 19, 1, 1),
    Rect.fromLTWH(15, 4, 2, 1),
    Rect.fromLTWH(3, 9, 1, 3),
    Rect.fromLTWH(4, 10, 1, 2),
    Rect.fromLTWH(6, 9, 1, 1),
    Rect.fromLTWH(15, 5, 1, 1),
    Rect.fromLTWH(20, 8, 1, 3),
    Rect.fromLTWH(19, 9, 1, 1),
    Rect.fromLTWH(7, 13, 1, 1),
    Rect.fromLTWH(9, 11, 1, 1),
    Rect.fromLTWH(16, 12, 1, 2),
    Rect.fromLTWH(13, 14, 1, 1),
    Rect.fromLTWH(12, 11, 1, 1),
    Rect.fromLTWH(10, 9, 1, 1),
    Rect.fromLTWH(10, 15, 1, 1),
    Rect.fromLTWH(10, 13, 1, 1),
    Rect.fromLTWH(15, 9, 1, 1),
    Rect.fromLTWH(13, 10, 1, 1),
    Rect.fromLTWH(12, 14, 1, 1),
    Rect.fromLTWH(5, 4, 3, 1),
    Rect.fromLTWH(6, 5, 1, 1),
    Rect.fromLTWH(7, 14, 1, 2),
    Rect.fromLTWH(6, 14, 3, 1),
    Rect.fromLTWH(16, 8, 1, 1),
    Rect.fromLTWH(8, 9, 1, 1),
    Rect.fromLTWH(20, 16, 1, 1),
    Rect.fromLTWH(12, 12, 1, 1),
    Rect.fromLTWH(8, 8, 1, 1),
    Rect.fromLTWH(14, 12, 1, 1),
    Rect.fromLTWH(17, 16, 2, 1),
    Rect.fromLTWH(14, 17, 1, 1),
    Rect.fromLTWH(11, 5, 3, 1),
    Rect.fromLTWH(12, 4, 1, 1),
    Rect.fromLTWH(12, 7, 1, 1),
    Rect.fromLTWH(7, 11, 1, 1),
    Rect.fromLTWH(15, 15, 1, 1),
    Rect.fromLTWH(11, 11, 1, 1),
    Rect.fromLTWH(13, 9, 1, 1),
    Rect.fromLTWH(12, 15, 1, 1),
    Rect.fromLTWH(9, 12, 2, 1),
    Rect.fromLTWH(19, 13, 2, 1),
    Rect.fromLTWH(9, 6, 1, 1),
    Rect.fromLTWH(20, 4, 1, 1),
    Rect.fromLTWH(19, 4, 1, 1),
    Rect.fromLTWH(3, 15, 1, 2),
    Rect.fromLTWH(3, 19, 1, 1),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / viewSize;
    canvas.save();
    canvas.scale(scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(_buildIconPath(), strokePaint);

    if (noisy) {
      final fillPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      for (final r in _noiseRects) {
        canvas.drawRect(r, fillPaint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ImageIconPainter old) =>
      old.color != color || old.noisy != noisy;
}
