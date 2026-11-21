import 'dart:math' as math;

import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';

// ---------------------------------------------------------------------------
// Calcium imaging — cells pop in on their own; click 1 colours the behaviour
// ensembles, click 2 the decision ensembles.
//
// The field of view is an illustration: cell positions and proportions are
// generated, not taken from the data.
// ---------------------------------------------------------------------------

const _gcamp = Color(0xFF3DDC84);
const _quiet = Color(0xFF28503C);

const _behaviourColors = [
  Color(0xFFB98CF0), // huddle
  Color(0xFF9FB4CC), // rest
  Color(0xFFFCB614), // social investigation
];
const _decisionColors = [
  Color(0xFFFF8A3D), // active entry
  Color(0xFF5DB4F0), // passive entry
  Color(0xFF4FD1C5), // speed-matched running
];

class _Cell {
  const _Cell(this.pos, this.radius, this.behaviour, this.decision, this.delay);

  /// Position in the unit disc.
  final Offset pos;
  final double radius;

  /// Index into [_behaviourColors], or -1 if not behaviour-selective.
  final int behaviour;

  /// Index into [_decisionColors], or -1. Never set together with
  /// [behaviour]: the paper finds minimal overlap between the two sets.
  final int decision;

  /// When the cell pops in (0 ... 1).
  final double delay;
}

final List<_Cell> _cells = () {
  final rnd = math.Random(11);
  final cells = <_Cell>[];
  for (var tries = 0; tries < 6000 && cells.length < 80; tries++) {
    final p = Offset(rnd.nextDouble() * 2 - 1, rnd.nextDouble() * 2 - 1);
    if (p.distance > 0.88) continue;
    if (cells.any((c) => (c.pos - p).distance < 0.13)) continue;
    final a = rnd.nextDouble();
    final behaviour = a < .14 ? 0 : a < .28 ? 1 : a < .42 ? 2 : -1;
    final b = rnd.nextDouble();
    final decision =
        behaviour != -1 ? -1 : b < .22 ? 0 : b < .44 ? 1 : b < .66 ? 2 : -1;
    cells.add(_Cell(
      p,
      0.04 + rnd.nextDouble() * 0.02,
      behaviour,
      decision,
      rnd.nextDouble(),
    ));
  }
  return cells;
}();

class _FovPainter extends CustomPainter {
  _FovPainter(this.seconds, this.stage);

  final double seconds;
  final double stage;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 6;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFF09130E));

    final byBehaviour = stage.clamp(0.0, 1.0);
    final byDecision = (stage - 1).clamp(0.0, 1.0);

    for (final cell in _cells) {
      final appear =
          ((seconds - 0.5 - cell.delay * 1.6) / 0.5).clamp(0.0, 1.0);
      if (appear <= 0) continue;

      final a = cell.behaviour >= 0 ? _behaviourColors[cell.behaviour] : _quiet;
      final b = cell.decision >= 0 ? _decisionColors[cell.decision] : _quiet;
      final color =
          Color.lerp(Color.lerp(_gcamp, a, byBehaviour), b, byDecision)!;

      final at = center + cell.pos * radius;
      final r = cell.radius * radius * Curves.easeOutBack.transform(appear);
      canvas.drawCircle(at, r * 1.7, Paint()..color = fade(color, 0.18));
      canvas.drawCircle(at, r, Paint()..color = color);
    }

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..color = ink,
    );
  }

  @override
  bool shouldRepaint(_FovPainter oldDelegate) => true;
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label);

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 34, top: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 12),
          Text(label, style: tSmall.copyWith(color: ink)),
        ],
      ),
    );
  }
}

Slide imaging() => Slide(
      duration: const Duration(seconds: 3),
      steps: 2,
      builder: (context) {
        final timeline = SlideTimeline.of(context);
        return SlideFrame(
          kicker: 'Neural encoding',
          title: 'dmPFC ensembles for behaviours and for decisions',
          source: 'Figs. 4a–f, 5a–h · illustration: cell positions and '
              'proportions are not data',
          child: Row(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: AnimatedBuilder(
                  animation: Listenable.merge([timeline.main, timeline.stage]),
                  builder: (context, _) => CustomPaint(
                    size: Size.infinite,
                    painter: _FovPainter(
                      timeline.main.value,
                      timeline.stage.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 80),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Bullets([
                      'GCaMP6f, a GRIN lens and a head-mounted miniscope in '
                          'one mouse; three cagemates alongside at 5 °C',
                      '5,141 dmPFC neurons from 11 mice',
                    ]),
                    const SizedBox(height: 10),
                    Anim(
                      step: 1,
                      from: const Offset(0, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Callout(
                            'Huddling, rest and social investigation '
                            'recruit largely separate cells',
                            style: tNote,
                          ),
                          Wrap(
                            children: [
                              _Legend(_behaviourColors[0], 'huddle'),
                              _Legend(_behaviourColors[1], 'rest'),
                              _Legend(_behaviourColors[2], 'investigation'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),
                    Anim(
                      step: 2,
                      from: const Offset(0, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Callout(
                            'Active and passive entry use different cells '
                            'again — and neither set is just running',
                            style: tNote,
                          ),
                          Wrap(
                            children: [
                              _Legend(_decisionColors[0], 'active entry'),
                              _Legend(_decisionColors[1], 'passive entry'),
                              _Legend(_decisionColors[2], 'matched running'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

// ---------------------------------------------------------------------------
// Decoding — rows appear on their own; click 1 adds cross-decoding,
// click 2 what could not be decoded.
// ---------------------------------------------------------------------------

class _DecoderRow extends StatelessWidget {
  const _DecoderRow(this.a, this.b, {required this.aboveChance});

  final String a;
  final String b;
  final bool aboveChance;

  @override
  Widget build(BuildContext context) {
    final color = aboveChance ? good : muted;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hairline, width: 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text('$a  vs  $b', style: tBody.copyWith(fontSize: 31)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: BoxDecoration(
              color: fade(color, 0.13),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Text(
              aboveChance ? 'above chance' : 'at chance',
              style: tSmall.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

Slide decoding() => Slide(
      duration: const Duration(milliseconds: 2600),
      steps: 2,
      builder: (context) => const SlideFrame(
        kicker: 'Neural encoding',
        title: 'Population activity tells active from passive',
        source: 'Fig. 5i–r · Extended Data Fig. 7',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Anim(
                    at: 0.3,
                    child: Text('SVM decoders on dmPFC activity',
                        style: tSmall),
                  ),
                  SizedBox(height: 14),
                  Anim(
                    at: 0.5,
                    from: Offset(-30, 0),
                    child: _DecoderRow('Active entry', 'passive entry',
                        aboveChance: true),
                  ),
                  Anim(
                    at: 0.7,
                    from: Offset(-30, 0),
                    child: _DecoderRow('Active entry', 'active exit',
                        aboveChance: true),
                  ),
                  Anim(
                    at: 0.9,
                    from: Offset(-30, 0),
                    child: _DecoderRow('Active exit', 'passive exit',
                        aboveChance: true),
                  ),
                  Anim(
                    at: 1.1,
                    from: Offset(-30, 0),
                    child: _DecoderRow('Passive entry', 'passive exit',
                        aboveChance: false),
                  ),
                  SizedBox(height: 10),
                  Anim(
                    at: 1.7,
                    child: Bullet(
                      'Decoding rises seconds before the behaviour starts, '
                      'and holds against speed-matched running and rest',
                      style: tNote,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 70),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Anim(
                    step: 1,
                    from: Offset(0, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Train on one decision, test on another',
                            style: tSmall),
                        SizedBox(height: 14),
                        Bullet('Active entry ⇄ active exit: transfers',
                            color: activeColor),
                        SizedBox(height: 14),
                        Bullet('Passive entry ⇄ passive exit: transfers',
                            color: passiveColor),
                        SizedBox(height: 14),
                        Bullet('Active ⇄ passive: does not transfer',
                            color: muted),
                        SizedBox(height: 20),
                        Callout(
                          'One partly shared code for “I act”, '
                          'another for “my partner acts”',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 34),
                  Anim(
                    step: 2,
                    from: Offset(0, 24),
                    child: Bullet(
                      'Not decodable: huddle size, or who is in the huddle. '
                      'dmPFC tracks decisions, not group structure.',
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
