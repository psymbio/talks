import 'package:flutter/foundation.dart';

/// Global, deck-wide state. Lives as long as the deck, so values survive
/// moving between slides (and slide restarts).
///
/// Each value is a [ValueNotifier], so any widget can listen to it with a
/// `ValueListenableBuilder` and any widget can write to it.
class DeckState {
  final _signals = <String, ValueNotifier<Object?>>{};

  /// Returns the signal stored under [key], creating it with [initial]
  /// the first time it is asked for.
  ValueNotifier<T> signal<T>(String key, T initial) {
    return _signals.putIfAbsent(key, () => ValueNotifier<T>(initial))
        as ValueNotifier<T>;
  }

  void dispose() {
    for (final s in _signals.values) {
      s.dispose();
    }
    _signals.clear();
  }
}
