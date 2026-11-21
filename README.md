# flutter_deck

    engine/               deck_engine package: reusable across every talk
    talks/demo/           tiny example deck (engine features only)
    talks/mouse_huddle/   the Raam et al. 2026 presentation

Each talk is its own Flutter app:

    cd talks/mouse_huddle
    flutter create .       # once, to generate the platform folders
    flutter run -d macos   # or windows, linux, chrome

## Controls

    click  →  Space  PageDown     next step, then next slide
    right-click  ←  PageUp        previous step, then previous slide
    ↓ / ↑                         skip to next / previous slide
    R                             restart current slide
    Home / End                    first / last slide

## Click-controlled animation

    Slide(
      steps: 3,                       // three clicks before the next slide
      builder: (context) => Column(children: [
        StageBuilder(                 // stage runs 0 → 3, eased, as you click
          builder: (context, stage) => CustomPaint(painter: MyPainter(stage)),
        ),
        Anim(step: 2, child: Text('appears on the second click')),
      ]),
    )
