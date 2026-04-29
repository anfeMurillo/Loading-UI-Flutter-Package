import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_ui_flutter/loading_ui_flutter.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

typedef LoaderBuilder = Widget Function();

final Map<String, LoaderBuilder> _loaders = {
  'InfinityLoader': () => const InfinityLoader(),
  'DashRingLoader': () => const DashRingLoader(),
  'SwirlingLoader': () => const SwirlingLoader(),
  'RippleLoader': () => const RippleLoader(),
  'WanderingEyesLoader': () => const WanderingEyesLoader(),
};

void main() {
  for (final entry in _loaders.entries) {
    group(entry.key, () {
      testWidgets('renders with Semantics label "Loading"', (tester) async {
        await tester.pumpWidget(_wrap(entry.value()));
        await tester.pump();
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.label == 'Loading',
          ),
          findsWidgets,
        );
      });

      testWidgets('animates over time without throwing', (tester) async {
        await tester.pumpWidget(_wrap(entry.value()));
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 1000));
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
