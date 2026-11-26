import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';

// ---------------------------------------------------------------------------
// The chain, one link per click, then what it means.
// ---------------------------------------------------------------------------

const _chain = [
  ('Amyloid reaches the midbrain', 'VTA and SNc, from 4 months', abRed),
  ('Dopamine release fails', 'for novel rewarded cues only, while the axons '
      'stay intact', dopamineGreen),
  ('LEC coding breaks', 'the new rewarded cue is never generalized with the '
      'known one', appPurple),
  ('New memories do not form', 'while old ones are retrieved normally',
      odorA),
];

Slide theChain() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 4,
      stepDuration: const Duration(milliseconds: 900),
      builder: (context) => SlideFrame(
        kicker: 'Summary',
        title: 'One chain, from plaque to forgetting',
        source: 'Nakagawa et al., Nat Neurosci 29, 1386–1396 (2026)',
        child: StageBuilder(
          builder: (context, stage) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, link) in _chain.indexed)
                Expanded(
                  child: Opacity(
                    opacity: 0.2 + 0.8 * (stage - i).clamp(0.0, 1.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text('${i + 1}',
                              style: tH1.copyWith(
                                  fontSize: 46, color: link.$3)),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(26, 18, 26, 18),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: fade(link.$3, 0.07),
                              border: Border(
                                left: BorderSide(color: link.$3, width: 7),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(link.$1,
                                    style: tH2.copyWith(fontSize: 36)),
                                Text(link.$2, style: tNote),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

Slide soWhat() => Slide(
      duration: const Duration(milliseconds: 2800),
      steps: 2,
      builder: (context) => SlideFrame(
        kicker: 'What follows',
        title: 'Two claims worth arguing about',
        source: 'Discussion',
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: ListPanel(
                      title: 'Why the LEC goes first',
                      at: 0.3,
                      items: [
                        'Within the entorhinal–hippocampal circuit, the '
                            'dopamine projection is the LEC’s alone',
                        'A vulnerable input can make an otherwise ordinary '
                            'region the first to fail',
                        'Entorhinal dopamine fibres exist in humans, and have '
                            'never been looked at in patients with AD',
                      ],
                    ),
                  ),
                  SizedBox(width: 30),
                  Expanded(
                    child: ListPanel(
                      title: 'Why L-DOPA is interesting here',
                      color: ldopaGreen,
                      at: 0.55,
                      items: [
                        'The terminals still hold dopamine — the fault is '
                            'release, which a precursor can drive',
                        'L-DOPA is already in clinical use for Parkinson’s '
                            'disease',
                        'It worked in two different AD models and not in '
                            'healthy mice',
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Anim(
              step: 1,
              from: Offset(0, 18),
              child: Callout(
                'these are mice, early in pathology, on a single odor task. '
                'Nothing here shows a dose, a timing, or an effect in a '
                'human brain.',
                lead: 'What it is not:',
                color: abRed,
              ),
            ),
            const SizedBox(height: 14),
            const Anim(
              step: 2,
              from: Offset(0, 18),
              child: IdeaBand(
                'go and measure dopamine in the entorhinal cortex of '
                'patients with early Alzheimer’s disease.',
                lead: 'The ask:',
              ),
            ),
          ],
        ),
      ),
    );
