import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';

// ---------------------------------------------------------------------------
// Slide 3 — the questions. Four clicks, one question each, so the talk can
// pause on whichever matters most to the room.
// ---------------------------------------------------------------------------

class _Question {
  const _Question(this.number, this.text, this.aside, this.color);

  final String number;
  final String text;
  final String aside;
  final Color color;
}

const _questions = [
  _Question('1', 'Does huddling actually keep a mouse warm?',
      'and does group size change that', warm),
  _Question('2', 'What decisions build a huddle?',
      'who moves, and who waits', activeColor),
  _Question('3', 'Does the dmPFC carry those decisions?',
      'separately from simply moving', accent),
  _Question('4', 'Is the dmPFC needed for them?',
      'and what does the rest of the group do', cnoColor),
];

Slide researchQuestion() => Slide(
      duration: const Duration(milliseconds: 1800),
      steps: 4,
      stepDuration: const Duration(milliseconds: 700),
      builder: (context) => SlideFrame(
        kicker: 'Experimental design · 1 of 2',
        title: 'Four questions',
        source: 'Groups of four co-housed C57BL/6J mice · 5 °C versus 20 °C',
        child: StageBuilder(
          builder: (context, stage) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, q) in _questions.indexed)
                Expanded(child: _QuestionRow(q, (stage - i).clamp(0.0, 1.0))),
            ],
          ),
        ),
      ),
    );

class _QuestionRow extends StatelessWidget {
  const _QuestionRow(this.question, this.lit);

  final _Question question;
  final double lit;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.22 + 0.78 * lit,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: question.color, width: 7),
            bottom: const BorderSide(color: hairline, width: 2),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Text(
                question.number,
                style: tH1.copyWith(fontSize: 58, color: question.color),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: tH2.copyWith(fontSize: 42),
                  ),
                  Text(question.aside, style: tSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Slide 4 — how each question is answered. One line per method, no prose.
// ---------------------------------------------------------------------------

const _methods = [
  ('1', 'Thermography and implanted temperature loggers', warm),
  ('2', 'SLEAP pose tracking, then frame-by-frame scoring', activeColor),
  ('3', 'Miniscope calcium imaging in dmPFC, then decoding', accent),
  ('4', 'Chemogenetic silencing of dmPFC in two of four mice', cnoColor),
];

Slide methodsOverview() => Slide(
      duration: const Duration(milliseconds: 2600),
      steps: 1,
      builder: (context) => SlideFrame(
        kicker: 'Experimental design · 2 of 2',
        title: 'How each one is answered',
        source: 'Methods · all measures taken in the same animals',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                children: [
                  for (final (i, m) in _methods.indexed)
                    Expanded(
                      child: Anim(
                        at: 0.3 + i * 0.2,
                        from: const Offset(-30, 0),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: fade(m.$3, 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                m.$1,
                                style: tBody.copyWith(
                                    color: m.$3, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 28),
                            Expanded(child: Text(m.$2, style: tLead)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Anim(
              at: 1.3,
              child: Row(
                children: [
                  for (final step in const [
                    'Behaviour',
                    'Recording',
                    'Decoding',
                    'Silencing',
                    'Physiology',
                  ]) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          border: Border(
                              top: BorderSide(color: hairline, width: 2)),
                        ),
                        child: Text(step,
                            style: tSmall.copyWith(color: ink)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Anim(
              step: 1,
              from: Offset(0, 18),
              child: Callout(
                'Imaging asks what the dmPFC represents; silencing asks '
                'whether the group still needs it',
                style: tNote,
              ),
            ),
          ],
        ),
      ),
    );
