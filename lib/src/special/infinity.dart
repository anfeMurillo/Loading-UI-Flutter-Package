import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A looping infinity (∞) symbol drawn with a dashed stroke.
///
/// The dash offset animates continuously around the hand-tuned lemniscate
/// Bézier path, creating a snake-eating-its-tail effect.
/// Respects [MediaQueryData.disableAnimations].
class InfinityLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const InfinityLoader({
    super.key,
    this.size = 40.0,
    this.color,
    this.duration = const Duration(milliseconds: 2000),
    this.semanticsLabel,
  });

  @override
  State<InfinityLoader> createState() => _InfinityLoaderState();
}

class _InfinityLoaderState extends State<InfinityLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(InfinityLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _ctrl.duration = widget.duration;
      if (_ctrl.isAnimating) _ctrl.repeat();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          painter: _InfinityPainter(color: c, progress: _ctrl.value),
        ),
      ),
    );
  }
}

// The infinity path in a 100×100 viewBox, scaled 0.8 from center (50,50).
// Full path length ≈ 256.59; dash = 205.27, gap = 51.32.
class _InfinityPainter extends CustomPainter {
  final Color color;
  final double progress;

  _InfinityPainter({required this.color, required this.progress});

  static final _basePath = Path()
    ..moveTo(24.3, 30)
    ..cubicTo(11.4, 30, 5, 43.3, 5, 50)
    ..cubicTo(5, 56.7, 11.4, 70, 24.3, 70)
    ..cubicTo(43.6, 70, 56.4, 30, 75.7, 30)
    ..cubicTo(88.6, 30, 95, 43.3, 95, 50)
    ..cubicTo(95, 56.7, 88.6, 70, 75.7, 70)
    ..cubicTo(56.4, 70, 43.6, 30, 24.3, 30)
    ..close();

  static const double _dashRatio = 205.27 / 256.59;
  static const double _scale = 0.8;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 100.0;
    final scaleY = size.height / 100.0;
    canvas.save();
    canvas.scale(scaleX, scaleY);
    // Apply the 0.8 scale from center (50, 50).
    canvas.translate(50, 50);
    canvas.scale(_scale);
    canvas.translate(-50, -50);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round;

    final metrics = _basePath.computeMetrics();
    for (final metric in metrics) {
      final total = metric.length;
      final dashLen = total * _dashRatio;
      final start = (progress * total) % total;
      final end = start + dashLen;
      if (end <= total) {
        canvas.drawPath(metric.extractPath(start, end), paint);
      } else {
        canvas.drawPath(metric.extractPath(start, total), paint);
        canvas.drawPath(metric.extractPath(0, end - total), paint);
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InfinityPainter old) =>
      old.color != color || old.progress != progress;
}
