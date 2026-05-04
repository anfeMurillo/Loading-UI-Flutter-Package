import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_ui/loading_ui.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const LoadingShowcaseApp());

// ─── App shell ────────────────────────────────────────────────────────────────

class LoadingShowcaseApp extends StatelessWidget {
  const LoadingShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'loading_ui showcase',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF6750A4),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const ShowcasePage(),
    );
  }
}

// ─── Controls state ───────────────────────────────────────────────────────────

class _Controls {
  const _Controls({
    required this.size,
    required this.durationScale,
    required this.colorIndex,
  });

  final double size;
  final double durationScale;
  final int colorIndex;

  static const colors = <Color>[
    Color(0xFF6750A4), // purple (default)
    Color(0xFF0061A4), // blue
    Color(0xFF006E2C), // green
    Color(0xFFBA1A1A), // red
    Color(0xFFE65C00), // orange
    Color(0xFF37474F), // slate
    Colors.black,
    Colors.white,
  ];

  Color get color => colors[colorIndex];

  Duration scale(Duration base) =>
      Duration(microseconds: (base.inMicroseconds * durationScale).round());
}

// ─── Loader catalogue ─────────────────────────────────────────────────────────

typedef _LoderEntry = ({
  String name,
  String category,
  Widget Function(_Controls) build,
});

List<_LoderEntry> _catalogue(_Controls c) => [
  // Spinners
  (
    name: 'RingLoader',
    category: 'Spinners',
    build: (_) => RingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'SpokesLoader',
    category: 'Spinners',
    build: (_) => SpokesLoader(
      size: c.size,
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 1200)),
    ),
  ),
  (
    name: 'ArcLoader',
    category: 'Spinners',
    build: (_) => ArcLoader(
      size: c.size,
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 900)),
    ),
  ),
  (
    name: 'DualArcLoader',
    category: 'Spinners',
    build: (_) => DualArcLoader(size: c.size, color: c.color),
  ),
  (
    name: 'QuarterRingLoader',
    category: 'Spinners',
    build: (_) => QuarterRingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'ClockRingLoader',
    category: 'Spinners',
    build: (_) => ClockRingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'ConcentricRingLoader',
    category: 'Spinners',
    build: (_) => ConcentricRingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'OrbitRingLoader',
    category: 'Spinners',
    build: (_) => OrbitRingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'SatelliteRingLoader',
    category: 'Spinners',
    build: (_) => SatelliteRingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'TripleDotLoader',
    category: 'Spinners',
    build: (_) => TripleDotLoader(size: c.size, color: c.color),
  ),
  (
    name: 'ClassicLoader',
    category: 'Spinners',
    build: (_) => ClassicLoader(size: c.size, color: c.color),
  ),
  (
    name: 'DotsRingLoader',
    category: 'Spinners',
    build: (_) => DotsRingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'SpiralLoader',
    category: 'Spinners',
    build: (_) => SpiralLoader(size: c.size, color: c.color),
  ),
  (
    name: 'TwinOrbitLoader',
    category: 'Spinners',
    build: (_) => TwinOrbitLoader(size: c.size, color: c.color),
  ),
  (
    name: 'DashRingLoader',
    category: 'Spinners',
    build: (_) => DashRingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'CometLoader',
    category: 'Spinners',
    build: (_) => CometLoader(
      size: c.size,
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 1800)),
    ),
  ),
  // Pulses
  (
    name: 'PulseLoader',
    category: 'Pulses',
    build: (_) => PulseLoader(size: c.size, color: c.color),
  ),
  (
    name: 'PulseDotLoader',
    category: 'Pulses',
    build: (_) => PulseDotLoader(size: c.size, color: c.color),
  ),
  (
    name: 'RippleLoader',
    category: 'Pulses',
    build: (_) => RippleLoader(size: c.size, color: c.color),
  ),
  // Dots
  (
    name: 'DotsLoader',
    category: 'Dots',
    build: (_) => DotsLoader(
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 1400)),
    ),
  ),
  (
    name: 'BouncingDotsLoader',
    category: 'Dots',
    build: (_) => BouncingDotsLoader(
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 600)),
    ),
  ),
  (
    name: 'BobbingDotsLoader',
    category: 'Dots',
    build: (_) => BobbingDotsLoader(color: c.color),
  ),
  (
    name: 'PulsatingDotsLoader',
    category: 'Dots',
    build: (_) => PulsatingDotsLoader(color: c.color),
  ),
  (
    name: 'TypingLoader',
    category: 'Dots',
    build: (_) => TypingLoader(color: c.color),
  ),
  // Bars
  (
    name: 'BarsLoader',
    category: 'Bars',
    build: (_) => BarsLoader(
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 1200)),
    ),
  ),
  (
    name: 'WaveLoader',
    category: 'Bars',
    build: (_) => WaveLoader(
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 1200)),
    ),
  ),
  // Text
  (
    name: 'TextBlinkLoader',
    category: 'Text',
    build: (_) => TextBlinkLoader(
      duration: c.scale(const Duration(milliseconds: 2000)),
      child: Text(
        'Loading…',
        style: TextStyle(color: c.color, fontWeight: FontWeight.w600),
      ),
    ),
  ),
  (
    name: 'TextDotsLoader',
    category: 'Text',
    build: (_) => TextDotsLoader(
      child: Text(
        'Loading',
        style: TextStyle(color: c.color, fontWeight: FontWeight.w600),
      ),
    ),
  ),
  (
    name: 'TextShimmerLoader',
    category: 'Text',
    build: (_) => TextShimmerLoader(
      text: 'Loading…',
      shimmerColor: c.color,
      duration: c.scale(const Duration(milliseconds: 2000)),
    ),
  ),
  (
    name: 'TextShimmerWaveLoader',
    category: 'Text',
    build: (_) => TextShimmerWaveLoader(
      text: 'Loading…',
      shimmerColor: c.color,
      duration: c.scale(const Duration(milliseconds: 1000)),
    ),
  ),
  // Special
  (
    name: 'SkeletonLoader',
    category: 'Special',
    build: (_) =>
        SkeletonLoader(width: c.size, height: c.size, color: c.color),
  ),
  (
    name: 'TerminalLoader',
    category: 'Special',
    build: (_) => TerminalLoader(
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 1000)),
    ),
  ),
  (
    name: 'InfinityLoader',
    category: 'Special',
    build: (_) => InfinityLoader(size: c.size, color: c.color),
  ),
  (
    name: 'SwirlingLoader',
    category: 'Special',
    build: (_) => SwirlingLoader(size: c.size, color: c.color),
  ),
  (
    name: 'WanderingEyesLoader',
    category: 'Special',
    build: (_) => WanderingEyesLoader(size: c.size, color: c.color),
  ),
  (
    name: 'AnalyzingImageLoader',
    category: 'Special',
    build: (_) => AnalyzingImageLoader(
      size: c.size,
      color: c.color,
      duration: c.scale(const Duration(milliseconds: 3000)),
    ),
  ),
  // Matrix — Dot Matrix loaders
  (
    name: 'NeonDrift',
    category: 'Matrix',
    build: (_) => NeonDriftLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PulseLadder',
    category: 'Matrix',
    build: (_) => PulseLadderLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'CoreSpiral',
    category: 'Matrix',
    build: (_) => CoreSpiralLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PrismSweep',
    category: 'Matrix',
    build: (_) => PrismSweepLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'FluxColumns',
    category: 'Matrix',
    build: (_) => FluxColumnsLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'CrtGlide',
    category: 'Matrix',
    build: (_) => CrtGlideLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'EchoRing',
    category: 'Matrix',
    build: (_) => EchoRingLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'OriginWave',
    category: 'Matrix',
    build: (_) => OriginWaveLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'CoreRotor',
    category: 'Matrix',
    build: (_) => CoreRotorLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'SoundBars',
    category: 'Matrix',
    build: (_) => SoundBarsLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'CoreSpokes',
    category: 'Matrix',
    build: (_) => CoreSpokesLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'AltitudeWave',
    category: 'Matrix',
    build: (_) => AltitudeWaveLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'CornerBounce',
    category: 'Matrix',
    build: (_) => CornerBounceLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'RowSweep',
    category: 'Matrix',
    build: (_) => RowSweepLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'ColumnRake',
    category: 'Matrix',
    build: (_) => ColumnRakeLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  // ── Phase 2: Square ───────────────────────────────────────────────────────────
  (
    name: 'TwinOrbit',
    category: 'Matrix',
    build: (_) => TwinOrbitMatrixLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'StrobeStack',
    category: 'Matrix',
    build: (_) => StrobeStackLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'GlyphPulse',
    category: 'Matrix',
    build: (_) => GlyphPulseLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PrismBloom',
    category: 'Matrix',
    build: (_) => PrismBloomLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'HelixGlow',
    category: 'Matrix',
    build: (_) => HelixGlowLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'HelixCore',
    category: 'Matrix',
    build: (_) => HelixCoreLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'HalfHelix',
    category: 'Matrix',
    build: (_) => HalfHelixLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'InfinityRun',
    category: 'Matrix',
    build: (_) => InfinityRunLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'MobiusRun',
    category: 'Matrix',
    build: (_) => MobiusRunLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'SnakeWave',
    category: 'Matrix',
    build: (_) => SnakeWaveLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'ColWave',
    category: 'Matrix',
    build: (_) => ColWaveLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'ConcentricRing',
    category: 'Matrix',
    build: (_) => ConcentricRingMatrixLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  // ── Phase 2: Circular ───────────────────────────────────────────────────────
  (
    name: 'HaloDrift',
    category: 'Matrix',
    build: (_) => HaloDriftLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'TriOrbit',
    category: 'Matrix',
    build: (_) => TriOrbitLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PlasmaVeil',
    category: 'Matrix',
    build: (_) => PlasmaVeilLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'RadarArc',
    category: 'Matrix',
    build: (_) => RadarArcLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'NovaWheel',
    category: 'Matrix',
    build: (_) => NovaWheelLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PhaseOrb',
    category: 'Matrix',
    build: (_) => PhaseOrbLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'GateShift',
    category: 'Matrix',
    build: (_) => GateShiftLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'HeartPulse',
    category: 'Matrix',
    build: (_) => HeartPulseLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'StarCompass',
    category: 'Matrix',
    build: (_) => StarCompassLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'BinaryBloom',
    category: 'Matrix',
    build: (_) => BinaryBloomLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  // ── Phase 2: Triangle ──────────────────────────────────────────────────────
  (
    name: 'VertexChase',
    category: 'Matrix',
    build: (_) => VertexChaseLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'BrailleBeat',
    category: 'Matrix',
    build: (_) => BrailleBeatLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'ObliqueWeave',
    category: 'Matrix',
    build: (_) => ObliqueWeaveLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  // ── Fase 3 ──
  (
    name: 'BlockDrop',
    category: 'Matrix',
    build: (_) => BlockDropLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'LunarBreathe',
    category: 'Matrix',
    build: (_) => LunarBreatheLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'ArcBeacon',
    category: 'Matrix',
    build: (_) => ArcBeaconLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'TwinHelix',
    category: 'Matrix',
    build: (_) => TwinHelixLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'RungShift',
    category: 'Matrix',
    build: (_) => RungShiftLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'GlyphCluster',
    category: 'Matrix',
    build: (_) => GlyphClusterLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'RailScan',
    category: 'Matrix',
    build: (_) => RailScanLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'CheckerShift',
    category: 'Matrix',
    build: (_) => CheckerShiftLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PulsePair',
    category: 'Matrix',
    build: (_) => PulsePairLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'OrbitCell',
    category: 'Matrix',
    build: (_) => OrbitCellLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'GlyphCycle',
    category: 'Matrix',
    build: (_) => GlyphCycleLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'WingMetronome',
    category: 'Matrix',
    build: (_) => WingMetronomeLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'CoronaTier',
    category: 'Matrix',
    build: (_) => CoronaTierLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'ShelfDescent',
    category: 'Matrix',
    build: (_) => ShelfDescentLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'SkewDrift',
    category: 'Matrix',
    build: (_) => SkewDriftLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  // ── Fase 4 ──
  (
    name: 'SerpentZip',
    category: 'Matrix',
    build: (_) => SerpentZipLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PillarSweep',
    category: 'Matrix',
    build: (_) => PillarSweepLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'TripodHandoff',
    category: 'Matrix',
    build: (_) => TripodHandoffLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'Updraft',
    category: 'Matrix',
    build: (_) => UpdraftLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'InfinityTrace',
    category: 'Matrix',
    build: (_) => InfinityTraceLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'HollowShell',
    category: 'Matrix',
    build: (_) => HollowShellLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'PivotRay',
    category: 'Matrix',
    build: (_) => PivotRayLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  (
    name: 'TwinPerimeter',
    category: 'Matrix',
    build: (_) => TwinPerimeterLoader(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
      animated: true,
    ),
  ),
  // ── Fase 5 (Icon) ──
  (
    name: 'DotMatrixIcon',
    category: 'Matrix',
    build: (_) => DotMatrixIcon(
      size: c.size,
      color: c.color,
      speed: c.durationScale,
    ),
  ),
];

// ─── Main page ────────────────────────────────────────────────────────────────

class ShowcasePage extends StatefulWidget {
  const ShowcasePage({super.key});

  @override
  State<ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<ShowcasePage> {
  double _size = 48;
  double _durationScale = 1.0;
  int _colorIndex = 7;
  String? _categoryFilter;

  _Controls get _controls => _Controls(
    size: _size,
    durationScale: _durationScale,
    colorIndex: _colorIndex,
  );

  static const _categories = [
    'All',
    'Spinners',
    'Pulses',
    'Dots',
    'Bars',
    'Text',
    'Special',
    'Matrix',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final controls = _controls;
    final all = _catalogue(controls);
    final visible = _categoryFilter == null || _categoryFilter == 'All'
        ? all
        : all.where((e) => e.category == _categoryFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text('loading_ui'),
            Text(
              'AI-created version from loading-ui.com',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: scheme.surfaceContainerHighest,
        actions: [
          IconButton(
            icon: const Icon(Icons.code),
            tooltip: 'View on GitHub',
            onPressed: () => launchUrl(
              Uri.parse(
                'https://github.com/anfeMurillo/Loading-UI-Flutter-Package.git',
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Controls panel ──────────────────────────────────────────────────
          _ControlsPanel(
            size: _size,
            durationScale: _durationScale,
            colorIndex: _colorIndex,
            onSizeChanged: (v) => setState(() => _size = v),
            onDurationChanged: (v) => setState(() => _durationScale = v),
            onColorChanged: (i) => setState(() => _colorIndex = i),
          ),
          // ── Category filter ─────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: _categories.map((cat) {
                final selected =
                    (cat == 'All' && _categoryFilter == null) ||
                    cat == _categoryFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _categoryFilter = (cat == 'All') ? null : cat;
                    }),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          // ── Grid ────────────────────────────────────────────────────────────
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisExtent: 160,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: visible.length,
              itemBuilder: (context, i) {
                final entry = visible[i];
                return _LoaderCard(
                  name: entry.name,
                  category: entry.category,
                  child: entry.build(controls),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Controls panel ───────────────────────────────────────────────────────────

class _ControlsPanel extends StatelessWidget {
  const _ControlsPanel({
    required this.size,
    required this.durationScale,
    required this.colorIndex,
    required this.onSizeChanged,
    required this.onDurationChanged,
    required this.onColorChanged,
  });

  final double size;
  final double durationScale;
  final int colorIndex;
  final ValueChanged<double> onSizeChanged;
  final ValueChanged<double> onDurationChanged;
  final ValueChanged<int> onColorChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.15),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
            border: Border(
              bottom: BorderSide(
                color: scheme.onSurface.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Size slider
              Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      'Size',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: scheme.primary.withValues(alpha: 0.8),
                        inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.15),
                        thumbColor: scheme.primary,
                        overlayColor: scheme.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: size,
                        min: 16,
                        max: 96,
                        divisions: 20,
                        label: '${size.round()} px',
                        onChanged: onSizeChanged,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${size.round()}px',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              // Duration slider
              Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      'Speed',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                        activeTrackColor: scheme.primary.withValues(alpha: 0.8),
                        inactiveTrackColor: scheme.onSurface.withValues(alpha: 0.15),
                        thumbColor: scheme.primary,
                        overlayColor: scheme.primary.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: durationScale,
                        min: 0.25,
                        max: 4.0,
                        divisions: 15,
                        label: '${durationScale.toStringAsFixed(2)}×',
                        onChanged: onDurationChanged,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '${durationScale.toStringAsFixed(2)}×',
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              // Color picker
              Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      'Color',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  ..._Controls.colors.asMap().entries.map((e) {
                    final selected = e.key == colorIndex;
                    return GestureDetector(
                      onTap: () => onColorChanged(e.key),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8, bottom: 4),
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: e.value,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? scheme.primary
                                : scheme.onSurface.withValues(alpha: 0.2),
                            width: selected ? 2.5 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: e.value.withValues(alpha: 0.6),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: selected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Loader card ──────────────────────────────────────────────────────────────

class _LoaderCard extends StatelessWidget {
  const _LoaderCard({
    required this.name,
    required this.category,
    required this.child,
  });

  final String name;
  final String category;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: Padding(padding: const EdgeInsets.all(12), child: child),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(12),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
