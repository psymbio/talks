import 'package:flutter/widgets.dart';

import 'theme.dart';
import 'widgets/mouse.dart';

/// The five group huddle states of Fig. 1b, most dispersed to most
/// aggregated. Positions are arena units; angles are headings in degrees.
/// Ported from the matplotlib prototype, with per-state headings so that
/// huddling mice lie alongside each other rather than crossing over.

MouseSpec _m(double x, double y, double degrees) =>
    MouseSpec(Offset(x, y), deg(degrees));

final huddleStates = <List<MouseSpec>>[
  // 0 — four apart
  [
    _m(.23, .25, -20),
    _m(.76, .24, 200),
    _m(.25, .76, 25),
    _m(.78, .75, 160),
  ],
  // 2:1:1 — one pair, two alone
  [
    _m(.46, .46, -90),
    _m(.56, .52, 90),
    _m(.79, .79, 150),
    _m(.21, .22, -25),
  ],
  // 2:2 — two pairs
  [
    _m(.34, .42, -90),
    _m(.44, .48, 90),
    _m(.66, .66, -90),
    _m(.76, .72, 90),
  ],
  // 3:1 — three together, one out
  [
    _m(.43, .50, -90),
    _m(.53, .50, 90),
    _m(.48, .61, -20),
    _m(.80, .80, 150),
  ],
  // 4:0 — fully aggregated
  [
    _m(.44, .47, -90),
    _m(.54, .47, 90),
    _m(.46, .59, -75),
    _m(.56, .59, 105),
  ],
];

const stateNames = ['0', '2:1:1', '2:2', '3:1', '4:0'];

const stateSubtitles = [
  'Dispersed',
  'One pair',
  'Two pairs',
  'Three together',
  'Fully aggregated',
];

/// Ambient temperature shown alongside each state in the walkthrough.
const stateTemps = [20.0, 16.0, 12.0, 8.0, 5.0];

const stateNotes = [
  'All four apart — the usual picture at 20 °C.',
  'A first pair forms; two mice are still alone.',
  'Two separate pairs. Rare: mice prefer one big huddle.',
  'Three mice together, one still out in the cold.',
  'The whole group in one huddle — dominant late at 5 °C.',
];
