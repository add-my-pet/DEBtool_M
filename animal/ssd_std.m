%% ssd_std
% Gets mean structural length^1,2,3 and wet weight at f and r

%%
function [EL, EL2, EL3, EWw, Prob_bp] = ssd_std(par, T_pop, f_pop, sgr)
  % created 2019/07/09 by Bas Kooijman
  
  %% Syntax
  % [EL, EL2, EL3, EWw, Prob_bp] = <../ssd_std.m *ssd_std*> (par, T_pop, f_pop, r)
  
  %% Description
  % Mean L, L^2, L^3, Ww, given f and r, on the assumptions that the population has the stable age distribution
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
  % * EL: mean structural length
  % * EL2: mean squared structural length
  % * EL3: mean cubed structural length
  % * EWw: mean wet weight (excluding contributions form reproduction buffer)
  % * Prob_bp: fraction of the post-natal individuals that is juvenile
  %
  %% Remarks
  %
  %% Example of use
  % cd to entries/Rana_temporaria/; load results_Rana_temporaria; 
  % [EL, EL2, EL3, EWw, Prob_bp] = sgr_std(par, [], [], 0.006, 1e10)

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
  
  TC = tempcorr(T, T_ref, T_A);
  kT_M = k_M * TC; vT = v * TC; hT_a = h_a * TC^2;
  rT_B = kT_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate  

  % get t_p
  [tau_p, tau_b, l_p, l_b, info] = get_tp([g k l_T v_Hb v_Hp], f);
  tT_p = (tau_p - tau_b)/ kT_M; % d, time since birth
  aT_b = tau_b/ k_M; % d, age at birth
  S_b = exp(-aT_b * h_B0b); % -, survivor prob at birth
  L_b = L_m * l_b; % cm, structural length at birth

  options = odeset('Events', @dead_for_sure);  
  [t, qhSL] = ode45(@dget_qhSL, [0, tT_p, 1e5], [0 0 S_b 0 0 0 0], options, sgr, f, L_b, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning);
  Prob_bp = qhSL(2,4); Prob_bi = qhSL(end,4); EL = qhSL(end,5); EL2 = qhSL(end,6); EL3 = qhSL(end,7); 
  % S_p = qhSL(2,3); % -, survival prob at puberty, just for checking
  % qhSL(3,4) is the integrated pfd of the stable age distribution and should equal 1
  EWw = EL3 * (1 + f * ome); % g, mean weight
  
end

function dqhSL = dget_qhSL(t, qhSL, sgr, f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  % t: time since birth
  q   = qhSL(1); % 1/d^2, aging acceleration
  h_A = qhSL(2); % 1/d^2, hazard rate due to aging
  S   = qhSL(3); % -, survival prob
  
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
  h = h_A + h_B + h_X + sgr; 
  dS = - h * S;
    
  dEL0 = h  * S;   % d/dt pdf(t) of times since birth
  dEL1 = L * dEL0; % d/dt L*pdf(t)
  dEL2 = L * dEL1; % d/dt L^2*pdf(t)
  dEL3 = L * dEL2; % d/dt L^3*pdf(t)
  dqhSL = [dq; dh_A; dS; dEL0; dEL1; dEL2; dEL3]; 
end

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSL, sgr, f, L_b, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  value = qhSL(3) - 1e-6;  % trigger 
  isterminal = 1;    % terminate after the first event
  direction  = [];  % get all the zeros
end
