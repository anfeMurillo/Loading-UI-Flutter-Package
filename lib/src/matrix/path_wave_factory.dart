import 'matrix_base.dart';
import 'styles.dart';

typedef PathNormFn = double Function(
    {required int row, required int col, required int index});

DotAnimationResolver createPathWaveResolver(PathNormFn getPathNorm) {
  return (ctx) {
    if (!ctx.isActive) return null;

    final path = getPathNorm(row: ctx.row, col: ctx.col, index: ctx.index);

    if (ctx.reducedMotion || ctx.phase == DotMatrixPhase.idle) {
      return DotAnimationState(opacity: idlePathOpacity(path));
    }

    final t = (ctx.cyclePhase + path * 0.2333) % 1.0;
    return DotAnimationState(opacity: rippleOpacity(t, 0.16, 1.0));
  };
}
