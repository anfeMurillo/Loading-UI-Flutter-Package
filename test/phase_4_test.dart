import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_ui/loading_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

typedef LoaderBuilder = Widget Function();

final Map<String, LoaderBuilder> _loaders = {
  'CometLoader': () => const CometLoader(),
  'TextShimmerLoader': () => const TextShimmerLoader(text: 'Loading'),
  'TextShimmerWaveLoader': () => const TextShimmerWaveLoader(text: 'Loading'),
  'AnalyzingImageLoader': () => const AnalyzingImageLoader(),
};

void main() {
  for (final entry in _loaders.entries) {
    group(entry.key, () {
      testWidgets('renders with Semantics label', (tester) async {
        await tester.pumpWidget(_wrap(entry.value()));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label != null,
          ),
          findsWidgets,
        );
      });

      testWidgets('animates over time without throwing', (tester) async {
        await tester.pumpWidget(_wrap(entry.value()));
        for (final ms in [100, 250, 500, 1000, 2000]) {
          await tester.pump(Duration(milliseconds: ms));
        }
        expect(tester.takeException(), isNull);
      });

      testWidgets('disposes cleanly', (tester) async {
        await tester.pumpWidget(_wrap(entry.value()));
        await tester.pump(const Duration(milliseconds: 50));
        await tester.pumpWidget(_wrap(const SizedBox.shrink()));
        expect(tester.takeException(), isNull);
      });

      testWidgets('respects MediaQuery.disableAnimations', (tester) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: _wrap(entry.value()),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(tester.takeException(), isNull);
      });
    });
  }
}
