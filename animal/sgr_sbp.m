%% sgr_sbp
% Gets specific population growth rate for the sbp model

%%
function [r, info] = sgr_sbp (par, T_pop, f_pop)
  % created 2019/07/30 by Bas Kooijman
  
  %% Syntax
  % [r, info] = <../sgr_sbp.m *sgr_sbp*> (par, T_pop, f_pop)
  
  %% Description
  % Specific population growth rate for the std model.
  % Hazard includes 
  %
  %  * thinning (optional, default: 1; otherwise specified in par.thinning), 
  %  * stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbp, par.h_Bpi)
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
  % See <ssd_sbp.html *ssd_sbp*> for mean age, length, squared length, cubed length and other statistics.
  % See <f_ris0_mod.html *f_ris0_mod*> for f at which r = 0.
  % par.thinning, par.h_B0b, par.h_Bbp and par.h_Bpi are not standard in structure par; Add them before use if necessary.
  % par.reprodCode is not standard in structure par. Add it before use. If missing, "O" is assumed.

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
  kT_M = k_M * TC; vT = v * TC; hT_a = h_a * TC^2; rT_B = kT_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate  
  
  % supporting statistics
  [u_E0, l_b, info] = get_ue0([g k v_Hb], f); % -, scaled cost for egg
  if info == 0
    r = NaN; return
  end
  [tau_p, tau_b, l_p, l_b, info] = get_tp([g k l_T v_Hb v_Hp], f, l_b); % -, scaled ages and lengths at puberty, birth
  if l_p > f || info == 0 || tau_p < 0
    r = NaN; info = 0;
    return
  end
  aT_b = tau_b/ kT_M; tT_p = (tau_p - tau_b)/ kT_M; % d, age at birth, time since birth at puberty
  S_b = exp(-aT_b * h_B0b);          % -, survivor prob at birth
  L_b = L_m * l_b; L_p = L_m * l_p;  % cm, struc length at birth, puberty
    
  % ceiling for r
  R_i = kap_R * (1 - kap) * kT_M * (l_p^2 - k * v_Hp)/ u_E0; % #/d, ultimate reproduction rate at T eq (2.56) of DEB3 for l_T = 0 and l = f
  char_eq = @(rho, rho_p) 1 + exp(- rho * rho_p) - exp(rho); % see DEB3 eq (9.22): exp(-r*a_p) = exp(r/R) - 1 
  [rho_max, fval, info] = fzero(@(rho) char_eq(rho, R_i * tT_p), [1e-9 1]); 
  r_max = rho_max * R_i; % 1/d, pop growth rate for eternal surivival and ultimate reproduction rate since puberty

  % find r from char eq 1 = \int_0^infty S(t) R(t) exp(-r*t) dt
  pars_charEq = {S_b, f, kap, kap_R, kT_M, k, v_Hp, u_E0, L_b, L_p, L_m, tT_p, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning};
  if charEq(0, pars_charEq{:}) > 0
    fprintf(['Warning from sgr_sbp: no root for the characteristic equation, thinning = ', num2str(thinning), '\n']);
    r = NaN; info = 0; % no positive r exists
  elseif charEq(r_max, pars_charEq{:}) < 0
    [r, info] = nmfzero(@charEq, 0, [], pars_charEq{:});
  else
    [r, info] = fzero(@charEq, [0 r_max], [], pars_charEq{:});
  end
end

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSC, varargin)
  value = qhSC(3) - 1e-6;  % trigger 
  isterminal = 1;    % terminate after the first event
  direction  = [];  % get all the zeros
end

% reproduction is continuous
function dqhSC = dget_qhSC(t, qhSC, sgr, f, kap, kap_R, k_M, k, v_Hp, u_E0, L_b, L_p, L_m, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  % t: time since birth
  q   = qhSC(1); % 1/d^2, aging acceleration
  h_A = qhSC(2); % 1/d^2, hazard rate due to aging
  S   = qhSC(3); % -, survival prob
  
  if t < t_p
    L_i = L_m * f;
    L = L_i - (L_i - L_b) * exp(- t * r_B);
    r = 3 * r_B * (L_i/ L - 1); % 1/d, spec growth rate of structure
    h_B = h_Bbp;
  else
    L = L_p;
    r = 0;
    h_B = h_Bpi;
  end
  dq = (q * s_G * L^3/ L_m^3 + h_a) * f * (v/ L - r) - r * q;
  dh_A = q - r * h_A;

  h_X = thinning * r * 2/3;
  h = h_A + h_B + h_X; 
  dS = - h * S;
  
  l_p = L_p/ L_m; 
  R = (t > t_p) * kap_R * k_M * (l_p^2 - k * v_Hp) * (1 - kap)/ u_E0; % 1/d, reprod rate
  dCharEq = S * R * exp(- sgr * t);
  
  dqhSC = [dq; dh_A; dS; dCharEq]; 

end

function value = charEq (r, S_b, f, kap, kap_R, k_M, k, v_Hp, u_E0, L_b, L_p, L_m, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  options = odeset('Events', @dead_for_sure, 'NonNegative', ones(4,1), 'AbsTol',1e-9, 'RelTol',1e-9);  
  [t, qhSC] = ode45(@dget_qhSC, [0 1e10], [0 0 S_b 0], options, r, f, kap, kap_R, k_M, k, v_Hp, u_E0, L_b, L_p, L_m, t_p, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning);
  value = 1 - qhSC(end,4);
end


