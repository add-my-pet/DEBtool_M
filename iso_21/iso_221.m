%% iso_221
% Obtains coefficients in case of 2-food, 2-reserve, 1-structure isomorph with fixed stoichiometry for growth

%%
function [var, coeff] = iso_221(tX12T, var_0, p, n_O, n_M, r0)
  % created 2011/04/29 by Bas Kooijman, modified 2012/01/30, 2023/07/26

  %% Syntax
  % [var, coeff] = <../iso_221.m *iso_221*> (tXT, var_0, p, n_O, n_M, r0)

  %% Description
  % Obtains coefficients in case of 2-food, 2-reserve, 1-structure isomorph with fixed stoichiometry for growth
  %
  % Input:
  %
  % * tXT: (n,4)-matrix of time, food densities, temperature
  %
  %  assumption: tXT(1,1) = 0: time that applies to vars_0
  %
  % * var_0: 13-vector with values of state variables at t = 0; see under var
  % * p: structure of parameters (see mydata_iso_221)
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
  % * coeff: (n,20)-matrix with coefficients
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

  % initialize r in sgr_iso_21 via call to sgr_iso_21 with r_0 specified; sgr_iso_21 works with continuation
  %   first get dL_0 from gr_iso_21; previous call to iso_21 left gr_iso_21 v_B at start
  TC = tempcorr(tX12T(1,4), 293, p.T_A); % -, temperature correction factor, T_ref = 293 K
  vT = TC * p.v;                  % cm/d, temp-corrected energy conductance 
  M_V_0 = var_0(7);               % mol, initial structural mass (at birth)
  L_0 = (M_V_0/ p.MV)^(1/3);      % cm, initial structural length (at birth)
  m_E10 = var_0(3)/ M_V_0;        % mol/mol, initial reserve 1 density (at birth)
  m_E20 = var_0(4)/ M_V_0;        % mol/mol, initial reserve 2 density (at birth)
  jT_E1M = TC * p.j_E1M;          % mol/d.mol, spec som maint for 1
  jT_E2M = jT_E1M * p.mu_E1/ p.mu_E2;   % mol/d.mol, spec som maint for 2
  JT_E1T = TC * p.J_E1T;          % mol/d.cm^2, area-spec som maint
  JT_E2T = JT_E1T * p.mu_E2/ p.mu_E1;    % mol/d.cm^2, area-spec som maint
  jT_E2S = jT_E2M + JT_E2T/ p.MV/ L_0; % mol/d.mol
  jT_E1S = jT_E1M + JT_E1T/ p.MV/ L_0; % mol/d.mol total spec somatic maint
  dL_0 = gr_iso_21(L_0, m_E10, m_E20, jT_E1M, jT_E2M, p.y_VE1, p.y_VE2, vT, p.kap, p.rho1); % cm/d, change in L at birth
  mu_EV = p.mu_E1/ p.mu_V; kT_E = vT/ L_0;% -, 1.d: ratio of chem pot, reserve turnover rate

  if exist('r0', 'var') == 0
    r0 = [];
  end
  if isempty(r0)    
    r0 = 3 * dL_0/ L_0; % 1/d, specific growth rate at birth at T(0), but som maint might change at birth
  end

  rT = sgr_iso_21 (m_E10, m_E20, jT_E1S, jT_E2S, p.y_VE1, p.y_VE2, mu_EV, kT_E, p.kap, p.rho1, r0); % 1/d, sgr

  % get variables
  options = odeset('AbsTol',1e-10, 'RelTol',1e-10);
  [t, var] = ode45(@diso_221, tX12T(:,1), var_0, options, tX12T, p);

  % unpack some variables
  M_E1 = var(:,3); M_E2 = var(:,4); E_H = var(:,5); M_V = var(:,7); 
  m_E1 = M_E1 ./ M_V; m_E2 = M_E2 ./ M_V;
  
  % get food environment
  X1 = tX12T(:,2); X2 = tX12T(:,3);   % M, food densities

  % get coefficients (dimless, so no temp corr)
  JT_X1Am = TC * p.J_X1Am; JT_X2Am = TC * p.J_X2Am;
  JT_E1Am_X1 = p.y_E1X1 * JT_X1Am; JT_E1Am_X2 = p.y_E1X2 * JT_X2Am; % mol/d.cm^2, max spec assim rate for reserve 1 
  JT_E2Am_X1 = p.y_E2X1 * JT_X1Am; JT_E2Am_X2 = p.y_E2X2 * JT_X2Am; % mol/d.cm^2, max spec assim rate for reserve 2
  m_E1m = (JT_E1Am_X1 + JT_E1Am_X2)/ vT/ p.MV;
  m_E2m = (JT_E2Am_X1 + JT_E2Am_X2)/ vT/ p.MV;
  s1 = max(0, 1 - m_E1/ m_E1m); s2 = max(0, 1 - m_E2/ m_E2m);
  rho_X1X2 = s1 * max(0, p.M_X1/ p.M_X2 * p.y_E1X1/ p.y_E1X2 - 1) + s2 * max(0, p.M_X1/ p.M_X2 * p.y_E2X1/ p.y_E2X2 - 1);
  rho_X2X1 = s1 * max(0, p.M_X2/ p.M_X1 * p.y_E1X2/ p.y_E1X1 - 1) + s2 * max(0, p.M_X2/ p.M_X1 * p.y_E2X2/ p.y_E2X1 - 1);
  hT_X1Am = JT_X1Am/ p.M_X1; hT_X2Am = JT_X2Am/ p.M_X2;
  alphaT_X1 = hT_X1Am + TC * p.F_X1m * X1 + TC * p.F_X2m * rho_X2X1 .* X2; 
  alphaT_X2 = hT_X2Am + TC * p.F_X2m * X2 + TC * p.F_X1m * rho_X1X2 .* X1;
  betaT_X1 = TC * p.F_X1m * X1 .* (1 - rho_X1X2); betaT_X2 = TC * p.F_X2m * X2 .* (1 - rho_X2X1);
  f1 = (alphaT_X2 * TC * p.F_X1m .* X1 - betaT_X1 * TC * p.F_X2m .* X2) ./ (alphaT_X1 .* alphaT_X2 - betaT_X1 .* betaT_X2);
  f2 = (alphaT_X1 * TC * p.F_X2m .* X2 - betaT_X2 * TC * p.F_X1m .* X1) ./ (alphaT_X1 .* alphaT_X2 - betaT_X1 .* betaT_X2);
  f1 = f1 .* (E_H > p.E_Hb); f2 = f2 .* (E_H > p.E_Hb); % -, no feeding in embryo

  % more quantities are planned in future releases, such as respiration, which involves n_O and n_M
  coeff = [f1, f2, s1, s2, rho_X1X2, rho_X2X1]; 
