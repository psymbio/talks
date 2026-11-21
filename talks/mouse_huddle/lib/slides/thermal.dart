import 'dart:math' as math;

import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';
import '../widgets/mouse.dart';

// ---------------------------------------------------------------------------
// Thermal contacts — 3 clicks grow the huddle from one mouse to four, laid
// out as in Fig. 2b: animals side by side, each labelled with its number of
// contacts, contact edges (C) in green and exposed edges (NC) in grey, over
// a simulated thermal image on the paper's 4–37 °C scale.
// ---------------------------------------------------------------------------

const _inferno = [
  Color(0xFF000004),
  Color(0xFF320A5A),
  Color(0xFF781C6D),
  Color(0xFFBB3754),
  Color(0xFFED6925),
  Color(0xFFFCB519),
  Color(0xFFFCFFA4),
];

Color _infernoAt(double t) =>
    lerpColors(_inferno, t.clamp(0.0, 1.0) * (_inferno.length - 1));

const _contactGreen = Color(0xFF1C7A4A);
const _ncGrey = Color(0xFFD5D9DE);

/// Huddle configurations, in body-length units around the group's centre,
/// with every animal facing the same way (nose up). Mice that have not
/// joined yet wait below the frame.
///
/// The four-animal step is the clustered arrangement from Fig. 2b, which
/// gives contact counts of 1, 2, 2 and 3 rather than the 1, 2, 2, 1 of a
/// straight row.
const _waiting = Offset(0, 2.2);
const _configs = [
  // Alone
  [Offset(0, 0), _waiting, _waiting, _waiting],
  // Two side by side
  [Offset(-0.31, 0), Offset(0.31, 0), _waiting, _waiting],
  // Three in a row
  [Offset(-0.62, 0), Offset(0, 0), Offset(0.62, 0), _waiting],
  // Four, clustered: one tucked in behind the middle pair
  [Offset(-0.62, -0.20), Offset(0, -0.20), Offset(0.62, -0.20),
      Offset(-0.31, 0.75)],
];

/// Centre-to-centre distance, in body lengths, at which two animals count
/// as touching. Neighbours in a row sit 0.62 apart and the tucked-in animal
/// about 1.0 away; animals two apart in a row sit 1.24 away.
const _touchNear = 1.05;
const _touchFar = 1.30;

class _ThermalPainter extends CustomPainter {
  _ThermalPainter(this.stage);

  /// 0 → one mouse, 3 → the four-animal cluster.
  final double stage;

  @override
  void paint(Canvas canvas, Size size) {
    final panel = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    canvas.drawRRect(panel, Paint()..color = const Color(0xFF17132A));
    canvas.save();
    canvas.clipRRect(panel);

    final plot = Rect.fromLTRB(
      size.width * 0.05,
      size.height * 0.10,
      size.width * 0.78,
      size.height * 0.94,
    );
    final s = plot.height * 0.42; // body length in pixels

    // Where each animal is, and how far it has faded in.
    final i = math.min(stage.floor(), _configs.length - 2);
    final t = Curves.easeInOut.transform((stage - i).clamp(0.0, 1.0));
    final local = [
      for (var k = 0; k < 4; k++)
        Offset.lerp(_configs[i][k], _configs[i + 1][k], t)!,
    ];
    final visible = [
      for (var k = 0; k < 4; k++) ((stage + 1) - k).clamp(0.0, 1.0),
    ];
    final centres = [
      for (final p in local) plot.center + Offset(p.dx * s, p.dy * s),
    ];

    // Contacts, from centre distance: everything else follows from these.
    final contacts = <({int a, int b, double strength})>[];
    final counts = List<double>.filled(4, 0);
    for (var a = 0; a < 4; a++) {
      for (var b = a + 1; b < 4; b++) {
        if (visible[a] < 0.5 || visible[b] < 0.5) continue;
        final d = (centres[a] - centres[b]).distance / s;
        final x = ((_touchFar - d) / (_touchFar - _touchNear)).clamp(0.0, 1.0);
        final strength = x * x * (3 - 2 * x);
        if (strength <= 0.01) continue;
        contacts.add((a: a, b: b, strength: strength));
        counts[a] += strength;
        counts[b] += strength;
      }
    }

    // One clip path covering every visible body, so contact glows stay
    // inside the animals.
    var bodies = Path();
    for (var k = 0; k < 4; k++) {
      if (visible[k] <= 0.01) continue;
      final shape = mouseSilhouette(s)
          .transform(_upright(centres[k]).storage);
      bodies = Path.combine(PathOperation.union, bodies, shape);
    }

    // Bodies: warmer overall the more contacts an animal has.
    for (var k = 0; k < 4; k++) {
      if (visible[k] <= 0.01) continue;
      canvas.save();
      canvas.translate(centres[k].dx, centres[k].dy);
      canvas.rotate(-math.pi / 2);
      final shape = mouseSilhouette(s);
      final bounds = shape.getBounds();
      final base = 0.30 + 0.13 * counts[k];
      canvas.save();
      canvas.clipPath(shape);
      canvas.drawRect(
        bounds,
        Paint()
          ..shader = RadialGradient(
            radius: 0.85,
            colors: [
              _infernoAt(base + 0.24),
              _infernoAt(base + 0.09),
              _infernoAt(base - 0.09),
            ],
            stops: const [0, 0.55, 1],
          ).createShader(bounds),
      );
      canvas.restore();
      canvas.restore();
    }

    // Warmth spilling in from each shared edge.
    canvas.save();
    canvas.clipPath(bodies);
    for (final c in contacts) {
      final mid = (centres[c.a] + centres[c.b]) / 2;
      final r = 0.52 * s;
      canvas.drawCircle(
        mid,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              fade(const Color(0xFFFFF6C9), 0.92 * c.strength),
              fade(const Color(0xFFFCB519), 0.48 * c.strength),
              fade(const Color(0xFFFCB519), 0),
            ],
            stops: const [0, 0.45, 1],
          ).createShader(Rect.fromCircle(center: mid, radius: r)),
      );
    }
    canvas.restore();

    // Traced perimeters and tails: grey, as the non-contact edges.
    for (var k = 0; k < 4; k++) {
      if (visible[k] <= 0.01) continue;
      canvas.save();
      canvas.translate(centres[k].dx, centres[k].dy);
      canvas.rotate(-math.pi / 2);
      canvas.drawPath(
        mouseTail(s),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.030 * s
          ..strokeCap = StrokeCap.round
          ..color = fade(_ncGrey, 0.7 * visible[k]),
      );
      canvas.drawPath(
        mouseSilhouette(s),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.026 * s
          ..color = fade(_ncGrey, visible[k]),
      );
      canvas.restore();
    }

    // Contact edges (C), drawn across each shared boundary.
    for (final c in contacts) {
      final mid = (centres[c.a] + centres[c.b]) / 2;
      final axis = centres[c.b] - centres[c.a];
      final along = Offset(-axis.dy, axis.dx) / axis.distance;
      final half = along * (0.26 * s * c.strength);
      canvas.drawLine(
        mid - half,
        mid + half,
        Paint()
          ..strokeWidth = 0.040 * s
          ..strokeCap = StrokeCap.round
          ..color = fade(_contactGreen, c.strength),
      );
    }

    // The contact count on each animal, as printed in Fig. 2b.
    for (var k = 0; k < 4; k++) {
      if (visible[k] < 0.6) continue;
      paintText(
        canvas,
        counts[k].round().toString(),
        centres[k],
        size: 0.34 * s,
        color: fade(Colors.white, visible[k]),
        weight: FontWeight.w600,
        anchor: Alignment.center,
      );
    }

    // NC on the outermost exposed flanks.
    final shown = [for (var k = 0; k < 4; k++) if (visible[k] > 0.6) k];
    final leftMost = shown.reduce((a, b) =>
        centres[a].dx <= centres[b].dx ? a : b);
    final rightMost = shown.reduce((a, b) =>
        centres[a].dx >= centres[b].dx ? a : b);
    for (final (k, dx) in [(leftMost, -0.46 * s), (rightMost, 0.46 * s)]) {
      paintText(
        canvas,
        'NC',
        centres[k] + Offset(dx, -0.40 * s),
        size: 25,
        color: Colors.white,
        weight: FontWeight.w600,
        anchor: Alignment.center,
      );
    }
    if (contacts.isNotEmpty) {
      final c = contacts.first;
      paintText(
        canvas,
        'C',
        (centres[c.a] + centres[c.b]) / 2 + Offset(0, -0.34 * s),
        size: 25,
        color: Colors.white,
        weight: FontWeight.w600,
        anchor: Alignment.center,
      );
    }

    _paintColorBar(canvas, size);
    canvas.restore();
  }

  /// Transform that places a nose-up mouse at [at].
  Matrix4 _upright(Offset at) => Matrix4.identity()
    ..translate(at.dx, at.dy)
    ..rotateZ(-math.pi / 2);

  void _paintColorBar(Canvas canvas, Size size) {
    final bar = Rect.fromLTWH(
      size.width * 0.87,
      size.height * 0.22,
      size.width * 0.04,
      size.height * 0.56,
    );
    canvas.drawRect(
      bar,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: _inferno,
        ).createShader(bar),
    );
    canvas.drawRect(
      bar,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = fade(Colors.white, 0.6),
    );
    paintText(canvas, '37 °C', Offset(bar.left, bar.top - 14),
        size: 23, color: Colors.white, anchor: Alignment.bottomLeft);
    paintText(canvas, '4 °C', Offset(bar.left, bar.bottom + 14),
        size: 23, color: Colors.white, anchor: Alignment.topLeft);
  }

  @override
  bool shouldRepaint(_ThermalPainter oldDelegate) =>
      oldDelegate.stage != stage;
}

const _thermalNotes = [
  ('Alone', 'No contact edges — the whole perimeter loses heat.'),
  ('Huddle of 2', 'One contact each; contact edges run several °C warmer '
      'than exposed ones.'),
  ('Huddle of 3', 'The middle animal gains two contacts, and more of its '
      'perimeter is covered.'),
  ('Huddle of 4', 'Counts of 1, 2, 2 and 3 — and even the exposed edges '
      'warm up.'),
];

Slide thermalContacts() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 3,
      stepDuration: const Duration(milliseconds: 1500),
      builder: (context) => SlideFrame(
        kicker: 'Figure 2a,b',
        title: 'Every contact is a warm edge',
        accentColor: warm,
        source: 'Illustration after Fig. 2a,b · numbers are contacts per '
            'animal; warmth is simulated, not measured',
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: StageBuilder(
                builder: (context, stage) => CustomPaint(
                  size: Size.infinite,
                  painter: _ThermalPainter(stage),
                ),
              ),
            ),
            const SizedBox(width: 56),
            Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StageBuilder(
                    builder: (context, stage) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final (i, note) in _thermalNotes.indexed)
                          Opacity(
                            opacity: 0.28 + 0.72 * focusAt(stage, i),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 18),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 210,
                                    child: Text(
                                      note.$1,
                                      style: tNote.copyWith(
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                      child: Text(note.$2, style: tNote)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _ThermalLegend(),
                  const SizedBox(height: 24),
                  const Anim(
                    at: 0.9,
                    child: Callout(
                      'Surface warmth scales with how many contacts an animal '
                      'has, and with how much of its perimeter they cover',
                      style: tNote,
                      color: warm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

class _ThermalLegend extends StatelessWidget {
  const _ThermalLegend();

  @override
  Widget build(BuildContext context) {
    Widget swatch(Color color, String label) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 44, height: 6, color: color),
            const SizedBox(width: 12),
            Text(label, style: tSmall),
          ],
        );

    return Row(
      children: [
        swatch(_contactGreen, 'contact edge (C)'),
        const SizedBox(width: 32),
        swatch(const Color(0xFFAFB6BD), 'non-contact edge (NC)'),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Core temperature — autoplay. The curves are drawn from the two facts the
// paper states (≈1 °C loss alone, stable in a group), not from its data.
// ---------------------------------------------------------------------------

class _CoreTempPainter extends CustomPainter {
  _CoreTempPainter(this.t);

  /// How much of the 30-minute session has been drawn (0 ... 1).
  final double t;

  static double _alone(double minutes) =>
      -0.95 * (1 - math.exp(-minutes / 9));
  static double _group(double minutes) => 0.04 * math.sin(minutes / 3.5);

  @override
  void paint(Canvas canvas, Size size) {
    final plot = Rect.fromLTRB(130, 70, size.width - 250, size.height - 90);
    double x(double minutes) => plot.left + plot.width * minutes / 30;
    double y(double delta) => plot.top + plot.height * (0.4 - delta) / 1.8;

    final grid = Paint()
      ..color = hairline
      ..strokeWidth = 2;
    for (final v in const [0.0, -0.5, -1.0]) {
      canvas.drawLine(Offset(plot.left, y(v)), Offset(plot.right, y(v)), grid);
      paintText(
        canvas,
        v == 0 ? '0' : v.toStringAsFixed(1).replaceFirst('-', '−'),
        Offset(plot.left - 20, y(v)),
        anchor: Alignment.centerRight,
      );
    }
    for (final m in const [0.0, 10.0, 20.0, 30.0]) {
      paintText(
        canvas,
        m.toStringAsFixed(0),
        Offset(x(m), plot.bottom + 16),
        anchor: Alignment.topCenter,
      );
    }
    canvas.drawLine(
      plot.bottomLeft,
      plot.bottomRight,
      Paint()
        ..color = ink
        ..strokeWidth = 3,
    );
    paintText(canvas, 'Δ core body temperature (°C)', Offset(plot.left, 14));
    paintText(
      canvas,
      'minutes at 5 °C',
      Offset(plot.center.dx, plot.bottom + 52),
      anchor: Alignment.topCenter,
    );

    void curve(
      double Function(double) f,
      Color color,
      String label,
      double labelDy,
    ) {
      final end = 30 * t;
      final path = Path()..moveTo(x(0), y(f(0)));
      for (var m = 0.25; m <= end; m += 0.25) {
        path.lineTo(x(m), y(f(m)));
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = color,
      );
      final tip = Offset(x(end), y(f(end)));
      canvas.drawCircle(tip, 10, Paint()..color = color);
      paintText(
        canvas,
        label,
        tip + Offset(22, labelDy),
        size: 29,
        color: color,
        weight: FontWeight.w600,
        anchor: Alignment.centerLeft,
      );
    }

    curve(_group, good, 'Group of four', -26);
    curve(_alone, passiveColor, 'Alone', 26);
  }

  @override
  bool shouldRepaint(_CoreTempPainter oldDelegate) => oldDelegate.t != t;
}

Slide coreTemperature() => Slide(
      duration: const Duration(milliseconds: 5600),
      builder: (context) => SlideFrame(
        kicker: 'Figure 2s–u',
        title: 'Huddling keeps core temperature stable',
        accentColor: warm,
        source: 'Schematic after Fig. 2s–u · curves are illustrative, '
            'not the published data',
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Anim(
                at: 0.6,
                dur: 3.2,
                curve: Curves.linear,
                builder: (context, t, _) => CustomPaint(
                  size: Size.infinite,
                  painter: _CoreTempPainter(t),
                ),
              ),
            ),
            const SizedBox(width: 60),
            const Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Anim(
                    at: 1.6,
                    from: Offset(0, 20),
                    child: Bullet(
                      'Alone, a mouse loses nearly 1 °C of core temperature '
                      'in 30 minutes',
                      color: passiveColor,
                    ),
                  ),
                  SizedBox(height: 24),
                  Anim(
                    at: 2.6,
                    from: Offset(0, 20),
                    child: Bullet(
                      'In a group, core temperature is the same in the '
                      'first and last minute',
                      color: good,
                    ),
                  ),
                  SizedBox(height: 24),
                  Anim(
                    at: 3.8,
                    from: Offset(0, 20),
                    child: Bullet(
                      'Pairs hold core temperature as well as groups of four, '
                      'even though bigger huddles warm the surface more',
                      color: muted,
                    ),
                  ),
                  SizedBox(height: 24),
                  Anim(
                    at: 4.4,
                    from: Offset(0, 20),
                    child: Bullet(
                      'So contact cuts heat loss — and the pull towards a '
                      'larger huddle may be about more than warmth: stress '
                      'reduction, or social reward',
                      color: warm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

// ---------------------------------------------------------------------------
// What Figure 2 adds up to.
// ---------------------------------------------------------------------------

Slide thermalSummary() => Slide(
      duration: const Duration(milliseconds: 2800),
      steps: 1,
      builder: (context) => SlideFrame(
        kicker: 'Figure 2 · summary',
        title: 'Contact warms the surface; the group protects the core',
        source: 'Fig. 2 · infrared thermography and implanted loggers',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: ListPanel(
                      title: 'Surface',
                      color: warm,
                      at: 0.3,
                      items: [
                        'More contacts, more peripheral warmth',
                        'Contact regions run several °C above non-contact '
                            'regions',
                        'Non-contact regions warm too as the huddle grows',
                      ],
                    ),
                  ),
                  SizedBox(width: 28),
                  Expanded(
                    child: ListPanel(
                      title: 'Core',
                      color: passiveColor,
                      at: 0.5,
                      items: [
                        'Alone: nearly 1 °C lost during cold exposure',
                        'In a group: core temperature holds steady',
                        'Pairs do this as well as larger groups',
                      ],
                    ),
                  ),
                  SizedBox(width: 28),
                  Expanded(
                    child: ListPanel(
                      title: 'So why huddle bigger?',
                      color: accent,
                      at: 0.7,
                      items: [
                        'Larger huddles add surface-level warming',
                        'The core benefit is already saturated in a pair',
                        'Stress reduction or social reward may carry the '
                            'rest',
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Anim(
              step: 1,
              from: Offset(0, 20),
              child: Callout(
                'Huddling works by cutting heat loss through social '
                'contact — the thermal gain is at the skin, not in the core',
                style: tBody,
                color: warm,
              ),
            ),
          ],
        ),
      ),
    );
