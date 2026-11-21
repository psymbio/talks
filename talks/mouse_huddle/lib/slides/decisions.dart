import 'dart:math' as math;

import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/frame.dart';
import '../widgets/mouse.dart';

// ---------------------------------------------------------------------------
// Fig. 3a — the four decision types, animated. Each click plays one panel:
// the pale silhouette is where the moving animal started, the arrow is its
// path, and the pink dot marks the subject being scored.
//
// Every scene resolves to a huddle of three, the size the paper's own
// schematic uses.
// ---------------------------------------------------------------------------

const _arenaFill = Color(0xFFE4E7EA);

/// Slots in a three-animal huddle, and the two corners animals come from.
const _slotL = (pos: Offset(0.40, 0.44), angle: -90.0);
const _slotR = (pos: Offset(0.56, 0.44), angle: 90.0);
const _slotB = (pos: Offset(0.48, 0.60), angle: -90.0);
const _cornerLow = (pos: Offset(0.22, 0.82), angle: -40.0);
const _cornerHigh = (pos: Offset(0.82, 0.18), angle: 150.0);

class _Actor {
  const _Actor({
    required this.from,
    required this.to,
    this.subject = false,
    this.moves = false,
  });

  final ({Offset pos, double angle}) from;
  final ({Offset pos, double angle}) to;
  final bool subject;
  final bool moves;

  bool get still => from.pos == to.pos;
}

class _Scene {
  const _Scene(this.title, this.caption, this.color, this.actors);

  final String title;
  final String caption;
  final Color color;
  final List<_Actor> actors;
}

/// A bystander that never moves, so each box holds four animals as in the
/// published schematic.
const _bystander = _Actor(
  from: (pos: Offset(0.18, 0.20), angle: 20.0),
  to: (pos: Offset(0.18, 0.20), angle: 20.0),
);

const _scenes = [
  _Scene(
    'Active entry',
    'The subject approaches a pair and joins it. Speed is high, then drops '
        'the moment it lands in the huddle.',
    activeColor,
    [
      _Actor(from: _slotL, to: _slotL),
      _Actor(from: _slotR, to: _slotR),
      _Actor(from: _cornerLow, to: _slotB, subject: true, moves: true),
      _bystander,
    ],
  ),
  _Scene(
    'Passive entry',
    'The subject stays where it is and a partner comes to it. Its speed '
        'never changes.',
    passiveColor,
    [
      _Actor(from: _slotL, to: _slotL),
      _Actor(from: _slotB, to: _slotB, subject: true),
      _Actor(from: _cornerHigh, to: _slotR, moves: true),
      _bystander,
    ],
  ),
  _Scene(
    'Active exit',
    'The subject leaves the huddle of its own accord, and its speed jumps '
        'as it goes.',
    activeColor,
    [
      _Actor(from: _slotL, to: _slotL),
      _Actor(from: _slotR, to: _slotR),
      _Actor(from: _slotB, to: _cornerLow, subject: true, moves: true),
      _bystander,
    ],
  ),
  _Scene(
    'Passive exit',
    'The subject holds its place and a partner leaves, breaking the huddle '
        'around it.',
    passiveColor,
    [
      _Actor(from: _slotL, to: _cornerHigh, moves: true),
      _Actor(from: _slotR, to: _slotR),
      _Actor(from: _slotB, to: _slotB, subject: true),
      _bystander,
    ],
  ),
];

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.scene, this.progress);

  final _Scene scene;

  /// 0 = before the decision, 1 = after it.
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final box = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(box, Paint()..color = _arenaFill);
    canvas.save();
    canvas.clipRect(box);

    final s = size.width * 0.19;
    final p = ease(progress.clamp(0.0, 1.0));
    Offset px(Offset u) => Offset(u.dx * size.width, u.dy * size.height);

    for (final actor in scene.actors) {
      if (actor.moves) {
        // Where it started, in pale grey.
        paintMouse(canvas, px(actor.from.pos), deg(actor.from.angle), s,
            ghost: true, opacity: 1 - 0.35 * p);
      }
    }

    for (final actor in scene.actors) {
      final pos = Offset.lerp(px(actor.from.pos), px(actor.to.pos), p)!;
      final angle = lerpAngle(deg(actor.from.angle), deg(actor.to.angle), p);
      paintMouse(canvas, pos, angle, s, subject: actor.subject);

      if (actor.moves && p > 0.04) {
        final start = px(actor.from.pos);
        final dir = (pos - start);
        if (dir.distance > s * 0.5) {
          final unit = dir / dir.distance;
          paintArrow(
            canvas,
            start + unit * s * 0.55,
            pos - unit * s * 0.62,
            color: ink,
            width: size.width * 0.009,
            opacity: math.min(1, p * 2),
          );
        }
      }
    }

    canvas.restore();
    canvas.drawRect(
      box,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = ink,
    );
  }

  @override
  bool shouldRepaint(_ScenePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _ScenePanel extends StatelessWidget {
  const _ScenePanel(this.index);

  final int index;

  @override
  Widget build(BuildContext context) {
    final scene = _scenes[index];
    return StageBuilder(
      builder: (context, stage) {
        final progress = (stage - index).clamp(0.0, 1.0);
        final lit = ((stage - index) * 3).clamp(0.0, 1.0);
        return Opacity(
          opacity: 0.4 + 0.6 * lit,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                color: fade(scene.color, 0.16),
                child: Text(
                  scene.title,
                  style: tBody.copyWith(
                      fontWeight: FontWeight.w600, fontSize: 29),
                ),
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CustomPaint(
                    painter: _ScenePainter(scene, progress),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 128,
                child: Text(scene.caption, style: tSmall.copyWith(color: ink)),
              ),
            ],
          ),
        );
      },
    );
  }
}

Slide decisions() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 5,
      stepDuration: const Duration(milliseconds: 1600),
      builder: (context) => SlideFrame(
        kicker: 'Figure 3a',
        title: 'Four ways to enter or leave a huddle',
        accentColor: activeColor,
        source: 'Illustration after Fig. 3a · pale shape = where the mover '
            'started',
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: subjectPink,
                  ),
                ),
                const SizedBox(width: 12),
                const Text('subject animal', style: tSmall),
                const SizedBox(width: 40),
                Text(
                  'self-initiated = active',
                  style: tSmall.copyWith(color: activeColor),
                ),
                const SizedBox(width: 28),
                Text(
                  'partner-initiated = passive',
                  style: tSmall.copyWith(color: passiveColor),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < _scenes.length; i++) ...[
                    if (i > 0) const SizedBox(width: 26),
                    Expanded(child: _ScenePanel(i)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Anim(
              step: 5,
              from: Offset(0, 18),
              child: Callout(
                'Most decisions are active, and each animal keeps a stable '
                'active or passive role — independent of social rank, and '
                'the same with unfamiliar partners',
                style: tNote,
                color: activeColor,
              ),
            ),
          ],
        ),
      ),
    );

// ---------------------------------------------------------------------------
// Fig. 3j — the group-size schematic, animated: a group of four splits into
// two pairs and comes back together.
// ---------------------------------------------------------------------------

const _groupOfFour = [
  MouseSpec(Offset(0.44, 0.46), -1.5708),
  MouseSpec(Offset(0.58, 0.46), 1.5708),
  MouseSpec(Offset(0.46, 0.62), -1.5708),
  MouseSpec(Offset(0.60, 0.62), 1.5708),
];

const _pairLeft = [
  MouseSpec(Offset(0.40, 0.52), -1.5708),
  MouseSpec(Offset(0.54, 0.52), 1.5708),
];

Slide groupSizeSchematic() => Slide(
      duration: const Duration(milliseconds: 1600),
      steps: 1,
      stepDuration: const Duration(milliseconds: 1600),
      builder: (context) => SlideFrame(
        kicker: 'Figure 3j',
        title: 'The same animals, tested as four and as two',
        accentColor: activeColor,
        source: 'Illustration after Fig. 3j · both boxes at 5 °C',
        child: StageBuilder(
          builder: (context, stage) {
            final split = ease(stage.clamp(0.0, 1.0));
            return Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: _GroupBox(
                          label: 'Group of 4',
                          labelColor: accent,
                          mice: [
                            for (final (i, m) in _groupOfFour.indexed)
                              m.copyWith(opacity: i < 2 ? 1 : 1 - split),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 26),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          size: 52,
                          color: fade(ink, 0.3 + 0.7 * split),
                        ),
                      ),
                      Expanded(
                        child: _GroupBox(
                          label: 'Group of 2',
                          labelColor: ink,
                          mice: [
                            for (final m in _pairLeft)
                              m.copyWith(opacity: split),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 60),
                const Expanded(
                  flex: 4,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Bullets([
                        'In a pair, decisions split roughly half active, half '
                            'passive: one animal’s move is the other’s wait',
                        'In a group of four, most decisions are active — a '
                            'passive one needs several animals to coordinate '
                            'at once',
                        'Entry roles carry over between the two conditions; '
                            'exit roles carry over less strongly',
                      ], style: tNote),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

class _GroupBox extends StatelessWidget {
  const _GroupBox({
    required this.label,
    required this.labelColor,
    required this.mice,
  });

  final String label;
  final Color labelColor;
  final List<MouseSpec> mice;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: tBody.copyWith(
              color: labelColor, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 14),
        AspectRatio(
          aspectRatio: 1,
          child: CustomPaint(
            painter: ArenaPainter(
              mice: mice,
              fill: coldTint,
              border: const Color(0xFF4A4F63),
              borderWidth: 7,
              snowflake: true,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Published panels for Figure 3.
// ---------------------------------------------------------------------------

Slide fig3_bc() => Slide(
      duration: const Duration(milliseconds: 2200),
      builder: (context) => const SlideFrame(
        kicker: 'Figure 3b,c',
        title: 'Most decisions are active, and they come early',
        accentColor: activeColor,
        source: 'Raam et al. 2026, Fig. 3b,c · n = 24 animals from six groups',
        child: Column(
          children: [
            Expanded(child: FigureImage('fig_3_b_c.png')),
            SizedBox(height: 16),
            Anim(
              at: 0.9,
              child: Bullets([
                'Active decisions outnumber passive ones for both entry and '
                    'exit',
                'Once a pair exists, the others join it one after another',
                'Decisions per minute peak in the first few minutes, then '
                    'fall as huddles get larger and last longer',
              ], start: 0.9, gap: 0.18, style: tNote, color: activeColor),
            ),
          ],
        ),
      ),
    );

Slide fig3_di() => Slide(
      duration: const Duration(milliseconds: 2400),
      builder: (context) => const SlideFrame(
        kicker: 'Figure 3d–i',
        title: 'Speed tells active from passive, for entry and for exit',
        accentColor: activeColor,
        source: 'Raam et al. 2026, Fig. 3d–i · speed from SLEAP tracking',
        child: Column(
          children: [
            Expanded(child: FigureImage('fig_3_d_to_i.png')),
            SizedBox(height: 16),
            Anim(
              at: 0.9,
              child: Bullets([
                'Active entry: speed is high before huddle onset and drops at '
                    'it. Active exit: speed jumps as the animal leaves',
                'Passive decisions are flat and slow throughout — the subject '
                    'never moves',
                'The share of decisions that are active climbs across the '
                    'session, for entry and exit alike',
                'Passive is mostly a huddle-of-two affair; joining or leaving '
                    'three or four almost always has to be active',
              ], start: 0.9, gap: 0.16, style: tNote, color: activeColor),
            ),
          ],
        ),
      ),
    );

Slide fig3_jn() => Slide(
      duration: const Duration(milliseconds: 2200),
      builder: (context) => const SlideFrame(
        kicker: 'Figure 3j–n',
        title: 'Group size changes the mix; the animal keeps its role',
        accentColor: activeColor,
        source: 'Raam et al. 2026, Fig. 3j–n · same animals in both '
            'conditions',
        child: Column(
          children: [
            Expanded(child: FigureImage('fig_3_j_to_n.png')),
            SizedBox(height: 16),
            Anim(
              at: 0.9,
              child: Bullets([
                'Pairs: about half active, half passive. Groups of four: '
                    'mostly active',
                'Entry roles correlate strongly between the two conditions',
                'Exit roles correlate more weakly — who breaks a huddle up is '
                    'less fixed',
              ], start: 0.9, gap: 0.18, style: tNote, color: activeColor),
            ),
          ],
        ),
      ),
    );

Slide fig3_otox() => Slide(
      duration: const Duration(milliseconds: 2200),
      builder: (context) => const SlideFrame(
        kicker: 'Figure 3o–x',
        title: 'Thermal consequences of a decision',
        accentColor: warm,
        source: 'Raam et al. 2026, Fig. 3o–x',
        child: Column(
          children: [
            Expanded(child: FigureImage('fig_3_o_to_x.png')),
            SizedBox(height: 16),
            Anim(
              at: 0.9,
              child: Bullets([
                'Surface temperature rises after entry and falls after exit — '
                    'active or passive makes no difference',
                'Core temperature does not move during these events: the '
                    'benefit is at the surface',
                'Group settings involve more locomotion, but locomotion does '
                    'not explain the core-temperature changes',
              ], start: 0.9, gap: 0.18, style: tNote, color: warm),
            ),
          ],
        ),
      ),
    );
