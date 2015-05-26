%  created at 2013/08/01 by Bas Kooijman 
%
%% Description
%  plots  variables (= functions of parameters) in Species.xls, which can be found at http://www.bio.vu.nl/thb/deb/deblab/
%  the present path-setting assumes that the file Species.xls is in subdir add_my_pet
%
%% Input
%  the file Species.xls
%
%% Output
%  lots of figures
%
%% Remarks
%  A desciption of pars and vars can be found in report_init
%
%% Example of use
%  shparameters 


  clear all
  close all

  file = 'add_my_pet/Species.xls';
  read_Species

  Wdp = l_p.^3 .* Wdm;
  muHp = EHp ./ Wdp;
  
  figure % kappa - mup
  hold on
  plot(kap(sel_1), log10(muHp(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(kap(sel_2), log10(muHp(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(kap(sel_3), log10(muHp(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(kap(sel_4), log10(muHp(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(kap(sel_5), log10(muHp(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(kap(sel_6), log10(muHp(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([0 1])
  xlabel('\kappa')
  ylabel('_{10}log(\mu_{Hp}, J/mol)')
  txt_taxa(.1, 1.5, taxa_loc, col_loc);

  figure % kappa - lp
  hold on
  plot(kap(sel_1), l_p(sel_1), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(kap(sel_2), l_p(sel_2), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(kap(sel_3), l_p(sel_3), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(kap(sel_4), l_p(sel_4), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(kap(sel_5), l_p(sel_5), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(kap(sel_6), l_p(sel_6), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([0 1])
  xlabel('\kappa')
  ylabel('l_p')
  txt_taxa(.1, .2, taxa_loc, col_loc);
