import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';
import '../widgets/mouse.dart';

// ---------------------------------------------------------------------------
// Chemogenetic silencing — 3 clicks:
//   1. two mice get CNO; their active decisions fall by 25%
//   2. their saline partners' active decisions rise by 25%
//   3. the group-level outcome is unchanged
//
// Bars show each mouse's share of active decisions relative to its own
// all-saline baseline. Only the ±25% is from the paper; the bars are a
// schematic of that statement.
// ---------------------------------------------------------------------------

const _pxPerPercent = 3.0;

class _MousePainter extends CustomPainter {
  _MousePainter(this.halo);

  final Color? halo;

  @override
  void paint(Canvas canvas, Size size) {
    paintMouse(
      canvas,
      size.center(Offset.zero) + Offset(size.width * 0.12, 0),
      0,
      size.width * 0.6,
      halo: halo,
    );
  }

  @override
  bool shouldRepaint(_MousePainter oldDelegate) => oldDelegate.halo != halo;
}

class _MouseBar extends StatelessWidget {
  const _MouseBar({
    required this.silenced,
    required this.drug,
    required this.compensation,
  });

  /// Whether this mouse is one of the two that receive CNO.
  final bool silenced;

  /// Progress of click 1 (CNO takes effect), 0 → 1.
  final double drug;

  /// Progress of click 2 (partners compensate), 0 → 1.
  final double compensation;

  @override
  Widget build(BuildContext context) {
    final change = silenced ? -25 * drug : 25 * compensation;
    final color = silenced
        ? Color.lerp(salColor, cnoColor, drug)!
        : Color.lerp(salColor, activeColor, compensation)!;
    final label = change.round() == 0
        ? ''
        : '${change > 0 ? '+' : '−'}${change.abs().round()}%';

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          label,
          style: tH2.copyWith(fontSize: 44, color: color),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 125 * _pxPerPercent,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: 130,
                height: (100 + change) * _pxPerPercent,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(14)),
                ),
              ),
              // The all-saline baseline.
              Positioned(
                left: 20,
                right: 20,
                bottom: 100 * _pxPerPercent,
                child: Container(height: 3, color: ink),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 190,
          height: 100,
          child: CustomPaint(
            painter: _MousePainter(silenced ? fade(cnoColor, drug) : null),
          ),
        ),
        Text(
          silenced && drug > 0.5 ? 'CNO' : 'Saline',
          style: tBody.copyWith(
            fontWeight: FontWeight.w700,
            color: silenced && drug > 0.5 ? cnoColor : salColor,
          ),
        ),
        Text(
          silenced && drug > 0.5 ? 'dmPFC silenced' : 'dmPFC intact',
          style: tSmall,
        ),
      ],
    );
  }
}

Slide silencing() => Slide(
      steps: 3,
      stepDuration: const Duration(milliseconds: 1300),
      builder: (context) => SlideFrame(
        kicker: 'Causality',
        title: 'Silence two mice and the other two compensate',
        source: 'Fig. 6b–l · bars are a schematic of the reported ±25%',
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Share of entry and exit decisions that are active — '
                    'line marks each mouse’s all-saline baseline',
                    style: tSmall,
                  ),
                  Expanded(
                    child: StageBuilder(
                      builder: (context, s) {
                        final drug = s.clamp(0.0, 1.0);
                        final compensation = (s - 1).clamp(0.0, 1.0);
                        return Row(
                          children: [
                            for (var i = 0; i < 4; i++)
                              Expanded(
                                child: _MouseBar(
                                  silenced: i < 2,
                                  drug: drug,
                                  compensation: compensation,
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 70),
            const Expanded(
              flex: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Anim(
                    at: 0.4,
                    child: Text(
                      'All four cagemates express hM4Di in dmPFC. On test '
                      'days, two receive CNO and two receive saline.',
                      style: tNote,
                    ),
                  ),
                  SizedBox(height: 30),
                  Anim(
                    step: 1,
                    from: Offset(0, 20),
                    child: Bullet(
                      'Silenced mice make 25% fewer active entries and exits',
                      color: cnoColor,
                    ),
                  ),
                  SizedBox(height: 22),
                  Anim(
                    step: 2,
                    from: Offset(0, 20),
                    child: Bullet(
                      'Their untouched partners make 25% more',
                      color: activeColor,
                    ),
                  ),
                  SizedBox(height: 30),
                  Anim(
                    step: 3,
                    from: Offset(0, 20),
                    child: Callout(
                      'The group is unchanged: same huddle states, same '
                      'huddling time per mouse, same total number of '
                      'decisions',
                      color: good,
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
// Controls — autoplay.
// ---------------------------------------------------------------------------

Slide controls() => Slide(
      duration: const Duration(seconds: 3),
      builder: (context) => const SlideFrame(
        kicker: 'Causality',
        title: 'What dmPFC silencing does not change',
        source: 'Fig. 6p–v · Extended Data Figs. 8–10',
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bullets([
              'Locomotion: speed outside huddling and distance in the open '
                  'field are unchanged',
              'Anxiety-like behaviour: time in the centre is unchanged at '
                  'room temperature and at 5 °C',
              'Autonomic thermogenesis: brown-fat temperature is unaffected',
              'Warmth seeking: mice still find and use a 30 °C corner',
              'CNO alone: mCherry-only controls show none of the effects',
            ]),
            SizedBox(height: 20),
            Anim(
              at: 2.0,
              dur: 0.8,
              child: Callout(
                'Silence all four and huddling is normal again — with no '
                'partner left to compensate, other circuits appear to take '
                'over',
              ),
            ),
          ],
        ),
      ),
    );
