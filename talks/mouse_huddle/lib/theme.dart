import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Typeface for the whole deck. Declared in pubspec.yaml; change both to
/// swap it out.
const fontFamily = 'Lato'; // bundled in fonts/

// ---------------------------------------------------------------------------
// Palette — white page, near-black ink, one teal accent, and the warm/cold
// pair that carries the temperature story. The published state colours are
// kept exactly as printed.
// ---------------------------------------------------------------------------

const paper = Color(0xFFFFFFFF);
const card = Color(0xFFFFFFFF);
const wash = Color(0xFFF2F5F7);
const ink = Color(0xFF111416);
const muted = Color(0xFF5A646C);
const hairline = Color(0xFFD5DADF);

/// Boxes in this deck are outlined, not shadowed — this is that outline.
const boxLine = Color(0xFF111416);
const accent = Color(0xFFC2162B); // poster red: titles, marks, rules
const accentDeep = Color(0xFF8E0F1E);

/// The second half of the two-colour scheme, and the colour of the band
/// that carries a slide's one-line idea.
const accentBlue = Color(0xFF2B7FC4);
const band = Color(0xFF5B85C0);

/// Arena fill at 20 °C and at 5 °C, after Fig. 1a.
const warmTint = Color(0xFFEDEDED);
const coldTint = Color(0xFF7B82CC);
const warm = Color(0xFFD1581F);
const cold = Color(0xFF3B4BA8);

const activeColor = Color(0xFFD1581F);
const passiveColor = Color(0xFF2B7FC4);
const cnoColor = Color(0xFFB0208C);
const salColor = Color(0xFF6C7883);
const good = Color(0xFF198A5A);

// Mouse colours
const fur = Color(0xFF2B303A);
const furLine = Color(0xFF161B22);
const subjectPink = Color(0xFFE6007E);

/// The pale "was here a moment ago" silhouette used in the Fig. 3a scenes.
const ghostFur = Color(0xFFC7CDD4);
const ghostLine = Color(0xFF98A2AC);

/// Fig. 3 colour coding for the two decision kinds.
const activeBlue = Color(0xFF3FA9DD);
const passiveAmber = Color(0xFFF5C277);

/// One colour per group state: 0, 2:1:1, 2:2, 3:1, 4:0 (Fig. 1b).
const stateColors = [
  Color(0xFF3BB44A),
  Color(0xFFFCB614),
  Color(0xFFEE3E23),
  Color(0xFFC5168C),
  Color(0xFF662F8E),
];

// ---------------------------------------------------------------------------
// Type scale — canvas is 1920 × 1080
// ---------------------------------------------------------------------------

const tH1 = TextStyle(
    fontSize: 84, fontWeight: FontWeight.w900, height: 1.08, color: accent);
const tH2 = TextStyle(
    fontSize: 58, fontWeight: FontWeight.w900, height: 1.1, color: accent);
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

/// Interpolates along a list of colours; [x] runs from 0 to `colors.length - 1`.
Color lerpColors(List<Color> colors, double x) {
  final i = math.min(math.max(x.floor(), 0), colors.length - 2);
  return Color.lerp(colors[i], colors[i + 1], (x - i).clamp(0.0, 1.0))!;
}

double deg(double degrees) => degrees * math.pi / 180;

/// Smoothstep: the deck's one easing curve, for hand-rolled interpolation
/// inside painters (widgets use Curves.easeInOutCubic instead).
double ease(double t) {
  final x = t.clamp(0.0, 1.0);
  return x * x * (3 - 2 * x);
}

/// 1 when [stage] is exactly on [index], 0 a whole step away. Used to dim
/// the items a click-driven slide is not talking about yet.
double focusAt(double stage, int index) =>
    (1 - (stage - index).abs()).clamp(0.0, 1.0);

/// A faint shadow. Used sparingly — the deck leans on rules, not depth.
List<BoxShadow> softShadow({double y = 6, double blur = 20, double a = 0.06}) =>
    [BoxShadow(color: fade(ink, a), offset: Offset(0, y), blurRadius: blur)];

/// Draws [text] on a canvas, anchored at [at].
void paintText(
  Canvas canvas,
  String text,
  Offset at, {
  double size = 26,
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