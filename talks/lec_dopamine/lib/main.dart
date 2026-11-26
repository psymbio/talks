import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import 'slides/behaviour.dart';
import 'slides/closing.dart';
import 'slides/dopamine.dart';
import 'slides/encoding.dart';
import 'slides/intro.dart';
import 'slides/panels.dart';
import 'slides/rescue.dart';
import 'theme.dart';

// Nakagawa et al., Nat Neurosci 29, 1386–1396 (2026).
// The whole talk at a glance: one function per slide, in order.
// "clicks" = presenter-controlled steps before the deck moves on.
//
// The list lives apart from main() so the PNG exporter in lib/export_web.dart
// can walk the same deck.
const deckSlides = <SlideFn>[
  // Opening
  title, //                2 clicks: dopamine grows in, then amyloid
  whyEntorhinal, //        1 click
  theGap, //               1 click
  questions, //            4 clicks: one question at a time
  task, //                 3 clicks: trial structure, then the four cues

  // Figure 1 — the behaviour
  amyloidProgression, //   3 clicks: 2 → 6 → 12 months
  learningCurves, //       2 clicks: WT draws, then APP-KI
  fig1_cde,
  fig1_fgh,

  // Figure 2 — what the LEC stops doing
  generalizationIdea, //   2 clicks: the A/1 cell, then the B/1 cell
  fig2_bc,
  fig2_d,
  generalizationPca, //    3 clicks: T1 → T3 → T5
  fig2_ef,
  similarityIndex, //      2 clicks
  fig2_ghi,

  // Figure 3 — the axons are intact
  axonsSpared, //          2 clicks
  fig3_ab,
  fig3_cd,

  // Figure 4 — the release fails
  photometry, //           4 clicks: one condition per click
  fig4_bc,
  fig4_def,

  // Figures 5 and 6 — putting it back
  optogenetics, //         2 clicks: laser on, then the specificity control
  fig5_panel,
  ldopaBehaviour, //       2 clicks: saline draws, then L-DOPA
  fig6_abc,
  ldopaEncoding, //        2 clicks: the trajectories reconverge
  fig6_efghi,
  fig6_jkl,

  // Close
  theChain, //             4 clicks: plaque → dopamine → coding → memory
  soWhat, //               2 clicks
];

void main() => runApp(Deck(theme: talkTheme, slides: deckSlides));
