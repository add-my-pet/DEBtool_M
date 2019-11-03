%% ssd_stf
% Gets mean structural length^1,2,3 and wet weight at f and r

%%
function stat = ssd_stf(stat, code, par, T_pop, f_pop, sgr)
  % created 2019/07/26 by Bas Kooijman
  
  %% Syntax
  % stat = <../ssd_stf.m *ssd_stf*> (stat, code, par, T_pop, f_pop, sgr)
  
  %% Description
  % Mean L, L^2, L^3, Ww, given f and r, on the assumption that the population has the stable age distribution.
  % Use sgr_stf to obtain sgr. Brackground hazards are not standard in par as produced by AmP; add them before use.
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
  kT_M = k_M * TC; kT_J = k_J * TC; vT = v * TC; hT_a = h_a * TC^2; pT_Am = TC * p_Am;
  rT_B = kT_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate  

  % get t_p
  [tau_p, tau_b, l_p, l_b] = get_tp_foetus([g k l_T v_Hb v_Hp], f);
  tT_p = (tau_p - tau_b)/ kT_M; % d, time since birth at puberty
  aT_b = tau_b/ kT_M; % d, age at birth
  L_b = L_m * l_b; % cm, structural length at birth

  % work with time since birth to exclude contributions from embryo lengths to EL, EL2, EL3, EWw
  options = odeset('Events',@dead_for_sure, 'NonNegative',ones(11,1), 'AbsTol',1e-8, 'RelTol',1e-8); 
  [S_b, q_b, h_Ab, tau_b, l_b, u_E0] = get_Sb_foetus([g k v_Hb h_a/k_M^2 s_G h_B0b], f);
  qhSL_0 = [q_b * kT_M^2; h_Ab * k_M; S_b; 0; 0; 0; 0; 0; 0; 0; 0]; % initial states
  pars_qhSL = {sgr, f, L_b, L_m, rT_B, vT, g, s_G, hT_a, h_Bbp, h_Bpi, thinning};
  [t, qhSL, t_event, qhSL_event] = ode45(@dget_qhSL, [0; 1e6], qhSL_0, options, tT_p, pars_qhSL{:});
  S_p = qhSL_event(1,3); % -, survival prob at puberty
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
  
  stat.(fldf).(fldt).(fldg).tS = [0 1; t + aT_b, qhSL(:,3)];             % d,-, convert time since birth to age for survivor probability
  stat.(fldf).(fldt).(fldg).tSs = [0 1; t + aT_b, 1 - qhSL(:,4)/ EL0_i]; % d,-, convert time since birth to age for survivor function of the stable age distribution
  
  p_C = f * g/ (f + g) * E_m * (vT * EL2_a + kT_M * (EL3_a + L_T * EL2_a)); % J/d, mean mobilisation of adults
  p_R = max(0, (1 - kap) * p_C - kT_J * E_Hp); % J/d, mean allocation to reproduction of adults
  E_0 = p_Am * initial_scaled_reserve_foetus(f, [V_Hb, g, k_J, k_M, v]); % J, energy costs of an egg
  ER = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adult female
  stat.(fldf).(fldt).(fldg).ER = ER; 
  del_ea = ER * aT_b * exp(h_B0b * aT_b/ 2); % -, number of embryos per adult
  stat.(fldf).(fldt).(fldg).del_ea = del_ea; 
  stat.(fldf).(fldt).(fldg).theta_e = del_ea/ (del_ea + 1/ theta_an); % -, fraction of individuals that is embryo

  Ep_A = EL2 * pT_Am * f;
  stat.(fldf).(fldt).(fldg).Ep_A = Ep_A; 
  stat.(fldf).(fldt).(fldg).EJ_X = Ep_A/ kap_X/ mu_X * w_X/ d_X; 
  stat.(fldf).(fldt).(fldg).EJ_P = Ep_A/ kap_X * kap_P/ mu_P * w_P/ d_P;

  % pack output
  stat.(fldf).(fldt).(fldg).EL_n=EL; stat.(fldf).(fldt).(fldg).EL2_n=EL2; stat.(fldf).(fldt).(fldg).EL3_n=EL3; 
  stat.(fldf).(fldt).(fldg).EL_a=EL_a; stat.(fldf).(fldt).(fldg).EL2_a=EL2_a; stat.(fldf).(fldt).(fldg).EL3_a=EL3_a; 
  stat.(fldf).(fldt).(fldg).a_b = aT_b; stat.(fldf).(fldt).(fldg).t_p = tT_p;
end

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSL, t_p, varargin)
  value = [t - t_p; qhSL(3) - 1e-6];  % trigger 
  isterminal = [0 1];                 % terminate after last event
  direction  = [];                    % get all the zeros
end

function dqhSL = dget_qhSL(t, qhSL, t_p, sgr, f, L_b, L_m, r_B, v, g, s_G, h_a, h_Bbp, h_Bpi, thinning)
  % t: time since birth
  q   = max(0, qhSL(1)); % 1/d^2, aging acceleration
  h_A = max(0, qhSL(2)); % 1/d^2, hazard rate due to aging
  S   = max(0, qhSL(3)); % -, survival prob
  
  L_i = L_m * f;
  L = L_i - (L_i - L_b) * exp(- t * r_B);
  r = max(0, v * (f/ L - 1/ L_m)/ (f + g)); % 1/d, spec growth rate of structure
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
  dEL1_a = (t > t_p) * L * dEL0; % d/dt L*pdf(t) of adults
  dEL2_a = L * dEL1_a; % d/dt L^2*pdf(t) of adults
  dEL3_a = L * dEL2_a; % d/dt L^3*pdf(t) of adults
  
  dhV = h * dEL3; % cm^3/d, production of dead structure
  
  dqhSL = [dq; dh_A; dS; dEL0; dEL1; dEL2; dEL3; dEL1_a; dEL2_a; dEL3_a; dhV]; 
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