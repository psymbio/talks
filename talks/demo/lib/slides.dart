import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

const _h1 = TextStyle(fontSize: 120, fontWeight: FontWeight.w700);
const _h2 = TextStyle(fontSize: 80, fontWeight: FontWeight.w600);
const _body = TextStyle(fontSize: 48);

// ---------------------------------------------------------------------------
// 1. Tandem: the heading and its underline share one Track.
// ---------------------------------------------------------------------------

const _headline = Track(at: 0.2, dur: 0.8);

Slide title() => Slide(
      duration: const Duration(seconds: 2),
      builder: (context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Anim(
              track: _headline,
              from: Offset(0, 60),
              child: Text('Deck Engine', style: _h1),
            ),
            Anim(
              track: _headline,
              builder: (context, t, _) => Container(
                width: 700 * t,
                height: 8,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 40),
            const Anim(
              at: 1.1,
              child: Text('Presentations written as Flutter code', style: _body),
            ),
          ],
        ),
      ),
    );

// ---------------------------------------------------------------------------
// 2. Stagger: each bullet starts a little later on the main timeline.
// ---------------------------------------------------------------------------

Slide agenda() {
  const bullets = [
    'Engine: timeline, navigation, global state',
    'Project: one function per slide',
    'Main: the deck at a glance',
  ];
  return Slide(
    duration: const Duration(seconds: 2),
    builder: (context) => Padding(
      padding: const EdgeInsets.all(120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Anim(child: Text('How it fits together', style: _h2)),
          const SizedBox(height: 60),
          for (final (i, text) in bullets.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Anim(
                at: 0.5 + i * 0.25,
                from: const Offset(-60, 0),
                child: Text('•  $text', style: _body),
              ),
            ),
        ],
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// 3. Control: the button plays the "panel" clip, the panel follows it.
//    It also writes to global state, which the last slide reads.
// ---------------------------------------------------------------------------

Slide controlDemo() => Slide(
      duration: const Duration(seconds: 1),
      builder: (context) {
        final timeline = SlideTimeline.of(context);
        final votes = Deck.of(context).state.signal<int>('votes', 0);

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Anim(
                child: Text('One element drives another', style: _h2),
              ),
              const SizedBox(height: 60),
              Anim(
                at: 0.4,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: () => timeline.toggle('panel'),
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Toggle panel',
                            style: TextStyle(fontSize: 36)),
                      ),
                    ),
                    const SizedBox(width: 32),
                    FilledButton.tonal(
                      onPressed: () => votes.value++,
                      child: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Vote', style: TextStyle(fontSize: 36)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              Anim(
                clip: 'panel',
                curve: Curves.easeOutBack,
                scale: 0.8,
                from: const Offset(0, 40),
                child: Container(
                  width: 900,
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ValueListenableBuilder<int>(
                    valueListenable: votes,
                    builder: (context, v, _) => Text(
                      'Votes so far: $v',
                      style: _body,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

// ---------------------------------------------------------------------------
// 4. Global state survives navigation.
// ---------------------------------------------------------------------------

Slide thanks() => Slide(
      builder: (context) {
        final votes = Deck.of(context).state.signal<int>('votes', 0);
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Anim(
                scale: 0.9,
                child: Text('Thanks!', style: _h1),
              ),
              const SizedBox(height: 40),
              Anim(
                at: 0.5,
                child: ValueListenableBuilder<int>(
                  valueListenable: votes,
                  builder: (context, v, _) => Text(
                    'You voted $v time${v == 1 ? '' : 's'} on the last slide',
                    style: _body,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
