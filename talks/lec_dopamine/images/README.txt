Figure crops go in this folder. The deck looks for exactly these names:

  fig_1_c_d_e.png        fig_1_f_g_h.png
  fig_2_b_c.png          fig_2_d.png        fig_2_e_f.png
  fig_2_g_h_i.png
  fig_3_a_b.png          fig_3_c_d.png
  fig_4_b_c.png          fig_4_d_e_f.png
  fig_5_a_b_c_d.png
  fig_6_a_b_c.png        fig_6_e_f_g_h_i.png   fig_6_j_k_l.png

Fig. 1a, 1b, 2a, 2e/f (schematic version), 3 (schematic), 4a and 5a are
drawn in code instead, so they need no file. A name the deck asks for but
cannot find shows a labelled box rather than crashing, so the deck still
runs with panels missing.

The whole folder is declared as an asset in pubspec.yaml: adding a file
here is enough, and FigureImage('my_panel.png') will pick it up.
