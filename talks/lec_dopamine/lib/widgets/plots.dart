import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

// ---------------------------------------------------------------------------
// The three plot shapes the talk keeps coming back to. All of them are
// schematics drawn from the values the paper reports, not its data: the
// learning curves use the published T5 percentages as asymptotes, the PC
// trajectories are illustrative, and the photometry traces carry the shape
// and timing described in the text.
// ---------------------------------------------------------------------------

/// One condition's learning curve, as a pair of asymptotes.
class LearnCurve {
  const LearnCurve({
    required this.label,
    required this.novelAsymptote,
    required this.rate,
    this.prelearned = 92,
    this.color = appPurple,
    this.wobble = 0,
  });

  final String label;

  /// Where the novel-odor trace lands by T5, in percent.
  final double novelAsymptote;

  /// How fast it gets there: higher is faster.
  final double rate;

  /// Where the prelearned trace sits, in percent.
  final double prelearned;

  /// Colour of the label.
  final Color color;

  /// Size of the dips along the novel trace — the saline and old APP-KI
  /// curves in the paper wander rather than rise cleanly.
  final double wobble;

  double novelAt(double trial) {
    final rise = 1 - math.exp(-trial / (160 / rate));
    final ripple = wobble * math.sin(trial / 18) * (1 - rise * 0.4);
    return 58 + (novelAsymptote - 58) * rise + ripple;
  }

  double prelearnedAt(double trial) =>
      prelearned + 1.4 * math.sin(trial / 11) - trial / 160 * 1.5;
}

/// Correct-trial rate against trial number, drawn as it plays.
class LearningCurvePainter extends CustomPainter {
  LearningCurvePainter({
    required this.curve,
    required this.progress,
    this.showTimepoints = true,
  });

  final LearnCurve curve;

  /// How much of the 160-trial session has been drawn.
  final double progress;
  final bool showTimepoints;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(78, 34, size.width - 20, size.height - 72);
    double x(double trial) => plot.left + plot.width * trial / 160;
    double y(double percent) =>
        plot.bottom - plot.height * (percent - 55) / 45;

    // Axes and the 80% criterion.
    canvas.drawLine(
      plot.bottomLeft,
      plot.bottomRight,
      Paint()
        ..strokeWidth = 3
        ..color = ink,
    );
    canvas.drawLine(
      plot.topLeft,
      plot.bottomLeft,
      Paint()
        ..strokeWidth = 3
        ..color = ink,
    );
    for (var v = 60.0; v <= 100; v += 20) {
      paintText(canvas, v.toStringAsFixed(0), Offset(plot.left - 12, y(v)),
          size: 22, anchor: Alignment.centerRight);
    }
    const dash = 12.0;
    for (var cx = plot.left; cx < plot.right; cx += dash * 2) {
      canvas.drawLine(
        Offset(cx, y(80)),
        Offset(math.min(cx + dash, plot.right), y(80)),
        Paint()
          ..strokeWidth = 2
          ..color = muted,
      );
    }
    paintText(canvas, '80%', Offset(plot.right - 4, y(80) - 6),
        size: 20, anchor: Alignment.bottomRight);
    for (final t in [0.0, 40.0, 80.0, 120.0, 160.0]) {
      paintText(canvas, t.toStringAsFixed(0), Offset(x(t), plot.bottom + 10),
          size: 22, anchor: Alignment.topCenter);
    }
    paintText(canvas, 'trial', Offset(plot.center.dx, plot.bottom + 40),
        size: 22, anchor: Alignment.topCenter);
    paintText(canvas, 'correct trials (%)', Offset(plot.left - 60, plot.top - 24),
        size: 22, anchor: Alignment.topLeft);

    if (showTimepoints) {
      for (var i = 0; i < 5; i++) {
        final from = x(i * 32.0), to = x(i * 32.0 + 30);
        canvas.drawRect(
          Rect.fromLTRB(from, plot.bottom + 2, to, plot.bottom + 10),
          Paint()..color = i.isEven ? const Color(0xFFBFC7CF) : hairline,
        );
        paintText(canvas, 'T${i + 1}', Offset((from + to) / 2, plot.bottom - 18),
            size: 19, anchor: Alignment.topCenter);
      }
    }

    void trace(double Function(double) f, Color color) {
      final end = 160 * progress;
      if (end < 1) return;
      final path = Path()..moveTo(x(0), y(f(0)));
      for (var t = 2.0; t <= end; t += 2) {
        path.lineTo(x(t), y(f(t)));
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
    }

    trace(curve.prelearnedAt, odorB);
    trace(curve.novelAt, abRed);

    if (progress > 0.45) {
      paintText(canvas, 'prelearned A / B', Offset(x(90), y(curve.prelearned) - 14),
          size: 24, color: odorB, weight: FontWeight.w700);
      paintText(canvas, 'novel 1 / 2',
          Offset(x(90), y(curve.novelAt(120)) + 10),
          size: 24, color: abRed, weight: FontWeight.w700);
    }
  }

  @override
  bool shouldRepaint(LearningCurvePainter old) =>
      old.progress != progress || old.curve != curve;
}

/// Population activity in PC space: four cue trajectories that either come
/// together or stay apart.
class PcaPainter extends CustomPainter {
  PcaPainter({required this.converge, this.spread = 1});

  /// 0 = Odor-A and Odor-1 far apart, 1 = overlapping.
  final double converge;

  /// How far the trajectories run from the origin.
  final double spread;

  static const _anchors = [
    (Offset(-1.25, 0.95), odorA, 'A'),
    (Offset(1.45, 1.15), odorB, 'B'),
    (Offset(-1.35, -1.15), odor1, '1'),
    (Offset(1.25, -1.35), odor2, '2'),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final centre = size.center(Offset.zero);
    final unit = size.shortestSide / 4.4;
    Offset p(Offset u) =>
        centre + Offset(u.dx * unit * spread, -u.dy * unit * spread);

    // Axes.
    canvas.drawLine(
      Offset(size.width * 0.06, size.height - 44),
      Offset(size.width * 0.06, size.height * 0.1),
      Paint()
        ..strokeWidth = 3
        ..color = ink,
    );
    canvas.drawLine(
      Offset(size.width * 0.06, size.height - 44),
      Offset(size.width * 0.9, size.height - 44),
      Paint()
        ..strokeWidth = 3
        ..color = ink,
    );
    paintText(canvas, 'PC 1', Offset(size.width * 0.48, size.height - 36),
        size: 21, anchor: Alignment.topCenter);

    // Where Odor-A and Odor-1 end up: either side of their midpoint.
    final aAnchor = _anchors[0].$1;
    final oneAnchor = _anchors[2].$1;
    final meeting = Offset.lerp(aAnchor, oneAnchor, 0.5)!;

    for (final (i, anchor) in _anchors.indexed) {
      var target = anchor.$1;
      if (i == 0) target = Offset.lerp(aAnchor, meeting, converge)!;
      if (i == 2) target = Offset.lerp(oneAnchor, meeting, converge)!;

      // A squiggle out from the origin to the anchor.
      final path = Path()..moveTo(p(Offset.zero).dx, p(Offset.zero).dy);
      for (var t = 0.0; t <= 1.0; t += 0.02) {
        final along = Offset(target.dx * t, target.dy * t);
        final wobble = Offset(
          0.16 * math.sin(t * 7 + i),
          0.16 * math.cos(t * 6 + i * 2),
        );
        final here = along + wobble * (0.4 + t);
        path.lineTo(p(here).dx, p(here).dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeJoin = StrokeJoin.round
          ..color = anchor.$2,
      );

      // Cue onset, delay onset, delay offset.
      canvas.drawCircle(p(Offset(target.dx * 0.25, target.dy * 0.25)), 7,
          Paint()..color = anchor.$2);
      canvas.drawRect(
        Rect.fromCenter(center: p(target), width: 16, height: 16),
        Paint()..color = anchor.$2,
      );
      paintText(canvas, anchor.$3, p(target) + const Offset(0, -26),
          size: 30,
          color: anchor.$2,
          weight: FontWeight.w900,
          anchor: Alignment.center);
    }
  }

  @override
  bool shouldRepaint(PcaPainter old) => old.converge != converge;
}

/// A cue-aligned ΔF/F trace, with the task structure behind it.
class PhotometryPainter extends CustomPainter {
  PhotometryPainter({
    required this.amplitude,
    required this.color,
    this.onset = 1.0,
    this.reveal = 1,
    this.label,
  });

  /// Peak z-scored ΔF/F.
  final double amplitude;
  final Color color;

  /// When the signal starts rising, in seconds after cue onset.
  final double onset;

  /// How much of the trace has been drawn.
  final double reveal;
  final String? label;

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(54, 24, size.width - 12, size.height - 42);
    double x(double t) => plot.left + plot.width * (t + 1) / 6; // −1 … 5 s
    double y(double z) => plot.bottom - plot.height * (z + 0.6) / 3.1;

    canvas.drawLine(
      Offset(plot.left, y(0)),
      Offset(plot.right, y(0)),
      Paint()
        ..strokeWidth = 2
        ..color = hairline,
    );
    for (final t in [0.0, 1.0, 3.0]) {
      canvas.drawLine(
        Offset(x(t), plot.top),
        Offset(x(t), plot.bottom),
        Paint()
          ..strokeWidth = 2
          ..color = const Color(0xFFE3E7EB),
      );
    }
    canvas.drawLine(
      plot.bottomLeft,
      plot.bottomRight,
      Paint()
        ..strokeWidth = 2
        ..color = ink,
    );
    for (final t in [0.0, 2.0, 4.0]) {
      paintText(canvas, t.toStringAsFixed(0), Offset(x(t), plot.bottom + 6),
          size: 19, anchor: Alignment.topCenter);
    }
    paintText(canvas, '0', Offset(plot.left - 8, y(0)),
        size: 19, anchor: Alignment.centerRight);
    paintText(canvas, '2', Offset(plot.left - 8, y(2)),
        size: 19, anchor: Alignment.centerRight);

    // A rise through the delay period, then decay after the choice.
    double signal(double t) {
      if (t < onset) return 0.02 * math.sin(t * 3);
      final rise = 1 - math.exp(-(t - onset) / 0.5);
      final fall = t > 3 ? math.exp(-(t - 3) / 0.7) : 1;
      return amplitude * rise * fall;
    }

    final end = -1 + 6 * reveal.clamp(0.0, 1.0);
    final path = Path()..moveTo(x(-1), y(signal(-1)));
    for (var t = -0.95; t <= end; t += 0.05) {
      path.lineTo(x(t), y(signal(t)));
    }
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );

    if (label != null) {
      paintText(canvas, label!, Offset(plot.right, plot.top),
          size: 23,
          color: color,
          weight: FontWeight.w700,
          anchor: Alignment.topRight);
    }
  }

  @override
  bool shouldRepaint(PhotometryPainter old) =>
      old.amplitude != amplitude || old.reveal != reveal;
}
