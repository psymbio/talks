import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Typeface for the whole deck. Declared in pubspec.yaml; change both to
/// swap it out.
const fontFamily = 'Lato';

// ---------------------------------------------------------------------------
// Palette. The cue colours are the paper's own, so every slide reads against
// the published figures without translation.
// ---------------------------------------------------------------------------

const paper = Color(0xFFFFFFFF);
const card = Color(0xFFFFFFFF);
const wash = Color(0xFFF1F3F6);
const ink = Color(0xFF14181C);
const muted = Color(0xFF5B656D);
const hairline = Color(0xFFD7DCE1);
const boxLine = Color(0xFF14181C);

/// The two strains.
const appPurple = Color(0xFF9B27D6);
const wtGrey = Color(0xFF6B757E);

/// The four cues (Fig. 1b onward).
const odorA = Color(0xFFE6007E); // prelearned, rewarded
const odorB = Color(0xFF2550C8); // prelearned, punished
const odor1 = Color(0xFF0E9E6E); // novel, rewarded
const odor2 = Color(0xFFE9A020); // novel, punished

/// Anatomy and interventions.
const dopamineGreen = Color(0xFF27B36B);
const abRed = Color(0xFFE23A2E);
const laserBlue = Color(0xFF2BAEE8);
const ldopaGreen = Color(0xFF2E9E4B);

const accent = appPurple;
const good = Color(0xFF1C8C57);

// ---------------------------------------------------------------------------
// Type scale — canvas is 1920 × 1080
// ---------------------------------------------------------------------------

const tH1 = TextStyle(
    fontSize: 80, fontWeight: FontWeight.w900, height: 1.08, color: ink);
const tH2 = TextStyle(
    fontSize: 52, fontWeight: FontWeight.w900, height: 1.12, color: ink);
const tLead = TextStyle(fontSize: 36, height: 1.4, color: ink);
const tBody = TextStyle(fontSize: 31, height: 1.45, color: ink);
const tNote = TextStyle(fontSize: 27, height: 1.45, color: ink);
const tSmall = TextStyle(fontSize: 24, height: 1.4, color: muted);
const tKicker = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.5,
    color: accent);

final talkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: fontFamily,
  scaffoldBackgroundColor: paper,
  colorScheme: ColorScheme.fromSeed(seedColor: accent),
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// [c] with its alpha replaced by [a] (0 ... 1).
Color fade(Color c, double a) => c.withAlpha((255 * a.clamp(0.0, 1.0)).round());

/// Interpolates along a list of colours; [x] runs 0 to `colors.length - 1`.
Color lerpColors(List<Color> colors, double x) {
  final i = math.min(math.max(x.floor(), 0), colors.length - 2);
  return Color.lerp(colors[i], colors[i + 1], (x - i).clamp(0.0, 1.0))!;
}

double deg(double degrees) => degrees * math.pi / 180;

/// Smoothstep, for hand-rolled interpolation inside painters.
double ease(double t) {
  final x = t.clamp(0.0, 1.0);
  return x * x * (3 - 2 * x);
}

/// 1 when [stage] sits on [index], 0 a whole step away.
double focusAt(double stage, int index) =>
    (1 - (stage - index).abs()).clamp(0.0, 1.0);

/// Draws [text] on a canvas, anchored at [at].
void paintText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 24,
  Color color = muted,
  FontWeight weight = FontWeight.w400,
  Alignment anchor = Alignment.topLeft,
}) {
  final painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontFamily: fontFamily,
        fontSize: size,
        color: color,
        fontWeight: weight,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  painter.paint(
    canvas,
    at -
        Offset(
          (anchor.x + 1) / 2 * painter.width,
          (anchor.y + 1) / 2 * painter.height,
        ),
  );
}
