%% iso_221_var
% fluxes with 2-food, 2-reserve, 1-structure isomorph with variable stoichiometry for growth

%%
function [var flux] = iso_221_var(tXT, var_0, p, n_O, n_M, r0)
  % created 2012/03/05 by Bas Kooijman

  %% Syntax
  % [var flux] = <../iso_221_var.m *iso_221_var*> (tXT, var_0, p, n_O, n_M, r0)
  
  %% Description
  % Obtains fluxes in case of 2-food, 2-reserve, 1-structure isomorph with variable stoichiometry for growth
  %
  % Input:
  %
  % * tXT: (n,4)-matrix of time, food densities, temperature
  %
  %        assumption: tXT(1,1) = 0: time that applies to vars_0
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
  % see <iso_221.html *iso_221*> for fixed stoichiometry;
  % model is presented in comment for 5.2.7 of DEB3

  % unpack some parameters, see diso_211_var for a full list
  M_X1      = p( 1); M_X2      = p( 2); % mol, size of food particle of type i
  F_X1m     = p( 3); F_X2m     = p( 4); % dm^2/d.cm^2, {F_Xim} spec searching rates
  y_E1X1    = p( 7); y_E2X1    = p( 8); % mol/mol, yield of reserve Ei on food X1
  y_E1X2    = p( 9); y_E2X2    = p(10); % mol/mol, yield of reserve Ei on food X2
  J_X1Am    = p(11); J_X2Am    = p(12); % mol/d.cm^2, {J_XiAm} max specific ingestion rate for food Xi
  v         = p(13);                    % cm/d, energy conductance, 
  MV        = p(20);                    % mol/cm^3, [M_V] density of structure
  E_Hb      = p(29);                    % J, maturity at birth

  % get variables
  [t var] = ode45(@diso_221_var, tXT(:,1), var_0, [], tXT, p);

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
                