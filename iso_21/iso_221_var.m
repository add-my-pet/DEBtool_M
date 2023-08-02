%% iso_221_var
% coefficients with 2-food, 2-reserve, 1-structure isomorph with variable stoichiometry for growth

%%
function [var, coeff] = iso_221_var(tX12T, var_0, p, n_O, n_M)
  % created 2012/03/05 by Bas Kooijman

  %% Syntax
  % [var, coeff] = <../iso_221_var.m *iso_221_var*> (tX12T, var_0, p, n_O, n_M, r0)
  
  %% Description
  % Obtains coefficients in case of 2-food, 2-reserve, 1-structure isomorph with variable stoichiometry for growth
  %
  % Input:
  %
  % * tX12T: (n,4)-matrix of time (since birth), food densities, temperature
  %
  %        assumption: tX12T(1,1) = 0: time that applies to vars_0
  %
  % * var_0: 13-vector with values of state variables at t = 0; see under var
  % * p: structure with parameters, mydata_iso_221_var 
  % * n_O: (4,7)-matrix with chemical indices for organics X1, X2, V, E1, E2, P1, P2
  % * n_M: (4,4)-matrix with chemical indices for minerals C, H, O, N
  %
  % Output:
  %
  % * var: (n,13)-matrix with variables
  %
  %        1      2     3       4      5        6   7        8      9      10  11 12 13
  %    cM_X1  cM_X2  M_E1    M_E2    E_H  max_E_H M_V  max_M_V cM_ER1  cM_ER2   q  h  S
  %    cum food eaten, reserves, (max)structure, (max)maturity , cumulative, allocation to reprod, acell, hazard, surv prob
  %
  % * coeff: (n,6)-matrix with coefficients
  %
  %     f1, f2: func responses
  %     s1, s2: reserve stress coefficients
  %     rho_X1X2, rho_X2X1: food preference coefficients

  %% Remarks
  % see <iso_221.html *iso_221*> for fixed stoichiometry;
  % model is presented in comment for 5.2.7 of DEB3

  % get variables
  [t, var] = ode45(@diso_221_var, tX12T(:,1), var_0, [], tX12T, p);

  % unpack some variables
  M_E1 = var(:,3); M_E2 = var(:,4); E_H = var(:,5); M_V = var(:,7); 
  m_E1 = M_E1 ./ M_V; m_E2 = M_E2 ./ M_V;

  % get food environment
  X1 = tX12T(:,2); X2 = tX12T(:,3);   % M, food densities

  % get coefficients (dimless, so no temp corr)
  J_E1Am_X1 = p.y_E1X1 * p.J_X1Am; J_E1Am_X2 = p.y_E1X2 * p.J_X2Am; % mol/d.cm^2, max spec assim rate for reserve 1 
  J_E2Am_X1 = p.y_E2X1 * p.J_X1Am; J_E2Am_X2 = p.y_E2X2 * p.J_X2Am; % mol/d.cm^2, max spec assim rate for reserve 2
  m_E1m = max(J_E1Am_X1/ p.v/ p.MV, J_E1Am_X2/ p.v/ p.MV);
  m_E2m = max(J_E2Am_X1/ p.v/ p.MV, J_E2Am_X2/ p.v/ p.MV);
  s1 = max(0, 1 - m_E1/ m_E1m); s2 = max(0, 1 - m_E2/ m_E2m);
  rho_X1X2 = s1 * max(0, p.M_X1/ p.M_X2 * p.y_E1X1/ p.y_E1X2 - 1) + s2 * max(0, p.M_X1/ p.M_X2 * p.y_E2X1/ p.y_E2X2 - 1);
  rho_X2X1 = s1 * max(0, p.M_X2/ p.M_X1 * p.y_E1X2/ p.y_E1X1 - 1) + s2 * max(0, p.M_X2/ p.M_X1 * p.y_E2X2/ p.y_E2X1 - 1);
  h_X1Am = p.J_X1Am/ p.M_X1; h_X2Am = p.J_X2Am/ p.M_X2;
  alpha_X1 = h_X1Am + p.F_X1m * X1 + p.F_X2m * rho_X2X1 .* X2; 
  alpha_X2 = h_X2Am + p.F_X2m * X2 + p.F_X1m * rho_X1X2 .* X1;
  beta_X1 = p.F_X1m * X1 .* (1 - rho_X1X2); beta_X2 = p.F_X2m * X2 .* (1 - rho_X2X1);
  f1 = (alpha_X2 * p.F_X1m .* X1 - beta_X1 * p.F_X2m .* X2) ./ (alpha_X1 .* alpha_X2 - beta_X1 .* beta_X2);
  f2 = (alpha_X1 * p.F_X2m .* X2 - beta_X2 * p.F_X1m .* X1) ./ (alpha_X1 .* alpha_X2 - beta_X1 .* beta_X2);
  f1 = f1 .* (E_H > p.E_Hb); f2 = f2 .* (E_H > p.E_Hb); % -, no feeding in embryo

  % more quantities are planned in future releases, such as respiration, which involves n_O and n_M
  coeff = [f1, f2, s1, s2, rho_X1X2, rho_X2X1]; 
                