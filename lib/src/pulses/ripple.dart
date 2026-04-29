import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// Two concentric ripple rings expanding outward.
///
/// Two rings expand from the center with a 0.5-phase offset, each fading
/// out as they grow. Cubic easing curves match the original CSS animation.
/// Respects [MediaQueryData.disableAnimations].
class RippleLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const RippleLoader({
    super.key,
    this.size = 32.0,
    this.color,
    this.duration = const Duration(milliseconds: 1800),
    this.semanticsLabel,
  });

  @override
  State<RippleLoader> createState() => _RippleLoaderState();
}

class _RippleLoaderState extends State<RippleLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(RippleLoader oldWidget) {
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
          painter: _RipplePainter(
            color: c,
            t1: _ctrl.value,
            t2: (_ctrl.value + 0.5) % 1.0,
            viewSize: 44.0,
            widgetSize: widget.size,
          ),
        ),
      ),
    );
  }
}

// Approximated cubic splines for the original SMIL keySplines.
const _radiusCurve = Cubic(0.165, 0.84, 0.44, 1);
const _opacityCurve = Cubic(0.3, 0.61, 0.355, 1);

class _RipplePainter extends CustomPainter {
  final Color color;
  final double t1;
  final double t2;
  final double viewSize;
  final double widgetSize;

  _RipplePainter({
    required this.color,
    required this.t1,
    required this.t2,
    required this.viewSize,
    required this.widgetSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / viewSize;
    final cx = size.width / 2;
    final cy = size.height / 2;
    _drawCircle(canvas, cx, cy, scale, t1);
    _drawCircle(canvas, cx, cy, scale, t2);
  }

  void _drawCircle(
    Canvas canvas,
    double cx,
    double cy,
    double scale,
    double t,
  ) {
    final r = (1.0 + 19.0 * _radiusCurve.transform(t)) * scale;
    final opacity = (1.0 - _opacityCurve.transform(t)).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = color.withValues(alpha: color.a * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0 * scale;
    canvas.drawCircle(Offset(cx, cy), r, paint);
  }

  @override
  bool shouldRepaint(covariant _RipplePainter old) =>
      old.color != color || old.t1 != t1 || old.t2 != t2;
}
