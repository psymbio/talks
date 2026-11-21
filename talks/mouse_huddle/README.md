# mouse_huddle

Talk on Raam et al., *Cortical regulation of collective social dynamics
during environmental challenge*, Nat Neurosci 29, 901–914 (2026).

    flutter create .          # once, to generate the platform folders
    flutter run -d macos      # or windows, linux, chrome

    lib/main.dart        the slide list, with the click count per slide
    lib/states.dart      the five group-huddle configurations (Fig. 1b)
    lib/slides/          one file per section of the talk
    lib/widgets/         slide frame, cards, the mouse and arena painters
    lib/theme.dart       palette and the Open Sans type scale
    fonts/               IBM Plex Sans (SIL OFL 1.1)
    images/              published figure panels

## Figure panels

Four slides read PNGs out of `images/`. Placeholders ship in the repo;
replace them in place, keeping the names:

    fig1_c_d_e.png   fig1_f_g_h.png   fig1_i.png   fig1_j_k_l.png
    fig3_b_c.png     fig3_d_e_f.png   fig3_g_h_i.png
    fig3_k_l_m_n.png fig3_o_to_x.png

To add another, use `FigureImage('my_panel.png')` from
`lib/widgets/frame.dart`. No pubspec change is needed — the whole folder
is declared as an asset.

## Controls

    click  →  Space  PageDown     next step, then next slide
    right-click  ←  PageUp        previous step, then previous slide
    ↓ / ↑                         skip a whole slide
    R                             restart the current slide

## Changing the title animation

`_titleStops` at the top of `lib/slides/intro.dart` lists one stop per click
position — a group state and the temperature shown with it. Two stops give
one click, three give two, and so on; `steps:` reads the length, so only the
list needs editing. `stepDuration` on that same `Slide` sets how slowly each
click plays.
