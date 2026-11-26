import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

// ---------------------------------------------------------------------------
// A schematic coronal section, drawn once and reused all through the deck:
// the circuit slides, the amyloid progression, photometry and optogenetics.
// Everything is in unit coordinates, so the same drawing scales anywhere.
// ---------------------------------------------------------------------------

const _lec = Offset(0.73, 0.70);
const _vta = Offset(0.28, 0.72);
const _snc = Offset(0.42, 0.75);
const _hippo = Offset(0.46, 0.40);

/// Outline of the hemisphere.
Path _outline(Size s) {
  Offset p(double x, double y) => Offset(x * s.width, y * s.height);
  return Path()
    ..moveTo(p(0.09, 0.28).dx, p(0.09, 0.28).dy)
    ..cubicTo(p(0.30, 0.05).dx, p(0.30, 0.05).dy, p(0.78, 0.09).dx,
        p(0.78, 0.09).dy, p(0.92, 0.40).dx, p(0.92, 0.40).dy)
    ..cubicTo(p(0.99, 0.60).dx, p(0.99, 0.60).dy, p(0.93, 0.80).dx,
        p(0.93, 0.80).dy, p(0.74, 0.88).dx, p(0.74, 0.88).dy)
    ..cubicTo(p(0.54, 0.95).dx, p(0.54, 0.95).dy, p(0.30, 0.90).dx,
        p(0.30, 0.90).dy, p(0.19, 0.76).dx, p(0.19, 0.76).dy)
    ..cubicTo(p(0.11, 0.66).dx, p(0.11, 0.66).dy, p(0.09, 0.46).dx,
        p(0.09, 0.46).dy, p(0.09, 0.28).dx, p(0.09, 0.28).dy)
    ..close();
}

/// The hippocampal band.
Path _hippocampus(Size s) {
  Offset p(double x, double y) => Offset(x * s.width, y * s.height);
  return Path()
    ..moveTo(p(0.24, 0.42).dx, p(0.24, 0.42).dy)
    ..cubicTo(p(0.30, 0.26).dx, p(0.30, 0.26).dy, p(0.58, 0.24).dx,
        p(0.58, 0.24).dy, p(0.66, 0.40).dx, p(0.66, 0.40).dy)
    ..cubicTo(p(0.70, 0.49).dx, p(0.70, 0.49).dy, p(0.62, 0.55).dx,
        p(0.62, 0.55).dy, p(0.54, 0.50).dx, p(0.54, 0.50).dy);
}

/// The dashed LEC boundary.
Path _lecOutline(Size s) {
  Offset p(double x, double y) => Offset(x * s.width, y * s.height);
  return Path()
    ..moveTo(p(0.63, 0.56).dx, p(0.63, 0.56).dy)
    ..cubicTo(p(0.78, 0.53).dx, p(0.78, 0.53).dy, p(0.88, 0.62).dx,
        p(0.88, 0.62).dy, p(0.83, 0.76).dx, p(0.83, 0.76).dy)
    ..cubicTo(p(0.79, 0.86).dx, p(0.79, 0.86).dy, p(0.64, 0.86).dx,
        p(0.64, 0.86).dy, p(0.61, 0.76).dx, p(0.61, 0.76).dy)
    ..cubicTo(p(0.58, 0.68).dx, p(0.58, 0.68).dy, p(0.58, 0.58).dx,
        p(0.58, 0.58).dy, p(0.63, 0.56).dx, p(0.63, 0.56).dy)
    ..close();
}

/// The dopamine projection, midbrain to LEC.
Path _dopaminePath(Size s, Offset from) {
  Offset p(Offset u) => Offset(u.dx * s.width, u.dy * s.height);
  final a = p(from);
  final b = p(_lec);
  return Path()
    ..moveTo(a.dx, a.dy)
    ..cubicTo(
      a.dx + s.width * 0.08,
      a.dy + s.height * 0.14,
      b.dx - s.width * 0.14,
      b.dy + s.height * 0.14,
      b.dx,
      b.dy,
    );
}

/// Draws the part of [path] up to [fraction] of its length.
Path _partial(Path path, double fraction) {
  final out = Path();
  for (final metric in path.computeMetrics()) {
    out.addPath(
      metric.extractPath(0, metric.length * fraction.clamp(0.0, 1.0)),
      Offset.zero,
    );
  }
  return out;
}

/// Plaque positions, generated once: a cortical ring plus a midbrain cluster.
class _Plaque {
  const _Plaque(this.pos, this.midbrain, this.order);

  final Offset pos;

  /// Midbrain plaques appear later than cortical ones (from 4 months).
  final bool midbrain;

  /// 0 … 1: the order plaques come up in.
  final double order;
}

final List<_Plaque> _plaques = () {
  final rnd = math.Random(7);
  final out = <_Plaque>[];
  while (out.length < 150) {
    final u = Offset(rnd.nextDouble(), rnd.nextDouble());
    final midbrain = (u - _vta).distance < 0.12 || (u - _snc).distance < 0.12;
    out.add(_Plaque(u, midbrain, rnd.nextDouble()));
  }
  return out;
}();

class CoronalPainter extends CustomPainter {
  CoronalPainter({
    this.dopamine = 0,
    this.plaques = 0,
    this.highlightLec = false,
    this.fiber = false,
    this.laser = false,
    this.labels = true,
    this.lecFill,
  });

  /// How far the dopamine projection has grown in, 0 … 1.
  final double dopamine;

  /// Amyloid load, 0 … 1. Cortical plaques come first, midbrain later.
  final double plaques;

  /// Draws the LEC boundary filled and bold.
  final bool highlightLec;

  /// Draws an implanted fiber over the LEC, and optionally its light.
  final bool fiber;
  final bool laser;
  final bool labels;
  final Color? lecFill;

  @override
  void paint(Canvas canvas, Size size) {
    Offset p(Offset u) => Offset(u.dx * size.width, u.dy * size.height);
    final brain = _outline(size);

    canvas.drawPath(brain, Paint()..color = wash);
    canvas.drawPath(
      brain,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.012
        ..color = ink,
    );

    canvas.drawPath(
      _hippocampus(size),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.022
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFFBFC7CF),
    );

    // Amyloid, clipped to the brain.
    if (plaques > 0) {
      canvas.save();
      canvas.clipPath(brain);
      for (final plaque in _plaques) {
        // Cortical plaques are already there at low load; midbrain ones
        // wait until the second half, as in the paper.
        final threshold = plaque.midbrain
            ? 0.45 + plaque.order * 0.5
            : plaque.order * 0.95;
        final shown = ((plaques - threshold) * 6).clamp(0.0, 1.0);
        if (shown <= 0) continue;
        canvas.drawCircle(
          p(plaque.pos),
          size.width * (0.006 + 0.004 * plaque.order) * shown,
          Paint()..color = fade(abRed, 0.85 * shown),
        );
      }
      canvas.restore();
    }

    // Midbrain sources.
    for (final (centre, label) in [(_vta, 'VTA'), (_snc, 'SNc')]) {
      canvas.drawCircle(
        p(centre),
        size.width * 0.035,
        Paint()..color = fade(dopamineGreen, 0.25 + 0.6 * dopamine),
      );
      canvas.drawCircle(
        p(centre),
        size.width * 0.035,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * 0.006
          ..color = dopamineGreen,
      );
      if (labels) {
        paintText(canvas, label, p(centre) + Offset(0, -size.width * 0.055),
            size: size.width * 0.038,
            color: ink,
            weight: FontWeight.w700,
            anchor: Alignment.center);
      }
    }

    // Dopamine axons.
    if (dopamine > 0) {
      for (final from in [_vta, _snc]) {
        canvas.drawPath(
          _partial(_dopaminePath(size, from), dopamine),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width * 0.012
            ..strokeCap = StrokeCap.round
            ..color = dopamineGreen,
        );
      }
    }

    // LEC.
    final lecPath = _lecOutline(size);
    if (lecFill != null || highlightLec) {
      canvas.drawPath(
        lecPath,
        Paint()..color = lecFill ?? fade(appPurple, 0.14),
      );
    }
    canvas.drawPath(
      lecPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * (highlightLec ? 0.014 : 0.009)
        ..color = highlightLec ? appPurple : ink,
    );
    if (labels) {
      paintText(canvas, 'LEC', p(_lec),
          size: size.width * 0.045,
          color: ink,
          weight: FontWeight.w900,
          anchor: Alignment.center);
      paintText(canvas, 'hippocampus', p(_hippo) + Offset(0, -size.width * 0.05),
          size: size.width * 0.034, anchor: Alignment.center);
    }

    // Implanted fiber, and the light it delivers.
    if (fiber) {
      final tip = p(_lec) + Offset(0, -size.width * 0.02);
      final top = Offset(tip.dx, -size.height * 0.04);
      canvas.drawLine(
        top,
        tip,
        Paint()
          ..strokeWidth = size.width * 0.022
          ..color = laser ? laserBlue : const Color(0xFF9AA3AC),
      );
      if (laser) {
        canvas.drawCircle(
          tip,
          size.width * 0.075,
          Paint()..color = fade(laserBlue, 0.35),
        );
        canvas.drawCircle(
          tip,
          size.width * 0.04,
          Paint()..color = fade(laserBlue, 0.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(CoronalPainter old) =>
      old.dopamine != dopamine ||
      old.plaques != plaques ||
      old.highlightLec != highlightLec ||
      old.laser != laser ||
      old.fiber != fiber;
}

/// The small lettered square the paper uses for each cue.
class OdorChip extends StatelessWidget {
  const OdorChip(this.label, this.color, {super.key, this.size = 44});

  final String label;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: color,
      child: Text(
        label,
        style: TextStyle(
          fontFamily: fontFamily,
          fontSize: size * 0.6,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// The odor / delay / choice structure of one trial, 0–4 s.
class TrialTimeline extends StatelessWidget {
  const TrialTimeline({super.key, required this.progress});

  /// 0 … 1 across the whole 4-second trial.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _TrialPainter(progress),
    );
  }
}

class _TrialPainter extends CustomPainter {
  _TrialPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const phases = [('Odor', 0.0, 1.0), ('Delay', 1.0, 3.0), ('Choice', 3.0, 4.0)];
    final h = size.height * 0.46;
    double x(double seconds) => size.width * seconds / 4;

    for (final (name, from, to) in phases) {
      final rect = Rect.fromLTRB(x(from), 0, x(to), h);
      final lit = ((progress * 4 - from) / (to - from)).clamp(0.0, 1.0);
      canvas.drawRect(rect, Paint()..color = fade(appPurple, 0.12 * lit));
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = ink,
      );
      paintText(canvas, name, rect.center,
          size: 26,
          color: ink,
          weight: FontWeight.w700,
          anchor: Alignment.center);
    }

    // The playhead.
    final head = x(progress * 4);
    canvas.drawLine(
      Offset(head, -8),
      Offset(head, h + 8),
      Paint()
        ..strokeWidth = 4
        ..color = appPurple,
    );

    // The LED, at the start of the choice window.
    canvas.drawRect(
      Rect.fromLTWH(x(3) - 10, -22, 34, 12),
      Paint()..color = progress * 4 >= 3 ? abRed : hairline,
    );
    paintText(canvas, 'LED', Offset(x(3) + 7, -30),
        size: 20, color: ink, anchor: Alignment.bottomCenter);

    for (final s in [0.0, 1.0, 2.0, 3.0, 4.0]) {
      paintText(canvas, '${s.toStringAsFixed(0)}', Offset(x(s), h + 14),
          size: 22, anchor: Alignment.topCenter);
    }
    paintText(canvas, 'seconds after cue onset',
        Offset(size.width / 2, h + 46),
        size: 22, anchor: Alignment.topCenter);
  }

  @override
  bool shouldRepaint(_TrialPainter old) => old.progress != progress;
}
