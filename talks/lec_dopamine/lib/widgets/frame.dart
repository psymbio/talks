import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Standard slide layout: a coloured rule down the left, kicker and title,
/// the content, then a footer with the figure reference, step dots and page
/// number. A thin progress bar runs along the bottom of the deck.
class SlideFrame extends StatelessWidget {
  const SlideFrame({
    super.key,
    required this.title,
    this.kicker,
    this.source,
    this.accentColor,
    required this.child,
  });

  final String title;
  final String? kicker;
  final String? source;

  /// Colours this slide's rule, kicker and progress bar.
  final Color? accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final deck = Deck.of(context);
    final progress = deck.length < 2 ? 0.0 : deck.index / (deck.length - 1);
    final mark = accentColor ?? accent;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(88, 50, 88, 50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Anim(
                      dur: 0.5,
                      child: Container(width: 9, color: mark),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (kicker != null)
                            Anim(
                              child: Text(
                                kicker!.toUpperCase(),
                                style: tKicker.copyWith(color: mark),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Anim(
                            at: 0.05,
                            from: const Offset(0, 16),
                            child: Text(title, style: tH2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              Expanded(child: child),
              const SizedBox(height: 14),
              Container(height: 2, color: hairline),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: Text(source ?? '', style: tSmall)),
                  const StepDots(),
                  const SizedBox(width: 30),
                  Text(
                    '${deck.index + 1} / ${deck.length}',
                    style: tSmall.copyWith(
                        color: ink, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Row(
            children: [
              Expanded(
                flex: (progress * 1000).round().clamp(1, 1000),
                child: Container(height: 6, color: mark),
              ),
              Expanded(
                flex: (1000 - progress * 1000).round().clamp(1, 1000),
                child: Container(height: 6, color: wash),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One dot per click on this slide; fills in as the presenter advances.
class StepDots extends StatelessWidget {
  const StepDots({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = SlideTimeline.of(context);
    if (timeline.steps == 0) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: timeline.stage,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('click', style: tSmall),
          const SizedBox(width: 12),
          for (var i = 1; i <= timeline.steps; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 13,
              height: 13,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: timeline.stage.value >= i - 0.5 ? accent : hairline,
              ),
            ),
        ],
      ),
    );
  }
}

/// A bulleted list whose items slide in one after another.
class Bullets extends StatelessWidget {
  const Bullets(
    this.items, {
    super.key,
    this.start = 0.35,
    this.gap = 0.2,
    this.style = tBody,
    this.color = accent,
  });

  final List<String> items;
  final double start;
  final double gap;
  final TextStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (i, text) in items.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Anim(
              at: start + i * gap,
              from: const Offset(-30, 0),
              child: Bullet(text, style: style, color: color),
            ),
          ),
      ],
    );
  }
}

class Bullet extends StatelessWidget {
  const Bullet(this.text, {super.key, this.style = tBody, this.color = accent});

  final String text;
  final TextStyle style;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final size = style.fontSize ?? 31;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: EdgeInsets.only(top: size * 0.56, right: 18),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

/// An outlined box for the sentence a slide turns on, with an optional bold
/// coloured opener.
class Callout extends StatelessWidget {
  const Callout(
    this.text, {
    super.key,
    this.lead,
    this.color = accent,
    this.style = tBody,
  });

  final String text;
  final String? lead;
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        color: card,
        border: Border.all(color: boxLine, width: 3),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            if (lead != null)
              TextSpan(
                text: '${lead!} ',
                style:
                    style.copyWith(fontWeight: FontWeight.w900, color: color),
              ),
            TextSpan(text: text),
          ],
        ),
        style: style,
      ),
    );
  }
}

/// The full-width coloured band for a slide's single idea.
class IdeaBand extends StatelessWidget {
  const IdeaBand(this.text, {super.key, this.lead, this.color = accent});

  final String text;
  final String? lead;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 22),
      color: color,
      child: Text.rich(
        TextSpan(
          children: [
            if (lead != null)
              TextSpan(
                text: '${lead!} ',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            TextSpan(text: text),
          ],
        ),
        textAlign: TextAlign.center,
        style: tLead.copyWith(color: Colors.white),
      ),
    );
  }
}

/// A card with a coloured rule across the top.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.accentColor,
    this.padding = const EdgeInsets.all(24),
  });

  final Widget child;
  final Color? accentColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        border: Border.all(color: hairline, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (accentColor != null) Container(height: 6, color: accentColor),
          Flexible(child: Padding(padding: padding, child: child)),
        ],
      ),
    );
  }
}

/// A heading with a short list inside a [Panel].
class ListPanel extends StatelessWidget {
  const ListPanel({
    super.key,
    required this.title,
    required this.items,
    this.color = accent,
    this.at = 0.35,
  });

  final String title;
  final List<String> items;
  final Color color;
  final double at;

  @override
  Widget build(BuildContext context) {
    return Anim(
      at: at,
      dur: 0.7,
      from: const Offset(0, 24),
      child: Panel(
        accentColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    tBody.copyWith(fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 14),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Bullet(item,
                    style: tSmall.copyWith(color: ink),
                    color: fade(color, 0.5)),
              ),
          ],
        ),
      ),
    );
  }
}

/// A published figure panel from images/. A name the deck cannot find shows
/// a labelled box rather than crashing.
class FigureImage extends StatelessWidget {
  const FigureImage(this.file, {super.key, this.at = 0.25});

  final String file;
  final double at;

  @override
  Widget build(BuildContext context) {
    return Anim(
      at: at,
      dur: 0.7,
      from: const Offset(0, 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: card,
          border: Border.all(color: boxLine, width: 3),
        ),
        child: Image.asset(
          'images/$file',
          fit: BoxFit.contain,
          errorBuilder: (context, _, __) => Center(
            child: Text('images/$file not found', style: tSmall),
          ),
        ),
      ),
    );
  }
}

/// One published panel plus the points to make while it is up.
Slide panelSlide({
  required String kicker,
  required String title,
  required String source,
  required String file,
  required List<String> points,
  Color color = accent,
}) =>
    Slide(
      duration: const Duration(milliseconds: 2400),
      builder: (context) => SlideFrame(
        kicker: kicker,
        title: title,
        accentColor: color,
        source: source,
        child: Column(
          children: [
            Expanded(child: FigureImage(file)),
            const SizedBox(height: 14),
            Anim(
              at: 0.8,
              child: Bullets(points,
                  start: 0.8, gap: 0.16, style: tNote, color: color),
            ),
          ],
        ),
      ),
    );
