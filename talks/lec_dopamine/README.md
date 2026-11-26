# lec_dopamine

Talk on Nakagawa et al., *Early dopamine disruption in the entorhinal cortex
of a knock-in model of Alzheimer's disease*, Nat Neurosci 29, 1386–1396
(2026).

    flutter create .
    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080

    lib/main.dart        the slide list, with the click count per slide
    lib/slides/          one file per act of the talk
    lib/widgets/         the frame, the coronal section, the three plots
    lib/theme.dart       palette (the paper's own cue colours) and type
    lib/export_web.dart  exports every slide as a PNG (see below)
    images/              published figure crops; see images/README.txt

## What is drawn versus what is a crop

Every schematic is drawn in code and animated: the circuit, the trial, the
amyloid progression, the learning curves, the PC-space trajectories, the
photometry traces, the fiber and laser. Each of those slides says in its
footer that it is an illustration. The quantitative panels are crops of the
published figures.

The learning curves use the paper's reported T5 percentages as asymptotes,
so the gap between conditions is real even though the trace shape is not.

## Controls

    click  →  Space  PageDown     next step, then next slide
    ←  PageUp                     previous step, then previous slide
    ↓ / ↑                         skip a whole slide
    R                             restart the current slide

Drag across text to select and copy it.

## Exporting every slide as a PNG

    flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 \
      -t lib/export_web.dart

Press Export; you get one slides.zip of numbered PNGs.
