import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';

// ---------------------------------------------------------------------------
// Published panels for Figures 2, 4, 5 and 6. Each slide is a figure crop
// from images/ with the points to make while it is up. Figures 1 and 3 keep
// their panels next to their own animations, in figure1.dart and
// decisions.dart.
// ---------------------------------------------------------------------------

/// One image, one list of points: the shape every panel slide takes.
Slide _panelSlide({
  required String kicker,
  required String title,
  required String source,
  required String file,
  required List<String> points,
  Color color = accent,
}) =>
    Slide(
      duration: const Duration(milliseconds: 2400),
      builder: (context) => SlideFrame(
        kicker: kicker,
        title: title,
        accentColor: color,
        source: source,
        child: Column(
          children: [
            Expanded(child: FigureImage(file)),
            const SizedBox(height: 16),
            Anim(
              at: 0.9,
              child: Bullets(points,
                  start: 0.9, gap: 0.16, style: tNote, color: color),
            ),
          ],
        ),
      ),
    );

// --------------------------------------------------------------- Figure 2 --

Slide fig2_cde() => _panelSlide(
      kicker: 'Figure 2c–e',
      title: 'Bigger huddles mean more contacts, and more contact means '
          'more warmth',
      source: 'Raam et al. 2026, Fig. 2c–e · thermography, n = 20 animals',
      file: 'fig_2_c_d_e.png',
      color: warm,
      points: [
        'Contacts per animal rise with huddle size',
        'More contacts cover a larger fraction of the animal’s perimeter',
        'That fraction correlates with average perimeter temperature',
      ],
    );

Slide fig2_fq() => _panelSlide(
      kicker: 'Figure 2f–q',
      title: 'Contact edges run warmer, and the whole animal follows',
      source: 'Raam et al. 2026, Fig. 2f–q',
      file: 'fig_2_f_to_q.png',
      color: warm,
      points: [
        'Across every huddle size, contact edges are several °C warmer than '
            'exposed ones',
        'Average surface temperature scales with huddle size and with the '
            'number of contacts',
        'Even non-contact edges warm up: the effect spreads beyond the '
            'contact zone itself',
      ],
    );

Slide fig2_ry() => _panelSlide(
      kicker: 'Figure 2r–y',
      title: 'Core temperature holds in a group and falls alone',
      source: 'Raam et al. 2026, Fig. 2r–y · implanted loggers, n = 12',
      file: 'fig_2_r_to_y.png',
      color: passiveColor,
      points: [
        'Alone at 5 °C, core temperature drops by nearly a full degree',
        'In a group it is no different at the end of the session than at '
            'the start',
        'Core temperature does not track huddle size or move at huddle '
            'entry — it is slow, and already protected',
      ],
    );

// --------------------------------------------------------------- Figure 4 --

Slide fig4_de() => _panelSlide(
      kicker: 'Figure 4d,e',
      title: 'Separate dmPFC cells for huddling, rest and investigation',
      source: 'Raam et al. 2026, Fig. 4d,e · 5,141 neurons from 11 animals',
      file: 'fig_4_d_e.png',
      color: accentBlue,
      points: [
        'Cells selective for huddling respond at huddle onset and not during '
            'the other two behaviours',
        'Rest is the control for immobility, social investigation the control '
            'for contact — huddling is neither',
      ],
    );

Slide fig4_fj() => _panelSlide(
      kicker: 'Figure 4f–j',
      title: 'Those populations barely overlap, and decode above chance',
      source: 'Raam et al. 2026, Fig. 4f–j · SVM, leave-one-out '
          'cross-validation',
      file: 'fig_4_f_to_j.png',
      color: accentBlue,
      points: [
        'The three responsive populations are largely non-overlapping',
        'Every pairwise decoder beats chance, and so does the three-way one',
      ],
    );

Slide fig4_kn() => _panelSlide(
      kicker: 'Figure 4k–n',
      title: 'Population activity separates by behaviour',
      source: 'Raam et al. 2026, Fig. 4k–n · LDA on population vectors',
      file: 'fig_4_k_to_n.png',
      color: accentBlue,
      points: [
        'Projected into LD space, bouts cluster by behaviour type',
        'Distances between behaviours exceed distances within one, so this '
            'is not trial-to-trial noise',
      ],
    );

// --------------------------------------------------------------- Figure 5 --

Slide fig5_ad() => _panelSlide(
      kicker: 'Figure 5a–d',
      title: 'Entry: active, passive and running use different cells',
      source: 'Raam et al. 2026, Fig. 5a–d · running bouts speed-matched '
          'to active entry',
      file: 'fig_5_a_to_d.png',
      color: activeColor,
      points: [
        'Active entry, passive entry and speed-matched running overlap very '
            'little',
        'Speed matching is what rules out "this is just locomotion"',
      ],
    );

Slide fig5_eh() => _panelSlide(
      kicker: 'Figure 5e–h',
      title: 'Exit looks the same: three separate populations',
      source: 'Raam et al. 2026, Fig. 5e–h',
      file: 'fig_5_e_to_h.png',
      color: activeColor,
      points: [
        'Active exit, passive exit and running are again largely distinct',
        'Each set responds to its own event and not to the others',
      ],
    );

Slide fig5_ir() => _panelSlide(
      kicker: 'Figure 5i–r',
      title: 'Decoders tell the decisions apart — with one exception',
      source: 'Raam et al. 2026, Fig. 5i–r',
      file: 'fig_5_i_to_r.png',
      color: activeColor,
      points: [
        'Active versus passive decodes above chance, and performance rises '
            'seconds before the behaviour starts',
        'Passive entry versus passive exit sits at chance: in both the change '
            'is driven by somebody else',
        'LDA agrees — every pair separates except those two',
      ],
    );

// --------------------------------------------------------------- Figure 6 --

Slide fig6_ch() => _panelSlide(
      kicker: 'Figure 6c–h',
      title: 'Silencing two animals leaves group huddling untouched',
      source: 'Raam et al. 2026, Fig. 6c–h · n = 6 groups',
      file: 'fig_6_c_to_h.png',
      color: cnoColor,
      points: [
        'No change in any of the five group states between all-saline and '
            'two-CNO sessions',
        'No change in how long each individual spends huddling',
      ],
    );

Slide fig6_io() => _panelSlide(
      kicker: 'Figure 6i–o',
      title: 'But the decisions move — and the partners move the other way',
      source: 'Raam et al. 2026, Fig. 6i–o · within-animal comparisons',
      file: 'fig_6_i_to_o.png',
      color: cnoColor,
      points: [
        'CNO animals make about 25% fewer active entries and exits',
        'Their saline partners make about 25% more, so the group total is '
            'unchanged',
        'Active entry and active exit stay correlated within animal in every '
            'condition',
      ],
    );

Slide fig6_pv() => _panelSlide(
      kicker: 'Figure 6p–v',
      title: 'Nothing else about the animal changed',
      source: 'Raam et al. 2026, Fig. 6p–v',
      file: 'fig_6_p_to_v.png',
      color: salColor,
      points: [
        'Open field: locomotion and time in the centre are unaffected at '
            'room temperature and at 5 °C',
        'Brown adipose tissue temperature is unaffected — autonomic '
            'thermogenesis is intact',
        'Warm-corner seeking in the thermotaxis assay is unaffected',
      ],
    );
