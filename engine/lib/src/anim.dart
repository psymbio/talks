import 'dart:ui' show lerpDouble;

import 'package:flutter/widgets.dart';

import 'timeline.dart';

typedef AnimBuilder = Widget Function(
  BuildContext context,
  double t,
  Widget? child,
);

/// Animates one element of a slide.
///
/// What drives it (pick one):
///  * [at] / [dur] / [curve]: a window on the slide's main timeline (seconds)
///  * [track]: a shared [Track], so several elements move in tandem
///  * [step]: the presenter's click into that step (rewinds on "previous")
///  * [clip]: a named clip that some other element plays
///
/// What it does:
///  * by default: fades in, optionally sliding in [from] an offset and
///    growing from [scale]
///  * or pass [builder] to do anything you like with the progress `t` (0 → 1)
class Anim extends StatelessWidget {
  const Anim({
    super.key,
    this.at = 0,
    this.dur = 0.6,
    this.curve = Curves.easeOutCubic,
    this.track,
    this.step,
    this.clip,
    this.fade = true,
    this.from = Offset.zero,
    this.scale = 1,
    this.builder,
    this.child,
  }) : assert(child != null || builder != null);

  final double at;
  final double dur;
  final Curve curve;
  final Track? track;
  final int? step;
  final String? clip;

  final bool fade;
  final Offset from;
  final double scale;

  final AnimBuilder? builder;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final timeline = SlideTimeline.of(context);
    final Animation<double> animation;
    if (clip != null) {
      animation = timeline.clip(clip!).drive(CurveTween(curve: curve));
    } else if (step != null) {
      animation = timeline.stepProgress(step!);
    } else {
      animation =
          timeline.window(track ?? Track(at: at, dur: dur, curve: curve));
    }

    return AnimatedBuilder(
      animation: animation,
      child: child,
      builder: (context, child) {
        final t = animation.value;
        if (builder != null) return builder!(context, t, child);
        return Opacity(
          opacity: fade ? t.clamp(0.0, 1.0) : 1,
          child: Transform.translate(
            offset: from * (1 - t),
            child: Transform.scale(
              scale: lerpDouble(scale, 1, t)!,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Rebuilds with the slide's continuous stage value (0 ... steps).
///
/// Use it for anything that should morph as the presenter clicks, e.g.
/// `positions = lerp(states[stage.floor()], states[stage.floor() + 1], ...)`.
class StageBuilder extends StatelessWidget {
  const StageBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, double stage) builder;

  @override
  Widget build(BuildContext context) {
    final stage = SlideTimeline.of(context).stage;
    return AnimatedBuilder(
      animation: stage,
      builder: (context, _) => builder(context, stage.value),
    );
  }
}
