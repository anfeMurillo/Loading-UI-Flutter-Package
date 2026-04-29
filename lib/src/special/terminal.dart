import 'package:flutter/material.dart';
import '../core/color_resolver.dart';
import '../core/loader_base.dart';

/// A terminal-cursor blinking loader.
///
/// Renders [prompt] followed by a blinking block cursor (`█`), simulating a
/// command-line prompt waiting for input. The cursor toggles on/off using a
/// step-end animation. Respects [MediaQueryData.disableAnimations].
class TerminalLoader extends StatefulWidget {
  final String prompt;
  final double fontSize;
  final Color? color;
  final Duration duration;
  final String? semanticsLabel;

  const TerminalLoader({
    super.key,
    this.prompt = '>',
    this.fontSize = 14.0,
    this.color,
    this.duration = const Duration(milliseconds: 1000),
    this.semanticsLabel,
  });

  @override
  State<TerminalLoader> createState() => _TerminalLoaderState();
}

class _TerminalLoaderState extends State<TerminalLoader>
    with SingleTickerProviderStateMixin, LoaderAnimationMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  AnimationController get controller => _ctrl;

  @override
  void didUpdateWidget(TerminalLoader oldWidget) {
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
    final style = TextStyle(
      fontSize: widget.fontSize,
      fontFamily: 'monospace',
      color: c,
    );
    return Semantics(
      container: true,
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: RepaintBoundary(
        child: DefaultTextStyle(
          style: style,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(widget.prompt),
              SizedBox(width: widget.fontSize * 0.25),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, _) => Opacity(
                  opacity: _ctrl.value < 0.5 ? 1.0 : 0.0,
                  child: Container(
                    width: widget.fontSize * 0.5,
                    height: widget.fontSize,
                    color: c,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
