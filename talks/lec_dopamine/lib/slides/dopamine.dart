import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/brain.dart';
import '../widgets/frame.dart';
import '../widgets/plots.dart';

// ---------------------------------------------------------------------------
// Figure 3 — the negative result that makes the rest of the paper work.
// ---------------------------------------------------------------------------

Slide axonsSpared() => Slide(
      duration: const Duration(milliseconds: 2600),
      steps: 2,
      stepDuration: const Duration(milliseconds: 1200),
      builder: (context) => SlideFrame(
        kicker: 'Figure 3',
        title: 'The dopamine axons are still there',
        accentColor: dopamineGreen,
        source: 'Fig. 3 · TH immunostaining, n = 8 young and 6 old per strain',
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Anim(
                      at: 0.4,
                      scale: 0.95,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: CoronalPainter(
                          dopamine: 1,
                          plaques: 0.55,
                          highlightLec: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 46),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Bullets([
                          'Plaques sit on dopamine cell bodies in the VTA and '
                              'SNc, and among the fibres in the LEC',
                          'Plaque density is higher in SNc than VTA',
                        ]),
                        const SizedBox(height: 6),
                        const Anim(
                          step: 1,
                          from: Offset(0, 20),
                          child: Callout(
                            'TH-positive fibre density in the LEC is '
                            'unchanged — young or old, APP-KI or WT. So is '
                            'the number of dopamine neurons.',
                            lead: 'And yet:',
                            color: dopamineGreen,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const Anim(
                          step: 2,
                          from: Offset(0, 20),
                          child: IdeaBand(
                            'if the wiring survives, the fault is in release '
                            '— and release is something you can put back.',
                            lead: 'Why it matters:',
                            color: dopamineGreen,
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

// ---------------------------------------------------------------------------
// Figure 4 — photometry. Four conditions, one click each.
// ---------------------------------------------------------------------------

class _Trace {
  const _Trace(this.strain, this.session, this.amplitude, this.onset,
      this.note, this.color);

  final String strain;
  final String session;

  /// Peak z-scored ΔF/F on Odor-1 trials, early in the session.
  final double amplitude;

  /// When the signal appears, in seconds after cue onset.
  final double onset;
  final String note;
  final Color color;
}

const _traces = [
  _Trace('WT', 'correct session', 1.8, 1.0,
      'Dopamine arrives for the novel rewarded cue from the very first '
          'trials, through the delay.', wtGrey),
  _Trace('WT', 'error session', 0.15, 1.0,
      'On the sessions where WT mice fail to learn, the Odor-1 signal is '
          'absent too.', wtGrey),
  _Trace('APP-KI', 'correct session', 0.55, 1.0,
      'When APP-KI mice do learn, the Odor-1 signal appears late — from T3 '
          'rather than T1 — and tracks their slow learning.', appPurple),
  _Trace('APP-KI', 'error session', 0.0, 1.0,
      'On the 39% of sessions they fail, the Odor-1 signal is gone '
          'altogether. Odor-A stays intact throughout.', appPurple),
];

Slide photometry() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 4,
      stepDuration: const Duration(milliseconds: 1200),
      builder: (context) => SlideFrame(
        kicker: 'Figure 4',
        title: 'Dopamine fails for the novel rewarded cue, and only for it',
        accentColor: dopamineGreen,
        source: 'Illustration after Fig. 4b–f · GCaMP in dopamine fibres, '
            'recorded in the LEC; traces are schematic',
        child: StageBuilder(
          builder: (context, stage) => Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, t) in _traces.indexed) ...[
                      if (i > 0) const SizedBox(width: 18),
                      Expanded(
                        child: Opacity(
                          opacity: 0.25 + 0.75 * (stage - i).clamp(0.0, 1.0),
                          child: _TracePanel(
                            trace: t,
                            reveal: (stage - i).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: (stage - 3.4).clamp(0.0, 1.0),
                child: const Callout(
                  'Odor-A keeps its dopamine signal in every condition. The '
                  'loss is specific to the cue the animal is trying to learn.',
                  lead: 'The control is internal:',
                  color: dopamineGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );

class _TracePanel extends StatelessWidget {
  const _TracePanel({required this.trace, required this.reveal});

  final _Trace trace;
  final double reveal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          alignment: Alignment.center,
          color: fade(trace.color, 0.14),
          child: Text(
            '${trace.strain} · ${trace.session}',
            style: tSmall.copyWith(
                color: trace.color, fontWeight: FontWeight.w900),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: hairline, width: 2),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: PhotometryPainter(
                amplitude: trace.amplitude,
                onset: trace.onset,
                reveal: reveal,
                color: odor1,
                label: 'Odor-1',
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: Text(trace.note, style: tSmall.copyWith(color: ink)),
        ),
      ],
    );
  }
}
