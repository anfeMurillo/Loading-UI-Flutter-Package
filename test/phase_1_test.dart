import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loading_ui/loading_ui.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

typedef LoaderBuilder = Widget Function();

final Map<String, LoaderBuilder> _loaders = {
  'RingLoader': () => const RingLoader(),
  'SpokesLoader': () => const SpokesLoader(),
  'ArcLoader': () => const ArcLoader(),
  'DualArcLoader': () => const DualArcLoader(),
  'QuarterRingLoader': () => const QuarterRingLoader(),
  'ClockRingLoader': () => const ClockRingLoader(),
  'ConcentricRingLoader': () => const ConcentricRingLoader(),
  'OrbitRingLoader': () => const OrbitRingLoader(),
  'SatelliteRingLoader': () => const SatelliteRingLoader(),
  'TripleDotLoader': () => const TripleDotLoader(),
  'PulseLoader': () => const PulseLoader(),
  'PulseDotLoader': () => const PulseDotLoader(),
  'SkeletonLoader': () => const SkeletonLoader(width: 100, height: 16),
  'TerminalLoader': () => const TerminalLoader(),
  'TextBlinkLoader': () => const TextBlinkLoader(child: Text('Loading')),
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
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(milliseconds: 500));
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
