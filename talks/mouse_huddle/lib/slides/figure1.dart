import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../states.dart';
import '../theme.dart';
import '../widgets/frame.dart';
import '../widgets/mouse.dart';

// ---------------------------------------------------------------------------
// Fig. 1a — 20 °C versus 5 °C. One click brings in the cold condition.
// ---------------------------------------------------------------------------

Slide thermalAssay() => Slide(
      duration: const Duration(milliseconds: 2400),
      steps: 1,
      stepDuration: const Duration(milliseconds: 1200),
      builder: (context) => SlideFrame(
        kicker: 'Figure 1a',
        title: 'The thermal challenge assay',
        source: 'Illustration after Fig. 1a',
        child: Row(
          children: [
            Expanded(
              child: Anim(
                at: 0.3,
                dur: 0.8,
                scale: 0.95,
                child: const _Condition(
                  temp: '20 °C',
                  caption: 'Control. Mice stay apart; contacts are brief '
                      'and mostly in twos.',
                  stateIndex: 0,
                  fill: warmTint,
                  border: ink,
                  accentColor: muted,
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: Anim(
                at: 0.8,
                child: Text(
                  'versus',
                  textAlign: TextAlign.center,
                  style: tBody.copyWith(color: muted),
                ),
              ),
            ),
            Expanded(
              child: Anim(
                step: 1,
                scale: 0.95,
                child: const _Condition(
                  temp: '5 °C',
                  caption: 'Thermal challenge. The group gathers into '
                      'huddles of three and four.',
                  stateIndex: 4,
                  fill: coldTint,
                  border: cold,
                  accentColor: cold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

class _Condition extends StatelessWidget {
  const _Condition({
    required this.temp,
    required this.caption,
    required this.stateIndex,
    required this.fill,
    required this.border,
    required this.accentColor,
  });

  final String temp;
  final String caption;
  final int stateIndex;
  final Color fill;
  final Color border;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(temp,
            style: tH2.copyWith(fontSize: 48, color: accentColor)),
        const SizedBox(height: 18),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: CustomPaint(
              painter: ArenaPainter(
                mice: huddleStates[stateIndex],
                fill: fill,
                border: border,
                borderWidth: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(caption, textAlign: TextAlign.center, style: tNote),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Fig. 1b, left — SLEAP pose estimation and identity tracking.
// Click 1 drops the landmarks on, click 2 colours the four identities.
// ---------------------------------------------------------------------------

const _idColors = [
  Color(0xFF3DA5F5),
  Color(0xFFFFA23A),
  Color(0xFF3BB44A),
  Color(0xFFB079F0),
];

Slide sleapTracking() => Slide(
      duration: const Duration(milliseconds: 2400),
      steps: 2,
      stepDuration: const Duration(milliseconds: 1100),
      builder: (context) => SlideFrame(
        kicker: 'Figure 1b',
        title: 'SLEAP: pose estimation and identity tracking',
        source: 'Illustration after Fig. 1b and Extended Data Fig. 1c',
        child: Row(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: StageBuilder(
                builder: (context, stage) {
                  final nodes = stage.clamp(0.0, 1.0);
                  final ids = (stage - 1).clamp(0.0, 1.0);
                  return CustomPaint(
                    size: Size.infinite,
                    painter: ArenaPainter(
                      mice: [
                        for (final (i, m) in huddleStates[3].indexed)
                          m.copyWith(
                            skeleton: nodes > 0.5,
                            halo: ids > 0.05
                                ? fade(_idColors[i], ids)
                                : null,
                          ),
                      ],
                      fill: coldTint,
                      border: cold,
                      borderWidth: 12,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 70),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Bullets([
                    'A neural network trained on hand-labelled frames of four '
                        'interacting, often overlapping mice',
                  ]),
                  Anim(
                    step: 1,
                    from: const Offset(0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Five landmarks per animal, every frame:',
                          style: tNote,
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 14,
                          runSpacing: 12,
                          children: [
                            for (final name in mouseNodes.keys)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                decoration: BoxDecoration(
                                  color: card,
                                  borderRadius: BorderRadius.circular(40),
                                  border:
                                      Border.all(color: hairline, width: 2),
                                ),
                                child: Text(name, style: tSmall),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),
                  Anim(
                    step: 2,
                    from: const Offset(0, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            for (final (i, c) in _idColors.indexed)
                              Container(
                                margin: const EdgeInsets.only(right: 14),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 8),
                                decoration: BoxDecoration(
                                  color: fade(c, 0.16),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Text(
                                  'mouse ${i + 1}',
                                  style: tSmall.copyWith(
                                      color: ink,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Callout(
                          'Identities are held through contact, so huddle '
                          'membership — not just huddle size — is known '
                          'frame by frame',
                          style: tNote,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Fig. 1b, right — the five group states. Four clicks walk from dispersed to
// fully aggregated, cooling the arena as they go. This is the matplotlib
// prototype, rebuilt as a click-driven slide.
// ---------------------------------------------------------------------------

Slide huddleStateWalk() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 4,
      stepDuration: const Duration(milliseconds: 2400),
      builder: (context) => SlideFrame(
        kicker: 'Figure 1b–e',
        title: 'Five group states, most dispersed to most aggregated',
        source: 'Illustration after Fig. 1b; state colours as published',
        child: StageBuilder(
          builder: (context, stage) {
            final index = stage.round().clamp(0, 4);
            final chill = (stage / 4).clamp(0.0, 1.0);
            final temp = stateTemps.first +
                (stateTemps.last - stateTemps.first) * chill;
            return Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CustomPaint(
                          size: Size.infinite,
                          painter: ArenaPainter(
                            mice: lerpStates(huddleStates, stage),
                            fill: Color.lerp(warmTint, coldTint, chill)!,
                            border: lerpColors(stateColors, stage),
                            borderWidth: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 60),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  stateNames[index],
                                  style: tH1.copyWith(
                                    fontSize: 104,
                                    color: stateColors[index],
                                  ),
                                ),
                                const SizedBox(width: 26),
                                Text(
                                  '${temp.round()} °C',
                                  style: tH2.copyWith(
                                    color: Color.lerp(warm, cold, chill),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              stateSubtitles[index],
                              style: tLead.copyWith(color: muted),
                            ),
                            const SizedBox(height: 26),
                            SizedBox(
                              width: 620,
                              child: Text(stateNotes[index], style: tBody),
                            ),
                            const SizedBox(height: 34),
                            const Anim(
                              at: 0.8,
                              child: Callout(
                                'Over a 45-minute session at 5 °C the dispersed '
                                'state falls to nearly zero while 3:1 and 4:0 '
                                'take over',
                                style: tNote,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 170,
                  child: Row(
                    children: [
                      for (var i = 0; i < huddleStates.length; i++) ...[
                        if (i > 0) const SizedBox(width: 18),
                        Expanded(child: _StateChip(i, focusAt(stage, i))),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

class _StateChip extends StatelessWidget {
  const _StateChip(this.index, this.focus);

  final int index;
  final double focus;

  @override
  Widget build(BuildContext context) {
    final color = stateColors[index];
    return Opacity(
      opacity: 0.4 + 0.6 * focus,
      child: Row(
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              painter: ArenaPainter(
                mice: huddleStates[index],
                fill: Color.lerp(warmTint, coldTint, index / 4)!,
                border: color,
                borderWidth: 6,
                mouseLength: 0.22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stateNames[index],
                  style: tBody.copyWith(
                      fontWeight: FontWeight.w700, color: color),
                ),
                Text(stateSubtitles[index], style: tSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Published panels. Drop the real crops into images/ with these names and
// they appear here; placeholders ship in the repo meanwhile.
// ---------------------------------------------------------------------------

Slide fig1_cde() => Slide(
      duration: const Duration(milliseconds: 2200),
      builder: (context) => const SlideFrame(
        kicker: 'Figure 1c–e',
        title: 'Cold shifts the group into longer, larger huddles',
        source: 'Raam et al. 2026, Fig. 1c–e · n = 6 groups of four',
        child: Column(
          children: [
            Expanded(child: FigureImage('fig_1_c_d_e.png')),
            SizedBox(height: 18),
            Anim(
              at: 0.9,
              child: Bullets([
                'At 5 °C the dispersed state loses time and duration; 3:1 and '
                    '4:0 gain both',
                'The 2:2 state stays rare — when all four want to huddle they '
                    'do it as one group',
                'State frequencies drift across the session: 0 and 2:1:1 fade, '
                    '3:1 and 4:0 take over',
              ], start: 0.9, gap: 0.18, style: tNote),
            ),
          ],
        ),
      ),
    );

Slide fig1_fgh() => Slide(
      duration: const Duration(milliseconds: 2200),
      builder: (context) => const SlideFrame(
        kicker: 'Figure 1f–h',
        title: 'Huddling replaces investigation, and transitions open up',
        source: 'Raam et al. 2026, Fig. 1f–h',
        child: Column(
          children: [
            Expanded(child: FigureImage('fig_1_f_g_h.png')),
            SizedBox(height: 18),
            Anim(
              at: 0.9,
              child: Bullets([
                'Social investigation dominates at 20 °C; huddling dominates '
                    'at 5 °C',
                'At 20 °C almost every transition runs between 0 and 2:1:1',
                'At 5 °C the group moves through a much broader range of '
                    'transitions, including between aggregated states',
              ], start: 0.9, gap: 0.18, style: tNote),
            ),
          ],
        ),
      ),
    );

/// Fig. 1i is not among the exported panels, so the design is drawn here
/// instead: the same animals as a group of four, as pairs, and as pairs in
/// a half-size box.
Slide fig1_i() => Slide(
      duration: const Duration(milliseconds: 2600),
      builder: (context) => SlideFrame(
        kicker: 'Figure 1i',
        title: 'Testing group size while holding density constant',
        source: 'Illustration after Fig. 1i · 1,600 cm² and 800 cm² boxes',
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Anim(
                      at: 0.3,
                      scale: 0.94,
                      child: const _DesignBox(
                        label: 'Group of 4',
                        area: 'Area: 1,600 cm²',
                        stateIndex: 3,
                        size: 1.0,
                      ),
                    ),
                  ),
                  const _Swap(at: 0.6),
                  Expanded(
                    child: Anim(
                      at: 0.6,
                      scale: 0.94,
                      child: const _DesignBox(
                        label: 'Group of 2',
                        area: 'Area: 1,600 cm²',
                        stateIndex: 1,
                        size: 1.0,
                        pairOnly: true,
                      ),
                    ),
                  ),
                  const _Swap(at: 0.9),
                  Expanded(
                    child: Anim(
                      at: 0.9,
                      scale: 0.94,
                      child: const _DesignBox(
                        label: 'Group of 2, small box',
                        area: 'Area: 800 cm²',
                        stateIndex: 1,
                        size: 0.7,
                        pairOnly: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Anim(
              at: 1.4,
              from: Offset(0, 20),
              child: IdeaBand(
                'the half-size box keeps animals per unit area constant, so '
                'any difference in huddling is not crowding',
                lead: 'Control:',
              ),
            ),
          ],
        ),
      ),
    );

class _Swap extends StatelessWidget {
  const _Swap({required this.at});

  final double at;

  @override
  Widget build(BuildContext context) => Anim(
        at: at,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Icon(Icons.swap_horiz_rounded, size: 40, color: muted),
        ),
      );
}

class _DesignBox extends StatelessWidget {
  const _DesignBox({
    required this.label,
    required this.area,
    required this.stateIndex,
    required this.size,
    this.pairOnly = false,
  });

  final String label;
  final String area;
  final int stateIndex;

  /// Relative edge length, so the small box reads as half the area.
  final double size;

  /// Hide the two animals that are not in the pair.
  final bool pairOnly;

  @override
  Widget build(BuildContext context) {
    final mice = [
      for (final (i, m) in huddleStates[stateIndex].indexed)
        if (!pairOnly || i < 2) m,
    ];
    // The arena takes whatever height is left after the two labels, and the
    // small box is drawn at 70% of that edge — about half the area.
    return Column(
      children: [
        Text(label, style: tBody.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Expanded(
          child: Center(
            child: FractionallySizedBox(
              widthFactor: size,
              heightFactor: size,
              child: AspectRatio(
                aspectRatio: 1,
                child: CustomPaint(
                  painter: ArenaPainter(
                    mice: mice,
                    fill: coldTint,
                    border: boxLine,
                    borderWidth: 8,
                    snowflake: true,
                    mouseLength: 0.21 / size,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(area, style: tSmall),
      ],
    );
  }
}

Slide fig1_jkl() => Slide(
      duration: const Duration(milliseconds: 2400),
      builder: (context) => const SlideFrame(
        kicker: 'Figure 1j–l',
        title: 'Groups of four huddle more than their pairs predict',
        source: 'Raam et al. 2026, Fig. 1j–l',
        child: Column(
          children: [
            Expanded(child: FigureImage('fig_1_j_k_l.png')),
            SizedBox(height: 18),
            Anim(
              at: 0.9,
              child: Bullets([
                'Each mouse spends about three times as long in huddles in a '
                    'group of four as in a pair',
                'A given pair huddles together more when the other two are '
                    'present',
                'The extra time is in huddles of three and four, not in more '
                    'pairs — huddling is emergent',
              ], start: 0.9, gap: 0.18, style: tNote),
            ),
          ],
        ),
      ),
    );