%% sgr_std
% Gets specific population growth rate for the std model

%%
function [r, S_b, S_p, aT_b, tT_p, info] = sgr_std (par, T_pop, f_pop)
  % created 2019/07/06 by Bas Kooijman
  
  %% Syntax
  % [r, S_b, S_p, aT_b, tT_p, info] = <../sgr_std.m *sgr_std*> (par, T_pop, f_pop)
  
  %% Description
  % Specific population growth rate for the std model.
  % Hazard includes 
  %
  %  * thinning (optional, default: 1; otherwise specified in par.thinning), 
  %  * stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbj, par.h_Bji)
  %  * ageing (controlled by par.h_a and par.s_G)
  %
  % With thinning the hazard rate is such that the feeding rate of a cohort does not change during growth, in absence of other causes of death.
  % Survival of embryo due to ageing is taken for sure
  % Buffer handling rule: produce an egg as soon as buffer allows, see sgr_std_c for continuous reproduction
  % Food density and temperature are assumed to be constant; temperature is specified in par.T_typical.
  % The resulting specific growth rate r is solved from the characteristic equation 1 = \int_0^a_max S(a) R(a) exp(- r a) da
  %   with a_max such that S(a_max) = 1e-6 and  R(a) consists of Dirac delta functions, while R(a) = 0 for a < a_p
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
  % * S_b: survivor probability at birth
  % * S_p: survivor probability at puberty
  % * aT_b: age at birth
  % * tT_p: time since birth at puberty
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % See <ssd_std.html *ssd_std*> for mean age, length, squared length, cubed length.
  % See <f_ris0_std.html *f_ris0_std*> for f at which r = 0.
  % par.thinning, par.h_B0b, par.h_Bbj and par.h_Bji are not standard in structure par; Add them before use if necessary.
  % par.gender is not standard in structure par. Add it before use.
  %
  %% Example of use
  % cd to entries/Rana_temporaria/; load results_Rana_temporaria; 
  % [r, S_b, S_p, tT_p, info] = sgr_std(par)

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
  if ~exist('h_Bbp', 'var')
    h_Bbp = 0;
  end
  if ~exist('h_Bpi', 'var')
    h_Bpi = 0;
  end
  if ~exist('gender', 'var')
    gender = 'D';
  end
  if ~isempty(strfind(gender, 'D'))
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
  kT_M = k_M * TC; vT = v * TC; hT_a = h_a * TC^2;
  rT_B = kT_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate  
  
  [u_E0, l_b, info] = get_ue0([g k v_Hb], f);
  if info == 0
    r = NaN; S_b = NaN; S_p = NaN; tT_p = NaN;
    return
  end
  [tau_p, tau_b, l_p, l_b, info] = get_tp([g k l_T v_Hb v_Hp], f, l_b);
  if l_p > f || info == 0 || tau_p < 0
    r = 0; S_b = NaN; S_p = NaN; aT_b = NaN; tT_p = NaN; info = 0;
    return
  end
  aT_b = tau_b/ kT_M; aT_p = tau_p/ kT_M; tT_p = aT_p - aT_b; % d, age at birth, puberty
  S_b = exp(-aT_b * h_B0b); % -, survivor prob at birth
  L_b = L_m * l_b; l_i = f - l_T; % -, cm, ultimate scaled struc length
  
  % max time for integration of the char eq
  options = odeset('Events', @dead_for_sure, 'AbsTol',1e-9, 'RelTol',1e-9);  
  [t, qhS] = ode45(@dget_qhS, [0; 1e10], [0, 0, S_b], options, f, L_b, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning);
  t_max = min(1e5,t(end)); % sometimes detection of proper t_max fails

  % survivor at egg-laying
  [t, N] = ode45(@dget_N, [0 t_max], 0, [], f, kap, kap_R, kT_M, k, g, v_Hp, l_p, l_i, l_T, u_E0, rT_B); % times since puberty
  R_i = (N(end) - N(end-1))/ (t(end) - t(end-1));
  t = spline1(1:N(end), [N, tT_p + t]);  % convert times since puberty to times since birth at egg laying
  [t_S, qhS] = ode45(@dget_qhS, [0; tT_p; t], [0, 0, S_b], [], f, L_b, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning);  
  S = qhS(:,3); S_p = S(3); S(1:2) = []; i = ~isnan(S); S = max(1e-9,S(i)); t = t(i); % survivor prob and times at egg laying
  
  if sum(S)<1
    r = NaN; info = 0; % no positive r exists
    return
  end
  
  % ceiling for r, see DEB3 eq (9.22) 
  char_eq = @(rho, rho_p) 1 + exp(- rho * rho_p) - exp(rho);
  [rho_max, fval, info] = fzero(@(rho) char_eq(rho, R_i * tT_p), [1e-9 1]); r_max = rho_max * R_i;
  
  % find r from char eq 1 = \int_0^infty S(t) R(t) exp(-r*t) dt
  %   for Dirac delta functions for R(t): 1 = sum_i S(t_i) exp(- r*t_i),
  %   where t_i's are times at egg laying
  char_eq = @(r, t, S) 1 - sum(S .* exp(- r * t));
  if char_eq(0, t, S) > 0
    r = NaN; info = 0; % no positive r exists
  else
    %options = optimset('Display','iter'); % show iterations
    [r, fval, info, output] = fzero(@(r) char_eq(r, t, S), [0 r_max]);
  end
 
end

function dN = dget_N(t, N, f, kap, kap_R, k_M, k, g, v_Hp, l_p, l_i, l_T, u_E0, r_B)
  % t: time since puberty
  % N: cumulative number of eggs
  l = l_i - (l_i - l_p) * exp(- r_B * t);
  dN = kap_R * k_M * (f * l^2/ (f + g) * (g + l_T + l) - k * v_Hp) * (1 - kap)/ u_E0;
end
    
function dqhS = dget_qhS(t, qhS, f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  % t: time since birth
  q   = qhS(1); % 1/d^2, aging acceleration
  h_A = qhS(2); % 1/d^2, hazard rate due to aging
  S   = max(0, qhS(3)); % -, survival prob
  
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

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhS, f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  value = qhS(3) - 1e-6;  % trigger 
  isterminal = 1;    % terminate after the first event
  direction  = [];  % get all the zeros
end
