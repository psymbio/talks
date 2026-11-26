import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/brain.dart';
import '../widgets/frame.dart';

// ---------------------------------------------------------------------------
// Cover. Two clicks: the dopamine projection grows from the midbrain into
// the LEC, then amyloid appears over it.
// ---------------------------------------------------------------------------

Slide title() => Slide(
      duration: const Duration(seconds: 4),
      steps: 2,
      stepDuration: const Duration(milliseconds: 2400),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(88, 54, 88, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Anim(
              child: Text(
                'NATURE NEUROSCIENCE 29, 1386–1396 (2026)',
                style: tKicker,
              ),
            ),
            const SizedBox(height: 14),
            const Anim(
              at: 0.1,
              dur: 1.0,
              from: Offset(0, 26),
              child: Text(
                'Early dopamine disruption in the entorhinal cortex '
                'of a knock-in model of Alzheimer’s disease',
                style: tH1,
              ),
            ),
            const SizedBox(height: 18),
            Anim(
              at: 0.2,
              dur: 1.0,
              builder: (context, t, _) => Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: t,
                  child: Container(height: 5, color: accent),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Anim(
              at: 0.9,
              child: Text(
                'Nakagawa, Xie, Park, Cao, Savadkohighodjanaki, Zhang, Jun, '
                'Ichii, Lee, Soma, Medhat, Saido & Igarashi   ·   '
                'University of California, Irvine',
                style: tNote,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Anim(
                      at: 0.5,
                      dur: 1.2,
                      scale: 0.96,
                      child: StageBuilder(
                        builder: (context, stage) => CustomPaint(
                          size: Size.infinite,
                          painter: CoronalPainter(
                            dopamine: ease(stage.clamp(0.0, 1.0)),
                            plaques: ease((stage - 1).clamp(0.0, 1.0)),
                            highlightLec: stage > 0.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                  Expanded(
                    flex: 4,
                    child: StageBuilder(
                      builder: (context, stage) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: focusAt(stage, 1).clamp(0.3, 1.0),
                            child: const Callout(
                              'the VTA and SNc send dopamine axons to the '
                              'lateral entorhinal cortex, where novel rewarded '
                              'cues are learned.',
                              lead: 'Healthy brain:',
                              color: dopamineGreen,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Opacity(
                            opacity: stage > 1.05 ? 1 : 0.0,
                            child: const Callout(
                              'amyloid accumulates over that circuit from '
                              'two months of age.',
                              lead: 'APP-KI:',
                              color: abRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Anim(
              at: 2.0,
              dur: 0.9,
              from: Offset(0, 22),
              child: IdeaBand(
                'the dopamine axons survive, but stop releasing for novel '
                'rewarded cues — and restoring dopamine restores memory.',
                lead: 'Finding:',
              ),
            ),
          ],
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Why this region.
// ---------------------------------------------------------------------------

Slide whyEntorhinal() => Slide(
      duration: const Duration(milliseconds: 2600),
      steps: 1,
      builder: (context) => SlideFrame(
        kicker: 'Background',
        title: 'The entorhinal cortex fails first in Alzheimer’s disease',
        source: 'Introduction, refs 3–8',
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Bullets([
                          'Post-mortem work: the entorhinal cortex atrophies '
                              'before the hippocampus, layer 2 first',
                          'Imaging in early-stage patients: the lateral '
                              'entorhinal cortex loses activity before the '
                              'medial',
                          'But why this region, and what function is lost, '
                              'has stayed unanswered',
                        ], style: tLead),
                      ],
                    ),
                  ),
                  const SizedBox(width: 50),
                  Expanded(
                    flex: 3,
                    child: Anim(
                      at: 0.5,
                      scale: 0.95,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: CoronalPainter(highlightLec: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Anim(
              step: 1,
              from: Offset(0, 20),
              child: Callout(
                'the LEC is where novel sensory cues get attached to '
                'outcomes. Lose it and you lose the making of new memories, '
                'not the keeping of old ones.',
                lead: 'What it does:',
              ),
            ),
          ],
        ),
      ),
    );

Slide theGap() => Slide(
      duration: const Duration(milliseconds: 2600),
      steps: 1,
      builder: (context) => SlideFrame(
        kicker: 'The gap',
        title: 'Dopamine was looked for in the wrong place',
        source: 'Introduction and Discussion, refs 26–36',
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: ListPanel(
                      title: 'What was known',
                      color: wtGrey,
                      at: 0.3,
                      items: [
                        'Dopamine loss is the story of Parkinson’s disease, '
                            'not of Alzheimer’s',
                        'Patients with AD show reduced dopamine and receptor '
                            'expression in the hippocampus',
                      ],
                    ),
                  ),
                  SizedBox(width: 26),
                  Expanded(
                    child: ListPanel(
                      title: 'Why that misses it',
                      color: abRed,
                      at: 0.5,
                      items: [
                        'The hippocampus gets few VTA or SNc axons — its '
                            'catecholamines come largely from locus coeruleus',
                        'The dopamine projection in this circuit lands on the '
                            'entorhinal cortex instead',
                      ],
                    ),
                  ),
                  SizedBox(width: 26),
                  Expanded(
                    child: ListPanel(
                      title: 'Why it should fail early',
                      color: dopamineGreen,
                      at: 0.7,
                      items: [
                        'Dopamine neurons carry high metabolic stress and '
                            'oxidant load, so they age badly',
                        'Entorhinal dopamine fibres exist in humans too, and '
                            'have never been assessed in AD',
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Anim(
              step: 1,
              from: Offset(0, 20),
              child: IdeaBand(
                'is the LEC vulnerable because of the dopamine input only it '
                'receives?',
                lead: 'Hypothesis:',
              ),
            ),
          ],
        ),
      ),
    );

// ---------------------------------------------------------------------------
// The questions.
// ---------------------------------------------------------------------------

const _questions = [
  ('1', 'Do APP-KI mice fail to form new associative memories?',
      'and is retrieval of old ones spared', appPurple),
  ('2', 'What happens to LEC coding during learning?',
      'how cue representations change', odorA),
  ('3', 'Are the dopamine axons gone, or just quiet?',
      'structure versus function', dopamineGreen),
  ('4', 'Does putting dopamine back restore memory?',
      'optogenetically, and with a drug', ldopaGreen),
];

Slide questions() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 4,
      stepDuration: const Duration(milliseconds: 700),
      builder: (context) => SlideFrame(
        kicker: 'The questions',
        title: 'Four questions',
        source: 'APP-KI (APPNL-G-F) versus C57BL/6 WT · young 3–6 months, '
            'old 7–11 months',
        child: StageBuilder(
          builder: (context, stage) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, q) in _questions.indexed)
                Expanded(
                  child: Opacity(
                    opacity: 0.22 + 0.78 * (stage - i).clamp(0.0, 1.0),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: q.$4, width: 7),
                          bottom:
                              const BorderSide(color: hairline, width: 2),
                        ),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 86,
                            child: Text(q.$1,
                                style: tH1.copyWith(
                                    fontSize: 54, color: q.$4)),
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q.$2,
                                    style: tH2.copyWith(fontSize: 38)),
                                Text(q.$3, style: tSmall),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

// ---------------------------------------------------------------------------
// The task, in one slide: the trial, then the four cues.
// ---------------------------------------------------------------------------

Slide task() => Slide(
      duration: const Duration(milliseconds: 2000),
      steps: 3,
      stepDuration: const Duration(milliseconds: 1400),
      builder: (context) => SlideFrame(
        kicker: 'The task',
        title: 'Lick for the rewarded odor, withhold for the punished one',
        source: 'Fig. 1b · head-fixed mice, ~160 trials per session',
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: StageBuilder(
                builder: (context, stage) =>
                    TrialTimeline(progress: stage.clamp(0.0, 1.0)),
              ),
            ),
            const SizedBox(height: 26),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Anim(
                      step: 2,
                      from: const Offset(0, 20),
                      child: const _CueCard(
                        chip: 'A',
                        chipColor: odorA,
                        title: 'Prelearned, rewarded',
                        detail: 'Lick → sucrose. Learned over 5–10 days '
                            'before any test session.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Anim(
                      step: 2,
                      from: const Offset(0, 20),
                      child: const _CueCard(
                        chip: 'B',
                        chipColor: odorB,
                        title: 'Prelearned, punished',
                        detail: 'Lick → quinine. Withholding is the correct '
                            'answer.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Anim(
                      step: 3,
                      from: const Offset(0, 20),
                      child: const _CueCard(
                        chip: '1',
                        chipColor: odor1,
                        title: 'Novel, rewarded',
                        detail: 'A fresh odor each day, never repeated. '
                            'The animal must work it out within the session.',
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                  Expanded(
                    child: Anim(
                      step: 3,
                      from: const Offset(0, 20),
                      child: const _CueCard(
                        chip: '2',
                        chipColor: odor2,
                        title: 'Novel, punished',
                        detail: 'Its partner odor, also new, also to be '
                            'figured out.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Anim(
              step: 3,
              child: Callout(
                'A and B test retrieval of an old memory; 1 and 2 test the '
                'formation of a new one — in the same session, minutes apart.',
                lead: 'The trick:',
              ),
            ),
          ],
        ),
      ),
    );

class _CueCard extends StatelessWidget {
  const _CueCard({
    required this.chip,
    required this.chipColor,
    required this.title,
    required this.detail,
  });

  final String chip;
  final Color chipColor;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Panel(
      accentColor: chipColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OdorChip(chip, chipColor),
          const SizedBox(height: 14),
          Text(title,
              style: tNote.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(detail, style: tSmall),
        ],
      ),
    );
  }
}
