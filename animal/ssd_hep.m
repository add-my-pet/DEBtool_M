%% ssd_hep
% Gets mean structural length^1,2,3 and wet weight at f and r

%%
function stat = ssd_hep(stat, code, par, T_pop, f_pop, sgr)
  % created 2019/07/31 by Bas Kooijman
  
  %% Syntax
  % stat = <../ssd_hep.m *ssd_hep*> (stat, code, par, T_pop, f_pop, sgr)
  
  %% Description
  % Mean L, L^2, L^3, Ww, given f and r, on the assumption that the population has the stable age distribution.
  % Use sgr_hep to obtain sgr. Background hazards are not standard in par as produced by AmP; add them before use.
  % If code is e.g. '01f', fields stat.f0.thin1.f are filled. For 'f0m', the fields stat.f.thin0.m are filled. 
  % If par is not a structure, all fields are filled with NaN.
  % Hazard includes 
  %
  % * thinning (optional, default: 1; otherwise specified in par.thinning), 
  % * stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbp, par.h_Bpi)
  % * ageing (controlled by par.h_a and par.s_G)
  %
  % Input
  %
  % * struc: structure to which output is added
  % * code: character string with scaled functional response (0,f,1), thinning (0,1), gender(f,m), e.g. '10f'
  % * par: structure with parameters for individual
  % * T_pop: optional temperature (in Kelvin, default C2K(20))
  % * f_pop: optional scalar with scaled functional response (overwrites value in par.f)
  % * sgr: specific population growth rate at T_pop
  %
  % Output: stat: structure with fields
  %
  % * EL: cm, mean structural length for post-natals
  % * EL2: cm^2, mean squared structural length for post-natals
  % * EL3: cm^3, mean cubed structural length for post-natals
  % * EL_a: cm, mean structural length for adults
  % * EL2_a: cm^2, mean squared structural length  for adults
  % * EL3_a: cm^3, mean cubed structural length  for adults
  % * EWw_n: g, mean wet weight of post-natals (excluding contributions from reproduction buffer)
  % * EWw_a: g, mean wet weight of adults (excluding contributions from reproduction buffer)
  % * hWw: 1/d, production of dead post-natals (excluding contributions from reproduction buffer)
  % * theta_jn: -, fraction of the post-natal individuals that is juvenile
  % * S_b: -, survival probability at birth
  % * S_p: -, survival probability at puberty
  % * tS: (n,2)-array with age (d), surivival probability (-)
  % * tSs: (n,2)-array with age (d), survivor function of the stable age distribution (-)
  % * ER: #/d, mean reproduction rate of adult female
  % * del_ea: -, number of embryos per adult
  % * theta_e: -, fraction of individuals that is embryo
  % * Ep_A: J/d, mean assimilation rate for post-natals
  % * EJ_X: g/d, mean feeding rate for post-natals
  % * EJ_P: g/d, mean defacating rate for post-natals
  % * a_b: d, age at birth
  % * t_p: d, time since birth at puberty
  %
  %% Remarks
  % The background hazards, if specified in par, are assumed to correspond with T_typical, not with T_ref

  % get output fields
  fldf = 'f0fff1'; fldf = fldf([-1 0] + 2 * strfind('0f1',code(1))); % f0 or ff or f1
  fldt = 'thin0thin1'; fldt = fldt([-4 -3 -2 -1 0] + 5 * strfind('01',code(2))); % thin0 or thin1
  fldg = code(3); % f or m
  
  if ~isstruct(par) || isnan(sgr)
    stat = setNaN(stat, fldf, fldt, fldg); % set all statistics to NaN
    return
  end

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
  kT_M = k_M * TC; vT = v * TC; hT_a = h_a * TC^2; pT_Am = TC * p_Am;

  % supporting statistics
  v_Rj = kap/ (1 - kap) * E_Rj/ E_G; pars_tj = [g k v_Hb v_Hp v_Rj];
  [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj_hep(pars_tj, f); 
  if isempty(tau_j)
    stat = setNaN(stat, fldf, fldt, fldg); % set all statistics to NaN
    return
  end
  aT_b = tau_b/ kT_M; tT_j = (tau_j - tau_b)/ kT_M; tT_p = (tau_p - tau_b)/ kT_M; % unscale
  L_b = L_m * l_b; L_p = L_m * l_p; L_j = L_m * l_j;   L_i = L_m * l_i;  % unscale
  rT_j = kT_M * rho_j; rT_B = kT_M * rho_B; % 1/d, growth rates
  
  % life span as imago
  pars_tm = [g; k; v_Hb; v_Hp; v_Rj; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  tau_m = get_tm_mod('hep',pars_tm, f);    % -, scaled mean life span at T_ref
  tT_im = (tau_m - tau_p)/ kT_M;           % d, mean life span as imago

  % reproduction rate of imago
  [S_b, q_b, h_Ab, tau_b, l_b, u_E0] = get_Sb([g k v_Hb h_a/k_M^2 s_G h_B0b], f);
  E_0 = u_E0 * g * E_m * L_m^3;       % J, energy cost of egg
  N = kap_R * E_Rj * L_j^3/ E_0;      % #, number of eggs at emergence
  R = N/ tT_im;                       % #/d, reproduction rate
  tT_N0 = tT_j + tT_im;               % d, time since birth at which all eggs are produced

  % work with time since birth to exclude contributions from embryo lengths to EL, EL2, EL3, EWw
  options = odeset('Events',@dead_for_sure, 'AbsTol', 1e-9, 'RelTol', 1e-9); 
  qhSL_0 = [q_b; h_Ab; S_b; 0; 0; 0; 0; 0; 0; 0; 0]; % initial states
  pars_qhSL = {sgr, f, kT_M, vT, g, k, R, L_b, L_p, L_j, L_i, L_m, tT_p, tT_j, tT_N0, rT_j, rT_B, v_Hp, s_G, hT_a, h_Bbp, h_Bpi, thinning};
  [t, qhSL] = ode45(@dget_qhSL, [0; min(1e6-1,tT_p); 1e6], qhSL_0, options, pars_qhSL{:});
  S_p = qhSL(2,3); % -, survival prob at puberty
  EL0_i = qhSL(end,4); theta_jn = qhSL(end,4)/ EL0_i; 
  stat.(fldf).(fldt).(fldg).theta_jn = theta_jn; % -, fraction of post-natals that is juvenile
  theta_an = 1 - theta_jn; % -, fraction of post-natals that is adult
  EL = qhSL(end,5)/ EL0_i; EL2 = qhSL(end,6)/ EL0_i; EL3 = qhSL(end,7)/ EL0_i; % mean L^1,2,3 for post-natals
  if theta_an > 0
    EL_a = qhSL(end,8)/ EL0_i/ theta_an; EL2_a = qhSL(end,9)/ EL0_i/ theta_an; EL3_a = qhSL(end,10)/ EL0_i/ theta_an; % mean L^1,2,3 for adults
  else % no adults present
    EL_a = NaN; EL2_a = NaN; EL3_a = NaN; % mean L^1,2,3 for adults
  end
  stat.(fldf).(fldt).(fldg).EWw_n = EL3 * (1 + f * ome); 
  stat.(fldf).(fldt).(fldg).EWw_a = EL3_a * (1 + f * ome);% g, mean weight of post-natails, adults
  stat.(fldf).(fldt).(fldg).hWw_n = qhSL(end,11)/ EL0_i * (1 + f * ome); % g/d, production of dead post-natal mass
  stat.(fldf).(fldt).(fldg).S_b = S_b; % -, survival prob at birth
  stat.(fldf).(fldt).(fldg).S_p = S_p; % -, survival prob at puberty
  
  stat.(fldf).(fldt).(fldg).tS = [0, 1; t + aT_b, qhSL(:,3)];          % d,-, convert time since birth to age for survivor probability
  stat.(fldf).(fldt).(fldg).tSs = [0 1; t + aT_b, 1 - qhSL(:,4)/ EL0_i]; % d,-, convert time since birth to age for survivor function of the stable age distribution
  
  ER = R; % 1/d, mean reproduction rate of  female imago
  stat.(fldf).(fldt).(fldg).ER = ER; 
  del_ea = ER * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
  stat.(fldf).(fldt).(fldg).del_ea = del_ea; 
  stat.(fldf).(fldt).(fldg).theta_e = del_ea/ (del_ea + 1/ theta_an); % -, fraction of individuals that is embryo

  Ep_A = EL3 * pT_Am/ L_b * f; % J/d, assimilation = mobilisation of adults
  stat.(fldf).(fldt).(fldg).Ep_A = Ep_A; 
  stat.(fldf).(fldt).(fldg).EJ_X = Ep_A/ kap_X/ mu_X * w_X/ d_X; 
  stat.(fldf).(fldt).(fldg).EJ_P = Ep_A/ kap_X * kap_P/ mu_P * w_P/ d_P;

  % pack output
  stat.(fldf).(fldt).(fldg).EL_n=EL; stat.(fldf).(fldt).(fldg).EL2_n=EL2; stat.(fldf).(fldt).(fldg).EL3_n=EL3; 
  stat.(fldf).(fldt).(fldg).EL_a=EL_a; stat.(fldf).(fldt).(fldg).EL2_a=EL2_a; stat.(fldf).(fldt).(fldg).EL3_a=EL3_a; 
  stat.(fldf).(fldt).(fldg).a_b = aT_b; stat.(fldf).(fldt).(fldg).t_p = tT_p;
end


function dqhSL = dget_qhSL(t, qhSL, sgr, f, k_M, v, g, k, R, L_b, L_p, L_j, L_i, L_m, t_p, t_j, t_N0, r_j, r_B, v_Hp, s_G, h_a, h_Bbp, h_Bpi, thinning)
  q   = max(0,qhSL(1)); % 1/d^2, aging acceleration
  h_A = max(0,qhSL(2)); % 1/d^2, hazard rate due to aging
  S   = max(0,qhSL(3)); % -, survival prob
  
  if t < t_p
    h_B = h_Bbp;
    L = L_b * exp(r_j * t);
    r = r_j;
    h_X = thinning * r; % 1/d, hazard due to thinning
    dq = 0;
    dh_A = 0;
  elseif t < t_j
    h_B = h_Bpi;
    L = L_i - (L_i - L_p) * exp(-r_B * (t - t_p));
    r = 3 * r_B * (L_i/ L - 1); % 1/d, spec growth rate of structure
    h_X = thinning * r * 2/3; % 1/d, hazard due to thinning
    dq = 0;
    dh_A = 0;
  else % imago
    h_B = h_Bpi;
    s_M = L_p/ L_b;
    L = L_j;
    r = 0; % 1/d, spec growth rate of structure
    h_X = 0; % 1/d, hazard due to thinning
    dq = (q * s_G * L^3/ L_m^3/ s_M^3 + h_a) * f * (v * s_M/ L - r) - r * q;
    dh_A = q - r * h_A; % 1/d^2, change in hazard due to aging
  end

  h = h_A + h_B + h_X; 
  dS = - h * S; % 1/d, change in survival prob
      
  dEL0 = exp(- sgr * t) * S;
  % EL0(t)/EL0(infty) equals distribution function of times since birth
  % so dEL0(t)/EL0(infty) equals pdf of times since birth
  % division by EL0(infty) is done after integration
  dEL1 = L * dEL0; % d/dt L*pdf(t)
  dEL2 = L * dEL1; % d/dt L^2*pdf(t)
  dEL3 = L * dEL2; % d/dt L^3*pdf(t)
  %
  dEL1_a = (t > t_p) * L * dEL0; % d/dt L*pdf(t) of adults
  dEL2_a = L * dEL1_a; % d/dt L^2*pdf(t) of adults
  dEL3_a = L * dEL2_a; % d/dt L^3*pdf(t) of adults
  
  dhV = h * dEL3; % cm^3/d, production of dead structure
  
  dqhSL = [dq; dh_A; dS; dEL0; dEL1; dEL2; dEL3; dEL1_a; dEL2_a; dEL3_a; dhV]; 
end

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSL, varargin)
  value = qhSL(3) - 1e-6;  % trigger 
  isterminal = 1;    % terminate after event
  direction  = [];   % get all the zeros
end

% fill fieds with nan
function stat = setNaN(stat, fldf, fldt, fldg)
    stat.(fldf).(fldt).(fldg).EL_n = NaN;     stat.(fldf).(fldt).(fldg).EL2_n = NaN;  stat.(fldf).(fldt).(fldg).EL3_n = NaN;   
    stat.(fldf).(fldt).(fldg).EL_a = NaN;     stat.(fldf).(fldt).(fldg).EL2_a = NaN;  stat.(fldf).(fldt).(fldg).EL3_a = NaN;   
    stat.(fldf).(fldt).(fldg).EWw_n = NaN;    stat.(fldf).(fldt).(fldg).EWw_a = NaN;  stat.(fldf).(fldt).(fldg).hWw_n = NaN;   
    stat.(fldf).(fldt).(fldg).theta_jn = NaN; stat.(fldf).(fldt).(fldg).S_b = NaN;    stat.(fldf).(fldt).(fldg).S_p = NaN; 
    stat.(fldf).(fldt).(fldg).tS = [NaN NaN]; stat.(fldf).(fldt).(fldg).tSs = [NaN NaN];
    stat.(fldf).(fldt).(fldg).ER = NaN;       stat.(fldf).(fldt).(fldg).del_ea = NaN; stat.(fldf).(fldt).(fldg).theta_e = NaN;   
    stat.(fldf).(fldt).(fldg).Ep_A = NaN;     stat.(fldf).(fldt).(fldg).EJ_X = NaN;   stat.(fldf).(fldt).(fldg).EJ_P = NaN;   
    stat.(fldf).(fldt).(fldg).a_b = NaN;      stat.(fldf).(fldt).(fldg).t_p = NaN;   
end