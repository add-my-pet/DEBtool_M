%% get_Sb
% Gets survival probability at birth and scaled variables

%%
function [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b, info] = get_Sb(p, f)
  % created 2019/10/09 by Bas Kooijman, modified 2020/02/21
  
  %% Syntax
  % [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b, info] = <../get_Sb.m *get_Sb*>(p, f)
  
  %% Description
  % Obtains survival probability at birth by integration survival prob over scaled age. All variables/parameters  are dimensionless.
  % Called by ssd functions for statistics at population level; rho_N is scaled spec pop growth rate, h_B0b, scaled background hazard between 0 and b.
  %
  % Input
  %
  % * p: 7-vector with parameters: g k v_Hb h_a S_G h_B0b rho_N; scaled background hazard h_B0b and rho_N are optional (default 0)
  % * f: optional scalar with scaled reserve density at birth (default f = 1)
  % 
  % Output
  %
  % * S_b: scalar with survival probability at birth 
  % * q_b: scalar with scaled acceleration at birth: q(b)/ k_M^2
  % * h_Ab: scalar scaled hazard at birth: h_A(b)/ k_M
  % * tau_b: scalar scaled age at birth
  % * tau_0b: % \int_0^tau_b exp(-rho_N*tau) S(tau) dtau
  % * u_E0: scaled initial reserve
  % * l_b: scaled length at birth
  % * info: boolean with success (true) or failure (false)

  %% Remarks
  % unscale 
  % 
  % * q_b by multiplying with kT_M^2, 
  % * h_Ab with kT_M 
  % * tau_b and tau_0b with 1/k_M
  % * l3_0b with kT_M * L_m^3
  % * u_E_0b with kT_M * {p_Am}*v^2/k_M^3/g^2
  %
  % See get_Sb_foetus for foetal development

  %% Example
  % [S_b, q_b, h_Ab, tau_b, tau_0b, l3_0b, u_E0b, u_E0, l_b, info] = get_Sb([1.1 .3 0.01 1e-7 1e-4])

  if ~exist('f','var')
    f = 1;
  end
  if length(p) == 5
    p([6 7]) = 0;  
  elseif length(p) == 6
    p(7) = 0; % background hazard h_B0b
  end

  [u_E0, l_b, info] = get_ue0(p(1:3), f);

  ulvqhS_0 = [1.001*u_E0; 1e-5; 0; 0; 0; 1; 0;]; % initial value
  options = odeset('Events',@birth, 'NonNegative',ones(10,1), 'AbsTol',1e-9, 'RelTol',1e-9); 
  try
    [tau, ulvqhS] = ode45(@dget_ulvqhS, [0 1e8], ulvqhS_0, options, p);
  catch
    options = odeset('Events',@birth, 'AbsTol',1e-8, 'RelTol',1e-8); 
    [tau, ulvqhS] = ode23(@dget_ulvqhS, [0 1e8], ulvqhS_0, options, p);
  end
  tau_b = tau(end); q_b = max(0,ulvqhS(end,4)); h_Ab = max(0,ulvqhS(end,5)); S_b = max(0,ulvqhS(end,6)); 
  tau_0b = ulvqhS(end,7); % \int_0^tau_b exp(-rho_N*tau) S(tau) dtau; 
  % stable-age pdf for embryo's equals exp(-rho_N*tau) S(tau)/ l0 
  
end

%% subfunctions

% event birth
function [value,isterminal,direction] = birth(~, ulvqhS, p)
  value = ulvqhS(3) - p(3);  % trigger 
  isterminal = 1;  % terminate after event
  direction  = []; % get all the zeros
end

% ode's for change of embryo state
function dulvqhS = dget_ulvqhS(tau, ulvqhS, p)
  u_E = ulvqhS(1); l = ulvqhS(2); v_H = ulvqhS(3); q = max(0,ulvqhS(4)); h = max(0,ulvqhS(5)); S = ulvqhS(6);
  g = p(1); k = p(2); v_Hb = p(3); h_a = p(4); s_G = p(5); e = g * u_E/ l^3; h_B = p(6); rho_N = p(7); 

  du_E = - u_E * l^2 * (g + l)/ (u_E + l^3);
  dl = (g * u_E - l^4)/ (u_E + l^3)/ 3;
  dv_H = u_E * l^2 * (g + l)/ (u_E + l^3) - k * v_H;
  rho = (e/ l - 1)/ (1 + e/ g);
  dq = g * u_E * (q * s_G + h_a/ l^3) * (g/ l - rho) - rho * q;
  dh = q - rho * h;
  dS = - (h + h_B) * S;
  
  dl0 = S * exp(- rho_N * tau);                       
  
  dulvqhS = [du_E; dl; dv_H; dq; dh; dS; dl0];
end

