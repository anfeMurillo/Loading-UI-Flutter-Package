# Plan de portación: `loading-ui` → `loading_ui_flutter`

Documento de planificación para portar el paquete React/Tailwind original (`loading_ui_original/`) a un paquete Flutter publicable en pub.dev. No es código todavía — sólo el plano técnico.

---

## 1. Análisis del proyecto original

### 1.1 Qué es

`loading-ui` es una librería de **35 componentes de carga** + 1 utilidad (`utils`) distribuidos al estilo `shadcn/ui`: el usuario copia el archivo del componente al registro, no consume un paquete npm tradicional. Cada componente es un `.tsx` autocontenido en `registry/components/loading-ui/`.

Repositorio original: estructura Next.js + fumadocs (sitio de documentación) + `registry.json` (índice del catálogo). Para la portación a Flutter sólo nos interesan los **componentes**, no el sitio.

### 1.2 Inventario completo (35 spinners)

Extraído de `registry.json`:

| Categoría | Componentes |
|---|---|
| **Spinners de anillo** | `ring`, `arc`, `dual-arc`, `quarter-ring`, `dash-ring`, `clock-ring`, `concentric-ring`, `orbit-ring`, `satellite-ring`, `spokes` |
| **Anillos de puntos / órbitas** | `dots-ring`, `spiral`, `swirling`, `comet-spinner`, `twin-orbit`, `triple-dot-spinner` |
| **Clásicos** | `classic` (12 barras radiales) |
| **Pulsos** | `pulse`, `pulse-dot`, `ripple` |
| **Puntos / dots** | `dots`, `bouncing-dots`, `bobbing-dots`, `pulsating-dots`, `typing` |
| **Barras** | `bars`, `wave` |
| **Texto** | `text-blink`, `text-dots`, `text-shimmer`, `text-shimmer-wave` |
| **Especiales** | `infinity`, `skeleton`, `terminal`, `analyzing-image`, `wandering-eyes` |

### 1.3 Patrones técnicos detectados

Después de leer ~20 componentes representativos, todo se reduce a **4 patrones** de implementación:

1. **CSS keyframes + `<style>` inline** (~25 componentes). Un `@keyframes` global, `animation-duration` controlado por la CSS variable `--duration`. Ej: `ring`, `bars`, `dots`, `wave`, `classic`.
2. **SVG con `<animate>` / `<animateTransform>` SMIL** (`ripple`, `dash-ring`).
3. **`motion/react` (Framer Motion)** para animaciones imperativas declarativas: `spiral`, `bobbing-dots`, `pulsating-dots`, `text-shimmer`, `text-shimmer-wave`, `analyzing-image`.
4. **Compuestos con varias capas** + composición de keyframes: `comet-spinner` (box-shadow animado), `wandering-eyes` (background-position + blink), `terminal` (cursor parpadeante).

### 1.4 Convenciones del original a respetar conceptualmente

- **`color: currentColor`**: el color del spinner se hereda del contexto (en Flutter: `DefaultTextStyle.color` o un `color` explícito).
- **CSS var `--duration`** para personalizar velocidad sin reescribir el componente (en Flutter: parámetro `duration`).
- **Tamaño desde el contenedor** (`size-5`, `cqmin`): el componente se adapta a su `width/height` (en Flutter: `SizedBox` o respetar `constraints`).
- **Accesibilidad**: `role="status"` + `<span class="sr-only">Loading</span>` (en Flutter: `Semantics(label: 'Loading', liveRegion: true)`).
- **API props** mínima y predecible: `className`, `style`, a veces `dots`, `radius`, `duration`.

---

## 2. Estrategia de portación a Flutter

### 2.1 Mapeo conceptual

| Concepto web | Equivalente Flutter |
|---|---|
| CSS `@keyframes` + `animation` | `AnimationController` + `Tween` / `TweenSequence` |
| `currentColor` | `IconTheme.of(context).color` o parámetro `color` con default `null` que cae en `DefaultTextStyle.color` |
| `--duration` CSS var | parámetro `Duration duration` |
| `transform: rotate(...)` | `Transform.rotate` o `RotationTransition` |
| `transform: scale(...)` | `Transform.scale` / `ScaleTransition` |
| `opacity` | `Opacity` / `FadeTransition` |
| SVG path estático | `CustomPaint` + `Path` (NO usar paquetes de SVG: cero dependencias) |
| SVG `<animate>` SMIL | `CustomPainter` que repinta vía `AnimationController` |
| `motion/react` keyframes con `times` | `TweenSequence<TweenSequenceItem>` |
| Tailwind `size-5`, `gap-[12%]` | `SizedBox`, `Row`/`Column` con `spacing` o `Padding` proporcional |
| `cqmin` (container query) | `LayoutBuilder` para leer el tamaño y derivar dimensiones |
| `bg-current` (texto/fondo color de texto) | `Container(color: effectiveColor)` |
| `[--var: x]` CSS custom prop | parámetros del widget; nada de variables globales |

### 2.2 Decisiones de diseño del paquete

1. **Cero dependencias** más allá del SDK de Flutter. Los paths SVG se reescriben como `Path` de `dart:ui`. Ningún paquete de animación externo (`flutter_animate`, etc.) — todo con `AnimationController`.
2. **Cada componente es un `StatefulWidget`** (necesario por `AnimationController` + `TickerProviderStateMixin`). Excepto los puramente estáticos compuestos (no hay).
3. **API uniforme** entre todos los spinners — superficie común:
   ```dart
   const RingLoader({
     Key? key,
     this.size = 24.0,
     this.color,           // null → hereda de IconTheme/DefaultTextStyle
     this.duration = const Duration(milliseconds: 1000),
     this.strokeWidth,     // sólo donde aplique
   });
   ```
4. **Color resolution helper** centralizado: una función `resolveColor(BuildContext, Color?)` que reproduce `currentColor` de la web.
5. **Naming**: `kebab-case` del original → `PascalCase` Dart. Para evitar colisión con widgets de Flutter (p. ej. `Skeleton` choca con varios paquetes), usar **sufijo `Loader`** sólo donde haya colisión: `RingLoader`, `PulseLoader`, `SkeletonLoader`. Donde no haya colisión, mantener el nombre directo (`Bars`, `Dots`, `WanderingEyes`). Decidir caso por caso al implementar; documentar en `PLAN_NAMING.md` la primera vez que aparezca duda.
6. **Sin StatefulBuilder mágico**: cada widget administra su propio `AnimationController` y lo dispone en `dispose()`.
7. **Performance**: usar `RepaintBoundary` alrededor de cada loader para que no invalide el árbol padre en cada frame.
8. **Accesibilidad**: cada widget se envuelve en `Semantics(label: 'Loading', liveRegion: true, ...)`. Parámetro `semanticsLabel` opcional para personalizar.

### 2.3 Plantilla mental para portar un componente CSS-keyframes

Original (`Ring`):
```tsx
@keyframes spin { to { transform: rotate(360deg); } }
animation: spin var(--duration, 1s) linear infinite;
```

Flutter:
```dart
class RingLoader extends StatefulWidget { /* ...props... */ }
class _RingLoaderState extends State<RingLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.semanticsLabel ?? 'Loading',
      liveRegion: true,
      child: SizedBox.square(
        dimension: widget.size,
        child: RepaintBoundary(
          child: RotationTransition(
            turns: _ctrl,
            child: CustomPaint(painter: _RingPainter(color: ...)),
          ),
        ),
      ),
    );
  }
}
```

### 2.4 Plantilla para componentes con `motion/react` (TweenSequence)

`spiral` con `scale: [0, 1, 0]`, `opacity: [0, 1, 0]` y `delay` por punto:

```dart
final scale = TweenSequence<double>([
  TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 50),
  TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 50),
]).animate(CurvedAnimation(parent: _ctrl, curve: Interval(delayFraction, 1.0, curve: Curves.easeInOut)));
```

Cada punto recibe un `Interval` distinto (equivalente al `delay` del original).

---

## 3. Estructura del paquete

```
loading_ui_flutter/
├── lib/
│   ├── loading_ui_flutter.dart        # barrel export
│   └── src/
│       ├── core/
│       │   ├── color_resolver.dart    # resolveColor(context, color?)
│       │   ├── loader_base.dart       # mixins/helpers compartidos (Semantics, RepaintBoundary)
│       │   └── painters/              # CustomPainters reutilizables (arc, ring stroke)
│       ├── spinners/
│       │   ├── ring.dart
│       │   ├── arc.dart
│       │   ├── dual_arc.dart
│       │   ├── quarter_ring.dart
│       │   ├── dash_ring.dart
│       │   ├── clock_ring.dart
│       │   ├── concentric_ring.dart
│       │   ├── orbit_ring.dart
│       │   ├── satellite_ring.dart
│       │   ├── spokes.dart
│       │   ├── dots_ring.dart
│       │   ├── spiral.dart
│       │   ├── swirling.dart
│       │   ├── comet_spinner.dart
│       │   ├── twin_orbit.dart
│       │   ├── triple_dot_spinner.dart
│       │   └── classic.dart
│       ├── pulses/
│       │   ├── pulse.dart
│       │   ├── pulse_dot.dart
│       │   └── ripple.dart
│       ├── dots/
│       │   ├── dots.dart
│       │   ├── bouncing_dots.dart
│       │   ├── bobbing_dots.dart
│       │   ├── pulsating_dots.dart
│       │   └── typing.dart
│       ├── bars/
│       │   ├── bars.dart
│       │   └── wave.dart
│       ├── text/
│       │   ├── text_blink.dart
│       │   ├── text_dots.dart
│       │   ├── text_shimmer.dart
│       │   └── text_shimmer_wave.dart
│       └── special/
│           ├── infinity.dart
│           ├── skeleton.dart
│           ├── terminal.dart
│           ├── analyzing_image.dart
│           └── wandering_eyes.dart
├── test/
│   └── (un *_test.dart por componente — ver §6)
├── example/
│   ├── lib/main.dart                  # app de demo con grid de los 35 widgets
│   └── pubspec.yaml
├── pubspec.yaml                       # actualizar: description, homepage, repository, topics
├── CHANGELOG.md
├── LICENSE                            # MIT (mismo que el original)
└── README.md                          # reescribir (sección Uso por componente)
```

---

## 4. Mapeo componente-por-componente (estrategia de implementación)

Tabla de las 35 portaciones. **Complejidad** estima esfuerzo (S/M/L). **Técnica** es el enfoque a usar.

| # | Componente | Complejidad | Técnica Flutter | Notas |
|--:|---|:-:|---|---|
| 1 | `ring` | S | `CustomPainter` (arco SVG) + `RotationTransition` | Path arc del original, stroke 2 |
| 2 | `spokes` | S | `CustomPainter` (8 líneas) + `RotationTransition` | |
| 3 | `classic` | S | `Stack` con 12 barras posicionadas + opacidad por `Interval` | El `transform: rotate(i*30deg) translate(146%)` → `Transform.translate(Offset.fromDirection(...))` |
| 4 | `arc` | S | `Container` con `BoxDecoration.border` (top color, resto translúcido) + `RotationTransition` | Sin `CustomPaint`, sólo borders |
| 5 | `dual-arc` | S | Igual que `arc` pero `border-y` | |
| 6 | `quarter-ring` | S | Border top + right en color, otros transparentes | |
| 7 | `concentric-ring` | M | 2 anillos (`Container` con border) anidados, padre rota | |
| 8 | `orbit-ring` | M | 1 anillo interno opaco + 1 anillo externo más grande con border-bottom | |
| 9 | `satellite-ring` | S | Anillo + `Positioned` dot, padre rota | |
| 10 | `clock-ring` | S | Anillo + `Positioned` barra vertical, padre rota | |
| 11 | `dash-ring` | M | `CustomPainter` (2 círculos) — uno fijo opacidad 0.1, otro con `dashArray` animado vía `Path.combine` o `PathMetric.extractPath` | SMIL → `AnimationController` con dos curvas |
| 12 | `dots-ring` | M | `LayoutBuilder` + N dots posicionados con trig (`sin/cos`) + escalas con `Interval` por dot | Reproducir `cqmin`: leer `min(width,height)` |
| 13 | `spiral` | M | Igual que `dots-ring` pero animación es scale+opacity 0→1→0 con `delay` por dot | |
| 14 | `swirling` | M | `CustomPainter` con stroke dasharray animado + rotación | Doble animación: `dash` (1.5s) + `spin` (2s, `1.333x`) |
| 15 | `comet-spinner` | L | El más complejo. La animación de `box-shadow` no es directamente portable. Estrategia: reemplazar por un trail de N círculos con `CustomPainter`, opacidades crecientes, todos rotando y siguiendo la cabeza | Considerar simplificación: trail de 5 círculos en arco, animado |
| 16 | `twin-orbit` | M | 2 dots orbitando un centro, una con `delay = duration/2` | `Transform.rotate(angle).translate(...)` con `AnimationController` |
| 17 | `triple-dot-spinner` | S | 3 círculos en línea horizontal, contenedor rota | |
| 18 | `pulse` | S | Borde circular + `ScaleTransition` (0.95↔1.05) + `FadeTransition` | |
| 19 | `pulse-dot` | S | Círculo lleno con `ScaleTransition` 1↔1.5 + opacidad | |
| 20 | `ripple` | M | 2 círculos creciendo (r:1→20) y fade-out, una desfasada -0.9s | `CustomPainter` con dos animaciones (la 2ª con `Interval` desplazado) |
| 21 | `dots` | S | Row de N dots con `FadeTransition` + delay por dot vía `Interval` | |
| 22 | `bouncing-dots` | S | Row de N dots con `ScaleTransition` (0.8↔1.2) + opacidad | |
| 23 | `bobbing-dots` | S | Row de N dots con `SlideTransition` (y: 0→0.625em→0) | |
| 24 | `pulsating-dots` | S | Row de N dots con scale+opacity, `delay = i*0.3` | |
| 25 | `typing` | S | Row de N dots con translateY+opacidad | |
| 26 | `bars` | S | Row de N barras con `ScaleTransition` (scaleY 1↔0.6) + opacidad | |
| 27 | `wave` | S | Row de 5 barras con alturas fijas `[50%,75%,100%,75%,50%]`, scaleY animado | |
| 28 | `text-blink` | S | `Text` envuelto en `FadeTransition` (1↔minOpacity↔1) | |
| 29 | `text-dots` | S | `Row` con texto hijo + N caracteres `.` con `FadeTransition` desfasada | |
| 30 | `text-shimmer` | L | `ShaderMask` con `LinearGradient` que se mueve. Animar `transform: GradientTransform` o el `stops` del gradiente | El truco web es `background-position` animado; en Flutter es un `LinearGradient` con `transform: GradientRotation`/`SlidingGradientTransform` |
| 31 | `text-shimmer-wave` | L | Letra por letra: cada `Text` un widget con animación 3D (translateZ, rotateY, scale, color). Usar `Transform` con `Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(...)` | Más demandante; puede simplificarse a 2D si la 3D no aporta visualmente |
| 32 | `infinity` | M | `CustomPainter` con `Path` del lemniscate, `strokeDashArray` animado vía `PathMetric.extractPath` | Path original es complejo — copiarlo literal |
| 33 | `skeleton` | S | `Container` con color base + `FadeTransition` 1→0.5→1 | Equivalente a `bg-muted animate-pulse` de shadcn |
| 34 | `terminal` | S | `Row` con `Text(prompt)` + `Container` (cursor) con `FadeTransition` step-end (sin interpolación; usar `AnimationStatus` o `Tween<double>` con `Curves.linear` discretizado) | Cuidado: `step-end` ≠ linear; usar listener para flip 0/1 |
| 35 | `analyzing-image` | L | `CustomPainter` (icono imagen estático) + capa con `ClipRect` animada (recorte horizontal: `inset(0 0 0 0)` → `inset(0 105% 0 0)`) + barra de scan que cruza | El icono SVG con todos los pixels de "ruido" — copiar el path literal o renderizar con varios `Container`s pequeños en un `Stack` |
| 36 | `wandering-eyes` | L | 2 ojos: `CustomPainter` por ojo (radial gradient pupil) + animación de `background-position` (offset del pupil dentro del ojo) + animación de `height` (parpadeo) | El radial-gradient del pupil → pintar círculo de pupila con offset animado |

**Total**: ~16 simples (S), ~13 medias (M), ~6 largas (L) — esfuerzo total ≈ 4-6 semanas para una persona dedicada.

---

## 5. Roadmap por fases

### Fase 0 — Preparación (½ día)
- Actualizar `pubspec.yaml`: `description`, `homepage`, `repository`, `topics: [loading, spinner, animation, ui]`, `version: 0.1.0-dev.1`.
- Crear estructura `lib/src/{core,spinners,pulses,dots,bars,text,special}/`.
- Implementar `lib/src/core/color_resolver.dart` y `lib/src/core/loader_base.dart`.
- Implementar `CustomPainter` base reutilizable en `lib/src/core/painters/arc_painter.dart`.

### Fase 1 — Spinners CSS-only triviales (2-3 días)
Empezar por los más simples para validar la arquitectura: `ring`, `spokes`, `arc`, `dual-arc`, `quarter-ring`, `clock-ring`, `concentric-ring`, `orbit-ring`, `satellite-ring`, `triple-dot-spinner`, `pulse`, `pulse-dot`, `skeleton`, `terminal`, `text-blink`.
- Cada uno con su test mínimo (renderiza + tick anima).
- Ajustar `loader_base.dart` según fricciones reales.

### Fase 2 — Dots, bars y text simples (2-3 días)
- `dots`, `bouncing-dots`, `bobbing-dots`, `pulsating-dots`, `typing`, `bars`, `wave`, `text-dots`, `classic`, `dots-ring`, `spiral`, `twin-orbit`, `satellite-ring`.
- Aquí aparece el patrón de **N elementos con delay escalado** — extraer helper `staggeredInterval(i, total)` en `core/`.

### Fase 3 — CustomPainter intensivo (3-4 días)
- `infinity`, `dash-ring`, `swirling`, `ripple`, `wandering-eyes`. Todos requieren `Path` + `PathMetric` o gradients.
- Validar performance con DevTools (objetivo: 60 fps en debug, 120 fps en release).

### Fase 4 — Componentes complejos (3-5 días)
- `comet-spinner` (decisión de simplificación de trail), `analyzing-image`, `text-shimmer`, `text-shimmer-wave`.
- Aquí se decide si `text-shimmer-wave` mantiene la 3D real o se simplifica.

### Fase 5 — Pulido y publicación (2 días)
- Example app con grid interactivo (sliders para `duration`, picker de `color`, slider de `size`).
- README con tabla de componentes + GIFs (capturados de la example app).
- `dartdoc` en cada widget público.
- `dart analyze` y `dart format` limpios.
- `flutter test` verde.
- `pub publish --dry-run` y `pana .` para revisar score.

**Estimación total**: 10-15 días de trabajo enfocado.

---

## 6. Estrategia de testing

Para cada widget, mínimo dos tests:

1. **Render test**: monta el widget, verifica que existe el `Semantics` con `label: 'Loading'`.
2. **Animation test**: usa `tester.pump(duration / 4)` y verifica que el árbol cambia (e.g. `Transform.rotate` con ángulo distinto, opacidad distinta). No comparar valores exactos — comparar que **algo** cambió.
3. **Dispose test** (sólo widgets stateful): monta y desmonta sin warnings de tickers no liberados.

Tests visuales con `golden_toolkit` (opcional, fase 5): un golden por componente en su frame medio.

---

## 7. Decisiones abiertas / a confirmar con el usuario

Estas decisiones afectan la API pública y conviene resolverlas antes de Fase 1:

1. **Naming**: ¿usar sufijo `Loader` siempre (`RingLoader`, `DotsLoader`) por consistencia, o sólo donde haya colisión? Recomendación: **siempre**, por previsibilidad y para evitar shadowing accidental con widgets de aplicación.
R// siempre
2. **Tamaño por defecto**: el original usa `currentColor` y "lo que el padre le diga". En Flutter no hay equivalente directo de `width: 100%`. Propuesta: `size: 24.0` por defecto (igual que `Icon`), con la opción de envolver en `SizedBox` o `Expanded` si se quiere más grande.
R// Usa la opcion propuesta
3. **Color por defecto**: ¿`null` que cae en `IconTheme.of(context).color`, o forzar `theme.colorScheme.primary`? Recomendación: **`null` → IconTheme** para mimetizar `currentColor`.
R// Usa la opcion recomendada
4. **Versión mínima de Flutter**: el `pubspec.yaml` dice `>=1.17.0` (heredado del template). Subir a `>=3.10.0` por `super-parameters` y `records`.
R// Subela
5. **Animaciones reducidas (a11y)**: respetar `MediaQuery.disableAnimations` → si está activo, mostrar el frame estático sin animar. El original no lo hace; aquí es valor añadido.
R// Si
6. **`comet-spinner`**: la animación original abusa de `box-shadow` con keyframes muy específicos. Tres opciones:
   - (a) Reproducir literal con `CustomPainter` calculando los offsets del trail por frame.
   - (b) Simplificar a un arco con gradiente que rota.
   - (c) Saltarlo en v0.1.0 y añadirlo después.
   Recomendación: **(a)**, pero confirmar.

R// a

---

## 8. Out of scope (explícito)

- **No portar el sitio web** (`app/`, `content/`, fumadocs). Esto es sólo el paquete.
- **No portar `motion/react` como dependencia**. Toda animación se reescribe nativa.
- **No portar `tailwind-merge`/`clsx`**. No aplica en Flutter.
- **No incluir CLI tipo `shadcn add ring`**. Distribución estándar de pub.dev.
- **No mantener compatibilidad bidireccional** con el `registry.json` original. Es un paquete distinto.

---

## 9. Próximo paso sugerido

Con este plan aprobado, el orden de ejecución es:

1. Confirmar las decisiones abiertas de §7. [X]
2. Implementar Fase 0 (estructura + helpers `core/`).[ ]
3. Implementar `ring.dart` end-to-end como prueba de concepto + su test.[ ]
4. Revisar el resultado y ajustar el plan si emergen problemas (especialmente con `currentColor` y sizing).[ ]

