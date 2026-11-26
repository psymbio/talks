import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/brain.dart';
import '../widgets/frame.dart';
import '../widgets/plots.dart';

// ---------------------------------------------------------------------------
// Figure 5 — put the dopamine back with light.
// ---------------------------------------------------------------------------

const _controlCurve = LearnCurve(
  label: 'No stimulation',
  novelAsymptote: 77.9,
  rate: 2.4,
  color: wtGrey,
  wobble: 1.4,
);
const _stimCurve = LearnCurve(
  label: 'Laser on Odor-1 trials',
  novelAsymptote: 95.2,
  rate: 5.0,
  color: laserBlue,
);

Slide optogenetics() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 2,
      stepDuration: const Duration(milliseconds: 2200),
      builder: (context) => SlideFrame(
        kicker: 'Figure 5',
        title: 'Stimulating LEC dopamine on Odor-1 trials rescues learning',
        accentColor: laserBlue,
        source: 'Illustration after Fig. 5 · ChR2 in dopamine fibres, '
            'n = 11 young APP-KI mice; curves are schematic',
        child: Column(
          children: [
            Expanded(
              child: StageBuilder(
                builder: (context, stage) => Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: CoronalPainter(
                          dopamine: 1,
                          plaques: 0.55,
                          highlightLec: true,
                          fiber: true,
                          laser: stage > 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      flex: 4,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: hairline, width: 2),
                        ),
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: LearningCurvePainter(
                            curve: stage > 0.5 ? _stimCurve : _controlCurve,
                            progress: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      flex: 3,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stage > 0.5
                                ? 'Laser on Odor-1'
                                : 'No stimulation',
                            style: tH2.copyWith(
                              fontSize: 36,
                              color: stage > 0.5 ? laserBlue : wtGrey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            stage > 0.5
                                ? '95.2% correct at T5, and 87% of sessions '
                                    'reach criterion.'
                                : '77.9% correct at T5, half the sessions '
                                    'short of criterion.',
                            style: tBody,
                          ),
                          const SizedBox(height: 26),
                          Opacity(
                            opacity: (stage - 1.2).clamp(0.0, 1.0),
                            child: const Callout(
                              'stimulating on all four cues does nothing. It '
                              'is the dopamine missing from Odor-1 that '
                              'matters.',
                              lead: 'Specificity:',
                              color: laserBlue,
                              style: tNote,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Figure 6 — and with a drug that already exists.
// ---------------------------------------------------------------------------

const _salineCurve = LearnCurve(
  label: 'Saline',
  novelAsymptote: 67.1,
  rate: 2.0,
  color: wtGrey,
  wobble: 2.0,
);
const _ldopaCurve = LearnCurve(
  label: 'L-DOPA',
  novelAsymptote: 82.6,
  rate: 4.2,
  color: ldopaGreen,
);

Slide ldopaBehaviour() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 2,
      stepDuration: const Duration(milliseconds: 2200),
      builder: (context) => SlideFrame(
        kicker: 'Figure 6a–c',
        title: 'L-DOPA brings APP-KI mice back up to WT performance',
        accentColor: ldopaGreen,
        source: 'Illustration after Fig. 6a–c · 5 mg ml⁻¹ i.p., 30 min '
            'before testing; curves are schematic',
        child: Column(
          children: [
            Expanded(
              child: StageBuilder(
                builder: (context, stage) => Row(
                  children: [
                    Expanded(
                      child: _Condition(
                        curve: _salineCurve,
                        progress: stage.clamp(0.0, 1.0),
                        note: '33% of sessions reach criterion',
                      ),
                    ),
                    const SizedBox(width: 34),
                    Expanded(
                      child: _Condition(
                        curve: _ldopaCurve,
                        progress: (stage - 1).clamp(0.0, 1.0),
                        note: '79% of sessions reach criterion',
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
                  'the same treatment also rescues memory in PS19 tau mice, '
                  'and does nothing in WT controls — it restores a deficit '
                  'rather than boosting a healthy brain.',
                  lead: 'Two more checks:',
                  color: ldopaGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );

class _Condition extends StatelessWidget {
  const _Condition({
    required this.curve,
    required this.progress,
    required this.note,
  });

  final LearnCurve curve;
  final double progress;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          color: fade(curve.color, 0.14),
          child: Text(curve.label,
              style: tBody.copyWith(
                  fontWeight: FontWeight.w900, color: curve.color)),
        ),
        Expanded(
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: hairline, width: 2)),
            child: CustomPaint(
              size: Size.infinite,
              painter:
                  LearningCurvePainter(curve: curve, progress: progress),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(note, style: tSmall),
      ],
    );
  }
}

/// The same PC-space picture as Figure 2, now as a rescue.
Slide ldopaEncoding() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 2,
      stepDuration: const Duration(milliseconds: 1800),
      builder: (context) => SlideFrame(
        kicker: 'Figure 6e–i',
        title: 'And it restores the coding, not just the behaviour',
        accentColor: ldopaGreen,
        source: 'Illustration after Fig. 6e–i · 132 saline and 144 L-DOPA '
            'LEC neurons; trajectories are schematic',
        child: StageBuilder(
          builder: (context, stage) => Column(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _PcaCard(
                        label: 'Saline',
                        color: wtGrey,
                        converge: 0,
                        note: 'A and 1 stay apart; SI negative throughout.',
                      ),
                    ),
                    const SizedBox(width: 34),
                    Expanded(
                      child: _PcaCard(
                        label: 'L-DOPA',
                        color: ldopaGreen,
                        converge: ease(stage.clamp(0.0, 1.0)),
                        note: 'A and 1 come together; SI turns positive from '
                            'trials 7–9 onward.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Opacity(
                opacity: (stage - 1.2).clamp(0.0, 1.0),
                child: const IdeaBand(
                  'the generalization that was missing in Figure 2 comes '
                  'back when dopamine does.',
                  lead: 'Same picture, reversed:',
                  color: ldopaGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );

class _PcaCard extends StatelessWidget {
  const _PcaCard({
    required this.label,
    required this.color,
    required this.converge,
    required this.note,
  });

  final String label;
  final Color color;
  final double converge;
  final String note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          color: fade(color, 0.14),
          child: Text(label,
              style: tBody.copyWith(
                  fontWeight: FontWeight.w900, color: color)),
        ),
        Expanded(
          child: Container(
            decoration:
                BoxDecoration(border: Border.all(color: hairline, width: 2)),
            child: CustomPaint(
              size: Size.infinite,
              painter: PcaPainter(converge: converge),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(note, style: tSmall),
      ],
    );
  }
}
