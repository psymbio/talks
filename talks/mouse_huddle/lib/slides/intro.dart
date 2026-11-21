import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../states.dart';
import '../theme.dart';
import '../widgets/frame.dart';
import '../widgets/mouse.dart';

// ---------------------------------------------------------------------------
// Title — a dark cover slide. Each click cools the chamber one stop and the
// group gathers; the left arrow walks it back.
// ---------------------------------------------------------------------------

/// One entry per click position: a group state (index into [huddleStates])
/// and the temperature shown with it.
///
/// To change the animation, edit this list — `steps:` reads its length, so
/// two stops give one click, three give two, and so on. `stepDuration` on
/// the Slide below sets how slowly each click plays out.
const _titleStops = [
  (state: 0, temp: 20.0), // start: dispersed, 20 °C
  (state: 1, temp: 12.0), // click 1: a first pair forms
  (state: 3, temp: 5.0), // click 2: three together at 5 °C
];

Slide title() => Slide(
      duration: const Duration(seconds: 4),
      steps: _titleStops.length - 1,
      stepDuration: const Duration(milliseconds: 3200),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(84, 56, 84, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Anim(
              child: Text(
                'NATURE NEUROSCIENCE 29, 901–914 (2026)',
                textAlign: TextAlign.center,
                style: tKicker,
              ),
            ),
            const SizedBox(height: 10),
            const Anim(
              at: 0.1,
              dur: 1.0,
              from: Offset(0, 28),
              child: Text(
                'Cortical regulation of collective social dynamics '
                'during environmental challenge',
                textAlign: TextAlign.center,
                style: tH1,
              ),
            ),
            const SizedBox(height: 18),
            Anim(
              at: 0.2,
              dur: 1.0,
              builder: (context, t, _) => Center(
                child: FractionallySizedBox(
                  widthFactor: t,
                  child: Container(height: 4, color: accent),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Anim(
              at: 0.9,
              child: Text(
                'Raam, Li, Gu, Elagio, Lim, Taimish, Zhang, Sandoval, '
                'Correa & Hong   ·   University of California, Los Angeles',
                textAlign: TextAlign.center,
                style: tNote,
              ),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Anim(
                      at: 0.5,
                      dur: 1.2,
                      scale: 0.95,
                      child: const _CoolingArena(),
                    ),
                  ),
                  const SizedBox(width: 64),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Anim(
                          at: 1.2,
                          from: Offset(0, 20),
                          child: Callout(
                            'Four mice, a 5 °C chamber, and nothing to do '
                            'about the cold except get closer to each other.',
                            lead: 'Setup:',
                          ),
                        ),
                        const SizedBox(height: 26),
                        Anim(
                          at: 1.6,
                          from: const Offset(0, 20),
                          child: Row(
                            children: const [
                              Text('click to cool the chamber',
                                  style: tSmall),
                              SizedBox(width: 20),
                              StepDots(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            const Anim(
              at: 2.0,
              dur: 0.9,
              from: Offset(0, 24),
              child: IdeaBand(
                'huddling is a group decision, and the dorsomedial '
                'prefrontal cortex is where each mouse makes its part of it',
                lead: 'Claim:',
              ),
            ),
          ],
        ),
      ),
    );

/// The arena on the title slide: mice gather and the box cools as the
/// presenter clicks, with a thermometer tracking the temperature.
class _CoolingArena extends StatelessWidget {
  const _CoolingArena();

  @override
  Widget build(BuildContext context) {
    return StageBuilder(
      builder: (context, stage) {
        final last = _titleStops.length - 1;
        final i = math.min(stage.floor(), last - 1);
        final t = ease((stage - i).clamp(0.0, 1.0));

        final mice = lerpStates(
          [
            huddleStates[_titleStops[i].state],
            huddleStates[_titleStops[i + 1].state],
          ],
          t,
        );
        final temp =
            lerpDouble(_titleStops[i].temp, _titleStops[i + 1].temp, t)!;
        final chill = ((20 - temp) / 15).clamp(0.0, 1.0);
        final stateIndex = _titleStops[stage.round().clamp(0, last)].state;

        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: CustomPaint(
                        painter: ArenaPainter(
                          mice: mice,
                          fill: Color.lerp(warmTint, coldTint, chill)!,
                          border: boxLine,
                          borderWidth: 6,
                          snowflake: chill > 0.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                  _Thermometer(chill: chill),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Text(
              '${temp.round()} °C',
              style: tH1.copyWith(
                fontSize: 80,
                color: Color.lerp(const Color(0xFFF0A868), const Color(0xFF8FA7F5), chill),
              ),
            ),
            Text(
              '${stateNames[stateIndex]}  ·  ${stateSubtitles[stateIndex]}',
              style: tBody.copyWith(color: const Color(0xFF7C949C)),
            ),
          ],
        );
      },
    );
  }
}

class _Thermometer extends StatelessWidget {
  const _Thermometer({required this.chill});

  final double chill;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: CustomPaint(painter: _ThermometerPainter(chill)),
    );
  }
}

class _ThermometerPainter extends CustomPainter {
  _ThermometerPainter(this.chill);

  final double chill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final bulbR = w * 0.5;
    final bulb = Offset(w / 2, size.height - bulbR);
    final tubeTop = w * 0.6;
    final tube = RRect.fromRectAndRadius(
      Rect.fromLTRB(w * 0.24, tubeTop, w * 0.76, bulb.dy),
      Radius.circular(w * 0.26),
    );

    const glass = Color(0xFFEDEFF2);
    canvas.drawRRect(tube, Paint()..color = glass);
    canvas.drawCircle(bulb, bulbR, Paint()..color = glass);

    final color = Color.lerp(warm, cold, chill)!;
    final fillTop = tubeTop + (bulb.dy - tubeTop) * (0.08 + 0.72 * chill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.32, fillTop, w * 0.68, bulb.dy),
        Radius.circular(w * 0.18),
      ),
      Paint()..color = color,
    );
    canvas.drawCircle(bulb, bulbR * 0.74, Paint()..color = color);

    final outline = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07
      ..color = boxLine;
    canvas.drawRRect(tube, outline);
    canvas.drawCircle(bulb, bulbR, outline);
  }

  @override
  bool shouldRepaint(_ThermometerPainter oldDelegate) =>
      oldDelegate.chill != chill;
}

// ---------------------------------------------------------------------------
// Slide 1 — what group living buys you, then what the environment takes away.
// ---------------------------------------------------------------------------

class _Benefit {
  const _Benefit(this.title, this.detail, this.color, this.icon);

  final String title;
  final String detail;
  final Color color;
  final IconData icon;
}

const _benefits = [
  _Benefit('Conserving resources', 'Less energy spent each',
      Color(0xFF198A5A), Icons.bolt_rounded),
  _Benefit('Regulating temperature', 'Shared warmth, less loss', activeColor,
      Icons.thermostat_rounded),
  _Benefit('Evading predators', 'Safety in numbers', cnoColor,
      Icons.visibility_rounded),
  _Benefit('Foraging and navigating', 'Food found faster', passiveColor,
      Icons.explore_rounded),
];

Slide whyGroups() => Slide(
      duration: const Duration(milliseconds: 2600),
      steps: 2,
      stepDuration: const Duration(milliseconds: 1100),
      builder: (context) => SlideFrame(
        kicker: 'Background',
        title: 'Huddling helps in',
        source: 'Introduction, refs 1–8',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  for (final (i, b) in _benefits.indexed)
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: i == 3 ? 0 : 24),
                        child: Anim(
                          at: 0.3 + i * 0.16,
                          dur: 0.6,
                          from: const Offset(0, 26),
                          child: _BenefitCard(b),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 4,
                    child: Anim(
                      step: 1,
                      scale: 0.97,
                      child: const _ChallengePanel(),
                    ),
                  ),
                  const SizedBox(width: 44),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Anim(
                          step: 1,
                          from: Offset(0, 18),
                          child: Text(
                            'Climate shifts and natural disasters press on '
                            'individuals and on whole groups.',
                            style: tLead,
                          ),
                        ),
                        SizedBox(height: 26),
                        Anim(
                          step: 2,
                          from: Offset(0, 18),
                          child: Callout(
                            'Social cohesion raises the odds of getting '
                            'through it — protection no single animal, and '
                            'no pair, can reach alone',
                            style: tNote,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

class _BenefitCard extends StatelessWidget {
  const _BenefitCard(this.benefit);

  final _Benefit benefit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 0, 20, 24),
      decoration: BoxDecoration(
        color: fade(benefit.color, 0.07),
        border: Border(top: BorderSide(color: benefit.color, width: 6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Icon(benefit.icon, size: 40, color: benefit.color),
          const SizedBox(height: 28),
          Text(
            benefit.title,
            style: tBody.copyWith(
                fontWeight: FontWeight.w600, height: 1.2, fontSize: 28),
          ),
          const SizedBox(height: 6),
          Text(benefit.detail, style: tSmall),
        ],
      ),
    );
  }
}

/// A storm front crosses the panel: one mouse alone, three together.
class _ChallengePanel extends StatelessWidget {
  const _ChallengePanel();

  @override
  Widget build(BuildContext context) {
    final timeline = SlideTimeline.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AnimatedBuilder(
        animation: Listenable.merge([timeline.main, timeline.stage]),
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _StormPainter(
            timeline.main.value,
            timeline.stage.value.clamp(0.0, 1.0),
          ),
        ),
      ),
    );
  }
}

class _StormPainter extends CustomPainter {
  _StormPainter(this.seconds, this.on);

  final double seconds;
  final double on;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = Color.lerp(warmTint, coldTint, on)!,
    );

    final streak = Paint()
      ..strokeCap = StrokeCap.round
      ..color = fade(Colors.white, 0.45 * on);
    for (var i = 0; i < 9; i++) {
      final y = size.height * (0.08 + 0.1 * i);
      final phase = (seconds * 0.4 + i * 0.27) % 1.0;
      final x = -0.3 * size.width + phase * 1.6 * size.width;
      final len = size.width * (0.1 + 0.06 * (i % 3));
      streak.strokeWidth = 4 + (i % 3) * 2;
      canvas.drawLine(Offset(x, y), Offset(x + len, y), streak);
    }

    final mouseLen = size.width * 0.15;
    final shiver = math.sin(seconds * 7) * 3.0 * on;

    // Left: one mouse, exposed.
    paintMouse(
      canvas,
      Offset(size.width * 0.22, size.height * 0.56) + Offset(shiver, 0),
      deg(-12),
      mouseLen,
    );
    paintText(
      canvas,
      'alone',
      Offset(size.width * 0.22, size.height * 0.80),
      size: 26,
      color: ink,
      weight: FontWeight.w600,
      anchor: Alignment.topCenter,
    );

    // Right: a huddle of three, steady.
    final centre = Offset(size.width * 0.66, size.height * 0.56);
    const offsets = [Offset(-0.34, 0.0), Offset(0.34, 0.0), Offset(0.0, 0.62)];
    const angles = [-90.0, 90.0, -90.0];
    for (final (i, o) in offsets.indexed) {
      paintMouse(
        canvas,
        centre + Offset(o.dx * mouseLen, o.dy * mouseLen),
        deg(angles[i]),
        mouseLen,
      );
    }
    paintText(
      canvas,
      'together',
      Offset(size.width * 0.66, size.height * 0.80),
      size: 26,
      color: ink,
      weight: FontWeight.w600,
      anchor: Alignment.topCenter,
    );
  }

  @override
  bool shouldRepaint(_StormPainter oldDelegate) => true;
}

// ---------------------------------------------------------------------------
// Slide 2 — why the neurobiology is still open.
// ---------------------------------------------------------------------------

Slide whyUnknown() => Slide(
      duration: const Duration(seconds: 3),
      builder: (context) => SlideFrame(
        kicker: 'The gap',
        title: 'We know the behaviour. We do not know the circuit.',
        source: 'Introduction, refs 9–19',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Bullets([
                'Little is known about the neurobiology that lets an '
                    'individual adapt to the rest of its group',
                'Group interactions are hard to study: recording and '
                    'manipulation demand constrained setups',
                'Multi-animal tracking has only recently opened multi-agent '
                    'behaviour to neuroscience',
              ], style: tLead),
            ),
            const SizedBox(width: 60),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Anim(
                    at: 1.1,
                    child: Text('Where progress has been made', style: tSmall),
                  ),
                  const SizedBox(height: 16),
                  for (final (i, item) in const [
                    ('Fish', 'schooling'),
                    ('Bats', 'group space and vocal exchange'),
                    ('Flies', 'collective escape and defence'),
                  ].indexed)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Anim(
                        at: 1.3 + i * 0.2,
                        from: const Offset(26, 0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 18),
                          decoration: const BoxDecoration(
                            color: wash,
                            border: Border(
                                left: BorderSide(color: accent, width: 5)),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 130,
                                child: Text(item.$1,
                                    style: tBody.copyWith(
                                        fontWeight: FontWeight.w600)),
                              ),
                              Expanded(child: Text(item.$2, style: tNote)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Anim(
                    at: 2.1,
                    child: Callout(
                      'How a group of mammals organises its behaviour '
                      'together is still largely unknown',
                      style: tNote,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
