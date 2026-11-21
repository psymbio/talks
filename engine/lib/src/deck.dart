import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'slide.dart';
import 'state.dart';
import 'timeline.dart';

/// Navigation + global state for a deck. Get it with `Deck.of(context)`.
class DeckController extends ChangeNotifier {
  int length = 0;
  final DeckState state = DeckState();

  int _index = 0;
  int _epoch = 0;
  SlideTimeline? _timeline;

  int get index => length == 0 ? 0 : _index.clamp(0, length - 1);

  /// Changes on every navigation or restart. The deck keys the current slide
  /// on this, so a new epoch means a fresh slide with fresh animations.
  int get epoch => _epoch;

  void attach(SlideTimeline timeline) => _timeline = timeline;

  void detach(SlideTimeline timeline) {
    if (identical(_timeline, timeline)) _timeline = null;
  }

  void goTo(int i) {
    final target = i.clamp(0, length - 1);
    if (target == index) return;
    _index = target;
    _epoch++;
    notifyListeners();
  }

  /// Advances the current slide's next step, or moves to the next slide if
  /// the slide has no steps left.
  void next() {
    final timeline = _timeline;
    if (timeline != null && timeline.advance()) return;
    nextSlide();
  }

  /// Rewinds the current slide by one step, or moves to the previous slide
  /// if it is already at its first step.
  void previous() {
    final timeline = _timeline;
    if (timeline != null && timeline.retreat()) return;
    previousSlide();
  }

  void nextSlide() => goTo(index + 1);
  void previousSlide() => goTo(index - 1);

  /// Replays the current slide from the start.
  void restart() {
    _epoch++;
    notifyListeners();
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}

/// The root of a presentation.
///
/// Controls
///   click / → / Space / PageDown   next step, then next slide
///   right-click / ← / PageUp       previous step, then previous slide
///   ↓ / ↑                          skip straight to next / previous slide
///   R                              restart current slide
///   Home / End                     first / last slide
///
/// Slides are laid out on a fixed [size] canvas that is scaled to fit the
/// window, so use absolute sizes (e.g. fontSize: 96) in your slides.
class Deck extends StatefulWidget {
  const Deck({
    super.key,
    required this.slides,
    this.size = const Size(1920, 1080),
    this.theme,
    this.background,
  });

  final List<SlideFn> slides;
  final Size size;
  final ThemeData? theme;

  /// Defaults to the theme's scaffold background colour.
  final Color? background;

  static DeckController of(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_DeckScope>();
    assert(scope != null, 'Deck.of() called outside of a Deck.');
    return scope!.controller;
  }

  @override
  State<Deck> createState() => _DeckState();
}

class _DeckState extends State<Deck> {
  final _controller = DeckController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller..length = widget.slides.length;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.theme ?? ThemeData.dark(useMaterial3: true),
      home: _DeckScope(
        controller: c,
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowRight): c.next,
            const SingleActivator(LogicalKeyboardKey.space): c.next,
            const SingleActivator(LogicalKeyboardKey.pageDown): c.next,
            const SingleActivator(LogicalKeyboardKey.arrowLeft): c.previous,
            const SingleActivator(LogicalKeyboardKey.pageUp): c.previous,
            const SingleActivator(LogicalKeyboardKey.arrowDown): c.nextSlide,
            const SingleActivator(LogicalKeyboardKey.arrowUp): c.previousSlide,
            const SingleActivator(LogicalKeyboardKey.keyR): c.restart,
            const SingleActivator(LogicalKeyboardKey.home): () => c.goTo(0),
            const SingleActivator(LogicalKeyboardKey.end): () =>
                c.goTo(c.length - 1),
          },
          child: Focus(
            autofocus: true,
            child: Scaffold(
              backgroundColor: widget.background,
              body: Center(
                child: FittedBox(
                  child: SizedBox.fromSize(
                    size: widget.size,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: c.next,
                      onSecondaryTap: c.previous,
                      child: ListenableBuilder(
                        listenable: c,
                        builder: (context, _) => KeyedSubtree(
                          key: ValueKey(c.epoch),
                          child: SlideHost(
                            slide: widget.slides[c.index](),
                            controller: c,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckScope extends InheritedWidget {
  const _DeckScope({required this.controller, required super.child});

  final DeckController controller;

  @override
  bool updateShouldNotify(_DeckScope oldWidget) =>
      controller != oldWidget.controller;
}
