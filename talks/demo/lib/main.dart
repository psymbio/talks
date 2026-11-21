import 'package:deck_engine/deck_engine.dart';
import 'package:flutter/material.dart';

import 'slides.dart';

// The whole presentation at a glance: one function per slide, in order.
void main() {
  runApp(
    Deck(
      slides: [
        title,
        agenda,
        controlDemo,
        thanks,
      ],
    ),
  );
}
