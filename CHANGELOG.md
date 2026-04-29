## 0.1.0-dev.1

Initial developer preview — full port of the [loading-ui](https://github.com/anfeh/loading-ui)
React/Tailwind library to Flutter.

### New widgets (36 total)

**Spinners**
- `RingLoader` — classic 315° rotating arc
- `SpokesLoader` — radial spokes fading in sequence
- `ArcLoader` — single growing/shrinking arc
- `DualArcLoader` — two arcs counter-rotating
- `QuarterRingLoader` — 90° arc spinner
- `ClockRingLoader` — clock-hand sweep
- `ConcentricRingLoader` — two concentric rings at different speeds
- `OrbitRingLoader` — dot orbiting a stationary ring
- `SatelliteRingLoader` — ring + trailing satellite dot
- `TripleDotLoader` — three dots rotating as a unit
- `ClassicLoader` — iOS-style 12-spoke fading spokes
- `DotsRingLoader` — ring of fading dots
- `SpiralLoader` — dots arranged in a spiral
- `TwinOrbitLoader` — two dots in opposing orbits
- `DashRingLoader` — Material indeterminate ring (dash-offset + spin)
- `CometLoader` — comet head with fading trail

**Pulses**
- `PulseLoader` — expanding ring that fades out
- `PulseDotLoader` — filled dot breathing in/out
- `RippleLoader` — two offset expanding ripple rings

**Dots**
- `DotsLoader` — dots fading in sequence
- `BouncingDotsLoader` — dots bouncing vertically
- `BobbingDotsLoader` — dots bobbing gently
- `PulsatingDotsLoader` — dots pulsing in scale
- `TypingLoader` — chat "someone is typing" indicator

**Bars**
- `BarsLoader` — vertical equaliser bars
- `WaveLoader` — smooth sine-wave bars

**Text**
- `TextBlinkLoader` — any widget pulsing in opacity
- `TextDotsLoader` — label + animated ellipsis dots
- `TextShimmerLoader` — highlight sweeps across text
- `TextShimmerWaveLoader` — per-character rise + colour wave

**Special**
- `SkeletonLoader` — shimmer placeholder rectangle
- `TerminalLoader` — blinking block cursor prompt
- `InfinityLoader` — ∞ symbol with animated dash stroke
- `SwirlingLoader` — swirling infinity with rotation
- `WanderingEyesLoader` — cartoon eyes that blink and look around
- `AnalyzingImageLoader` — AI image-scan effect with sweep line

### Core infrastructure
- `LoaderAnimationMixin` — auto-starts/stops on `MediaQuery.disableAnimations`
- `LoaderWrapper` — `Semantics(liveRegion: true)` + `RepaintBoundary`
- `phaseOf` / `lerpStops` stagger helpers in `core/stagger.dart`
- Uniform API: `size`, `color`, `duration`, `semanticsLabel` on all widgets
- 145 passing widget tests across 4 test suites
