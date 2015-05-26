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

if 0 % taxonomic distance - parameter distance
  
  d_t = dist_taxon(spec, genus, family, order, class, phylum, superphylum);
  d_t = d_t(:); % taxonomic distances between pairs of species
      
  p =  [pAm ./ zj, v, kap, pM, kJ, EG, EHb ./ zj3, EHj ./ zj3, EHp ./ zj3, ha ./ zj, sG];
  d_p = dist_stat(p);  d_p = d_p(:); % relative distances in energetics between pairs of species
  md_p = [mean(d_p(d_t == 0)); mean(d_p(d_t == 1)); mean(d_p(d_t == 2)); 
          mean(d_p(d_t == 3)); mean(d_p(d_t == 4)); mean(d_p(d_t == 5)); 
          mean(d_p(d_t == 6)); mean(d_p(d_t == 7))]; 
  d_pAm = dist_stat(pAm ./ zj);  d_pAm = d_pAm(:); 
  md_pAm = [mean(d_pAm(d_t == 0)); mean(d_pAm(d_t == 1)); mean(d_pAm(d_t == 2)); 
            mean(d_pAm(d_t == 3)); mean(d_pAm(d_t == 4)); mean(d_pAm(d_t == 5)); 
            mean(d_pAm(d_t == 6)); mean(d_pAm(d_t == 7))]; 
  d_v = dist_stat(v);  d_v = d_v(:);
  md_v = [mean(d_v(d_t == 0)); mean(d_v(d_t == 1)); mean(d_v(d_t == 2)); 
          mean(d_v(d_t == 3)); mean(d_v(d_t == 4)); mean(d_v(d_t == 5)); 
          mean(d_v(d_t == 6)); mean(d_v(d_t == 7))]; 
  d_kap = dist_stat(kap);  d_kap = d_kap(:);
  md_kap = [mean(d_kap(d_t == 0)); mean(d_kap(d_t == 1)); mean(d_kap(d_t == 2)); 
            mean(d_kap(d_t == 3)); mean(d_kap(d_t == 4)); mean(d_kap(d_t == 5)); 
            mean(d_kap(d_t == 6)); mean(d_kap(d_t == 7))]; 
  d_pM = dist_stat(pM);  d_pM = d_pM(:);
  md_pM = [mean(d_pM(d_t == 0)); mean(d_pM(d_t == 1)); mean(d_pM(d_t == 2)); 
           mean(d_pM(d_t == 3)); mean(d_pM(d_t == 4)); mean(d_pM(d_t == 5)); 
           mean(d_pM(d_t == 6)); mean(d_pM(d_t == 7))]; 
  d_kJ = dist_stat(kJ);  d_kJ = d_kJ(:);
  md_kJ = [mean(d_kJ(d_t == 0)); mean(d_kJ(d_t == 1)); mean(d_kJ(d_t == 2)); 
           mean(d_kJ(d_t == 3)); mean(d_kJ(d_t == 4)); mean(d_kJ(d_t == 5)); 
           mean(d_kJ(d_t == 6)); mean(d_kJ(d_t == 7))]; 
  d_EG = dist_stat(EG);  d_EG = d_EG(:);
  md_EG = [mean(d_EG(d_t == 0)); mean(d_EG(d_t == 1)); mean(d_EG(d_t == 2)); 
           mean(d_EG(d_t == 3)); mean(d_EG(d_t == 4)); mean(d_EG(d_t == 5)); 
           mean(d_EG(d_t == 6)); mean(d_EG(d_t == 7))]; 
  d_EHb = dist_stat(EHb ./ zj3);  d_EHb = d_EHb(:);
  md_EHb = [mean(d_EHb(d_t == 0)); mean(d_EHb(d_t == 1)); mean(d_EHb(d_t == 2)); 
            mean(d_EHb(d_t == 3)); mean(d_EHb(d_t == 4)); mean(d_EHb(d_t == 5)); 
            mean(d_EHb(d_t == 6)); mean(d_EHb(d_t == 7))]; 
  d_EHj = dist_stat(EHj ./ zj3);  d_EHj = d_EHj(:);
  md_EHj = [mean(d_EHj(d_t == 0)); mean(d_EHj(d_t == 1)); mean(d_EHj(d_t == 2)); 
          mean(d_EHj(d_t == 3)); mean(d_EHj(d_t == 4)); mean(d_EHj(d_t == 5)); 
          mean(d_EHj(d_t == 6)); mean(d_EHj(d_t == 7))]; 
  d_EHp = dist_stat(EHp ./ zj3);  d_EHp = d_EHp(:);
  md_EHp = [mean(d_EHp(d_t == 0)); mean(d_EHp(d_t == 1)); mean(d_EHp(d_t == 2)); 
            mean(d_EHp(d_t == 3)); mean(d_EHp(d_t == 4)); mean(d_EHp(d_t == 5)); 
            mean(d_EHp(d_t == 6)); mean(d_EHp(d_t == 7))]; 
  d_ha = dist_stat(ha ./ zj);  d_ha = d_ha(:);
  md_ha = [mean(d_ha(d_t == 0)); mean(d_ha(d_t == 1)); mean(d_ha(d_t == 2)); 
           mean(d_ha(d_t == 3)); mean(d_ha(d_t == 4)); mean(d_ha(d_t == 5)); 
           mean(d_ha(d_t == 6)); mean(d_ha(d_t == 7))]; 
  d_sG = dist_stat(sG);  d_sG = d_sG(:);
  md_sG = [mean(d_sG(d_t == 0)); mean(d_sG(d_t == 1)); mean(d_sG(d_t == 2)); 
           mean(d_sG(d_t == 3)); mean(d_sG(d_t == 4)); mean(d_sG(d_t == 5)); 
           mean(d_sG(d_t == 6)); mean(d_sG(d_t == 7))]; 
     
  
  figure % taxon distance
  subplot(3,4,1)
  plot(d_t(:), d_p(:), '.m', 0:7, md_p, 'ok')
  xlabel('taxon distance')
  ylabel('energetic distance')

  subplot(3,4,2)
  plot(d_t(:), d_pAm(:), '.m', 0:7, md_pAm, 'ok')
  xlabel('taxon distance')
  ylabel('{p_Am}/z distance')

  subplot(3,4,3)
  plot(d_t(:), d_v(:), '.m', 0:7, md_v, 'ok')
  xlabel('taxon distance')
  ylabel('v distance')

  subplot(3,4,4)
  plot(d_t(:), d_kap(:), '.m', 0:7, md_kap, 'ok')
  xlabel('taxon distance')
  ylabel('\kappa distance')

  subplot(3,4,5)
  plot(d_t(:), d_pM(:), '.m', 0:7, md_pM, 'ok')
  xlabel('taxon distance')
  ylabel('[p_M] distance')

  subplot(3,4,6)
  plot(d_t(:), d_kJ(:), '.m', 0:7, md_kJ, 'ok')
  xlabel('taxon distance')
  ylabel('k_J distance')

  subplot(3,4,7)
  plot(d_t(:), d_EG(:), '.m', 0:7, md_EG, 'ok')
  xlabel('taxon distance')
  ylabel('[E_G] distance')

  subplot(3,4,8)
  plot(d_t(:), d_EHb(:), '.m', 0:7, md_EHb, 'ok')
  xlabel('taxon distance')
  ylabel('E_H^b/z^3 distance')

  subplot(3,4,9)
  plot(d_t(:), d_EHj(:), '.m', 0:7, md_EHj, 'ok')
  xlabel('taxon distance')
  ylabel('E_H^j/z^3 distance')

  subplot(3,4,10)
  plot(d_t(:), d_EHp(:), '.m', 0:7, md_EHp, 'ok')
  xlabel('taxon distance')
  ylabel('E_H^p/z^3 distance')

  subplot(3,4,11)
  plot(d_t(:), d_ha(:), '.m', 0:7, md_ha, 'ok')
  xlabel('taxon distance')
  ylabel('h_a/z distance')

  subplot(3,4,12)
  plot(d_t(:), d_sG(:), '.m', 0:7, md_sG, 'ok')
  xlabel('taxon distance')
  ylabel('s_G distance')

end

  figure % Li - acceleration sM
  hold on
  %plot(log10(Li), log10(s_M), '.r', 'MarkerSize', 20)
  scatter(log10(Li(TYPE>0)), log10(s_M(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(s_M(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log(L_j/ L_b)')
  xlim([-2.5; 2.5]);
  ylim([0; 2]);
  txt_taxa(-2.2, 1.5, taxa, col_taxa);

  figure 
  subplot(1,3,1) % Li - ap
  %plot(log10(Li), log10(ap), '.r', 'MarkerSize', 20)
  scatter(log10(Li(TYPE>0)), log10(ap(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(ap(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log(L_\infty), cm')
  ylabel('_{10}log(a_p), d')
  xlim([-2.5; 2.5]);
  ylim([-1; 6.2]);
  txt_taxa(-2.2, 4, taxa, col_taxa);

  %figure
  subplot(1,3,2) % [p_M] - ap
  %plot(pM, ap, '.r', 'MarkerSize', 20)
  scatter(log10(pM(TYPE>0)), log10(ap(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(pM(TYPE>0 & s_M == 1)), log10(ap(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log [p_M], J cm^{-3} d^{-1}')
  ylabel('_{10}log a_p, d')
  xlim([-1; 5]);
  ylim([-1; 6.2]);
  %saveas (gca,'../pM_ap.png')

  %figure
  subplot(1,3,3) % [p_M] - Li/ap
  %plot(pM, ap, '.r', 'MarkerSize', 20)
  scatter(log10(pM(TYPE>0)), log10(Li(TYPE>0) ./ ap(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(pM(TYPE>0 & s_M == 1)), log10(Li(TYPE>0 & s_M == 1) ./ ap(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log [p_M], J cm^{-3} d^{-1}')
  ylabel('_{10}log (L_\infty/a_p), cm d^{-1}')
  xlim([-1; 5]);
  %ylim([-1; 6.2]);
  %saveas (gca,'../pM_ap.png')

  figure % Wi - specific respiration
  hold on
  %plot(lWdm, lVO, '.r', [-20; 20], [-7 - 20*3/4; -7 + 20*3/4], 'b')
  %plot(lWdm, lVO, '.r', 'MarkerSize', 20)
  VOWdm = VO./Wdm; % specific respiration
  scatter(log10(Wdm(TYPE>0)), log10(VOWdm(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Wdm(TYPE>0 & s_M == 1)), log10(VOWdm(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-20; 20], [-3 + 20/4; -3 - 20/4], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-10 10])
  xlabel('_{10}log max dry weight, g')
  %ylabel('_{10}log -J_O, L/h')
  ylabel('_{10}log(-J_O/W_d), L/g.h')
  txt_taxa(7, -2, taxa, col_taxa);
  
  figure % Li - yolkiness sE0
  hold on
  %logLi = log10(Li);
  %plot(logLi(twin<2   & TYPE == 1), s_E(twin<2 & TYPE == 1), '.b', 'MarkerSize', 20)
  %plot(logLi(twin<2   & TYPE == 3), s_E(twin<2 & TYPE == 3), 'ob', 'LineWidth', 2)
  %plot(logLi(twin>=2  & twin<4 & TYPE == 1), s_E(twin>=2 & twin<4 & TYPE == 1),  '.g', 'MarkerSize', 20)
  %plot(logLi(twin>=2  & twin<4 & TYPE == 3), s_E(twin>=2 & twin<4 & TYPE == 3),  'og', 'LineWidth', 2)
  %plot(logLi(twin>=4  & twin<8 & TYPE == 1), s_E(twin>=4 & twin<8 & TYPE == 1),  '.k', 'MarkerSize', 20)
  %plot(logLi(twin>=4  & twin<8 & TYPE == 3), s_E(twin>=4 & twin<8 & TYPE == 3),  'ok', 'LineWidth', 2)
  %plot(logLi(twin>=8  & twin<16 & TYPE == 1),s_E(twin>=8 & twin<16 & TYPE == 1), '.m', 'MarkerSize', 20)
  %plot(logLi(twin>=8  & twin<16 & TYPE == 3), s_E(twin>=8 & twin<16 & TYPE == 3), 'om', 'LineWidth', 2)
  %plot(logLi(twin>=16 & TYPE == 1), s_E(twin>=16 & TYPE == 1), '.r', 'MarkerSize', 20)
  %plot(logLi(twin>=16 & TYPE == 3), s_E(twin>=16 & TYPE == 3), 'or', 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), s_E(TYPE>0), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), s_E(TYPE>0 & s_M == 1), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-3;3], log10([2;2]), 'k-')
  plot([-3;3], log10([4;4]), 'k-')
  plot([-3;3], log10([8;8]), 'k-')
  ylim([0;2])
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log(E_0^{max}/ E_0^{min})')
  txt_taxa(-2.5, 1.4, taxa, col_taxa);
  
  figure % acceleration - yolkiness: sM - sE0
  hold on
  scatter(log10(s_M(TYPE == 1 | TYPE == 3)), s_E(TYPE == 1 | TYPE == 3), 60, color(TYPE == 1 | TYPE == 3,:), 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on','LineWidth', 2)
  xlabel('_{10}log(L_j/ L_b)')
  ylabel('_{10}log(E_0^{max}/ E_0^{min})')
  txt_taxa(1.7, 0.8, taxa, col_taxa);

  figure % acceleration - spec maturity at birth : sM - [EHb]
  logEHb = log10(EHb ./ Li.^3);
  scatter(log10(s_M(TYPE == 1 | TYPE == 3)), logEHb(TYPE == 1 | TYPE == 3), 60, color(TYPE == 1 | TYPE == 3,:), 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on','LineWidth', 2)
  xlabel('_{10}log(L_j/ L_b)')
  ylabel('_{10}log(E_H^b/ L_\infty^3), J/cm^3')
  txt_taxa(1.7, 0.8, taxa, col_taxa);

  figure % acceleration - altriciality: sM - sH
  %s_H = log10(EHp ./ EHb); % altriciality index
  scatter(log10(s_M(TYPE == 1 | TYPE == 3)), s_H(TYPE == 1 | TYPE == 3), 60, color(TYPE == 1 | TYPE == 3,:), 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on','LineWidth', 2)
  xlabel('_{10}log(L_j/ L_b)')
  ylabel('_{10}log(E_H^p/ E_H^b)')
  txt_taxa(1.8, 9, taxa, col_taxa);

  figure % acceleration - spec maturity at puberty : sM - [EHp]
  logEHp = log10(EHp ./ Li.^3);
  scatter(log10(s_M(TYPE == 1 | TYPE == 3)), logEHp(TYPE == 1 | TYPE == 3), 60, color(TYPE == 1 | TYPE == 3,:), 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on','LineWidth', 2)
  xlabel('_{10}log(L_j/ L_b)')
  ylabel('_{10}log(E_H^p/ L_\infty^3), J/cm^3')
  txt_taxa(1.8, 5, taxa, col_taxa);

  figure % neonate energy conductance - acceleration: v - sM
  logv = log10(v);
  scatter(log10(s_M(TYPE == 1 | TYPE == 3)), logv(TYPE == 1 | TYPE == 3), 60, color(TYPE == 1 | TYPE == 3,:), 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on','LineWidth', 2)
  xlabel('_{10}log(L_j/ L_b)')
  ylabel('_{10}log(v), cm/d')
  txt_taxa(1.8, -2.5, taxa, col_taxa);

  figure % Li - r_B
  hold on
  rB = kM / 3./ (1+1./g);
  scatter(log10(Li(TYPE > 0)), log10(rB(TYPE > 0)), 60, color(TYPE > 0,:), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(rB(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  % expected from generalised animal:
  L_i = 10.^(linspace(-2, 2, 100)); r_B = 18/ 2800/ 3 ./ (1 + 1 ./ (2800 * .02/ 22.5 ./ L_i));
  plot(log10(L_i), log10(r_B), 'k', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on','LineWidth', 2)
  xlabel('_{10}log(L_\infty)')
  ylabel('_{10}log(r_B), 1/d')
  txt_taxa(-2.5, -4, taxa, col_taxa);

  figure % Li - max spec reprod investment
  hold on
  pJp = kJ .* EHp ./ zj3;
  pRm = (1 - kap) .* pM ./ kap - pJp;
  plot(log10(Li(TYPE == 1 & ~vertebrata)), log10(pRm(TYPE == 1 & ~vertebrata)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(TYPE == 1 & vertebrata)), log10(pRm(TYPE == 1 & vertebrata)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(TYPE == 1 & endotherms)), log10(pRm(TYPE == 1 & endotherms)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(TYPE == 3 & ~vertebrata)), log10(pRm(TYPE == 3 & ~vertebrata)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(TYPE == 3 & vertebrata)), log10(pRm(TYPE == 3 & vertebrata)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(TYPE == 3 & endotherms)), log10(pRm(TYPE == 3 & endotherms)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log(p_R^m/ L_m^3), J/d.cm^3')
  txt_taxa(-2, -2, taxa_loc, col_loc);

  figure % Li - max spec mat maintenance
  hold on
  plot(log10(Li(sel_1)), log10(pJp(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), log10(pJp(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), log10(pJp(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), log10(pJp(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), log10(pJp(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), log10(pJp(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log(p_J^p/ L_m^3), J/d.cm^3')
  txt_taxa(-2, -4, taxa_loc, col_loc);

  figure % Li - mat maint relative to reprod
  hold on
  kapJ = pJp ./ (pJp + pRm);
  plot(log10(Li(sel_1)), kapJ(sel_1), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), kapJ(sel_2), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), kapJ(sel_3), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), kapJ(sel_4), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), kapJ(sel_5), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), kapJ(sel_6), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('p_J^p/ (p_J^p + p_R^m)')
  txt_taxa(-2, 0.6, taxa_loc, col_loc);

  figure % Wi - max reprod rate
  hold on
  scatter(log10(Wdm(TYPE > 0)), log10(Ri(TYPE > 0)), 60, color(TYPE > 0,:), 'LineWidth', 2)
  scatter(log10(Wdm(TYPE>0 & s_M == 1)), log10(Ri(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-10 10])
  xlabel('_{10}log max dry weight, g')
  ylabel('_{10}log max rep rate, #/d')
  txt_taxa(7, 3, taxa, col_taxa);

  figure % Li - max reprod rate
  hold on
  plot([-2; 2], log10(3.029) + [0;-4], 'b', 'LineWidth', 2) % DEB-expectation from Tab 8.1
  % value obtain from running pars_my_pet for z = 0.01
  plot(log10(Li(sel_1)), log10(Ri(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), log10(Ri(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), log10(Ri(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), log10(Ri(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), log10(Ri(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), log10(Ri(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log R_\infty, #/d')
  txt_taxa(-2, 5, taxa_loc, col_loc);

  figure % Li - max life span
  hold on
  plot(log10(Li(sel_1)), log10(am(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), log10(am(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), log10(am(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), log10(am(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), log10(am(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), log10(am(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log a_m, d')
  txt_taxa(-2, 5, taxa_loc, col_loc);

  figure % Li - max pop growth rate
  hold on
  plot([-2; 2], log10(.012721) + [0;-4], 'b', 'LineWidth', 2) % DEB-expectation from Tab 8.1
  % value obtain from running pars_my_pet for z = 0.01
  plot(log10(Li(sel_1)), log10(rm(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), log10(rm(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), log10(rm(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), log10(rm(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), log10(rm(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), log10(rm(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  %ylim([-4 0.75])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log r_m, d^{-1}')
  txt_taxa(-2, -3, taxa_loc, col_loc);

  figure % Li - max egg mass
  hold on
  plot([-2; 2], log10(2.509e-12) + [0;16], 'b', 'LineWidth', 2) % DEB-expectation from Tab 8.1
  % value obtain from running pars_my_pet for z = 0.01
  plot(log10(Li(sel_1)), log10(M_E0_max(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), log10(M_E0_max(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), log10(M_E0_max(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), log10(M_E0_max(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), log10(M_E0_max(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), log10(M_E0_max(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log M_{E0}^{max}, C-mol')
  txt_taxa(-2, -3, taxa_loc, col_loc);
  
  figure % altriciality index
  s_H = log10(EHp ./ EHb); % altriciality index
  %printpar(species, AI)
  hold on
  s_sH = surv(s_H, 0);
  s_sH_endo = surv(s_H(endotherms == 1), 0);
  plot(s_sH(:,1), s_sH(:,2),'g', 'Linewidth', 2)
  plot(s_sH_endo(:,1), s_sH_endo(:,2),'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('altriciality index, _{10}log(E_H^p/ E_H^b)')
  taxa_alt = {'all'; 'endo'}; col_alt = [0 1 0; 1 0 0];
  txt_taxa(6, 0.6, taxa_alt, col_alt);

  figure % Li- altriciality-index
  hold on
  plot(log10(Li(sel_1)), s_H(sel_1), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), s_H(sel_2), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), s_H(sel_3), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), s_H(sel_4), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), s_H(sel_5), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), s_H(sel_6), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log(E_H^p/ E_H^b)')
  txt_taxa(-2, 8, taxa_loc, col_loc);

  figure % acceleration - altriciality-index
  hold on
  plot(log10(s_M(sel_1)), s_H(sel_1), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(s_M(sel_2)), s_H(sel_2), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(s_M(sel_3)), s_H(sel_3), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(s_M(sel_4)), s_H(sel_4), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(s_M(sel_5)), s_H(sel_5), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(s_M(sel_6)), s_H(sel_6), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  %xlim([0 *])
  xlabel('_{10}log(L_j/ L_b)')
  ylabel('_{10}log(E_H^p/ E_H^b)')
  txt_taxa(1.5, 10, taxa_loc, col_loc);

  figure % Li- lp
  hold on
  plot(log10(Li(sel_1)), l_p(sel_1), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(Li(sel_2)), l_p(sel_2), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(Li(sel_3)), l_p(sel_3), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(Li(sel_4)), l_p(sel_4), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(Li(sel_5)), l_p(sel_5), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(Li(sel_6)), l_p(sel_6), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([-2.5 2.5])
  xlabel('_{10}log L_\infty, cm')
  ylabel('l_p')
  txt_taxa(-2, .9, taxa_loc, col_loc);

  figure % determinateness - altriciality
  hold on
  plot(l_p(sel_1), s_H(sel_1), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(l_p(sel_2), s_H(sel_2), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(l_p(sel_3), s_H(sel_3), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(l_p(sel_4), s_H(sel_4), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(l_p(sel_5), s_H(sel_5), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(l_p(sel_6), s_H(sel_6), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  %xlim([0 *])
  xlabel('l_p')
  ylabel('_{10}log(E_H^p/ E_H^b)')
  txt_taxa(.9, 10, taxa_loc, col_loc);

  figure % determinateness - acceleration
  hold on
  plot(l_p(sel_1), log10(s_M(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(l_p(sel_2), log10(s_M(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(l_p(sel_3), log10(s_M(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(l_p(sel_4), log10(s_M(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(l_p(sel_5), log10(s_M(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(l_p(sel_6), log10(s_M(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  %xlim([0 *])
  xlabel('l_p')
  ylabel('_{10}log(L_j/ L_b)')
  txt_taxa(.9, 1.5, taxa_loc, col_loc);

  figure % kappa - acceleration
  hold on
  plot(kap(sel_1), log10(s_M(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(kap(sel_2), log10(s_M(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(kap(sel_3), log10(s_M(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(kap(sel_4), log10(s_M(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(kap(sel_5), log10(s_M(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(kap(sel_6), log10(s_M(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([0 1])
  xlabel('kap')
  ylabel('_{10}log(L_j/ L_b)')
  txt_taxa(.1, 1.5, taxa_loc, col_loc);

  figure % [p_M] L_b - (1 - kap_G) [E_G] v
  x = pM .* Lb; y = (1 - kapG) .* EG  .* v;
  hold on
  plot(log10(x(sel_1)), log10(y(sel_1)), '.', 'MarkerSize', 20, 'Color', col_sel_1)
  plot(log10(x(sel_2)), log10(y(sel_2)), '.', 'MarkerSize', 20, 'Color', col_sel_2)
  plot(log10(x(sel_3)), log10(y(sel_3)), '.', 'MarkerSize', 20, 'Color', col_sel_3)
  plot(log10(x(sel_4)), log10(y(sel_4)), 'o', 'LineWidth', 2, 'Color', col_sel_4)
  plot(log10(x(sel_5)), log10(y(sel_5)), 'o', 'LineWidth', 2, 'Color', col_sel_5)
  plot(log10(x(sel_6)), log10(y(sel_6)), 'o', 'LineWidth', 2, 'Color', col_sel_6)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log([p_M] L_b), J/d.cm^2')
  ylabel('_{10}log((1-kap_G) [E_G] v), J/d.cm^2')
  txt_taxa(3, 0, taxa_loc, col_loc);
  
  figure % s_s - kap
  hold on
  %s_d = 4/27 - s_s;  % distance to demand end
  n = 100; sd = linspace(1e-6, 4/27 - 1e-10, n)'; ss = 4/27 - sd;
  kap_ss = zeros(n,2);
  for i = 1:n
      kap_ss(i,:) = roots3([-1; 1;  0; -ss(i)],2);
  end
  plot(ss, kap_ss(:,1), 'k', ...
       ss, kap_ss(:,2), 'k', 'Linewidth', 2)
  plot(s_s, kap, '.k', 'Markersize', 4)
  plot(s_s(fish==1), kap(fish==1), '.', 'Markersize', 20, 'Color', col_fish)
  plot(s_s(Amphibia==1), kap(Amphibia==1), '.', 'Markersize', 20, 'Color', col_Amph)
  plot(s_s(Chondrichthyes==1), kap(Chondrichthyes==1), '.', 'Markersize', 20, 'Color', col_Chon)
  plot(s_s(Reptilia==1), kap(Reptilia==1), '.', 'Markersize', 20, 'Color', col_Rept)
  plot(s_s(Aves==1), kap(Aves==1), '.', 'Markersize', 20, 'Color', col_Aves)
  plot(s_s(Mammalia==1), kap(Mammalia==1), '.', 'Markersize', 20, 'Color', col_Mamm)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('supply stress, -')
  ylabel('\kappa, -')
  ylim([0;1])
  xlim([0;0.15])
  txt_taxa(0.13, 0.2, taxa_vert, col_vert);

  figure % fmin - s_s
  hold on
  f = linspace(0,1,100)';
  plot(f, f.^3 * 4/27, 'k', 'Linewidth', 2)
  plot(fmin, s_s, '.k', 'Markersize', 4)
  plot(fmin(fish==1), s_s(fish==1), '.', 'Markersize', 20, 'Color', col_fish)
  plot(fmin(Amphibia==1), s_s(Amphibia==1), '.', 'Markersize', 20, 'Color', col_Amph)
  plot(fmin(Chondrichthyes==1), s_s(Chondrichthyes==1), '.', 'Markersize', 20, 'Color', col_Chon)
  plot(fmin(Reptilia==1), s_s(Reptilia==1), '.', 'Markersize', 20, 'Color', col_Rept)
  plot(fmin(Aves==1), s_s(Aves==1), '.', 'Markersize', 20, 'Color', col_Aves)
  plot(fmin(Mammalia==1), s_s(Mammalia==1), '.', 'Markersize', 20, 'Color', col_Mamm)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('min f for reprod, -')
  ylabel('supply stress, -')
  xlim([0;1])
  ylim([0;0.15])
  txt_taxa(0.1, 0.1, taxa_vert, col_vert);
  
  figure % s_s - kap - fmin
  hold on
  plot3(s_s, kap, fmin, '.k', 'Markersize', 4)
  plot3(s_s(fish==1), kap(fish==1), fmin(fish==1), '.', 'Markersize', 20, 'Color', col_fish)
  plot3(s_s(Amphibia==1), kap(Amphibia==1), fmin(Amphibia==1), '.', 'Markersize', 20, 'Color', col_Amph)
  plot3(s_s(Chondrichthyes==1), kap(Chondrichthyes==1), fmin(Chondrichthyes==1), '.', 'Markersize', 20, 'Color', col_Chon)
  plot3(s_s(Reptilia==1), kap(Reptilia==1), fmin(Reptilia==1), '.', 'Markersize', 20, 'Color', col_Rept)
  plot3(s_s(Aves==1), kap(Aves==1), fmin(Aves==1), '.', 'Markersize', 20, 'Color', col_Aves)
  plot3(s_s(Mammalia==1), kap(Mammalia==1), fmin(Mammalia==1), '.', 'Markersize', 20, 'Color', col_Mamm)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('supply stress, -')
  ylabel('\kappa, -')
  zlabel('min f for reprod, -')
  xlim([0;0.15])
  ylim([0;1])
  zlim([0;1])
  txt_taxa(0.125, 0.20, taxa_vert, col_vert);
