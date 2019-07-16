%% f_ris0_std
% Gets scaled functional response at with the specific population growth rate is zero for the std model

%%
function [f, S_b, S_p, a_b, t_p, info] = f_ris0_std (par)
  % created 2019/07/06 by Bas Kooijman
  
  %% Syntax
  % [f, S_b, S_p, a_b, t_p, info] = <../f_ris0_std.m *f_ris0_std*> (par)
  
  %% Description
  % Obtains the scaled function response at which specific population growth rate for the std model equals zero, 
  %   by solving the characteristic equation. We work at T_ref here.
  %
  % Input
  %
  % * par: structure with parameters for individual
  %
  % Output
  %
  % * f: scaled func response at which r = 0 forfor the std model
  % * S_b: survivor probability at birth
  % * S_p: survivor probability at puberty
  % * a_b: age at birth at T_ref
  % * t_p: time since birth at puberty at T_ref
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % optional thinning (a boolean, default 1), and background hazards h_B0b, h_Bbp, h_Bpi (default all 0) must be added to par before use, if necessary
  %
  %% Example of use
  % cd to entries/Passer_domesticus/; load results_Passer_domesticus; 
  % f = f_ris0_std(par)

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  
  if strcmp(gender,'D')
    kap_R = kap_R/2; % take cost of male production into account
  end

  % defaults
  if ~exist('thinning','var')
    thinning = 1;
  end
  if ~exist('h_B0b', 'var')
    h_B0b = 0;
  end
  if ~exist('h_Bbp', 'var')
    h_Bbp = 0;
  end
  if ~exist('h_Bpi', 'var')
    h_Bpi = 0;
  end
  
  % max time
  pars_tm = [g; k; l_T; v_Hb; v_Hp; h_a/ k_M^2; s_G]; % compose parameter vector
  t_m = get_tm_s(pars_tm, f)/ k_M;                    % -, scaled median life span
  t_max = 10 * t_m; % maximum time for integration of the char eq

  % get f at r = 0
  f_0 = get_ep_min([k; l_T; v_Hp]); % -, scaled functional response at which puberty can just be reached
  [f, fval, info, output] = fzero(@char_eq_0, [f_0+1e-4; 1], [], t_max, kap, kap_R, k_M, k, g, v_Hb, v_Hp, l_T, L_m, v, s_G, h_a, h_B0b, h_Bbp, h_Bpi, thinning);

  % get S_b and S_p at this f
  [tau_p, tau_b, l_p, l_b] = get_tp([g k l_T v_Hb v_Hp], f);
  a_b = tau_b/ k_M; % d, age at birth
  t_p = (tau_p - tau_b)/ k_M; % d, time since birth at puberty
  L_b = L_m * l_b; % cm, struc length at birth
  S_b = exp(- h_B0b * a_b); % -, survival prob at birth
  r_B = k_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate
  [t, qhS] = ode45(@dget_qhS, [0; t_p], [0, 0, S_b], [], f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning);
  S_p = qhS(end,3); % - , survival prob at puberty
  
end

function val = char_eq_0(f, t_max, kap, kap_R, k_M, k, g, v_Hb, v_Hp, l_T, L_m, v, s_G, h_a, h_B0b, h_Bbp, h_Bpi, thinning)
% val = char eq in f, for r = 0

  r_B = k_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate  
  [u_E0, l_b] = get_ue0([g, k, v_Hb], f);
  [tau_p, tau_b, l_p, l_b] = get_tp([g k l_T v_Hb v_Hp], f, l_b);
  L_b = L_m * l_b; l_i = f - l_T; L_T = L_m * l_T;  a_b = tau_b/ k_M; t_p = (tau_p - tau_b)/ k_M;
  S_b = exp(- h_B0b * a_b);

  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  t_MAX = 10 * t_m/ k_M;                % d, mean life span at T

  [t, N] = ode45(@dget_N, [0; t_MAX], 0, [], f, kap, kap_R, k_M, k, g, v_Hp, l_p, l_i, l_T, u_E0, r_B);
  if N(end) < 1
    val = -100;
  else
    t = t_p + spline1(1:N(end), [N, t]); % time points of egg laying
    [t, qhS] = ode45(@dget_qhS, [0; t], [0, 0, S_b], [], f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning);
    val = 1 - sum(qhS(2:end, 3));
  end
end

function dN = dget_N(t, N, f, kap, kap_R, k_M, k, g, v_Hp, l_p, l_i, l_T, u_E0, r_B)
  % t: time since puberty
  % N: cumulative number of eggs
  l = l_i - (l_i - l_p) * exp(- r_B * t); % -, struct length
  dN = max(0, kap_R * k_M * (f * l^2/ (f + g) * (g + l_T + l) - k * v_Hp) * (1 - kap)/ u_E0); % 1/d, R
end
    
function dqhS = dget_qhS(t, qhS, f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  % t: time since birth
  
  q   = max(0,qhS(1)); % 1/d^2, aging acceleration
  h_A = max(0,qhS(2)); % 1/d^2, hazard rate due to aging
  S   = max(0,qhS(3)); % -, survival prob

  L_i = L_m * f - L_T;
  L = L_i - (L_i - L_b) * exp(- t * r_B);
  r = v * (f/ L - (1 + L_T/ L)/ L_m)/ (f + g); % 1/d, spec growth rate of structure
  dq = (q * s_G * L^3/ L_m^3 + h_a) * f * (v/ L - r) - r * q;
  dh_A = q - r * h_A;
  if t < t_p
    h_B = h_Bbp;
  else
    h_B = h_Bpi;
  end
  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  
  dqhS = [dq; dh_A; dS]; 
end

