%% sgr_std_c
% Gets specific population growth rate for the std model

%%
function [r, S_b, S_p, t_max, info] = sgr_std_c (par, T_pop, f_pop)
  % created 2019/07/06 by Bas Kooijman
  
  %% Syntax
  % [r, S_b, S_p, t_max, info] = <../sgr_std_c.m *sgr_std*> (par, T_pop, f_pop)
  
  %% Description
  % Specific population growth rate for the std model;
  % Hazard includes 
  %
  %  * thinning (optional, default: 1; otherwise specified in par.thinning), 
  %  * stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbj, par.h_Bji)
  %  * ageing (controlled by par.h_a and par.s_G)
  %
  % With thinning the hazard rate is such that the feeding rate of a cohort does not change during growth, in absence of other causes of death.
  % Survival of embryo due to ageing is taken for sure
  % Buffer handling rule: continuous reproduction, see sgr_std for producing an egg as soon as buffer allows.
  % Food density and temperature are assumed to be constant; temperature is specified in par.T_typical.
  % The resulting specific growth rate r is solved from the characteristic equation 1 = \int_0^a_max S(a) R(a) exp(- r a) da
  %   with a_max such that S(a_max) = 1e-6;
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
  % * t_max: maximum time since birth for integration of the characteristic equation
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % See <ssd_std.html *ssd_std*> for mean age, length, squared length, cubed length.
  % See <f_ris0_std.html *f_ris0_std*> for f at which r = 0
  % par.thinning, par.h_B0b, par.h_Bbj and par.h_Bji are not standard in structure par; Add them before use if necessary.
  %
  %% Example of use
  % cd to entries/Passer_domesticus/; load results_Passer_domesticus; 
  % [r, r_max, S_b, S_p, info] = sgr_std(par)

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  

  % defaults
  if exist('T_pop','var')
    T = T_pop;
  else
    T = C2K(20);
  end
  if exist('f_pop','var')
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
  [u_E0, l_b, info] = get_ue0([g k v_Hb], f);
  if info == 0
    r = NaN;  S_b = NaN; S_p = NaN; t_max = NaN;
    return
  end
  [tau_p, tau_b, l_p, l_b, info] = get_tp([g k l_T v_Hb v_Hp], f, l_b);
  if l_p > f || info == 0 || tau_p < 0
    r = 0; S_b = NaN; S_p = NaN; t_max = NaN; info = 0;
    return
  end
  aT_b = tau_b/ kT_M; aT_p = tau_p/ kT_M; tT_p = aT_p - aT_b; % d, age at birth, puberty
  S_b = exp(- aT_b * h_B0b);              % -, survivor prob at birth
  L_b = L_m * l_b; L_p = L_m * l_p;
  l_i = f - l_T; L_i = L_m * l_i;         % -, cm, ultimate scaled struc length
  
  % get S_p
  [t, qhSC] = ode45(@dget_qhSC, [0; tT_p], [0, 0, S_b, 0], [], 0, f, kap, kap_R, kT_M, k, v_Hp, u_E0, L_b, L_p, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning);
  S_p = qhSC(end,3);
  
  % max time for integration of the char eq
  options = odeset('Events', @dead_for_sure);  
  [t, qhSC] = ode45(@dget_qhSC, [0; 1e10], [0, 0, S_b, 0], options, 0, f, kap, kap_R, kT_M, k, v_Hp, u_E0, L_b, L_p, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning);
  t_max = t(end);
  
  % ceiling for r, see DEB3 eq (9.22) 
  pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp]; % compose parameter vector at T
  R_i = TC * reprod_rate(L_i, f, pars_R);                % #/d, ultimate reproduction rate at T
  char_eq = @(rho, rho_p) 1 + exp(- rho * rho_p) - exp(rho);
  r_max = R_i * fzero(@(rho) char_eq(rho, R_i * tT_p), [0 1]);
  
  % find r from char eq 1 = \int_0^infty S(t) R(t) exp(-r*t) dt
  [r, fval, info, output] = fzero(@charEq, [0 r_max], [], t_max, S_b, f, kap, kap_R, kT_M, k, v_Hp, u_E0, L_b, L_p, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning);
 
end
   
function value = charEq (r, t_max, S_b, f, kap, kap_R, k_M, k, v_Hp, u_E0, L_b, L_p, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  [t, qhSC] = ode45(@dget_qhSC, [0 t_max], [0 0 S_b 0], [], r, f, kap, kap_R, k_M, k, v_Hp, u_E0, L_b, L_p, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning);
  value = 1 - qhSC(end,4);
end

function dqhSC = dget_qhSC(t, qhSC, sgr, f, kap, kap_R, k_M, k, v_Hp, u_E0, L_b, L_p, L_m, L_T, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  % t: time since birth
  q   = qhSC(1); % 1/d^2, aging acceleration
  h_A = qhSC(2); % 1/d^2, hazard rate due to aging
  S   = qhSC(3); % -, survival prob
  
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
  
  l = L/ L_m; l_p = L_p/ L_m; l_T = L_T/ L_m;
  R = (l > l_p) * kap_R * k_M * (f * l^2/ (f + g) * (g + l_T + l) - k * v_Hp) * (1 - kap)/ u_E0;
  dCharEq = S * R * exp(- sgr * t);
  
  dqhSC = [dq; dh_A; dS; dCharEq]; 
end

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSC, r, f, kap, kap_R, kT_M, k, v_Hp, u_E0, L_b, L_p, L_m, L_T, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning)
  value = qhSC(3) - 1e-6;  % trigger 
  isterminal = 1;    % terminate after the first event
  direction  = [];  % get all the zeros
end
