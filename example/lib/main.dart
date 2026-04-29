import 'package:flutter/material.dart';
import 'package:loading_ui_flutter/loading_ui_flutter.dart';

void main() => runApp(const LoadingShowcaseApp());

// ─── App shell ────────────────────────────────────────────────────────────────

class LoadingShowcaseApp extends StatelessWidget {
  const LoadingShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'loading_ui_flutter showcase',
      debugShowCheckedModeBanner: false,
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
  int _colorIndex = 0;
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
        title: const Text('loading_ui_flutter'),
        centerTitle: true,
        backgroundColor: scheme.surfaceContainerHighest,
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

    return Container(
      color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Size slider
          Row(
            children: [
              const SizedBox(
                width: 72,
                child: Text(
                  'Size',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Slider(
                  value: size,
                  min: 16,
                  max: 96,
                  divisions: 20,
                  label: '${size.round()} px',
                  onChanged: onSizeChanged,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${size.round()}px',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          // Duration slider
          Row(
            children: [
              const SizedBox(
                width: 72,
                child: Text(
                  'Speed',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Slider(
                  value: durationScale,
                  min: 0.25,
                  max: 4.0,
                  divisions: 15,
                  label: '${durationScale.toStringAsFixed(2)}×',
                  onChanged: onDurationChanged,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '${durationScale.toStringAsFixed(2)}×',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          // Color picker
          Row(
            children: [
              const SizedBox(
                width: 72,
                child: Text(
                  'Color',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ..._Controls.colors.asMap().entries.map((e) {
                final selected = e.key == colorIndex;
                return GestureDetector(
                  onTap: () => onColorChanged(e.key),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6, bottom: 6),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                      border: selected
                          ? Border.all(color: scheme.primary, width: 2.5)
                          : Border.all(color: scheme.outlineVariant, width: 1),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: e.value.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
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
