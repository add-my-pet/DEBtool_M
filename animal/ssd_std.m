%% ssd_std
% Gets mean structural length^1,2,3 and wet weight at f and r

%%
function [EL, EL2, EL3, EL_pi, EL2_pi, EL3_pi, EWw, EWw_pi, hWw, theta_bp, S_p, tS, tSs] = ssd_std(par, T_pop, f_pop, sgr)
  % created 2019/07/09 by Bas Kooijman
  
  %% Syntax
  % [EL, EL2, EL3, EL_pi, EL2_pi, EL3_pi, hWw, EWw, EWw_pi, theta_bp, S_p, tS, tSs] = <../ssd_std.m *ssd_std*> (par, T_pop, f_pop, sgr)
  
  %% Description
  % Mean L, L^2, L^3, Ww, given f and r, on the assumptions that the population has the stable age distribution.
  % Use sgr_std to obtain 4th input: sgr. brackground hazards are not standard in par as produced by AmP; add them before use.
  % Hazard includes 
  %
  % * thinning (optional, default: 1; otherwise specified in par.thinning), 
  % * stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbj, par.h_Bji)
  % * ageing (controlled by par.h_a and par.s_G)
  %
  % Input
  %
  % * par: structure with parameters for individual
  % * T_pop: optional temperature (in Kelvin, default C2K(20))
  % * f_pop: optional scalar with scaled functional response (overwrites value in par.f)
  % * sgr: specific population growth rate at T_pop
  %
  % Output
  %
  % * EL: mean structural length for post-natals
  % * EL2: mean squared structural length for post-natals
  % * EL3: mean cubed structural length for post-natals
  % * EL_pi: mean structural length for adults
  % * EL2_pi: mean squared structural length  for adults
  % * EL3_pi: mean cubed structural length  for adults
  % * EWw: mean wet weight of post-natals (excluding contributions from reproduction buffer)
  % * EWw_pi: mean wet weight of adults (excluding contributions from reproduction buffer)
  % * hWw: production of dead post-natals (excluding contributions from reproduction buffer)
  % * theta_bp: fraction of the post-natal individuals that is juvenile
  % * S_p: survival probability at puberty
  % * tS: (n,2)-array with age (d), surivival probability (-)
  % * tSs: (n,2)-array with age (d), survivor function of the stable age distribution (-)
  %
  %% Remarks
  % The background hazards, if specified in par, are assumed to correspond with T_typical, not with T_ref
  %
  %% Example of use
  % cd to entries/Rana_temporaria/; load results_Rana_temporaria; 
  % [EL, EL2, EL3, EWw, Prob_bp] = ssd_std(par, [], [], 0.006, 1e10)

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

  % get t_p
  [tau_p, tau_b, l_p, l_b, info] = get_tp([g k l_T v_Hb v_Hp], f);
  tT_p = (tau_p - tau_b)/ kT_M; % d, time since birth
  aT_b = tau_b/ kT_M; % d, age at birth
  S_b = exp(-aT_b * h_B0b); % -, survivor prob at birth
  L_b = L_m * l_b; % cm, structural length at birth

  % work with time since birth to exclude contributions from embryo lengths to EL, EL2, EL3, EWw
  options = odeset('Events', @p_dead_for_sure, 'AbsTol', 1e-9, 'RelTol', 1e-9); 
  qhSL_0 = [0 0 S_b 0 0 0 0 0 0 0 0]; % initial states
  [t, qhSL, t_pi, qhSL_pi, ie] = ode45(@dget_qhSL, [0, 1e5], qhSL_0, options, sgr, f, L_b, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning);
  if length(ie) == 1
    EL=NaN; EL2=NaN; EL3=NaN; EL_pi=NaN; EL2_pi=NaN; EL3_pi=NaN; EWw=NaN; EWw_pi=NaN; hWw=NaN; theta_bp=NaN; S_p = NaN; tS=[NaN NaN]; tSs=[NaN NaN];
    return
  end
  EL0_i = qhSL_pi(2,4); theta_bp = qhSL_pi(1,4)/ EL0_i; % -, fraction of post-natals that is juvenile
  theta_pi = 1 - theta_bp; % -, fraction of post-natals that is adult
  EL = qhSL(end,5)/ EL0_i; EL2 = qhSL(end,6)/ EL0_i; EL3 = qhSL(end,7)/ EL0_i; % mean L^1,2,3 for post-natals
  EL_pi = qhSL(end,8)/ EL0_i/ theta_pi; EL2_pi = qhSL(end,9)/ EL0_i/ theta_pi; EL3_pi = qhSL(end,10)/ EL0_i/ theta_pi; % mean L^1,2,3 for adults
  EWw = EL3 * (1 + f * ome); EWw_pi = EL3_pi * (1 + f * ome);% g, mean weight of post-natails, adults
  hWw = qhSL(end,11)/ EL0_i * (1 + f * ome); % g/d, production of dead post-natal mass
  S_p = qhSL_pi(1,3); % -, survival prob at puberty
  
  tS = [0, 1; t + aT_b, qhSL(:,3)];                   % d,-, convert time since birth to age for survivor probability
  tSs = [0 1; t + aT_b, 1 - qhSL(:,4)/ qhSL_pi(2,4)]; % d,-, convert time since birth to age for survivor function of the stable age distribution
end

function dqhSL = dget_qhSL(t, qhSL, sgr, f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  % t: time since birth
  q   = max(0, qhSL(1)); % 1/d^2, aging acceleration
  h_A = max(0, qhSL(2)); % 1/d^2, hazard rate due to aging
  S   = max(0, qhSL(3)); % -, survival prob
  
  L_i = L_m * f - L_T;
  L = L_i - (L_i - L_b) * exp(- t * r_B);
  r = max(0, v * (f/ L - (1 + L_T/ L)/ L_m)/ (f + g)); % 1/d, spec growth rate of structure
  dq = (q * s_G * L^3/ L_m^3 + h_a) * f * (v/ L - r) - r * q; % 1/d^3
  dh_A = q - r * h_A;                                         % 1/d^2
  if t < t_p
    h_B = h_Bbp;
  else
    h_B = h_Bpi;
  end
  h_X = thinning * r * 2/3;
  h = max(0, h_A + h_B + h_X); 
  dS = - h * S;
    
  dEL0 = exp(- sgr * t) * S;
  % EL0(t)/EL0(infty) equals distribution function of times since birth
  % so dEL0(t)/EL0(infty) equals pdf of times since birth
  % division by EL0(infty) is done after integration
  dEL1 = L * dEL0; % d/dt L*pdf(t)
  dEL2 = L * dEL1; % d/dt L^2*pdf(t)
  dEL3 = L * dEL2; % d/dt L^3*pdf(t)
  %
  dEL1_pi = (t > t_p) * L * dEL0; % d/dt L*pdf(t) of adults
  dEL2_pi = L * dEL1_pi; % d/dt L^2*pdf(t) of adults
  dEL3_pi = L * dEL2_pi; % d/dt L^3*pdf(t) of adults
  
  dhV = h * dEL3; % cm^3/d, production of dead structure
  
  dqhSL = [dq; dh_A; dS; dEL0; dEL1; dEL2; dEL3; dEL1_pi; dEL2_pi; dEL3_pi; dhV]; 
end

% event p_dead_for_sure
function [value,isterminal,direction] = p_dead_for_sure(t, qhSFL, sgr, f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  value = [t - t_p; qhSFL(3) - 1e-6];  % trigger 
  isterminal = [0; 1];    % terminate after the second event
  direction  = [];  % get all the zeros
end
