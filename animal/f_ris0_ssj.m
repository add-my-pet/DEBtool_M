%% f_ris0_ssj
% Gets scaled functional response at with the specific population growth rate is zero for the ssj model

%%
function [f, info] = f_ris0_ssj (par)
  % created 2019/07/31 by Bas Kooijman
  
  %% Syntax
  % [f, info] = <../f_ris0_ssj.m *f_ris0_ssj*> (par)
  
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
  % * f: scaled func response at which r = 0 for the ssj model
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % optional thinning (a boolean, default 1), and background hazards h_B0b, h_Bbj, h_Bjp, h_Bpi (default all 0) must be added to par before use, if necessary.
  % par.reprodCode must exist.
  % R(t) is taken to be continuous.

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  
  if strcmp(reprodCode,'O') && strcmp(genderCode,'D')
    kap_R = kap_R/2; % take cost of male production into account
  end

  % defaults
  if ~exist('thinning','var')
    thinning = 1;
  end
  if ~exist('h_B0b', 'var')
    h_B0b = 0;
  end
  if ~exist('h_Bbs', 'var')
    h_Bbs = 0;
  end
  if ~exist('h_Bsp', 'var')
    h_Bsp = 0;
  end
  if ~exist('h_Bpi', 'var')
    h_Bpi = 0;
  end
  
  % get f at r = 0
  f_0 = 1e-5 + get_ep_min([k; l_T; v_Hp]); % -, scaled functional response at which puberty can just be reached
  pars_charEq0 = {L_m, kap, kap_R, k_M, k_E, v, g, k, t_sj, v_Hb, v_Hs, v_Hp, s_G, h_a, h_B0b, h_Bbs, h_Bsp, h_Bpi, thinning};
  if charEq0(f_0, pars_charEq0{:}) > 0
    fprintf(['Warning from f_ris0_ssj: f for which r = 0 is very close to that for R_i = 0 and thinning = ', num2str(thinning), '\n']);
    f = f_0; info = 1; return
  end
  
  % initialize range for f
  f_1 = 1;         % upper boundary (lower boundary is f_0)
  if charEq0(1, pars_charEq0{:}) < 0
    fprintf(['Warning from f_ris0_ssj: no f detected for which r = 0 and thinning = ', num2str(thinning), '\n']);
    info = 0; f = f_0; return
  end
  norm = 1; i = 0; % initialize norm and counter

  % 2^-18 = 4e-6: min accuracy of f_min, starting from worst-case (0,1)
  while i < 18 && norm^2 > 1e-16 && f_1 - f_0 > 1e-5 % bisection method
    i = i + 1;
    f = (f_0 + f_1)/ 2;
    norm = charEq0(f, pars_charEq0{:});
    %[i f_0 f f_1 norm] % show progress
    if norm > 0
      f_1 = f;
    else
      f_0 = f;
    end
  end

  if i == 18 
    info = 0;
    fprintf('f_ris0_ssj warning: no convergence for f in 18 steps\n')
  elseif f_1 - f_0 > 1e-4
    info = 0;
    fprintf('f_ris0_ssj warning: interval for f < 1e-4, norm = %g\n', norm)
  else
    info = 1;
  end
  
end

function val = charEq0(f, L_m, kap, kap_R, k_M, k_E, v, g, k, t_sj, v_Hb, v_Hs, v_Hp, s_G, h_a, h_B0b, h_Bbs, h_Bsp, h_Bpi, thinning)
  % val = char eq in f, for r = 0
  [u_E0, l_b] = get_ue0([g k v_Hb], 1); % -, scaled cost for egg
  pars_ts = [g k 0 v_Hb v_Hs]; [tau_s, tau_b, l_s, l_b] = get_tp(pars_ts, 1);
  pars_tp = [g k 0 v_Hs v_Hp]; [tau_p, tau_ss, l_p, l_ss] = get_tp(pars_tp, 1);
  a_b = tau_b/ k_M; t_s = (tau_p - tau_s)/ k_M; t_j = t_s + t_sj; t_p = t_j + (tau_p - tau_ss)/ k_M; 
  L_b = L_m * l_b; L_s = L_m * l_s; L_j = L_s * exp(- k_E * t_sj);
  S_b = exp( - a_b * h_B0b); % - , survival prob at birth
  r_B = k_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate
  pars_qhSC = {f, kap, kap_R, k_M, k_E, v, g, k, u_E0, L_b, L_s, L_j, L_m, t_s, t_j, t_p, r_B, v_Hp, s_G, h_a, h_Bbs, h_Bsp, h_Bpi, thinning};
  options = odeset('Events', @dead_for_sure, 'AbsTol',1e-9, 'RelTol',1e-9);  
  [t, qhSC] = ode45(@dget_qhSC, [0; 1e10], [0, 0, S_b, 0], options, pars_qhSC{:});
  val = qhSC(end, 4) - 1;
end
    
function dqhSC = dget_qhSC(t, qhSC, f, kap, kap_R, k_M, k_E, v, g, k, u_E0, L_b, L_s, L_j, L_m, t_s, t_j, t_p, r_B, v_Hp, s_G, h_a, h_Bbs, h_Bsp, h_Bpi, thinning)
  q   = qhSC(1); % 1/d^2, aging acceleration
  h_A = qhSC(2); % 1/d^2, hazard rate due to aging
  S   = qhSC(3); % -, survival prob
  
  
  if t < t_s
    L = f * L_m - (f * L_m - L_b) * exp(- t * r_B);  % cm, structural length
    r = v * (f/ L - 1/ L_m)/ (f + g); % 1/d, spec growth rate of structure
    h_B = h_Bbs;
  elseif t < t_j
    L = L_s * exp( - k_E * (t - t_s));  % cm, structural length
    r = 0; % 1/d, spec growth rate of structure; it actually is -k_E, but h_X cannot become < 0
    h_B = h_Bsp;
  elseif t < t_p
    L = f * L_m - (f * L_m - L_j) * exp(- (t - t_j) * r_B);  % cm, structural length
    r = v * (f/ L - 1/ L_m)/ (f + g); % 1/d, spec growth rate of structure
    h_B = h_Bsp;
  else
    L = f * L_m - (f * L_m - L_j) * exp(- (t - t_j) * r_B);  % cm, structural length
    r = v * (f/ L - 1/ L_m)/ (f + g); % 1/d, spec growth rate of structure
    h_B = h_Bpi;
  end
  h_X = thinning * r * 2/3; % 1/d, hazard due to thinning
  h = h_A + h_B + h_X; 
  dq = (q * s_G * L^3/ L_m^3 + h_a) * f * (v/ L - r) - r * q;
  dh_A = q - r * h_A; % 1/d^2, change in hazard due to aging
  dS = - h * S; % 1/d, change in survival prob

  l = L/ L_m; % -, scaled structural length
  R = (t > t_p) * kap_R * k_M * (f * l^2/ (f + g) * (g + l) - k * v_Hp) * (1 - kap)/ u_E0; % 1/d, reprod rate
  dCharEq = S * R;
  
  dqhSC = [dq; dh_A; dS; dCharEq]; 
end

% event dead_for_sure, linked to dget_qhSC
function [value, isterminal, direction] = dead_for_sure(t, qhSC, varargin)
  value = qhSC(3) - 1e-6;  % trigger 
  isterminal = 1;   % terminate after the first event
  direction  = [];  % get all the zeros
end
