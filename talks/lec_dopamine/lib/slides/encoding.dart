import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/brain.dart';
import '../widgets/frame.dart';
import '../widgets/plots.dart';

// ---------------------------------------------------------------------------
// Figure 2 — what the LEC is supposed to do, and what it does instead.
// ---------------------------------------------------------------------------

Slide generalizationIdea() => Slide(
      duration: const Duration(milliseconds: 2000),
      steps: 2,
      stepDuration: const Duration(milliseconds: 1200),
      builder: (context) => SlideFrame(
        kicker: 'The mechanism',
        title: 'Learning here means treating a new cue like a known one',
        source: 'Fig. 2b,c · 64-channel tetrode recordings in LEC layer 2/3',
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Anim(
                      step: 1,
                      from: const Offset(0, 22),
                      child: const _CellCard(
                        chips: [('A', odorA), ('1', odor1)],
                        title: 'WT: the A/1 cell',
                        detail: 'Fires to prelearned rewarded Odor-A from the '
                            'first trials, then picks up Odor-1 as the animal '
                            'learns. The new cue joins the old one.',
                        color: wtGrey,
                      ),
                    ),
                  ),
                  const SizedBox(width: 34),
                  Expanded(
                    child: Anim(
                      step: 2,
                      from: const Offset(0, 22),
                      child: const _CellCard(
                        chips: [('B', odorB), ('1', odor1)],
                        title: 'APP-KI: the B/1 cell',
                        detail: 'Fires to punished Odor-B and to rewarded '
                            'Odor-1 together — the new rewarded cue is filed '
                            'with the wrong outcome.',
                        color: appPurple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Anim(
              step: 2,
              from: Offset(0, 18),
              child: IdeaBand(
                'a rewarded cue is learned by being represented like the '
                'rewarded cue you already know.',
                lead: 'Generalization:',
              ),
            ),
          ],
        ),
      ),
    );

class _CellCard extends StatelessWidget {
  const _CellCard({
    required this.chips,
    required this.title,
    required this.detail,
    required this.color,
  });

  final List<(String, Color)> chips;
  final String title;
  final String detail;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Panel(
      accentColor: color,
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              for (final (i, chip) in chips.indexed) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('/', style: tH2),
                  ),
                OdorChip(chip.$1, chip.$2, size: 52),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Text(title, style: tH2.copyWith(fontSize: 36, color: color)),
          const SizedBox(height: 10),
          Text(detail, style: tBody),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// The centre of the talk: the trajectories converge, or they do not.
// ---------------------------------------------------------------------------

Slide generalizationPca() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 3,
      stepDuration: const Duration(milliseconds: 1800),
      builder: (context) => SlideFrame(
        kicker: 'Figure 2e,f',
        title: 'In WT the A and 1 trajectories merge; in APP-KI they never do',
        source: 'Illustration after Fig. 2e,f · PCA of LEC layer 2/3 '
            'population activity; trajectories are schematic',
        child: StageBuilder(
          builder: (context, stage) {
            final phase = ['T1 · first 10 trials', 'T3 · middle 10 trials',
                'T5 · last 10 trials'][stage.round().clamp(0, 2).clamp(0, 2)];
            return Column(
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _PcaPanel(
                          label: 'Young WT',
                          color: wtGrey,
                          // A and 1 come together between T1 and T3.
                          converge: ease((stage / 1.4).clamp(0.0, 1.0)),
                        ),
                      ),
                      const SizedBox(width: 34),
                      Expanded(
                        child: _PcaPanel(
                          label: 'Young APP-KI',
                          color: appPurple,
                          converge: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(phase,
                    style: tBody.copyWith(fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                Opacity(
                  opacity: (stage - 2).clamp(0.0, 1.0),
                  child: const Callout(
                    'the four cues stay separated all session. Odor-1 is '
                    'never pulled into the rewarded representation, so the '
                    'association is never formed.',
                    lead: 'In APP-KI:',
                    color: appPurple,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

class _PcaPanel extends StatelessWidget {
  const _PcaPanel({
    required this.label,
    required this.color,
    required this.converge,
  });

  final String label;
  final Color color;
  final double converge;

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
            decoration: BoxDecoration(
              border: Border.all(color: hairline, width: 2),
            ),
            child: CustomPaint(
              size: Size.infinite,
              painter: PcaPainter(converge: converge),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// How that distance becomes one number.
// ---------------------------------------------------------------------------

Slide similarityIndex() => Slide(
      duration: const Duration(milliseconds: 2400),
      steps: 2,
      builder: (context) => SlideFrame(
        kicker: 'Figure 2g–i',
        title: 'One number for "are these two cues the same thing?"',
        source: 'Fig. 2g–i · distance against a 1,000-fold trial shuffle',
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: const [
                  Expanded(
                    child: ListPanel(
                      title: 'The measure',
                      at: 0.3,
                      items: [
                        'Euclidean distance between two cue trajectories, '
                            '0.5–1.5 s after cue onset',
                        'Compared against shuffled trial labels; the 95th '
                            'percentile is the threshold',
                        'Similarity index: positive means closer than chance, '
                            'negative means further apart',
                      ],
                    ),
                  ),
                  SizedBox(width: 28),
                  Expanded(
                    child: ListPanel(
                      title: 'The result',
                      color: appPurple,
                      at: 0.55,
                      items: [
                        'WT: A–1 distance drops below shuffle from T2 onward '
                            '— positive SI',
                        'APP-KI: stays above shuffle all session — negative '
                            'SI at every timepoint',
                        'Holds per animal, and again in old mice',
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Anim(
              step: 1,
              from: Offset(0, 18),
              child: Callout(
                'the split is there within the first nine trials — by T1c, '
                'before the animal has had a chance to learn much at all.',
                lead: 'And it is early:',
              ),
            ),
            const SizedBox(height: 14),
            const Anim(
              step: 2,
              from: Offset(0, 18),
              child: Callout(
                'APP-KI mice have twice as many cue-responsive cells '
                '(34% versus 16% at T5) and higher firing rates. More '
                'activity, worse coding.',
                lead: 'Not a quiet cortex:',
                color: abRed,
              ),
            ),
          ],
        ),
      ),
    );
