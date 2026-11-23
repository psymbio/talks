import 'package:flutter/widgets.dart';

/// A reusable time window on a slide's main timeline, in seconds.
/// Give the same Track to several [Anim]s to make them move in tandem.
class Track {
  const Track({
    this.at = 0,
    this.dur = 0.6,
    this.curve = Curves.easeOutCubic,
  });

  final double at;
  final double dur;
  final Curve curve;
}

/// The animation clocks for one slide.
///
/// * [main] plays once, automatically, when the slide appears. Its value is
///   the number of seconds elapsed.
/// * [stage] is driven by the presenter. It rests at whole numbers
///   (0, 1, 2 ... [steps]); each click or "next" key animates it to the next
///   whole number, and "previous" animates it back. Anything that reads
///   `stage.value` therefore plays forward on click and rewinds on back.
/// * [clip] gives named controllers that do NOT autoplay. One element can
///   play/reverse a clip and any number of other elements can follow it.
class SlideTimeline {
  SlideTimeline(
    this._vsync,
    this.duration, {
    this.steps = 0,
    this.stepDuration = const Duration(milliseconds: 900),
  })  : main = AnimationController(
          vsync: _vsync,
          duration: duration,
          lowerBound: 0,
          upperBound: duration.inMicroseconds / 1e6,
        ),
        stage = AnimationController(
          vsync: _vsync,
          lowerBound: 0,
          upperBound: steps < 1 ? 1.0 : steps.toDouble(),
          value: 0,
        );

  final TickerProvider _vsync;
  final Duration duration;
  final int steps;
  final Duration stepDuration;

  final AnimationController main;
  final AnimationController stage;
  final _clips = <String, AnimationController>{};

  int _step = 0;

  /// The step the presenter has clicked to (0 ... [steps]).
  int get step => _step;

  static SlideTimeline of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<TimelineScope>();
    assert(scope != null, 'SlideTimeline.of() called outside of a slide.');
    return scope!.timeline;
  }

  void play() => main.forward(from: 0);

  /// Moves to the next step. Returns false if the slide has no steps left,
  /// in which case the deck moves on to the next slide.
  bool advance() {
    if (_step >= steps) return false;
    _step++;
    _seek();
    return true;
  }

  /// Moves back one step. Returns false if already at step 0.
  bool retreat() {
    if (_step <= 0) return false;
    _step--;
    _seek();
    return true;
  }

  /// Jumps straight to [step], animating from wherever the slide is now.
  /// Lets a slide offer its own targets — a strip of state chips, a legend,
  /// a timeline — that the presenter can click in any order.
  void goToStep(int step) {
    final target = step.clamp(0, steps);
    if (target == _step) return;
    _step = target;
    _seek();
  }

  void _seek() {
    stage.animateTo(
      _step.toDouble(),
      duration: stepDuration,
      curve: Curves.easeInOutCubic,
    );
  }

  /// Progress (0 → 1) through [track] on the main timeline.
  Animation<double> window(Track track) {
    assert(
      track.at + track.dur <= main.upperBound + 1e-9,
      'Track ends at ${track.at + track.dur}s but the slide duration is '
      '${main.upperBound}s. Increase Slide.duration.',
    );
    return main.drive(_Window(track));
  }

  /// Progress (0 → 1) of the click that leads INTO [step]
  /// (i.e. while [stage] travels from `step - 1` to `step`).
  Animation<double> stepProgress(int step) {
    assert(step >= 1 && step <= steps,
        'Step $step is outside this slide\'s 1..$steps steps.');
    return stage.drive(_StepWindow(step));
  }

  /// A controller that runs forever with the given [period], created and
  /// started on first use. Use it for ambient motion that should not need,
  /// or respond to, a click.
  ///
  /// By default it eases 0 → 1 → 0, which suits breathing and drifting.
  /// Pass `reverse: false` for motion that must always travel the same way
  /// — wind, rotation, a marching dash — and read the value as a sawtooth
  /// that snaps back to 0.
  AnimationController looping(
    Duration period, {
    String name = 'default',
    bool reverse = true,
  }) {
    final key = 'loop:$name';
    final existing = _clips[key];
    if (existing != null) return existing;
    final controller = AnimationController(vsync: _vsync, duration: period);
    _clips[key] = controller;
    controller.repeat(reverse: reverse);
    return controller;
  }

  /// The named, manually driven controller [name] (created on first use).
  AnimationController clip(
    String name, {
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return _clips.putIfAbsent(
      name,
      () => AnimationController(vsync: _vsync, duration: duration),
    );
  }

  /// Plays clip [name] forward, or backward if it is already open.
  void toggle(String name) {
    final c = clip(name);
    final opening = c.status == AnimationStatus.dismissed ||
        c.status == AnimationStatus.reverse;
    opening ? c.forward() : c.reverse();
  }

  void dispose() {
    main.dispose();
    stage.dispose();
    for (final c in _clips.values) {
      c.dispose();
    }
  }
}

/// Maps "seconds elapsed" to curved 0 → 1 progress through a [Track].
class _Window extends Animatable<double> {
  const _Window(this.track);

  final Track track;

  @override
  double transform(double seconds) {
    if (track.dur <= 0) return seconds >= track.at ? 1 : 0;
    final t = ((seconds - track.at) / track.dur).clamp(0.0, 1.0);
    return track.curve.transform(t);
  }
}

class _StepWindow extends Animatable<double> {
  const _StepWindow(this.step);

  final int step;

  @override
  double transform(double stage) => (stage - (step - 1)).clamp(0.0, 1.0);
}

class TimelineScope extends InheritedWidget {
  const TimelineScope({
    super.key,
    required this.timeline,
    required super.child,
  });

  final SlideTimeline timeline;

  @override
  bool updateShouldNotify(TimelineScope oldWidget) =>
      timeline != oldWidget.timeline;
}