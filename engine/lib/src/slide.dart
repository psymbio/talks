import 'package:flutter/widgets.dart';

import 'deck.dart';
import 'timeline.dart';

/// One slide: a widget builder plus its timing.
///
/// * [duration] is the length of the autoplaying main timeline. It should
///   cover the end of the last timed animation (`at + dur` of the latest
///   [Anim]).
/// * [steps] is the number of presenter-controlled steps. With `steps: 3`
///   the first three clicks advance the slide's animation; the fourth click
///   moves to the next slide.
class Slide {
  const Slide({
    this.duration = const Duration(seconds: 2),
    this.steps = 0,
    this.stepDuration = const Duration(milliseconds: 900),
    required this.builder,
  });

  final Duration duration;
  final int steps;
  final Duration stepDuration;
  final WidgetBuilder builder;
}

/// A function that produces a slide. A presentation is a list of these.
typedef SlideFn = Slide Function();

/// Mounts a [Slide] and owns its [SlideTimeline]. The deck gives every visit
/// to a slide a fresh SlideHost, which is what makes animations restart.
class SlideHost extends StatefulWidget {
  const SlideHost({super.key, required this.slide, required this.controller});

  final Slide slide;
  final DeckController controller;

  @override
  State<SlideHost> createState() => _SlideHostState();
}

class _SlideHostState extends State<SlideHost> with TickerProviderStateMixin {
  late final SlideTimeline _timeline;

  @override
  void initState() {
    super.initState();
    _timeline = SlideTimeline(
      this,
      widget.slide.duration,
      steps: widget.slide.steps,
      stepDuration: widget.slide.stepDuration,
    )..play();
    widget.controller.attach(_timeline);
  }

  @override
  void dispose() {
    widget.controller.detach(_timeline);
    _timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TimelineScope(
      timeline: _timeline,
      child: Builder(builder: widget.slide.builder),
    );
  }
}
