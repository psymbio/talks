# flutter_deck

A reusable Flutter presentation engine for creating interactive, animated scientific talks.

## Project Structure

```text
engine/               deck_engine package: reusable across every talk
talks/demo/           tiny example deck (engine features only)
talks/mouse_huddle/   the Raam et al. 2026 presentation
```

Each talk is its own Flutter app and uses the shared `deck_engine` package.

## Setup & Run

```bash
# Navigate to the project
cd talks/mouse_huddle

# Run the presentation
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
```

```
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 \
  -t lib/export_web.dart
```

Open in browser: http://localhost:8080

For access from another device on the same network, use:

```text
http://<your-ip-address>:8080
```

## Controls

| Action | Control |
|---|---|
| Next step / slide | Click / Space / PageDown |
| Previous step / slide | Right-click / PageUp |
| Next slide | ↓ |
| Previous slide | ↑ |
| Restart current slide | R |
| First slide | Home |
| Last slide | End |

## Click-Controlled Animation

Slides can define multiple interaction steps before advancing to the next slide.

```dart
Slide(
  steps: 3,                       // three clicks before the next slide
  builder: (context) => Column(children: [
    StageBuilder(                 // stage runs 0 → 3, eased, as you click
      builder: (context, stage) => CustomPaint(painter: MyPainter(stage)),
    ),
    Anim(step: 2, child: Text('appears on the second click')),
  ]),
)
```