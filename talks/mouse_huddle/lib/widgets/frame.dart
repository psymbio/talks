import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import '../theme.dart';

/// Standard slide layout: kicker, title, content, and a footer with the
/// figure reference, step dots (if the slide has clicks) and page number.
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

  /// Colours this slide's marker block, kicker and progress bar. Defaults
  /// to the deck accent.
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
          padding: const EdgeInsets.fromLTRB(84, 44, 84, 52),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (kicker != null)
                Anim(
                  child: Text(
                    kicker!.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: tKicker.copyWith(color: muted),
                  ),
                ),
              const SizedBox(height: 4),
              Anim(
                at: 0.05,
                from: const Offset(0, 18),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: tH2.copyWith(color: mark),
                ),
              ),
              const SizedBox(height: 18),
              Anim(
                at: 0.1,
                dur: 0.9,
                builder: (context, t, _) => Center(
                  child: FractionallySizedBox(
                    widthFactor: t,
                    child: Container(height: 3, color: mark),
                  ),
                ),
              ),
              const SizedBox(height: 26),
              Expanded(child: child),
              const SizedBox(height: 16),
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
        // Deck progress, along the very bottom.
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
    this.start = 0.4,
    this.gap = 0.22,
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
            padding: const EdgeInsets.only(bottom: 20),
            child: Anim(
              at: start + i * gap,
              from: const Offset(-36, 0),
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
    final size = style.fontSize ?? 32;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 11,
          height: 11,
          margin: EdgeInsets.only(top: size * 0.55, right: 20),
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        Expanded(child: Text(text, style: style)),
      ],
    );
  }
}

/// A tinted callout box for the one sentence a slide is really about.
class Callout extends StatelessWidget {
  const Callout(
    this.text, {
    super.key,
    this.lead,
    this.color = accent,
    this.style = tBody,
  });

  final String text;

  /// Optional bold, coloured opener — 'Idea:', 'Finding:', and so on.
  final String? lead;
  final Color color;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 20),
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
                style: style.copyWith(
                    fontWeight: FontWeight.w900, color: color),
              ),
            TextSpan(text: text),
          ],
        ),
        style: style,
      ),
    );
  }
}

/// The full-width coloured band the deck uses for a slide's single idea.
class IdeaBand extends StatelessWidget {
  const IdeaBand(this.text, {super.key, this.lead, this.color = band});

  final String text;
  final String? lead;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 24),
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

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.color = card,
    this.accentColor,
    this.padding = const EdgeInsets.all(30),
  });

  final Widget child;
  final Color color;

  /// When set, draws a thick coloured rule along the top of the card.
  final Color? accentColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    // The accent rule is a child, not a border side: a BoxDecoration may
    // only round its corners when every side matches.
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: boxLine, width: 3),
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

/// A heading with a short list inside a [Panel] — the workhorse of the
/// methods slides.
class ListPanel extends StatelessWidget {
  const ListPanel({
    super.key,
    required this.title,
    required this.items,
    this.color = accent,
    this.at = 0.4,
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
      from: const Offset(0, 28),
      child: Panel(
        accentColor: color,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: tBody.copyWith(
                    fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 16),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Bullet(item, style: tSmall.copyWith(color: ink),
                    color: fade(color, 0.55)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows a figure panel from `images/`. Until the real file is dropped in,
/// the placeholder that ships with the repo appears instead; if the file is
/// missing altogether, a labelled box appears so the slide still works.
class FigureImage extends StatelessWidget {
  const FigureImage(this.file, {super.key, this.caption, this.at = 0.3});

  /// File name inside `images/`, e.g. 'fig1_c_d_e.png'.
  final String file;
  final String? caption;
  final double at;

  @override
  Widget build(BuildContext context) {
    return Anim(
      at: at,
      dur: 0.8,
      from: const Offset(0, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(22),
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
          ),
          if (caption != null) ...[
            const SizedBox(height: 14),
            Text(caption!, style: tSmall),
          ],
        ],
      ),
    );
  }
}
