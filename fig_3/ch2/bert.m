function f = bert(p,a)
%% called from fig_1_1, fig_2_4, fig_2_5 fig_3_5 fig_4_29 fg_7_6 fig_8_4

  %% von Bertalanffy growth model: Eq 3.20 {95}
  f = p(2) - (p(2) - p(1)) * exp( - p(3) * a(:,1));
