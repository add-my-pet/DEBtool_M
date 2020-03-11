%% get_Sb_foetus
% Gets scaled survival probability at birth

%%
function [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b, info] = get_Sb_foetus(p, f)
  % created 2019/10/09 by Bas Kooijman, modified 2020/02/21
  
  %% Syntax
  % [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b, info] = <../get_Sb.m *get_Sb*>(p, f)
  
  %% Description
  % Obtains survival probability at birth by integration survival prob over age. 
  %
  % Input
  %
  % * p: 6-vector with parameters: g k v_Hb h_a S_G h_B0b rho_N ; scaled background hazard h_B0b is optional (default 0)
  % * f: optional scalar with scaled reserve density at birth (default F = 1)
  %  _
  % Output
  %
  % * S_b: scalar with survival probability at birth 
  % * q_b: scalar with scaled acceleration at birth: q(b)/ k_M^2
  % * h_Ab: scalar scaled hazard at birth: h_A(b)/ k_M
  % * tau_b: scaled time at birth a_b * k_M
  % * tau_0b: \int_0^{tau_b} S(tau) exp(- rho_N tau) dtau
  % * l3_0b: mean cibed length
  % * u_E0: scaled energy cost for foetus
  % * l_b: scaled length at birth
  % * info: boolean with success (true) or failure (false)

  %% Remarks
  % unscale q_b by multiplying with k_M^2, and h_Ab with k_M and tau_b with k_M and l_b with L_m and u_E0 with {p_Am}*v^2/k_M^3/g^2.
  % See get_Sb for egg development

  %% Example
  % [S_b, q_b, h_Ab, tau_b, l_b, u_E0, info] = get_Sb_foetus([1.1 .3 0.01 1e-7 1e-4])

  if ~exist('f','var')
    f = 1;
  end
  if length(p) == 6
    p(7) = 0; % background hazard h_B0b
  end

  [u_E0, l_b, tau_b, info] = get_ue0_foetus(p(1:3), f);

  elvqhS_0 = [f; 1e-9; 0; 0; 0; 1; 0]; % initial value
  options = odeset('NonNegative',ones(8,1), 'AbsTol',1e-9, 'RelTol',1e-9);  
  [tau, elvqhS] = ode45(@dget_elvqhS, [0 tau_b], elvqhS_0, options, p);
  q_b = max(0,elvqhS(end,4)); h_Ab = max(0,elvqhS(end,5)); S_b = max(0,elvqhS(end,6));
  tau_0b = elvqhS(end,7); 
  
end

%% subfunctions

% ode's for change of embryo state
function delvqhS = dget_elvqhS(tau, elvqhS, p)
  e = elvqhS(1); l = elvqhS(2); v_H = elvqhS(3); q = max(0,elvqhS(4)); h = max(0,elvqhS(5)); S = elvqhS(6);
  g = p(1); k = p(2); h_a = p(4);  s_G = p(5); h_B = p(6); rho_N = p(7); 

  de = 0; % no change in scaled reserve density during foetal development
  dl = (e - l)/ (e + g) * g/ 3;
  dv_H = e * l^2 * (g + l)/ (g + e) - k * v_H;
  r = (e/ l - 1)/ (1 + e/ g);
  dq = e * (q * l^3 * s_G + h_a) * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - (h + h_B) * S;

  dl0 = S * exp(- rho_N * tau);                       

  delvqhS = [de; dl; dv_H; dq; dh; dS; dl0];
end

