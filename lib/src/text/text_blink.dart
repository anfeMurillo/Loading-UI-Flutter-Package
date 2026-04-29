import 'package:flutter/material.dart';
import '../core/loader_base.dart';

/// Wraps any widget in a slow opacity blink.
///
/// The [child] fades from full opacity down to [minOpacity] and back,
/// suggesting ongoing activity without moving parts.
/// Accepts any widget as [child] — typically a [Text].
/// Respects [MediaQueryData.disableAnimations].
class TextBlinkLoader extends StatefulWidget {
  final Widget child;
  final double minOpacity;
  final Duration duration;
  final String? semanticsLabel;

  const TextBlinkLoader({
    super.key,
    required this.child,
    this.minOpacity = 0.45,
    this.duration = const Duration(milliseconds: 2000),
    this.semanticsLabel,
  });

  @override
  State<TextBlinkLoader> createState() => _TextBlinkLoaderState();
}

class _TextBlinkLoaderState extends State<TextBlinkLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  late Animation<double> _opacity = _buildOpacity();

  Animation<double> _buildOpacity() => TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 1.0, end: widget.minOpacity),
      weight: 50,
    ),
    TweenSequenceItem(
      tween: Tween(begin: widget.minOpacity, end: 1.0),
      weight: 50,
    ),
  ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TextBlinkLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration != oldWidget.duration) {
      _ctrl.duration = widget.duration;
      if (_ctrl.isAnimating) _ctrl.repeat();
    }
    if (widget.minOpacity != oldWidget.minOpacity) {
      _opacity = _buildOpacity();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: FadeTransition(opacity: _opacity, child: widget.child),
      ),
    );
  }
}
