%% f_ris0_abj
% Gets scaled functional response at with the specific population growth rate is zero for the abj model

%%
function [f, info] = f_ris0_abj (par)
  % created 2019/07/27 by Bas Kooijman
  
  %% Syntax
  % [f, info] = <../f_ris0_abj.m *f_ris0_abj*> (par)
  
  %% Description
  % Obtains the scaled function response at which specific population growth rate for the abj model equals zero, 
  %   by solving the characteristic equation. We work at T_ref here.
  %
  % Input
  %
  % * par: structure with parameters for individual
  %
  % Output
  %
  % * f: scaled func response at which r = 0 for the abj model
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % optional thinning (a boolean, default 1), and background hazards h_B0b, h_Bbj, h_Bjp, h_Bpi (default all 0) must be added to par before use, if necessary.
  % par.reprodCode must exist
  % R(t) is taken to be continuous; t_p at searched f is presemably large, so effect will be little.

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  
  if strcmp(reprodCode,'O')
    kap_R = kap_R/2; % take cost of male production into account
  end

  % defaults
  if ~exist('thinning','var')
    thinning = 1;
  end
  if ~exist('h_B0b', 'var')
    h_B0b = 0;
  end
  if ~exist('h_Bbj', 'var')
    h_Bbj = 0;
  end
  if ~exist('h_Bbp', 'var')
    h_Bjp = 0;
  end
  if ~exist('h_Bpi', 'var')
    h_Bpi = 0;
  end
  
  % set lower boundary of f
  f_0 = 1e-5 + get_ep_min_j([g k l_T v_Hb v_Hj v_Hp]); % -, scaled functional response at which puberty can just be reached
  pars_charEq0 = {L_m, kap, kap_R, k_M, v, g, k, v_Hb, v_Hj, v_Hp, s_G, h_a, h_B0b, h_Bbj, h_Bjp, h_Bpi, thinning};
  if charEq0(f_0, pars_charEq0{:}) > 0
    fprintf('Warning from f_ris0_abj: f for which r = 0 is very close to that for R_i = 0\n');
    f = f_0; info = 1; return
  end
  
  % set upper boundary of f
  f_1 = 1;         % upper boundary (lower boundary is f_0)
  if charEq0(f_1, pars_charEq0{:}) < 0
    fprintf('Warning from f_ris0_abj: no f detected for which r = 0\n');
    info = 0; f = f_0; return
  end
  
  % get f at r = 0
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
    fprintf('f_ris0_abj warning: no convergence for f in 18 steps\n')
  elseif f_1 - f_0 > 1e-4
    info = 0;
    fprintf('f_ris0_abj warning: interval for f < 1e-4, norm = %g\n', norm)
  else
    info = 1;
  end
  
end

function val = charEq0(f, L_m, kap, kap_R, k_M, v, g, k, v_Hb, v_Hj, v_Hp, s_G, h_a, h_B0b, h_Bbj, h_Bjp, h_Bpi, thinning)
  % val = char eq in f, for r = 0
  u_E0 = get_ue0([g k v_Hb], f); % -, scaled cost for egg
  [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj([g, k, 0, v_Hb, v_Hj, v_Hp], f); 
  if isempty(tau_j)
    val = -1; return
  end
  a_b = tau_b/ k_M; t_j = (tau_j - tau_b)/ k_M; t_p = (tau_p - tau_b)/ k_M; % unscale
  L_b = L_m * l_b; L_j = L_m * l_j; L_i = L_m * l_i; % unscale
  S_b = exp( - a_b * h_B0b); % - , survival prob at birth
  r_j = k_M * rho_j; r_B = k_M * rho_B; % 1/d, von Bert growth rate
  options = odeset('Events', @dead_for_sure, 'AbsTol',1e-9, 'RelTol',1e-9); 
  pars_qhSC = {f, kap, kap_R, k_M, v, g, k, u_E0, L_b, L_j, L_i, L_m, t_j, t_p, r_j, r_B, v_Hp, s_G, h_a, h_Bbj, h_Bjp, h_Bpi, thinning};
  [t, qhSC] = ode45(@dget_qhSC, [0; 1e8], [0, 0, S_b, 0], options, pars_qhSC{:});
  i = ~isnan(qhSC(:,3)); qhSC = qhSC(i,:); t = t(i);
  val = qhSC(end, 4) - 1;
end
    
function dqhSC = dget_qhSC(t, qhSC, f, kap, kap_R, k_M, v, g, k, u_E0, L_b, L_j, L_i, L_m, t_j, t_p, r_j, r_B, v_Hp, s_G, h_a, h_Bbj, h_Bjp, h_Bpi, thinning)
  q   = max(0,qhSC(1)); % 1/d^2, aging acceleration
  h_A = max(0,qhSC(2)); % 1/d^2, hazard rate due to aging
  S   = max(0,qhSC(3)); % -, survival prob
  
  if t < t_j
    h_B = h_Bbj;
    L = L_b * exp(t * r_j/ 3);
    s_M = L/ L_b;
    r = r_j;
    h_X = thinning * r; % 1/d, hazard due to thinning
  else
    h_B = (t < t_p) * h_Bjp + (t > t_p) * h_Bpi;
    L = L_i - (L_i - L_j) * exp(- r_B * (t - t_j));
    s_M = L_j/ L_b;
    r = 3 * r_B * (L_i/ L - 1); % 1/d, spec growth rate of structure
    h_X = thinning * r * 2/3; % 1/d, hazard due to thinning
  end

  dq = (q * s_G * L^3/ L_m^3 + h_a) * f * (v * s_M/ L - r) - r * q;
  dh_A = q - r * h_A; % 1/d^2, change in hazard due to aging

  h = h_A + h_B + h_X; 
  dS = - h * S; % 1/d, change in survival prob
    
  l = L/ L_m; % -, scaled structural length
  R = (t > t_p) * kap_R * k_M * (f * l^2/ (f + g) * (g * s_M + l) - k * v_Hp) * (1 - kap)/ u_E0; % 1/d, reprod rate
  dCharEq = S * R;

  dqhSC = [dq; dh_A; dS; dCharEq]; 
end

% event dead_for_sure
function [value, isterminal, direction] = dead_for_sure(t, qhSC, varargin)
  value = qhSC(3) - 1e-6;  % trigger 
  isterminal = 1;          % terminate after the first event
  direction = [];          % get all the zeros
end
