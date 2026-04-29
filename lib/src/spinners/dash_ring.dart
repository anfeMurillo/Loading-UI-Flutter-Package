import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A dashed ring with an animated dash-offset.
///
/// Uses two independent [AnimationController]s: one for continuous rotation
/// ([spinDuration]) and one for the pulsing dash gap ([dashDuration]). The
/// combination produces the Material-style indeterminate progress ring.
/// Respects [MediaQueryData.disableAnimations].
class DashRingLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration spinDuration;
  final Duration dashDuration;
  final String? semanticsLabel;

  const DashRingLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.spinDuration = const Duration(milliseconds: 2000),
    this.dashDuration = const Duration(milliseconds: 1500),
    this.semanticsLabel,
  });

  @override
  State<DashRingLoader> createState() => _DashRingLoaderState();
}

class _DashRingLoaderState extends State<DashRingLoader>
    with TickerProviderStateMixin {
  late final AnimationController _spinCtrl;
  late final AnimationController _dashCtrl;

  @override
  void initState() {
    super.initState();
    _spinCtrl = AnimationController(vsync: this, duration: widget.spinDuration);
    _dashCtrl = AnimationController(vsync: this, duration: widget.dashDuration);
    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = reducedMotionOf(context);
    if (reduced) {
      _spinCtrl.stop();
      _dashCtrl.stop();
    } else {
      if (!_spinCtrl.isAnimating) _spinCtrl.repeat();
      if (!_dashCtrl.isAnimating) _dashCtrl.repeat();
    }
  }

  @override
  void didUpdateWidget(DashRingLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.spinDuration != oldWidget.spinDuration) {
      _spinCtrl.duration = widget.spinDuration;
      if (_spinCtrl.isAnimating) _spinCtrl.repeat();
    }
    if (widget.dashDuration != oldWidget.dashDuration) {
      _dashCtrl.duration = widget.dashDuration;
      if (_dashCtrl.isAnimating) _dashCtrl.repeat();
    }
  }

  void _start() {
    _spinCtrl.repeat();
    _dashCtrl.repeat();
  }

  @override
  void dispose() {
    _spinCtrl.dispose();
    _dashCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spinCtrl, _dashCtrl]),
        builder: (_, _) => CustomPaint(
          painter: _DashRingPainter(
            color: c,
            spinT: _spinCtrl.value,
            dashT: _dashCtrl.value,
          ),
        ),
      ),
    );
  }
}

class _DashRingPainter extends CustomPainter {
  final Color color;
  final double spinT;
  final double dashT;

  _DashRingPainter({
    required this.color,
    required this.spinT,
    required this.dashT,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    // r=9.5 in 24x24 viewBox → scale to widget size
    final r = (9.5 / 12) * (math.min(size.width, size.height) / 2);
    final strokeW = 2.0 * (size.width / 24);
    final circumference = 2 * math.pi * r;

    // Background circle at 10% opacity.
    final bgPaint = Paint()
      ..color = color.withValues(alpha: color.a * 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bgPaint);

    // Animated dash: dasharray 0→42, offset 0→-16→-59, over 1.5s in 24-unit space.
    final scale = size.width / 24;
    final dashLen =
        _lerpSegments(dashT, [0.0, 0.5, 1.0], [0.0, 42.0, 42.0]) * scale;
    final dashOff =
        _lerpSegments(dashT, [0.0, 0.5, 1.0], [0.0, -16.0, -59.0]) * scale;

    if (dashLen <= 0) return;

    // Rotation from spin controller.
    final rotAngle = spinT * 2 * math.pi - math.pi / 2;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotAngle);
    canvas.translate(-cx, -cy);

    // Draw arc: start at adjusted dashOffset, sweep for dashLen.
    final startAngle = -math.pi / 2 + (dashOff / circumference) * 2 * math.pi;
    final sweepAngle = (dashLen / circumference) * 2 * math.pi;
    canvas.drawArc(rect, startAngle, sweepAngle, false, fgPaint);
    canvas.restore();
  }

  double _lerpSegments(double t, List<double> stops, List<double> values) {
    for (var i = 0; i < stops.length - 1; i++) {
      if (t <= stops[i + 1]) {
        final span = stops[i + 1] - stops[i];
        final segT = span == 0 ? 0.0 : ((t - stops[i]) / span).clamp(0.0, 1.0);
        return values[i] + (values[i + 1] - values[i]) * segT;
      }
    }
    return values.last;
  }

  @override
  bool shouldRepaint(covariant _DashRingPainter old) =>
      old.color != color || old.spinT != spinT || old.dashT != dashT;
}
