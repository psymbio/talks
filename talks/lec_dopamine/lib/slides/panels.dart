import 'package:deck_engine/deck_engine.dart';

import '../theme.dart';
import '../widgets/frame.dart';

// ---------------------------------------------------------------------------
// The published panels. Crops go in images/ under the names below; a file the
// deck cannot find shows a labelled box rather than crashing.
// ---------------------------------------------------------------------------

Slide fig1_cde() => panelSlide(
      kicker: 'Figure 1c–e',
      title: 'Young: the old association holds, the new one does not',
      source: 'Nakagawa et al. 2026, Fig. 1c–e · n = 11 WT, 16 APP-KI',
      file: 'fig_1_c_d_e.png',
      points: [
        'Novel odors: 90.6% correct at T5 in WT versus 78.6% in APP-KI',
        'Prelearned odors: no difference at all',
        'Fewer sessions reach the 80% criterion in APP-KI (59% versus 78%)',
      ],
    );

Slide fig1_fgh() => panelSlide(
      kicker: 'Figure 1f–h',
      title: 'Old: the same deficit, deeper',
      source: 'Nakagawa et al. 2026, Fig. 1f–h · n = 11 WT, 14 APP-KI, '
          '7–11 months',
      file: 'fig_1_f_g_h.png',
      points: [
        'Novel odors fall to 67.9% in old APP-KI against 84.9% in WT',
        'Old WT decline slightly too — this is ageing on top of genotype',
        'Prelearned performance is still untouched',
      ],
    );

Slide fig2_bc() => panelSlide(
      kicker: 'Figure 2b,c',
      title: 'The example cells',
      source: 'Nakagawa et al. 2026, Fig. 2b,c',
      file: 'fig_2_b_c.png',
      points: [
        'WT: an Odor-A cell at T1 that has become an A/1 cell by T5',
        'APP-KI: a B/1 cell — punished Odor-B and rewarded Odor-1 share a '
            'representation',
      ],
    );

Slide fig2_d() => panelSlide(
      kicker: 'Figure 2d',
      title: 'Twice as many cue-responsive cells, coding worse',
      source: 'Nakagawa et al. 2026, Fig. 2d · 423 WT and 636 APP-KI cells',
      file: 'fig_2_d.png',
      points: [
        '16% of LEC layer 2/3 cells respond to a cue at T5 in WT, 34% in '
            'APP-KI',
        'The excess is largest among Odor-A responsive cells',
      ],
      color: appPurple,
    );

Slide fig2_ef() => panelSlide(
      kicker: 'Figure 2e,f',
      title: 'The published trajectories',
      source: 'Nakagawa et al. 2026, Fig. 2e,f · heatmaps, PCA and distance',
      file: 'fig_2_e_f.png',
      points: [
        'WT: A and 1 start apart at T1 and are together by T3',
        'APP-KI: all four cues stay separated through T5',
      ],
    );

Slide fig2_ghi() => panelSlide(
      kicker: 'Figure 2g–i',
      title: 'Distance, similarity index and the bootstrap',
      source: 'Nakagawa et al. 2026, Fig. 2g–i · 1,000 bootstraps',
      file: 'fig_2_g_h_i.png',
      points: [
        'WT A–1 distance drops below the shuffle line from T2',
        'APP-KI stays above it, giving a negative SI at every timepoint',
        'The difference is significant from the first nine trials onward',
      ],
      color: appPurple,
    );

Slide fig3_ab() => panelSlide(
      kicker: 'Figure 3a,b',
      title: 'Plaques sit on the dopamine neurons',
      source: 'Nakagawa et al. 2026, Fig. 3a,b · TH and Aβ, n = 12 mice',
      file: 'fig_3_a_b.png',
      points: [
        'Aβ overlaps dopamine cell bodies in the VTA and SNc, and fibres in '
            'the LEC',
        'Density is higher in SNc than in VTA',
      ],
      color: abRed,
    );

Slide fig3_cd() => panelSlide(
      kicker: 'Figure 3c,d',
      title: 'But fibre density in the LEC is unchanged',
      source: 'Nakagawa et al. 2026, Fig. 3c,d · n = 8 young, 6 old per '
          'strain',
      file: 'fig_3_c_d.png',
      points: [
        'No effect of strain, of age, or of the two together',
        'Dopamine neuron counts in VTA and SNc are also unchanged',
        'So the deficit ahead is functional, not degenerative',
      ],
      color: dopamineGreen,
    );

Slide fig4_bc() => panelSlide(
      kicker: 'Figure 4b,c',
      title: 'Example photometry sessions',
      source: 'Nakagawa et al. 2026, Fig. 4b,c',
      file: 'fig_4_b_c.png',
      points: [
        'WT correct: Odor-1 dopamine from T1, sustained through the delay',
        'APP-KI correct: Odor-1 appears only from T3',
        'Both error conditions: no Odor-1 signal, Odor-A intact',
      ],
      color: dopamineGreen,
    );

Slide fig4_def() => panelSlide(
      kicker: 'Figure 4d–f',
      title: 'Across animals, the loss is specific to Odor-1 at T1',
      source: 'Nakagawa et al. 2026, Fig. 4d–f · 10 WT and 8 APP-KI '
          'hemispheres',
      file: 'fig_4_d_e_f.png',
      points: [
        'Odor-1 at T1 is significantly lower in APP-KI, in all sessions and '
            'in correct ones',
        'Odor-A and Odor-B do not differ',
        'In error sessions there is nothing left to differ',
      ],
      color: dopamineGreen,
    );

Slide fig5_panel() => panelSlide(
      kicker: 'Figure 5',
      title: 'The optogenetic rescue',
      source: 'Nakagawa et al. 2026, Fig. 5 · n = 11 young APP-KI mice',
      file: 'fig_5_a_b_c_d.png',
      points: [
        'Laser from Odor-1 cue onset, 5 s plus a taper',
        '95.2% versus 77.9% correct at T5; 87% versus 50% of sessions at '
            'criterion',
      ],
      color: laserBlue,
    );

Slide fig6_abc() => panelSlide(
      kicker: 'Figure 6a–c',
      title: 'The L-DOPA rescue',
      source: 'Nakagawa et al. 2026, Fig. 6a–c · n = 8 saline, 9 L-DOPA',
      file: 'fig_6_a_b_c.png',
      points: [
        '82.6% versus 67.1% correct at T5',
        '79% of sessions reach criterion against 33% on saline',
      ],
      color: ldopaGreen,
    );

Slide fig6_efghi() => panelSlide(
      kicker: 'Figure 6e–i',
      title: 'Coding restored: the trajectories come back together',
      source: 'Nakagawa et al. 2026, Fig. 6e–i · 132 saline and 144 L-DOPA '
          'cells',
      file: 'fig_6_e_f_g_h_i.png',
      points: [
        'Saline: A and 1 separated, SI negative',
        'L-DOPA: distance below shuffle, SI above zero from trials 7–9',
      ],
      color: ldopaGreen,
    );

Slide fig6_jkl() => panelSlide(
      kicker: 'Figure 6j–l',
      title: 'The same rescue in a tau model',
      source: 'Nakagawa et al. 2026, Fig. 6j–l · PS19 mice, n = 5 per group',
      file: 'fig_6_j_k_l.png',
      points: [
        'L-DOPA lifts novel-odor performance in PS19 tau mice as well',
        'No effect in WT controls',
        'So the mechanism is not specific to amyloid',
      ],
      color: ldopaGreen,
    );
