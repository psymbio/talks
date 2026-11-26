import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/brain.dart';
import '../widgets/frame.dart';
import '../widgets/plots.dart';

// ---------------------------------------------------------------------------
// Figure 1 — amyloid, then the behaviour.
// ---------------------------------------------------------------------------

const _ages = ['2 months', '6 months', '12 months'];
const _ageNotes = [
  'Amyloid is already there in cortex, including the LEC.',
  'Denser, and now present in the midbrain — the VTA and SNc included.',
  'Widespread across cortex and hippocampus.',
];

Slide amyloidProgression() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 3,
      stepDuration: const Duration(milliseconds: 1600),
      builder: (context) => SlideFrame(
        kicker: 'Figure 1a',
        title: 'Amyloid arrives early, and reaches the midbrain by 4 months',
        accentColor: abRed,
        source: 'Illustration after Fig. 1a · plaque positions are '
            'schematic, not traced',
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: StageBuilder(
                      builder: (context, stage) => CustomPaint(
                        size: Size.infinite,
                        painter: CoronalPainter(
                          dopamine: 0.9,
                          plaques: 0.1 + 0.3 * stage,
                          highlightLec: true,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    child: StageBuilder(
                      builder: (context, stage) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage < 0.5
                                ? 'WT, 3 months'
                                : 'APP-KI, ${_ages[(stage.round() - 1).clamp(0, 2)]}',
                            style: tH2.copyWith(
                                fontSize: 46,
                                color: stage < 0.5 ? wtGrey : appPurple),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 560,
                            child: Text(
                              stage < 0.5
                                  ? 'No plaques. This is the control at the '
                                      'age the behaviour is first tested.'
                                  : _ageNotes[(stage.round() - 1).clamp(0, 2)],
                              style: tBody,
                            ),
                          ),
                          const SizedBox(height: 30),
                          const Anim(
                            at: 0.6,
                            child: Callout(
                              'the APP knock-in accumulates amyloid '
                              'gradually, without the overexpression '
                              'artefacts of transgenic models.',
                              lead: 'Why this model:',
                              color: abRed,
                              style: tNote,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

const _wtCurve = LearnCurve(
  label: 'Young WT',
  novelAsymptote: 90.6,
  rate: 4.5,
  color: wtGrey,
);
const _appCurve = LearnCurve(
  label: 'Young APP-KI',
  novelAsymptote: 78.6,
  rate: 2.2,
  color: appPurple,
  wobble: 1.2,
);

Slide learningCurves() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 2,
      stepDuration: const Duration(milliseconds: 2400),
      builder: (context) => SlideFrame(
        kicker: 'Figure 1c,d',
        title: 'APP-KI mice keep the old association and fail the new one',
        source: 'Schematic after Fig. 1c · asymptotes are the reported T5 '
            'values, the traces are illustrative',
        child: Column(
          children: [
            Expanded(
              child: StageBuilder(
                builder: (context, stage) => Row(
                  children: [
                    Expanded(
                      child: _CurvePanel(
                        curve: _wtCurve,
                        progress: stage.clamp(0.0, 1.0),
                      ),
                    ),
                    const SizedBox(width: 34),
                    Expanded(
                      child: _CurvePanel(
                        curve: _appCurve,
                        progress: (stage - 1).clamp(0.0, 1.0),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            StageBuilder(
              builder: (context, stage) => Opacity(
                opacity: (stage - 1.6).clamp(0.0, 1.0),
                child: const Callout(
                  'the blue traces are identical. Perception and retrieval '
                  'are intact; it is the forming of the new association that '
                  'breaks, from 4 months of age.',
                  lead: 'Read the blue:',
                ),
              ),
            ),
          ],
        ),
      ),
    );

class _CurvePanel extends StatelessWidget {
  const _CurvePanel({required this.curve, required this.progress});

  final LearnCurve curve;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          color: fade(curve.color, 0.14),
          child: Text(
            curve.label,
            style: tBody.copyWith(
                fontWeight: FontWeight.w900, color: curve.color),
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: hairline, width: 2),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: LearningCurvePainter(
                curve: curve,
                progress: progress,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'novel odors reach ${curve.novelAsymptote.toStringAsFixed(1)}% '
          'by T5',
          style: tSmall,
        ),
      ],
    );
  }
}
