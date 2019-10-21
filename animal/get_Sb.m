%% get_Sb
% Gets scaled survival probability at birth

%%
function [S_b, q_b, h_Ab, tau_b, l_b, u_E0, info] = get_Sb(p, f)
  % created 2019/10/09 by Bas Kooijman
  
  %% Syntax
  % [S_b, q_b, h_Ab, tau_b, l_b, u_E0, info] = <../get_Sb.m *get_Sb*>(p, f)
  
  %% Description
  % Obtains survival probability at birth by integration survival prob over age. 
  %
  % Input
  %
  % * p: 6-vector with parameters: g k v_Hb h_a S_G h_B0b; scaled background hazard h_B0b is optional (default 0)
  % * f: optional scalar with scaled reserve density at birth (default F = 1)
  %  _
  % Output
  %
  % * S_b: scalar with survival probability at birth 
  % * q_b: scalar with scaled acceleration at birth: q(b)/ k_M^2
  % * h_Ab: scalar scaled hazard at birth: h_A(b)/ k_M
  % * tau_b: scaled time at birth a_b * k_M
  % * l_b: scaled struc length at birth L_b/ L_m
  % * u_E0: scaled initial reserve E_0 * g^2 * k_M^3/ v^2/ {p_Am}
  % * info: boolean with success (true) or failure (false)

  %% Remarks
  % unscale q_b by multiplying with k_M^2, and h_Ab with k_M and tau_b with k_M and l_b with L_m and u_E0 with {p_Am}*v^2/k_M^3/g^2.
  % See get_Sb_foetus for foetal development

  %% Example
  % [S_b, q_b, h_Ab, tau_b, l_b, u_E0, info] = get_Sb([1.1 .3 0.01 1e-7 1e-4])

  if ~exist('f','var')
    f = 1;
  end
  if length(p) == 5
    p(6) = 0; % background hazard h_B0b
  end

  [u_E0, l_b, info] = get_ue0(p(1:3), f);

  ulvqhS_0 = [1.005*u_E0; 1e-5; 0; 0; 0; 1]; % initial value
  options = odeset('Events',@birth, 'NonNegative',ones(4,1), 'AbsTol',1e-9, 'RelTol',1e-9);  
  [tau, ulvqhS] = ode45(@dget_ulvqhS, [0 1e8], ulvqhS_0, options, p);
  tau_b = tau(end); q_b = max(0,ulvqhS(end,4)); h_Ab = max(0,ulvqhS(end,5)); S_b = max(0,ulvqhS(end,6)) * exp(- p(6) * tau_b);
 
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
  g = p(1); k = p(2); v_Hb = p(3); h_a = p(4);  s_G = p(5); e = g * u_E/ l^3;

  du_E = - u_E * l^2 * (g + l)/ (u_E + l^3);
  dl = (g * u_E - l^4)/ (u_E + l^3)/ 3;
  dv_H = u_E * l^2 * (g + l)/ (u_E + l^3) - k * v_H;
  r = (e/ l - 1)/ (1 + e/ g);
  dq = g * u_E * (q * s_G + h_a/ l^3) * (g/ l - r) - r * q;
  dh = q - r * h;
  dS = - h * S;

  dulvqhS = [du_E; dl; dv_H; dq; dh; dS];
end

