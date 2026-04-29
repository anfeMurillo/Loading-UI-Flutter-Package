# loading_ui

> **Note**: This is an **AI-created version** based on the original work of [loading-ui.com](https://loading-ui.com).

A collection of **36 beautiful, customisable loading animations** for Flutter,
ported from the [loading-ui](https://github.com/anfeMurillo/Loading-UI-Flutter-Package) library.

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

- Scrollable grid of all 36 widgets
- Size slider (16–96 px)
- Speed multiplier slider (0.25×–4×)
- Colour picker with 8 swatches
- Category filter chips

Run it with:

```sh
cd example
flutter run
```

---

## Contributing

Issues and pull requests are welcome on
[GitHub](https://github.com/anfeMurillo/Loading-UI-Flutter-Package).

---

## License

MIT — see [LICENSE](LICENSE).
