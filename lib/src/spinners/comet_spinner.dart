import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A comet with a trailing tail orbiting in a circle.
///
/// A bright head dot leads a fading trail of smaller dots, each
/// progressively scaled and made more transparent to simulate a comet's
/// tail. Respects [MediaQueryData.disableAnimations].
class CometLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final double headScale;
  final double radiusScale;
  final int trailDots;
  final String? semanticsLabel;

  const CometLoader({
    super.key,
    this.size = 32.0,
    this.color,
    this.duration = const Duration(milliseconds: 1700),
    this.headScale = 0.2,
    this.radiusScale = 0.83,
    this.trailDots = 5,
    this.semanticsLabel,
  });

  @override
  State<CometLoader> createState() => _CometLoaderState();
}

class _CometLoaderState extends State<CometLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(CometLoader oldWidget) {
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
    final safeHead = widget.headScale.clamp(0.08, 0.35);
    final safeRadius = widget.radiusScale.clamp(0.3, 1.1);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, _) => CustomPaint(
          painter: _CometPainter(
            color: c,
            t: _ctrl.value,
            headFraction: safeHead,
            radiusFraction: safeRadius,
            trailDots: widget.trailDots,
          ),
        ),
      ),
    );
  }
}

// Trail spread envelope: mirrors the CSS keyframes (0→5%→20%→38%→59%→95%→100%).
// Maps [0..1] → spread fraction [0..1].
double _spreadAt(double t) {
  const stops = [0.0, 0.05, 0.20, 0.38, 0.59, 0.95, 1.0];
  const vals = [0.0, 0.0, 0.72, 0.988, 0.988, 0.0, 0.0];
  for (var i = 0; i < stops.length - 1; i++) {
    if (t <= stops[i + 1]) {
      final span = stops[i + 1] - stops[i];
      final segT = span == 0 ? 0.0 : ((t - stops[i]) / span).clamp(0.0, 1.0);
      return vals[i] + (vals[i + 1] - vals[i]) * segT;
    }
  }
  return 0.0;
}

class _CometPainter extends CustomPainter {
  final Color color;
  final double t;
  final double headFraction;
  final double radiusFraction;
  final int trailDots;

  _CometPainter({
    required this.color,
    required this.t,
    required this.headFraction,
    required this.radiusFraction,
    required this.trailDots,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final half = math.min(size.width, size.height) / 2;
    final r = half * radiusFraction;
    final headR = half * headFraction;

    final headAngle = t * 2 * math.pi - math.pi / 2;
    final spread = _spreadAt(t);

    // Angular gap between trail dots — max ~21° (≈0.368 rad) each.
    const maxDeltaAngle = 0.21 * math.pi;

    // Draw trail dots (back to front so head is on top).
    for (var i = trailDots; i >= 1; i--) {
      final lag = i * maxDeltaAngle * spread;
      final angle = headAngle - lag;
      final x = cx + math.cos(angle) * r;
      final y = cy + math.sin(angle) * r;
      final fraction = 1.0 - (i / (trailDots + 1));
      final dotR = headR * (0.4 + 0.6 * fraction);
      final opacity = fraction * spread;
      if (opacity <= 0) continue;
      final paint = Paint()
        ..color = color.withValues(alpha: color.a * opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), dotR, paint);
    }

    // Draw head.
    final hx = cx + math.cos(headAngle) * r;
    final hy = cy + math.sin(headAngle) * r;
    canvas.drawCircle(
      Offset(hx, hy),
      headR,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CometPainter old) =>
      old.color != color || old.t != t;
}
