import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// An infinity path with a pulsing dash gap — the "swirling" variant.
///
/// Like [InfinityLoader] but uses `repeat(reverse: true)` on the dash
/// controller, so the stroke appears to swirl in and out. A secondary
/// rotation controller spins the whole figure continuously.
/// Respects [MediaQueryData.disableAnimations].
class SwirlingLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration dashDuration;
  final String? semanticsLabel;

  const SwirlingLoader({
    super.key,
    this.size = 32.0,
    this.color,
    // dash=1.5s, spin=1.5s×1.333=2s
    this.dashDuration = const Duration(milliseconds: 1500),
    this.semanticsLabel,
  });

  @override
  State<SwirlingLoader> createState() => _SwirlingLoaderState();
}

class _SwirlingLoaderState extends State<SwirlingLoader>
    with TickerProviderStateMixin {
  late final AnimationController _dashCtrl;
  late final AnimationController _spinCtrl;

  @override
  void initState() {
    super.initState();
    final spinMs = (widget.dashDuration.inMilliseconds * 1.333333).round();
    _dashCtrl = AnimationController(vsync: this, duration: widget.dashDuration);
    _spinCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: spinMs),
    );
    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = reducedMotionOf(context);
    if (reduced) {
      _dashCtrl.stop();
      _spinCtrl.stop();
    } else {
      if (!_dashCtrl.isAnimating) _dashCtrl.repeat(reverse: true);
      if (!_spinCtrl.isAnimating) _spinCtrl.repeat();
    }
  }

  void _start() {
    _dashCtrl.repeat(reverse: true);
    _spinCtrl.repeat();
  }

  @override
  void dispose() {
    _dashCtrl.dispose();
    _spinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_dashCtrl, _spinCtrl]),
        builder: (_, _) => CustomPaint(
          painter: _SwirlingPainter(
            color: c,
            dashT: _dashCtrl.value,
            spinT: _spinCtrl.value,
          ),
        ),
      ),
    );
  }
}

class _SwirlingPainter extends CustomPainter {
  final Color color;
  final double dashT;
  final double spinT;

  _SwirlingPainter({
    required this.color,
    required this.dashT,
    required this.spinT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    // viewBox 800×800, r=200 → scale to fit
    final r = cx * 0.5; // r=200/400=0.5 of half-width
    final strokeW = size.width * 0.0625; // 50/800
    final circumference = 2 * math.pi * r;

    // dasharray: 1→400→800 (easeInOut, alternate via reverse:true)
    final eased = Curves.easeInOut.transform(dashT);
    final dashLen = 1.0 + 799.0 * eased;
    // Normalize to this circle's circumference (800-unit viewBox scaled)
    final scaledDashLen = (dashLen / 800) * circumference;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(spinT * 2 * math.pi - math.pi / 2);
    canvas.translate(-cx, -cy);

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      (scaledDashLen / circumference) * 2 * math.pi,
      false,
      paint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SwirlingPainter old) =>
      old.color != color || old.dashT != dashT || old.spinT != spinT;
}
