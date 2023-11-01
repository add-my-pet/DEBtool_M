%% sgr_iso_21_var
% specific growth rate for isomorph with 2 reserves 

%%
function [r, j_E1_S, j_E2_S, j_E1C, j_E2C, j_E1P, j_E2P, mode] = ...
    sgr_iso_21_var (m_E1, m_E2, j_E1S, j_E2S, mu_E1, mu_E2, mu_V, k_E, kap, y_VE1)
  % created: 2012/03/07 by Bas Kooijman, modified 2023/08/05
  
  %% Syntax
  % [r, j_E1_S, j_E2_S, j_E1C, j_E2C, j_E1P, j_E2P, mode] = <../sgr_iso_21_var.m *sgr_iso_21_var*> (m_E1, m_E2, j_E1S, j_E2S, mu_E1, mu_E2, mu_V, k_E, kap_G, kap, y_VE1) 

  %% Description
  % specific growth rate for isomorph with 2 reserves, allowing for shrinking and variable stoichiometry.
  % The anabolic part of growth is paid from reserve 1, but the catabolic part (growth overhead) and somatic maintenance
  %   can be paid from reserve 1 (with absolute preference above reserve 1), as well as from reserve 2.
  % 4 modes of growth/maintenance are delineated
  %
  % * mode 1: the E_2 flux that is allocated to soma is more than can be used for somatic maintenance plus growth overheads
  % * mode 2: the E_2 flux that is allocated to soma can cover all somatic maintenance, but not all growth overheads
  % * mode 3: the E_2 flux cannot cover all somatic maintenance, but growth is still positive, some of the costs needs to be covered from E_1
  % * mode 4: the E_1 and E_2 fluxes can cover only part of the somatic maintenance costs, and the remaining part has to be covered from shrinking of structure.
  %
  % Input:
  %
  % * m_E1, m_E2:   mol/mol,   scalars with reserve density
  % * j_E1S, j_E2S: mol/d.mol, scalars with spec maintenance flux if from reserve i
  % * mu_E1, mu_E2, mu_V:  -,  scalars with chem potential for reserve 1, 2, structure
  % * k_E:  1/d,               scalar with reserve turnover rate v/ L
  % * kap: -,                  scalar with allocation fraction to soma
  % * y_VE1; mol/mol           scalar with yield of structure on reserve 1
  %
  % Output:
  %
  % * r: 1/d,                  scalar with spec growth rate
  % * j_E1_S, j_E2_S: mol/d.mol, scalars with  actual spec som maintenance flux
  % * j_E1C, j_E2C: mol/d.mol, scalars with mobilised flux of reserves
  % * j_E1P, j_E2P: mol/d.mol, scalars with rejected flux of reserves
  % * mode: -,                 scalar for case indicator (1,2,3,4)
  
  %% remarks
  % spec growth rate r = j_VG and kap_G = mu_V*y_VE1/mu_E1
  % at max size, where r = 0:
  %  mode 1 can only occur if m_E1 = 0 and L_i is not well defined
  %  mode 2,3 L_i = kap * v * (mu_E1 * m_E1 + mu_E2 * m_E2)/ (mu_E2 * j_E2S);
  %  mode 4 only applies when shrinking
  %  if mu_E1 = mu_E2 = mu_E and m_E1 = m_E2 = m_E: L_m = kap * v * 2 * m_E / j_ES
  
  mode = 1; % the E_2 flux that is allocated to soma is more than can be used for somatic maintenance plus growth overheads
  r = kap * m_E1 * k_E/ (kap * m_E1 + mu_V/ mu_E1); % 1/d, spec growth rate
  j_E1C = m_E1 * (k_E - r); j_E2C = m_E2 * (k_E - r); % mol/d.mol, mobilization fluxes
  kap_G = y_VE1 * mu_V/ mu_E1; % -, growth efficiency (applies to all modes)
  j_E2G = (1 - kap_G) * r * mu_V/ mu_E2; % mol/d.mol, E2 allocation flux to growth
  j_E1P = 0; j_E2P = kap * j_E2C - j_E2S - j_E2G; % mol/d.mol, rejected fluxes
  j_E1_S = 0; j_E2_S = j_E2S; % mol/d.mol, allocation fluxes to somatic maintenance
  if m_E2 > (j_E2S + j_E2G)/ kap/ (k_E - r); return; end
  
  mode = 2; % the E_2 flux that is allocated to soma can cover all somatic maintenance, but not all growth overheads
  j_E1P = 0; j_E2P = 0; % mol/d.mol, rejected fluxes (applies to all further modes)
  r = (kap * k_E * (mu_E1 * m_E1 + mu_E2 * m_E2) - mu_E2 * j_E2S)/ (mu_E1/ y_VE1 + kap * (mu_E1 * m_E1 + mu_E2 * m_E2));
  j_E1C = m_E1 * (k_E - r); j_E2C = m_E2 * (k_E - r); % mol/d.mol, mobilization fluxes
  j_E1_S = 0; j_E2_S = j_E2S; % mol/d.mol, allocation fluxes to somatic maintenance
  if m_E2 > (j_E2S/ kap + r)/ k_E ; return; end
  
  mode = 3; % the E_2 flux cannot cover all somatic maintenance, but growth is still positive
  r = ((m_E1 + m_E2 * mu_E2/ mu_E1) * kap * k_E - j_E1S)/ (kap + kap * mu_E2/ mu_E1 + mu_E1/ y_VE1);
  j_E1C = m_E1 * (k_E - r); j_E2C = m_E2 * (k_E - r); % mol/d.mol, mobilization fluxes
  j_E2_S = kap * j_E2C; j_E1_S = j_E1S - j_E2_S * mu_E2/ mu_E1; % mol/d.mol, allocation fluxes to somatic maintenane
  if m_E1 + m_E2 * mu_E2/ mu_E1 > j_E2S/ k_E/ kap; return; end
 
  mode = 4; % the E_1 and E_2 fluxes can cover only part of the somatic maintenance costs
  r = - (mu_E1 * j_E1S - (mu_E1 * m_E1 + mu_E2 * m_E2) * k_E)/ (mu_V * kap_G + mu_E1 + mu_E2);
  j_E1C = m_E1 * (k_E - r); j_E2C = m_E2 * (k_E - r); % mol/d.mol, mobilization fluxes
  j_E2_S = kap * j_E2C; j_E1_S = kap * j_E2C; % mol/d.mol, allocation fluxes to somatic maintenane
  
end
