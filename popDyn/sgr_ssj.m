%% sgr_ssj
% Gets specific population growth rate for the ssj model

%%
function [r, info] = sgr_ssj (par, T_pop, f_pop)
  % created 2019/07/31 by Bas Kooijman, modified 2020/03/12
  
  %% Syntax
  % [r, info] = <../sgr_ssj.m *sgr_ssj*> (par, T_pop, f_pop)
  
  %% Description
  % Specific population growth rate for the std model.
  % Hazard includes 
  %
  %  * thinning (optional, default: 1; otherwise specified in par.thinning), 
  %  * stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbs, par.h_Bsp, par.h_Bpi)
  %  * ageing (controlled by par.h_a and par.s_G)
  %
  % With thinning the hazard rate is such that the feeding rate of a cohort does not change during growth, in absence of other causes of death.
  % Survival of embryo due to ageing is taken for sure
  % Buffer handling rule: produce an egg as soon as buffer allows. Continuous reproduction is used.
  % Food density and temperature are assumed to be constant; temperature is specified in par.T_typical.
  % The resulting specific growth rate r is solved from the characteristic equation 1 = \int_0^a_max S(a) R(a) exp(- r a) da
  %   with a_max such that S(a_max) = 1e-6
  %
  % Input
  %
  % * par: structure with parameters for individual (for hazard rates, see remarks)
  % * T_pop: optional temperature (in Kelvin, default C2K(20))
  % * f_pop: optional scalar with scaled functional response (overwrites value in par.f)
  %
  % Output
  %
  % * r: scalar with specific population growth rate
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % See <ssd_ssj.html *ssd_ssj*> for mean age, length, squared length, cubed length and other statistics.
  % See <f_ris0_mod.html *f_ris0_mod*> for f at which r = 0.
  % par.thinning, par.h_B0b, par.h_Bbs, par.h_Bsp and par.h_Bpi are not standard in structure par; Add them before use if necessary.
  % par.reprodCode is not standard in structure par. Add it before use. If missing, "O" is assumed.
  %
  %% Example of use
  % cd to entries/Rana_temporaria/; load results_Rana_temporaria; 
  % [r, info] = sgr_std(par)

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  

  % defaults
  if exist('T_pop','var') && ~isempty(T_pop)
    T = T_pop;
  else
    T = C2K(20);
  end
  if exist('f_pop','var') && ~isempty(f_pop)
    f = f_pop;  % overwrites par.f
  end
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
  if (~exist('reprodCode', 'var') || strcmp(reprodCode, 'O')) && (~exist('genderCode', 'var') || strcmp(genderCode, 'D'))
    kap_R = kap_R/2; % take cost of male production into account
  end
  
  % temperature correction
  pars_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    pars_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  TC = tempcorr(T, T_ref, pars_T);   % -, Temperature Correction factor
  kT_M = k_M * TC; kT_E = k_E * TC; vT = v * TC; hT_a = h_a * TC^2;
  
  % supporting statistics
  [u_E0, l_b, info] = get_ue0([g k v_Hb], f); % -, scaled cost for egg
  if info == 0
    r = NaN; return
  end
  pars_ts = [g k 0 v_Hb v_Hs]; [tau_s, tau_b, l_s, l_b] = get_tp(pars_ts, 1);
  pars_tp = [g k 0 v_Hs v_Hp]; [tau_p, tau_ss, l_p, l_ss] = get_tp(pars_tp, 1);
  aT_b = tau_b/ kT_M; tT_s = (tau_s - tau_b)/ kT_M; tT_j = tT_s + t_sj; tT_p = tT_j + (tau_p - tau_ss)/ kT_M; % d, unscale times
  L_b = L_m * l_b; L_s = L_m * l_s; L_j = L_s * exp(- k_E * t_sj); L_p = L_m * l_p;                           % -, cm, struc lengths
  S_b = exp( - aT_b * h_B0b); % - , survival prob at birth
  rT_B = kT_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate
  pars_charEq = {f, kap, kap_R, kT_M, kT_E, vT, g, k, u_E0, L_b, L_s, L_j, L_p, L_m, tT_s, tT_j, tT_p, rT_B, v_Hp, s_G, hT_a, h_Bbs, h_Bsp, h_Bpi, thinning};
  
  % find r from char eq 1 = \int_0^infty S(t) R(t) exp(-r*t) dt
  if charEq(0, S_b, pars_charEq{:}) > 0
    r = NaN; info = 0; % no positive r exists
  else
    [r, info] = nmfzero(@charEq, 0.001, [], S_b, pars_charEq{:});
  end
 
end

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSC, varargin)
  value = qhSC(3) - 1e-6;  % trigger 
  isterminal = 1;    % terminate after the first event
  direction  = [];  % get all the zeros
end

% reproduction is continuous
function dqhSC = dget_qhSC(t, qhSC, sgr, f, kap, kap_R, k_M, k_E, v, g, k, u_E0, L_b, L_s, L_j, L_p, L_m, t_s, t_j, t_p, r_B, v_Hp, s_G, h_a, h_Bbs, h_Bsp, h_Bpi, thinning)  
  % t: time since birth
  q   = qhSC(1); % 1/d^2, aging acceleration
  h_A = qhSC(2); % 1/d^2, hazard rate due to aging
  S   = qhSC(3); % -, survival prob
  
  if t < t_s
    L = f * L_m - (f * L_m - L_b) * exp(- t * r_B);  % cm, structural length
    r = v * (f/ L - 1/ L_m)/ (f + g); % 1/d, spec growth rate of structure
    h_B = h_Bbs;
  elseif t < t_j
    L = L_s * exp( - k_E * (t - t_s)/ 3);  % cm, structural length
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
  
  l = L/ L_m; 
  R = (t > t_p) * kap_R * k_M * (f * l^2/ (f + g) * (g + l) - k * v_Hp) * (1 - kap)/ u_E0;
  dCharEq = S * R * exp(- sgr * t);
  
  dqhSC = [dq; dh_A; dS; dCharEq]; 

end

function value = charEq (r, S_b, f, kap, kap_R, k_M, k_E, v, g, k, u_E0, L_b, L_s, L_j, L_p, L_m, t_s, t_j, t_p, r_B, v_Hp, s_G, h_a, h_Bbs, h_Bsp, h_Bpi, thinning)
  options = odeset('Events', @dead_for_sure, 'NonNegative', ones(4,1), 'AbsTol',1e-9, 'RelTol',1e-9);  
  [t, qhSC] = ode45(@dget_qhSC, [0 1e10], [0 0 S_b 0], options, r, f, kap, kap_R, k_M, k_E, v, g, k, u_E0, L_b, L_s, L_j, L_p, L_m, t_s, t_j, t_p, r_B, v_Hp, s_G, h_a, h_Bbs, h_Bsp, h_Bpi, thinning);
  value = 1 - qhSC(end,4);
end

