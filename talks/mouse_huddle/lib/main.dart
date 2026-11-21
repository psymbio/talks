import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import 'slides/closing.dart';
import 'slides/decisions.dart';
import 'slides/figure1.dart';
import 'slides/intro.dart';
import 'slides/methods.dart';
import 'slides/neural.dart';
import 'slides/panels.dart';
import 'slides/silencing.dart';
import 'slides/thermal.dart';
import 'theme.dart';

// Raam et al., Nat Neurosci 29, 901–914 (2026).
// The whole talk at a glance: one function per slide, in order.
// "clicks" = presenter-controlled steps before the deck moves on.
void main() {
  runApp(
    Deck(
      theme: talkTheme,
      slides: [
        // Opening
        title, //              2 clicks: 20 °C → 5 °C, the group gathers
        whyGroups, //          2 clicks: four benefits, then the storm
        whyUnknown,

        // Experimental design
        researchQuestion, //   4 clicks: one question at a time
        methodsOverview, //    1 click:  how each question is answered

        // Figure 1
        thermalAssay, //       1 click:  20 °C versus 5 °C
        sleapTracking, //      2 clicks: landmarks, then identities
        huddleStateWalk, //    4 clicks: 0 → 2:1:1 → 2:2 → 3:1 → 4:0
        fig1_cde,
        fig1_fgh,
        fig1_i,
        fig1_jkl,

        // Figure 2: thermal physiology
        thermalContacts, //    3 clicks: alone → the 1-2-2-3 cluster
        fig2_cde,
        fig2_fq,
        coreTemperature,
        fig2_ry,
        thermalSummary, //     1 click:  what Figure 2 adds up to

        // Figure 3: decisions
        decisions, //          5 clicks: one decision type, then the finding
        fig3_bc,
        fig3_di,
        groupSizeSchematic, // 1 click:  group of four splits into pairs
        fig3_jn,
        fig3_otox,

        // Figure 4: dmPFC encodes huddling
        imaging, //            2 clicks: behaviour, then decision ensembles
        fig4_de,
        fig4_fj,
        fig4_kn,

        // Figure 5: dmPFC encodes the decisions
        fig5_ad,
        fig5_eh,
        fig5_ir,
        decoding, //           2 clicks: cross-decoding, then the limits

        // Figure 6: chemogenetics
        silencing, //          3 clicks: CNO → compensation → conserved
        fig6_ch,
        fig6_io,
        fig6_pv,
        controls,

        // Close
        takeaways,
      ],
    ),
  );
}
