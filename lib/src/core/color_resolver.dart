import 'package:flutter/material.dart';

/// Resolves the color to use for a loader.
/// 
/// If [color] is provided, it is returned.
/// Otherwise, it attempts to use [IconTheme.of(context).color].
/// If that's also null, it falls back to [DefaultTextStyle.of(context).style.color].
/// As a last resort, it defaults to [Colors.black].
Color resolveColor(BuildContext context, Color? color) {
  if (color != null) return color;
  
  final iconColor = IconTheme.of(context).color;
  if (iconColor != null) return iconColor;

  final textColor = DefaultTextStyle.of(context).style.color;
  if (textColor != null) return textColor;

  return Colors.black;
}
