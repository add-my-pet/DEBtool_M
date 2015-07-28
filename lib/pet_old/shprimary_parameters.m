function [pars vars TYPE FIT COMPLETE] = shprimary_parameters 
% created at 2013/08/01 by Bas Kooijman 
%
%% Description
%  plots parameters in Species.xls, which can be found at http://www.bio.vu.nl/thb/deb/deblab/
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
%  [pars vars TYPE FIT COMPLETE] = shprimary_parameters 

  file = '/add_my_pet/Species.xls';
  read_Species

  if 0
    mv = mean(v); mvj = mean(vj);
    cv = std(v)/mv; cvj = std(vj)/mvj; % -, variation coeff of v, vj
    txt = {'before acceleration'; 'after acceleration'};
    printpar(txt, [mv; mvj], [cv; cvj], 'energy conductance mean, var coeff');
  end
  
  close all
  
if 1
    
  figure % L_i 
  hold on
  surv_Li = surv(Li, 0);
  m_Li = sum(Li  > 1)/ n_species;
  plot(surv_Li(:,1), surv_Li(:,2),'g', 'Linewidth', 2)
  plot([0; 1; 1], [m_Li; m_Li; 0], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  ylim([0;1]);
  xlabel('L_\infty, cm')
  
  figure % v
  hold on
  surv_v = surv(v,0);  surv_vj = surv(vj,0); 
  m_v = sum(v > .02)/ n_species;
  plot(surv_v(:,1), surv_v(:,2),'b', 'Linewidth', 2)
  plot(surv_vj(:,1), surv_vj(:,2),'r', 'Linewidth', 2)
  plot([0; .02; .02], [m_v; m_v; 0], 'g', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('v, cm d^{-1}')
  taxa_loc = {'v_b'; 'v_j'}; col_taxa_loc = [0 0 1; 1 0 0];
  txt_taxa(1, .8, taxa_loc, col_taxa_loc);

  figure % L_i - v
  hold on
  scatter(log10(Li(TYPE>0)), log10(vj(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), log10(v(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(v(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2;2], [log10(0.02); log10(0.02)],'b', 'linewidth', 2)
  for i = 1:n_species
    if TYPE(i) > 0 && s_M(i) > 1 % TYPE(i) == 3 || TYPE(i) == 4
      %plot(log10(Li(i)), log10(v(i)), 'ob', 'linewidth', 2)
      %plot(log10(Li(i)), log10(vj(i)), 'or', 'linewidth', 2)
      plot(log10(Li(i) * ones(2,1)), log10([vj(i); v(i)]),'-k', 'Linewidth', 2)
    %elseif TYPE(i) == 1 || TYPE(i) == 2
      %plot(log10(Li(i)), log10(v(i)), '.b', 'markersize', 20)
    end
  end
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  %set(gca, 'ylim', [-3 0.5], 'YTick', -2:.5:0.5)
  xlabel('_{10}log L_\infty, cm', 'FontSize', 15)
  ylabel('_{10}log v, cm d^{-1}', 'FontSize', 15)
  txt_taxa(-2, 0.85, taxa, col_taxa);

  figure % kap
  hold on
  surv_kap = surv(kap,0);  
  m_kap = sum(kap > .8)/ n_species;
  plot(surv_kap(:,1), surv_kap(:,2),'g', 'Linewidth', 2)
  plot([0; .8; .8], [m_kap; m_kap; 0], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('\kappa, -')

  figure % L_i - kap
  hold on
  scatter(log10(Li(TYPE>0)), kap(TYPE>0), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), kap(TYPE>0 & s_M == 1), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], 0.8 * [1; 1], 'b', 'linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  %set(gca, 'ylim', [0 1], 'YTick', 0:.2:1)
  xlabel('_{10}log L_\infty, cm')
  ylabel('\kappa, -')
  txt_taxa(-2.2, 0.3, taxa, col_taxa);

  figure % [p_M]
  hold on
  surv_pM = surv(pM,0);  
  m_pM = sum(pM > 20)/ n_species;
  plot(surv_pM(:,1), surv_pM(:,2),'g', 'Linewidth', 2)
  plot([0; 20; 20], [m_pM; m_pM; 0], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('[p_M], J cm^{-1} d^{-1}')

  figure % L_i - [p_M]
  hold on
  %scatter(log10(Li(TYPE>0)), log10(pM(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li), log10(pM), 60, color, 'LineWidth', 2)
  %scatter(log10(Li(TYPE>0 & s_M == 1)), log10(pM(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  scatter(log10(Li(s_M == 1)), log10(pM(s_M == 1)), 20, color(s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(18) * [1; 1], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  set(gca, 'ylim', [.25 4], 'YTick', 0.5:1:4)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log [p_M], J cm^{-3} d^{-1}')
  txt_taxa(2, 3, taxa, col_taxa);

  figure % L_i - p_M
  hold on
  pMLi3 = pM .* Li.^3;
  %scatter(log10(Li(TYPE>0)), log10(pM(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li), log10(pMLi3), 60, color, 'LineWidth', 2)
  %scatter(log10(Li(TYPE>0 & s_M == 1)), log10(pM(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  scatter(log10(Li(s_M == 1)), log10(pMLi3(s_M == 1)), 20, color(s_M == 1, :), 'LineWidth', 4)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  %set(gca, 'ylim', [.25 4], 'YTick', 0.5:1:4)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log p_M, J d^{-1}')
  txt_taxa(2, 3, taxa, col_taxa);

  figure % L_i - [p_M]/ d_V
  pMdV = pM ./ dV;
  hold on
  scatter(log10(Li(TYPE>0)), log10(pMdV(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(pMdV(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(180) * [1; 1], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  %set(gca, 'ylim', [.25 4], 'YTick', 0.5:1:4)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log [p_M]/d_V, J g^{-1} d^{-1}')
  txt_taxa(2, 4.5, taxa, col_taxa);

  figure % kap - [p_M]
  hold on
  scatter(kap(TYPE>0), log10(pM(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(kap(TYPE>0 & s_M == 1), log10(pM(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  set(gca, 'FontSize', 15, 'Box', 'on')
  %set(gca, 'xlim', [0 1])
  %set(gca, 'ylim', [.25 4], 'YTick', 0.5:1:4)
  xlabel('\kappa, -')
  ylabel('_{10}log [p_M], J cm^{-3} d^{-1}')
  txt_taxa(.1, .5, taxa, col_taxa);

  figure % k_J
  hold on
  surv_kJ = surv(kJ,0);  
  m_kJ = sum(kJ > .002)/ n_species;
  plot(surv_kJ(:,1), surv_kJ(:,2),'g', 'Linewidth', 2)
  plot([0; .002; .002], [m_kJ; m_kJ; 0], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('k_J, d^{-1}')

  figure % L_i - k_J
  hold on
  %plot(log10(Li(TYPE == 1 | TYPE == 2)), log10(kJ(TYPE == 1 | TYPE == 2)),'.b', 'Markersize', 20)
  %plot(log10(Li(TYPE == 3 | TYPE == 4)), log10(kJ(TYPE == 3 | TYPE == 4)),'ob', 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), log10(kJ(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(kJ(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(0.002) * [1; 1], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  set(gca, 'ylim', [-8 -.5], 'YTick', -8:2:1)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log k_J, d^{-1}')
  txt_taxa(-2, -6, taxa, col_taxa);

  figure % [E_G]
  hold on
  surv_EG = surv(EG,0);  
  m_EG = sum(EG > 2800)/ n_species;
  plot(surv_EG(:,1), surv_EG(:,2),'g', 'Linewidth', 2)
  plot([0; 2800; 2800], [m_EG; m_EG; 0], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('[E_G], J cm^{-1}')
  
  figure% [E_G]/ d_V
  EGdV = EG ./ dV;
  surv_EGdV = surv(EGdV,0);
  plot(surv_EGdV(:,1), surv_EGdV(:,2),'g', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('[E_G]/ d_V, J g^{-1}')

  figure % L_i - [E_G]/ d_V
  hold on
  %plot(log10(Li(TYPE == 1 | TYPE == 2)), log10(EGdV(TYPE == 1 | TYPE == 2)),'.b', 'MarkerSize', 20)
  %plot(log10(Li(TYPE == 3 | TYPE == 4)), log10(EGdV(TYPE == 3 | TYPE == 4)),'ob', 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), log10(EGdV(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(EGdV(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(28000) * [1; 1], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  set(gca, 'ylim', [4.3 4.8], 'YTick', 4.3:.1:4.8)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log [E_G]/d_V, J g^{-1}')
  txt_taxa(-2, 4.65, taxa, col_taxa);


  figure % {p_Am}/ L_i
  hold on
  pAmLi = pAm ./ Li;
  surv_pAm = surv(log10(pAmLi), 0);
  EpAmLi = 20/ 0.8; % J/d.cm^3, expected  {p_Am}/L_i for generlized animal
  m_pAm = sum(log10(pAmLi)  > log10(EpAmLi))/ n_species;
  plot(surv_pAm(:,1), surv_pAm(:,2),'g', 'Linewidth', 2)
  plot([surv_pAm(1,1); log10(EpAmLi); log10(EpAmLi)], [m_pAm; m_pAm; 0], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log \{p_{Am}\}/L_\infy, J cm^{-3} d^{-1}')

  figure % L_i - {p_Am}
  hold on
  scatter(log10(Li(TYPE>0)), log10(pAmj(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), log10(pAm(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(pAm(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  %plot(log10(Li(TYPE == 1 | TYPE == 2)), log10(pAm(TYPE == 1 | TYPE == 2)),'.b', 'MarkerSize', 20)
  %plot(log10(Li(TYPE == 3 | TYPE == 4)), log10(pAm(TYPE == 3 | TYPE == 4)),'ob', 'LineWidth', 2)
  %plot(log10(Li(TYPE == 3 | TYPE == 4)), log10(pAmj(TYPE == 3 | TYPE == 4)),'or', 'LineWidth', 2)
  plot([-2; 2], log10(22.5) + [-2; 2], 'b', 'LineWidth', 2)
  for i = 1:n_species
    if TYPE(i) > 0 && s_M(i) > 1 % TYPE(i) == 3 || TYPE(i) == 4
      plot(log10(Li(i) * ones(2,1)), log10([pAmj(i); pAm(i)]),'-k', 'Linewidth', 2)
    end
  end
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  set(gca, 'ylim', [-.5 4.5], 'YTick', 0:1:4)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log \{p_{Am}\}, J cm^{-2} d^{-1}')
  txt_taxa(-2, 3.5, taxa, col_taxa);
  
  figure % {p_Am} - [p_M] - kap
  hold on
  plot3(log10(pAmj), log10(pM), kap, '.k', 'Markersize', 4)
  plot3(log10(pAmj(fish==1)), log10(pM(fish==1)), kap(fish==1), '.', 'Markersize', 20, 'Color', col_fish)
  plot3(log10(pAmj(Amphibia==1)), log10(pM(Amphibia==1)), kap(Amphibia==1), '.', 'Markersize', 20, 'Color', col_Amph)
  plot3(log10(pAmj(Chondrichthyes==1)), log10(pM(Chondrichthyes==1)), kap(Chondrichthyes==1), '.', 'Markersize', 20, 'Color', col_Chon)
  plot3(log10(pAmj(Reptilia==1)), log10(pM(Reptilia==1)), kap(Reptilia==1), '.', 'Markersize', 20, 'Color', col_Rept)
  plot3(log10(pAmj(Aves==1)), log10(pM(Aves==1)), kap(Aves==1), '.', 'Markersize', 20, 'Color', col_Aves)
  plot3(log10(pAmj(Mammalia==1)), log10(kap(Mammalia==1)), kap(Mammalia==1), '.', 'Markersize', 20, 'Color', col_Mamm)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log \{p_{Am}\}, J cm^{-2} d^{-1}')
  ylabel('_{10}log [p_M], J cm^{-3} d^{-1}')
  zlabel('\kappa, -')
  txt_taxa(0.125, 0.20, taxa_vert, col_vert);
  
  figure % E_H^b/ L_i^3
  surv_EHb = surv(log10(EHb ./ Li.^3), 0);
  plot(surv_EHb(:,1), surv_EHb(:,2),'g', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log E_H^b/ L_\infty^3, J/cm^2')

  figure % L_i - E_H^b
  hold on
  %plot(log10(Li(TYPE == 1 | TYPE == 2)), log10(EHb(TYPE == 1 | TYPE == 2)),'.b', 'MarkerSize', 20)
  %plot(log10(Li(TYPE == 3 | TYPE == 4)), log10(EHb(TYPE == 3 | TYPE == 4)),'ob', 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), log10(EHb(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(EHb(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(275) - 3 + [-6; 6], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  %set(gca, 'ylim', [-10 10], 'YTick', -10:5:10)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log E_H^b')
  txt_taxa(-2, 3.5, taxa, col_taxa);
  
  figure % E_H^j/ L_i^3
  surv_EHj = surv(log10(EHj ./ Li.^3), 0);
  plot(surv_EHj(:,1), surv_EHj(:,2),'g', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10} log E_H^j/ L_\infty^3, J/cm^3')

  figure % L_i - E_H^j
  hold on
  %plot(log10(Li(TYPE == 1 | TYPE == 2)), log10(EHj(TYPE == 1 | TYPE == 2)),'.b', 'MarkerSize', 20)
  %plot(log10(Li(TYPE == 3 | TYPE == 4)), log10(EHj(TYPE == 3 | TYPE == 4)),'ob', 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), log10(EHj(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(EHj(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(275) - 3 + [-6; 6], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  set(gca, 'ylim', [-7 9], 'YTick', -10:3:10)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log E_H^j')
  txt_taxa(-2, 3.5, taxa, col_taxa);

  figure % E_H^p/ L_i^3
  surv_EHp = surv(log10(EHp ./ Li.^3), 0);
  plot(surv_EHp(:,1), surv_EHp(:,2),'g', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('_{10}log E_H^p/ L_\infty^3, J/cm^3')

  figure % L_i - E_H^p
  hold on
  %plot(log10(Li(TYPE == 1 | TYPE == 2)), log10(EHp(TYPE == 1 | TYPE == 2)),'.b', 'MarkerSize', 20)
  %plot(log10(Li(TYPE == 3 | TYPE == 4)), log10(EHp(TYPE == 3 | TYPE == 4)),'ob', 'LineWidth', 2)
  scatter(log10(Li(TYPE>0)), log10(EHp(TYPE>0)), 60, color(TYPE>0, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & s_M == 1)), log10(EHp(TYPE>0 & s_M == 1)), 20, color(TYPE>0 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(166) + [-6; 6], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  %set(gca, 'ylim', [-5 10], 'YTick', -5:5:10)
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log E_H^p')
  txt_taxa(-2, 3.5, taxa, col_taxa);

  figure % L_i - h_a
  hold on
  scatter(log10(Li(TYPE>0 & sG < 1e-3)), log10(ha(TYPE>0 & sG < 1e-3)), 60, color(TYPE>0 & sG < 1e-3, :), 'LineWidth', 2)
  scatter(log10(Li(TYPE>0 & sG < 1e-3 & s_M == 1)), log10(ha(TYPE>0 & sG < 1e-3 & s_M == 1)), 20, color(TYPE>0 & sG < 1e-3 & s_M == 1, :), 'LineWidth', 4)
  plot([-2; 2], log10(1e-6) + [2; -2], 'b', 'LineWidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  set(gca, 'xlim', [-2.5 2.5], 'XTick', -2:1:2)
  set(gca, 'ylim', [-15 0])
  xlabel('_{10}log L_\infty, cm')
  ylabel('_{10}log h_a, d^{-2}')
  txt_taxa(-2, -11, taxa, col_taxa);

end

  figure % FIT
  hold on
  surv_FIT = surv(FIT,0);  
  m_FIT = sum(FIT)/ n_species; 
  M_FIT = sum(FIT > m_FIT)/ n_species;
  plot(surv_FIT(:,1), surv_FIT(:,2),'g', 'Linewidth', 2)
  plot([m_FIT; m_FIT; 0], [0; M_FIT; M_FIT], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlim([0 10]);
  xlabel('FIT mark')
  fprintf(['mean FIT ', num2str(mean(FIT)), '\n'])

  figure % COMPLETE
  hold on
  surv_COMPLETE = surv(COMPLETE,0);  
  m_COMPLETE = sum(COMPLETE)/ n_species; 
  M_COMPLETE = sum(COMPLETE > m_COMPLETE)/ n_species;
  plot(surv_COMPLETE(:,1), surv_COMPLETE(:,2),'g', 'Linewidth', 2)
  plot([m_COMPLETE; m_COMPLETE; 0], [0; M_COMPLETE; M_COMPLETE], 'r', 'Linewidth', 2)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('COMPLETE mark')

  figure % COMPLETE - FIT
  plot(COMPLETE, FIT,'.r','MarkerSize', 20)
  set(gca, 'FontSize', 15, 'Box', 'on')
  xlabel('COMPLETE mark')
  ylabel('FIT mark')
  
  figure % number of entries
  date_ampm = max(date_amp);
  t_amp = linspace(1,date_ampm,100)'; n_amp = zeros(100,1);
  for i=1:100
      n_amp(i) = sum(t_amp(i) > date_amp);
  end
  %date_max = datenum([2015 02 12]) - datenum([2009 02 12]);
  plot(t_amp, n_amp, 'k');
  xlabel('time since start, d')
  ylabel('entries, #')

