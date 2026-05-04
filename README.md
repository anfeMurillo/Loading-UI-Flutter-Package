# loading_ui

> **Note**: This is an **AI-created version** based on original works:
> - Spinners, pulses, dots, bars, text & special loaders — ported from [loading-ui.com](https://loading-ui.com)
> - Dot Matrix loaders (63 matrix + 1 icon) — ported from [dotmatrix](https://github.com/zzzzshawn/matrix)

A collection of **100 loading animations** for Flutter (63 dot-matrix loaders + 36 classic loaders + 1 icon),
ported from the [loading-ui](https://github.com/anfeMurillo/Loading-UI-Flutter-Package) and
[dotmatrix](https://github.com/zzzzshawn/matrix) libraries.

All widgets are:
- **Accessible** — wrapped in `Semantics(liveRegion: true, label: 'Loading')`
- **Reduced-motion aware** — respect `MediaQuery.disableAnimations`
- **Dispose-safe** — controllers are always cleaned up
- **Zero dependencies** — only Flutter SDK, no third-party packages

![Showcase](example_image.gif)

---

## Installation

```yaml
dependencies:
  loading_ui: ^0.1.0-dev.1
```

Then import:

```dart
import 'package:loading_ui/loading_ui.dart';
```

---

## Usage

### Simple implementation

Just drop a loader widget into your widget tree. Most loaders require only a `size` and `color`.

```dart
import 'package:loading_ui/loading_ui.dart';

class MyLoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RingLoader(
        size: 40.0,
        color: Theme.of(context).primaryColor,
      ),
    );
  }
}
```

### Quick start examples

```dart
// Spinner
RingLoader(size: 32, color: Colors.blue)

// Dots
BouncingDotsLoader(color: Colors.purple)

// Text shimmer
TextShimmerLoader(text: 'Loading…', shimmerColor: Colors.indigo)

// Chat typing indicator
TypingLoader(color: Colors.green)

// Infinity loop
InfinityLoader(size: 48, color: Colors.orange)
```

---

## Widget catalogue

### Spinners (16)

| Widget | Description |
|---|---|
| `RingLoader` | Classic 315° rotating arc |
| `SpokesLoader` | Radial spokes fading in sequence |
| `ArcLoader` | Single growing/shrinking arc |
| `DualArcLoader` | Two arcs counter-rotating |
| `QuarterRingLoader` | 90° arc spinner |
| `ClockRingLoader` | Clock-hand sweep |
| `ConcentricRingLoader` | Two concentric rings at different speeds |
| `OrbitRingLoader` | Dot orbiting a stationary ring |
| `SatelliteRingLoader` | Ring + trailing satellite dot |
| `TripleDotLoader` | Three dots rotating as a unit |
| `ClassicLoader` | iOS-style 12-spoke fading spokes |
| `DotsRingLoader` | Ring of fading dots |
| `SpiralLoader` | Dots arranged in a spiral |
| `TwinOrbitLoader` | Two dots in opposing orbits |
| `DashRingLoader` | Material indeterminate ring (dash + spin) |
| `CometLoader` | Comet head with fading trail |

### Pulses (3)

| Widget | Description |
|---|---|
| `PulseLoader` | Expanding ring that fades out |
| `PulseDotLoader` | Filled dot breathing in/out |
| `RippleLoader` | Two offset expanding ripple rings |

### Dots (5)

| Widget | Description |
|---|---|
| `DotsLoader` | Dots fading in sequence |
| `BouncingDotsLoader` | Dots bouncing vertically |
| `BobbingDotsLoader` | Dots bobbing gently |
| `PulsatingDotsLoader` | Dots pulsing in scale |
| `TypingLoader` | Chat "someone is typing" indicator |

### Bars (2)

| Widget | Description |
|---|---|
| `BarsLoader` | Vertical equaliser bars |
| `WaveLoader` | Smooth sine-wave bars |

### Text (4)

| Widget | Description |
|---|---|
| `TextBlinkLoader` | Any widget pulsing in opacity |
| `TextDotsLoader` | Label + animated ellipsis dots |
| `TextShimmerLoader` | Highlight sweeps across text |
| `TextShimmerWaveLoader` | Per-character rise + colour wave |

### Special (6)

| Widget | Description |
|---|---|
| `SkeletonLoader` | Shimmer placeholder rectangle |
| `TerminalLoader` | Blinking block cursor prompt |
| `InfinityLoader` | ∞ symbol with animated dash stroke |
| `SwirlingLoader` | Swirling infinity with rotation |
| `WanderingEyesLoader` | Cartoon eyes that blink and look around |
| `AnalyzingImageLoader` | AI image-scan effect with sweep line |

### Dot Matrix (64)

> Ported from [dotmatrix](https://github.com/zzzzshawn/matrix) — 5×5 and 7×7 grid animations.

| Category | Count | Examples |
|---|---|---|
| **Square** (23) | `NeonDrift`, `PulseLadder`, `CoreSpiral`, `TwinOrbitMatrix`, `StrobeStack`, `GlyphPulse`, `PrismBloom`, `HelixGlow`, `InfinityRun`, `MobiusRun`, `BlockDrop`, etc. | 5×5 grid, `DotMatrixBase` widget |
| **Circular** (20) | `HaloDrift`, `TriOrbit`, `PlasmaVeil`, `RadarArc`, `NovaWheel`, `PhaseOrb`, `LunarBreathe`, `ArcBeacon`, `TwinHelix`, `GlyphCycle`, etc. | 5×5 masked to circle |
| **Triangle** (20) | `CoreSpokes`, `AltitudeWave`, `VertexChase`, `BrailleBeat`, `WingMetronome`, `CoronaTier`, `SerpentZip`, `PivotRay`, `TwinPerimeter`, etc. | 7×7 triangular mask, `TriangleMatrixBase` widget |
| **Icon** (1) | `DotMatrixIcon` | Phase-reactive icon: idle/collapse/hoverRipple/loadingRipple |

All matrix loaders share:
- `speed` parameter (same 1× multiplier)
- `color`, `size`, `dotSize` tuning
- Optional `opacityBase`, `opacityMid`, `opacityPeak` overrides
- `hoverAnimated` toggle
- Reduced-motion support via `DotMatrixPhases`

---

## Common parameters

Most widgets share this uniform API:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `size` | `double` | `24.0` | Overall bounding box in logical pixels |
| `color` | `Color?` | icon/text theme | Tint colour (`null` → resolves from context) |
| `duration` | `Duration` | varies | One full animation cycle |
| `semanticsLabel` | `String?` | `'Loading'` | Override the screen-reader label |

Text loaders (`TextShimmerLoader`, `TextShimmerWaveLoader`) also accept:

| Parameter | Description |
|---|---|
| `text` | The string to render |
| `style` | `TextStyle?` to apply |
| `baseColor` | Dim colour at rest |
| `shimmerColor` | Bright colour at peak |

Wrapper loaders (`TextBlinkLoader`, `TextDotsLoader`) accept:

| Parameter | Description |
|---|---|
| `child` | Any widget (typically `Text`) |

Matrix loaders additionally accept:

| Parameter | Type | Default | Description |
|---|---|---|---|
| `speed` | `double` | `1.0` | Speed multiplier (1× normal) |
| `dotSize` | `double` | `4.0` | Each dot diameter in px |
| `opacityBase` | `double?` | `null` | Minimum dot opacity override |
| `opacityMid` | `double?` | `null` | Mid-tier opacity override |
| `opacityPeak` | `double?` | `null` | Peak opacity override |
| `hoverAnimated` | `bool` | `false` | React to mouse hover |
| `cellPadding` | `double?` | `null` | Gap between dots |
| `pattern` | `MatrixPattern` | `full` | Dot visibility pattern (diamond, outline, rose, cross, full, rings) |

---

## Accessibility

Every widget automatically announces itself as a live region:

```dart
Semantics(
  container: true,
  label: semanticsLabel ?? 'Loading',
  liveRegion: true,
  child: ...,
)
```

When `MediaQuery.disableAnimations` is `true` the animation controller is
stopped immediately via the `LoaderAnimationMixin`, so no motion occurs on
devices with "Reduce Motion" enabled.

---

## Example app

The `example/` directory contains an interactive showcase with:

- Scrollable grid of all **100 widgets** (64 matrix + 36 classic)
- Size slider (16–96 px)
- Speed multiplier slider (0.25×–4×)
- Colour picker with 8 swatches
- Category filter chips (`All`, `Spinners`, `Pulses`, `Dots`, `Bars`, `Text`, `Special`, `Matrix`)

Run it with:

```sh
cd example
flutter run
```

---

## Credits

This package ports animations from two open-source libraries:

| Source | Library | License |
|---|---|---|
| [loading-ui.com](https://loading-ui.com) | 36 classic loaders (spinners, pulses, dots, bars, text, special) | MIT |
| [zzzzshawn/matrix](https://github.com/zzzzshawn/matrix) | 63 dot-matrix loaders + 1 icon | MIT |

Both original projects are MIT-licensed. This Flutter port is also MIT.

## Contributing

Issues and pull requests are welcome on
[GitHub](https://github.com/anfeMurillo/Loading-UI-Flutter-Package).

---

## License

MIT — see [LICENSE](LICENSE).
