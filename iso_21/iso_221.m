%% iso_221
% Obtains fluxes in case of 2-food, 2-reserve, 1-structure isomorph with fixed stoichiometry for growth

%%
function [var flux] = iso_221(tXT, var_0, p, n_O, n_M, r0)
  % created 2011/04/29 by Bas Kooijman, modified 2012/01/30

  %% Syntax
  % [var flux] = <../iso_221.m *iso_221*> (tXT, var_0, p, n_O, n_M, r0)

  %% Description
  % Obtains fluxes in case of 2-food, 2-reserve, 1-structure isomorph with fixed stoichiometry for growth
  %
  % Input:
  %
  % * tXT: (n,4)-matrix of time, food densities, temperature
  %
  %  assumption: tXT(1,1) = 0: time that applies to vars_0
  %
  % * var_0: 13-vector with values of state variables at t = 0; see under var
  % * p: vector of parameters (see diso_221)
  % * n_O: (4,7)-matrix with chemical indices for organics X1, X2, V, E1, E2, P1, P2
  % * n_M: (4,4)-matrix with chemical indices for minerals C, H, O, N
  % * r0: optional scalar with initial estimate for spec growth rate r
  %
  % Output:
  %
  % * var: (n,13)-matrix with variables
  %
  %        1      2     3       4      5        6   7        8      9      10  11 12 13
  %    cM_X1  cM_X2  M_E1    M_E2    E_H  max_E_H M_V  max_M_V cM_ER1  cM_ER2   q  h  S
  %    cum food eaten, reserves, (max)structure, (max)maturity , cumulative, allocation to reprod, acell, hazard, surv prob
  %
  % * flux: (n,20)-matrix with fluxes
  %
  %     f1, f2: func responses
  %     J_X1A, J_X2A: food eaten
  %     J_E1A, J_E2A: assimilation
  %     J_EC1, J_EC2: mobilisation
  %     J_EM1, J_EM2: somatic maintenance
  %     J_VG: growth
  %     J_E1J, J_E2J: maturity maintenance
  %     J_E1R, J_E2R: maturation
  %     R: reproduction rate
  %     J_C, J_H, J_O, J_N: fluxes of  CO2, H20, O2, NH3

  %% Remarks
  % see <iso_221_var.html *iso_221_var*> for variable stoichiometry;
  % model is presented in comment for 5.2.7 of DEB3

  % unpack some parameters, see diso_211 for a full list
  M_X1      = p( 1); M_X2      = p( 2); % mol, size of food particle of type i
  F_X1m     = p( 3); F_X2m     = p( 4); % dm^2/d.cm^2, {F_Xim} spec searching rates
  y_E1X1    = p( 7); y_E2X1    = p( 8); % mol/mol, yield of reserve Ei on food X1
  y_E1X2    = p( 9); y_E2X2    = p(10); % mol/mol, yield of reserve Ei on food X2
  J_X1Am    = p(11); J_X2Am    = p(12); % mol/d.cm^2, {J_XiAm} max specific ingestion rate for food Xi
  v         = p(13); kap       = p(14); % cm/d, energy conductance, 
                                        % -, allocation fraction to soma
  mu_E1     = p(15); mu_E2     = p(16); % J/mol, chemical potential of reserve i
  mu_V      = p(17); j_E1M     = p(18); % J/mol, chemical potential of structure
                                        % mol/d.mol, spec som maint for reserve 1
  J_E1T     = p(19); MV        = p(20); % mol/d.cm^2, {J_E1T}, spec surface-area-linked som maint costs J_E1T/ J_E2T = j_E1M/ j_E2M
                                        % mol/cm^3, [M_V] density of structure
  k_J       = p(21);                    % 1/d, maturity maint rate coefficient
  rho1      = p(23);                    % -, preference for reserve 1 for som maintenance
  y_VE1     = p(25); y_VE2     = p(26); % mol/mol, yield of structure on reserve i 
  kap_E1    = p(27); kap_E2    = p(28); % -, fraction of rejected mobilised flux that is returned to reserve
  E_Hb      = p(31);                    % J, maturity at birth
  T_A       = p(33);                    % K, Arrhenius temperature

  % initialize r in sgr_iso_21 via call to sgr_iso_21 with r_0 specified; sgr_iso_21 works with continuation
  %   first get dL_0 from gr_iso_21; previous call to iso_21 left gr_iso_21 v_B at start
  TC = tempcorr(tXT(1,4), 293, T_A); % -, temperature correction factor, T_ref = 293 K
  M_V_0 = var_0(7);               % mol, initial structural mass
  L_0 = (M_V_0/ MV)^(1/3);        % cm, initial structural length
  m_E10 = var_0(3)/ M_V_0;        % mol/mol, initial reserve 1 density
  m_E20 = var_0(4)/ M_V_0;        % mol/mol, initial reserve 2 density
  j_E2M = j_E1M * mu_E1/ mu_E2;   % mol/d.mol, spec som maint for 2
  J_E2T = J_E1T * mu_E2/ mu_E1;   % mol/d.cm^2
  j_E2S = j_E2M + J_E2T/ MV/ L_0; % mol/d.mol
  j_E1S = j_E1M + J_E1T/ MV/ L_0; % mol/d.mol total spec somatic maint
  dL_0 = gr_iso_21(L_0, m_E10, m_E20, TC * j_E1M, TC * j_E2M, y_VE1, y_VE2, TC * v, kap, rho1); % cm/d, change in L at birth
  mu_EV = mu_E1/ mu_V; k_E = v/ L_0;% -, 1.d: ratio of chem pot, reserve turnover rate

  if exist('r0', 'var') == 0
    r0 = [];
  end
  if isempty(r0)    
    r0 = 3 * dL_0/ L_0; % 1/d, specific growth rate at birth at T(0), but som maint might change at birth
  end

  r = sgr_iso_21 (m_E10, m_E20, TC * j_E1S, TC * j_E2S, y_VE1, y_VE2, mu_EV, TC * k_E, kap, rho1, r0); % 1/d, sgr

  % get variables
  [t var] = ode45(@diso_221, tXT(:,1), var_0, [], tXT, p);

  % unpack some variables
  M_E1 = var(:,3); M_E2 = var(:,4); E_H = var(:,5); M_V = var(:,7); 
  m_E1 = M_E1 ./ M_V; m_E2 = M_E2 ./ M_V;

  % get fluxes
  X1 = tXT(:,2); X2 = tXT(:,3);   % M, food densities
  J_E1Am_X1 = y_E1X1 * J_X1Am; J_E1Am_X2 = y_E1X2 * J_X2Am; % mol/d.cm^2, max spec assim rate for reserve 1 
  J_E2Am_X1 = y_E2X1 * J_X1Am; J_E2Am_X2 = y_E2X2 * J_X2Am; % mol/d.cm^2, max spec assim rate for reserve 2
  m_E1m = max(J_E1Am_X1/ v/ MV, J_E1Am_X2/ v/ MV);
  m_E2m = max(J_E2Am_X1/ v/ MV, J_E2Am_X2/ v/ MV);
  s1 = max(0, 1 - m_E1/ m_E1m); s2 = max(0, 1 - m_E2/ m_E2m);
  rho_X1X2 = s1 * max(0, M_X1/ M_X2 * y_E1X1/ y_E1X2 - 1) + s2 * max(0, M_X1/ M_X2 * y_E2X1/ y_E2X2 - 1);
  rho_X2X1 = s1 * max(0, M_X2/ M_X1 * y_E1X2/ y_E1X1 - 1) + s2 * max(0, M_X2/ M_X1 * y_E2X2/ y_E2X1 - 1);
  h_X1Am = J_X1Am/ M_X1; h_X2Am = J_X2Am/ M_X2;
  alpha_X1 = h_X1Am + F_X1m * X1 + F_X2m * rho_X2X1 .* X2; 
  alpha_X2 = h_X2Am + F_X2m * X2 + F_X1m * rho_X1X2 .* X1;
  beta_X1 = F_X1m * X1 .* (1 - rho_X1X2); beta_X2 = F_X2m * X2 .* (1 - rho_X2X1);
  f1 = (alpha_X2 * F_X1m .* X1 - beta_X1 * F_X2m .* X2) ./ (alpha_X1 .* alpha_X2 - beta_X1 .* beta_X2);
  f2 = (alpha_X1 * F_X2m .* X2 - beta_X2 * F_X1m .* X1) ./ (alpha_X1 .* alpha_X2 - beta_X1 .* beta_X2);
  f1 = f1 .* (E_H > E_Hb); f2 = f2 .* (E_H > E_Hb); % -, no feeding in embryo

  % more quantities are planned in future releases, such as respiration, which involves n_O and n_M
  flux = [f1, f2, s1, s2, rho_X1X2, rho_X2X1]; 
