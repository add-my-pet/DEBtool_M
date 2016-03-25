%% iso_21_b_var
% gets values of state variables at birth

%%
function [var_b a_b M_E10 M_E20] = iso_21_b_var(X1X2, p)
  
  %% Syntax
  % [var_b a_b M_E10 M_E20] = <../iso_21_b_var.m *iso_21_b_var*> (X1X2, p)

  %% Description
  % gets values of state variables at birth; assumption: no aging during embryo stage
  %
  % Input:
  %
  % * X1X2: 2-vector with food densities to specify the maternal effect
  % * p: 37-vector with parameters, see diso_211_var for a full list
  %
  % Output:
  %
  % * var_b: 13-vector with state variables:
  %      cM_X1, cM_X2, M_E1, M_E2, E_H, max_E_H, M_V, max_M_V, cM_ER1, cM_ER2, q, h,  S
  % * a_b: scalar with age at birth
  % * M_E10, M_E20: scalars with intitial reserves

  % unpack some parameters
  F_X1m     = p( 3); F_X2m     = p( 4); % dm^2/d.cm^2, {F_Xim} spec searching rates
  y_E1X1    = p( 7); y_E2X1    = p( 8); % mol/mol, yield of reserve Ei on food X1
  y_E1X2    = p( 9); y_E2X2    = p(10); % mol/mol, yield of reserve Ei on food X2
  J_X1Am    = p(11); J_X2Am    = p(12); % mol/d.cm^2, {J_XiAm} max specific ingestion rate for food Xi
  v         = p(13); kap       = p(14); % cm/d, energy conductance, 
                                        % -, allocation fraction to soma
  mu_E1     = p(15); mu_E2     = p(16); % J/mol, chemical potential of reserve i
  mu_V      = p(17); j_E1M     = p(18); % J/mol, chemical potential of structure
                                        % mol/d.mol, spec som maint for reserve 1
  MV        = p(20);                    % mol/cm^3, [M_V] density of structure
  k_J       = p(21);                    % 1/d, maturity maint rate coefficient
  kap_G     = p(23);                    % -, growth efficiency
  kap_E1    = p(25); kap_E2    = p(26); % -, fraction of rejected mobilised flux that is returned to reserve
  E_Hb      = p(29);                    % J, maturity at birth
  T_A       = p(31);                    % K, Arrhenius temperature

  % get state at birth and M_E0
  X1 = X1X2(1); X2 = X1X2(2);                                   % M, food densities
  K1 = J_X1Am/ F_X1m; K2 = J_X2Am/ F_X2m;                       % M, half saturation coefficients
  f1 = X1/ (X1 + K1); f2 = X2/ (X2 + K2);                       % -, scaled functional responses
  J_E1Am_X1 = y_E1X1 * J_X1Am; J_E2Am_X1 = y_E2X1 * J_X1Am;     % mol/d, max assim rate
  J_E1Am_X2 = y_E1X2 * J_X2Am; J_E2Am_X2 = y_E2X2 * J_X2Am;     % mol/d, max assim rate
  m_E1b = max(f1 * J_E1Am_X1/ v/ MV, f2 * J_E1Am_X2/ v/ MV);    % mol/mol, reserve density 1 at birth
  m_E2b = max(f1 * J_E2Am_X1/ v/ MV, f2 * J_E2Am_X2/ v/ MV);    % mol/mol, reserve density 2 at birth
  pars_iso_21 = [v; kap; mu_E1; mu_E2; mu_V; j_E1M; MV; k_J; kap_G; kap_E1; kap_E2; E_Hb];
  [L_b a_b M_E10 M_E20 info] = iso_21_var(m_E1b, m_E2b, pars_iso_21); % a_b is not corrected for temperature!
  if info == 0
    fprintf('warning in iso_21: no convergence for embryo states \n')
  end
  M_Vb = MV * L_b^3; M_E1b = m_E1b * M_Vb; M_E2b = m_E2b * M_Vb; % mol, masses at birth

  % compose variables at birth
  %        1     2       3       4      5      6     7      8      9      10     11 12 13
  %      cM_X1  cM_X2  M_E1    M_E2    E_H  max_E_H M_V  max_M_V cM_ER1  cM_ER2   q  h  S
  var_b = [0,    0,   M_E1b,  M_E2b,  E_Hb,  E_Hb, M_Vb,  M_Vb,    0,      0,     0  0  1]; % mol, 
