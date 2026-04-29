import 'package:flutter/material.dart';
import '../core/loader_base.dart';
import '../core/stagger.dart';

/// A text widget followed by animated ellipsis dots.
///
/// Displays [child] (typically a [Text] label) with an animated series of
/// dots that appear one by one, then reset — the classic "Loading…" effect.
/// Respects [MediaQueryData.disableAnimations].
class TextDotsLoader extends StatefulWidget {
  final Widget child;
  final int dots;
  final Duration duration;
  final Duration delay;
  final String? semanticsLabel;

  const TextDotsLoader({
    super.key,
    required this.child,
    this.dots = 3,
    this.duration = const Duration(milliseconds: 1400),
    this.delay = const Duration(milliseconds: 200),
    this.semanticsLabel,
  });

  @override
  State<TextDotsLoader> createState() => _TextDotsLoaderState();
}

class _TextDotsLoaderState extends State<TextDotsLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TextDotsLoader oldWidget) {
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
    final delayFraction =
        widget.delay.inMicroseconds / widget.duration.inMicroseconds;

    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.child,
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.dots, (i) {
                  final t = phaseOf(_ctrl.value, (i + 1) * delayFraction);
                  final opacity = lerpStops(
                    t,
                    const [0.0, 0.5, 1.0],
                    const [0.0, 1.0, 0.0],
                  );
                  return Opacity(opacity: opacity, child: const Text('.'));
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
