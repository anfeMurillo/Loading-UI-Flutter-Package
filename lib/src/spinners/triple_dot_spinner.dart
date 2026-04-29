import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// Three dots arranged in a triangle, rotating as a unit.
///
/// Three equally-spaced dots orbit a shared center point, creating a
/// simple triple-dot spinner effect.
/// Respects [MediaQueryData.disableAnimations].
class TripleDotLoader extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const TripleDotLoader({
    super.key,
    this.size = 24.0,
    this.color,
    this.duration = const Duration(milliseconds: 2000),
    this.semanticsLabel,
  });

  @override
  State<TripleDotLoader> createState() => _TripleDotLoaderState();
}

class _TripleDotLoaderState extends State<TripleDotLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late final Animation<double> _turns = CurvedAnimation(
    parent: _ctrl,
    curve: Curves.easeInOut,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TripleDotLoader oldWidget) {
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

  Widget _dot(Color c) => Container(
    width: widget.size,
    height: widget.size,
    decoration: BoxDecoration(shape: BoxShape.circle, color: c),
  );

  @override
  Widget build(BuildContext context) {
    final c = resolveColor(context, widget.color);
    return LoaderWrapper(
      semanticsLabel: widget.semanticsLabel,
      size: widget.size,
      child: RotationTransition(
        turns: _turns,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: -widget.size * 1.5, top: 0, child: _dot(c)),
            Positioned(left: 0, top: 0, child: _dot(c)),
            Positioned(left: widget.size * 1.5, top: 0, child: _dot(c)),
          ],
        ),
      ),
    );
  }
}
