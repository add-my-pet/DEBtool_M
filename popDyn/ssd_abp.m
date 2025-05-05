%% ssd_abp
% Gets mean structural length^1,2,3 and wet weight at f and r

%%
function [stat, txtStat] = ssd_abp(stat, code, par, T_pop, f_pop, sgr)
  % created 2019/07/30 by Bas Kooijman, modified 2020/02/19
  
  %% Syntax
  % [stat, txtStat] = <../ssd_abp.m *ssd_abp*> (stat, code, par, T_pop, f_pop, sgr)
  
  %% Description
  % Mean L, L^2, L^3, Ww, given f and r, on the assumption that the population has the stable age distribution.
  % Use sgr_abp to obtain sgr. Background hazards are not standard in par as produced by AmP; add them before use.
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
  % Output: 
  %
  %   - a_b: d, age at birth
  %   - t_p: d, time since birth at puberty
  %   - L_bi: cm, mean structural length for post-natals
  %   - L2_bi: cm^2, mean squared structural length for post-natals
  %   - L3_bi: cm^3, mean cubed structural length for post-natals
  %   - L_pi: cm, mean structural length for adults
  %   - L2_pi: cm^2, mean squared structural length  for adults
  %   - L3_pi: cm^3, mean cubed structural length  for adults
  %   - Ww_bi: g, mean wet weight of post-natals (excluding contributions from reproduction buffer)
  %   - Ww_pi: g, mean wet weight of adults (excluding contributions from reproduction buffer)
  %   - S_b: -, survival probability at birth
  %   - S_p: -, survival probability at puberty
  %   - tS: (n,2)-array with age (d), surivival probability (-)
  %   - tSs: (n,2)-array with age (d), survivor function of the stable age distribution (-)
  %   - theta_0b: -, fraction of individuals that is embryo
  %   - theta_bp: -, fraction of individuals that is juvenile
  %   - theta_pi: -, fraction of individuals that is adult
  %   - Y_PX: mol/mol, yield of faeces on food
  %   - Y_VX: mol/mol, yield of living structure on food
  %   - Y_VX_d: mol/mol, yield of dead structure on food
  %   - Y_EX: mol/mol, yield of living reserve on food
  %   - Y_EX_d: mol/mol, yield of dead reserve on food
  %   - mu_xH: J/mol, yield of heat on food
  %   - Y_CX: mol/mol, yield of CO2 on food
  %   - Y_HX: mol/mol, yield of H2O on food
  %   - Y_OX: mol/mol, yield of O2 on food
  %   - Y_NX: mol/mol, yield of N-waste on food
  %   - R: #/d, mean reproduction rate of adult female
  %   - J_X: g/d, mean feeding rate of post-natals
  %
  % * txtStat: structure with units and labels

  %% Remarks
  % The background hazards, if specified in par, are assumed to correspond with T_typical, not with T_ref

  % get output fields
  fldf = 'f0fff1'; fldf = fldf([-1 0] + 2 * strfind('0f1',code(1))); % f0 or ff or f1
  fldt = 'thin0thin1'; fldt = fldt([-4 -3 -2 -1 0] + 5 * strfind('01',code(2))); % thin0 or thin1
  fldg = code(3); % f or m
  
  if ~isstruct(par) || isnan(sgr)
    stat = setNaN(stat, fldf, fldt, fldg); % set all statistics to NaN
    txtStat = NaN;
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
  if exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_H; T_AH];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  TC = tempcorr(T, T_ref, pars_T);   % -, Temperature Correction factor
  kT_M = k_M * TC; kT_J = k_J * TC; vT = v * TC; hT_a = h_a * TC^2; pT_Am = TC * p_Am;

  % supporting statistics
  v_Hj = v_Hp - 1e-3;
  [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j] = get_tj([g k l_T v_Hb v_Hj v_Hp], f);
  if isempty(tau_j)
    stat = setNaN(stat, fldf, fldt, fldg); % set all statistics to NaN
    txtStat = NaN;
    return
  end
  aT_b = tau_b/ kT_M;           % d, age at birth
  stat.(fldf).(fldt).(fldg).a_b = aT_b; txtStat.units.a_b  = 'd'; txtStat.label.a_b = 'age at birth';
  tT_p = (tau_p - tau_b)/ kT_M; % d, time since birth at puberty
  stat.(fldf).(fldt).(fldg).t_p = tT_p; txtStat.units.t_p  = 'd'; txtStat.label.t_p = 'time since birth at puberty';
  L_b = L_m * l_b; L_p = L_m * l_p; L_i = L_m * l_i; % cm, structural length at birth, ultimate
  rT_j = kT_M * rho_j;  % 1/d, expo  growth rate  

  % embryos
  [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0] = get_Sb([g; k; v_Hb; h_a/k_M^2; s_G; h_B0b/kT_M; sgr/kT_M], f);
  stat.(fldf).(fldt).(fldg).S_b = S_b; txtStat.units.S_b  = '-'; txtStat.label.S_b = 'survival probability at birth';
  E_0 = u_E0 * g * E_m * L_m^3;   % J, initial reserve
  t_0b = tau_0b/ kT_M; % d, \int_0^a_b exp(-sgr*t)*S(t) dt 

  % post-natals: work with time since birth to exclude contributions from embryo lengths to EL, EL2, EL3, EWw  
  options = odeset('Events',@dead_for_sure, 'NonNegative',ones(10,1), 'AbsTol',1e-9, 'RelTol',1e-9); 
  qhSL_0 = [q_b * kT_M^2; h_Ab * kT_M; S_b; 0; 0; 0; 0; 0; 0; 0]; % initial states
  pars_qhSL = {aT_b, tT_p, sgr, f, vT, L_b, L_p, L_m, rT_j, s_G, hT_a, h_Bbp, h_Bpi, thinning};
  [t, qhSL, t_event, qhSL_event] = ode45(@dget_qhSL, [0; 1e8], qhSL_0, options, pars_qhSL{:});
  t_bi = qhSL(end,4);   % d, \int_{a_b}^\infty S(t)*exp(-sgr*t) dt

  S_p = qhSL_event(1,3);  % -, survival prob at puberty
  stat.(fldf).(fldt).(fldg).S_p = S_p; txtStat.units.S_p  = '-'; txtStat.label.S_p = 'survival probability at puberty';
  
  % survival probability (at individual level)
  stat.(fldf).(fldt).(fldg).tS = [0 1; t + aT_b, min(1, qhSL(:,3))];     % d,-, convert time since birth to age for survivor probability
  % survivor of stable age distr: \frac{\int_{a}^\infty S(t)*exp(-sgr*t) dt} {\int_{a_b}^\infty S(t)*exp(-sgr*t) dt}
  stat.(fldf).(fldt).(fldg).tSs = [0 1; t + aT_b, 1 - qhSL(:,4)/ t_bi]; % d,-, convert time since birth to age for survivor function of the stable age distribution

  theta_0b = t_0b/ (t_0b + t_bi);               % -, fraction of individuals that is embryo
  stat.(fldf).(fldt).(fldg).theta_0b = theta_0b; txtStat.units.theta_0b = '-'; txtStat.label.theta_0b = 'frac of ind that is embryo';
  theta_bp = qhSL_event(1,4)/ (t_0b + t_bi);    % -, fraction of individuals that is juvenile
  stat.(fldf).(fldt).(fldg).theta_bp = theta_bp; txtStat.units.theta_bp = '-'; txtStat.label.theta_bp = 'frac of ind that is juvenile';
  theta_pi = 1 - theta_0b - theta_bp;           % -, fraction of individuals that is adult
  stat.(fldf).(fldt).(fldg).theta_pi = theta_pi; txtStat.units.theta_pi = '-'; txtStat.label.theta_pi = 'frac of ind that is adult';
  del_an = theta_pi/ (theta_bp + theta_pi); % fraction of post-natals that is adult
  
  % mean L^i for post-natals: \frac{\int_{a_b}^\infty L^i*S(t)*exp(-sgr*t) dt} {\int_{a_b}^\infty S(t)*exp(-sgr*t) dt}
  L_bi = qhSL(end,5)/ t_bi; L2_bi = qhSL(end,6)/ t_bi; L3_bi = qhSL(end,7)/ t_bi; % mean L^1,2,3 for post-natals
  stat.(fldf).(fldt).(fldg).L_bi  = L_bi; txtStat.units.L_bi = 'cm'; txtStat.label.L_bi  = 'mean structural length of post-natals';
  stat.(fldf).(fldt).(fldg).L2_bi = L2_bi; txtStat.units.L2_bi = 'cm^2'; txtStat.label.L2_bi = 'mean squared structural length of post-natals';
  stat.(fldf).(fldt).(fldg).L3_bi = L3_bi; txtStat.units.L3_bi = 'cm^3'; txtStat.label.L3_bi = 'mean cubed structural length of post-natals';
  stat.(fldf).(fldt).(fldg).Ww_bi = L3_bi * (1 + f * ome); txtStat.units.Ww_bi  = 'g'; txtStat.label.Ww_bi  = 'mean wet weight of post-natals';
  %
  sL2_bi = qhSL(end,10)/ t_bi; % cm^2, \frac{\int_{a_b}^\infty s_M(t) L^2*S(t)*exp(-sgr*t) dt} {\int_{a_b}^\infty S(t)*exp(-sgr*t) dt}
  rL3_bi = qhSL(end,8)/ t_bi; % cm^3/d, \frac{\int_{a_b}^\infty r(t) L^3*S(t)*exp(-sgr*t) dt} {\int_{a_b}^\infty S(t)*exp(-sgr*t) dt}
  hL3_bi = qhSL(end,9)/ t_bi; % cm^3/d, \frac{\int_{a_b}^\infty h(t) L^3*S(t)*exp(-sgr*t) dt} {\int_{a_b}^\infty S(t)*exp(-sgr*t) dt}

  % mean L^i for adults: \frac{\int_{a_p}^\infty L^i*S(t)*exp(-sgr*t) dt} {\int_{a_p}^\infty S(t)*exp(-sgr*t) dt}
  t_pi = t_bi - qhSL_event(1,4); % d, \int_{a_p}^\infty S(t)*exp(-sgr*t) dt
  L_pi = (qhSL(end,5)-qhSL_event(1,5))/ t_pi; L2_pi = (qhSL(end,6)-qhSL_event(1,6))/ t_pi; L3_pi = (qhSL(end,7)-qhSL_event(1,7))/ t_pi; % mean L^1,2,3 for adults
  stat.(fldf).(fldt).(fldg).L_pi = L_pi;   txtStat.units.L_pi = 'cm';    txtStat.label.L_pi  = 'mean structural length of adults';
  stat.(fldf).(fldt).(fldg).L2_pi = L2_pi; txtStat.units.L2_pi = 'cm^2'; txtStat.label.L2_pi = 'mean squared structural length of adults';
  stat.(fldf).(fldt).(fldg).L3_pi = L3_pi; txtStat.units.L3_pi = 'cm^3'; txtStat.label.L3_pi = 'mean cubed structural length of adults';
  stat.(fldf).(fldt).(fldg).Ww_pi = L3_pi * (1 + f * ome); txtStat.units.Ww_pi  = 'g'; txtStat.label.Ww_pi  = 'mean wet weight of adults';
  sL2_pi = (qhSL(end,10)-qhSL_event(1,10))/ t_pi; % cm^2, \frac{\int_{a_p}^\infty s_M(t) L^2*S(t)*exp(-sgr*t) dt} {\int_{a_p}^\infty S(t)*exp(-sgr*t) dt}
    
  % food intake and reprod rate
  p_C = f * g/ (f + g) * E_m * (vT * sL2_pi + kT_M * (L3_pi + L_T * L2_pi)); % J/d, mean mobilisation of adults
  p_R = max(0, (1 - kap) * p_C - kT_J * E_Hp); % J/d, mean allocation to reproduction of adults
  R = kap_R * p_R/ E_0; % 1/d, mean reproduction rate of adult female
  stat.(fldf).(fldt).(fldg).R = R; txtStat.units.R = '1/d';  txtStat.label.R = 'mean reproduction rate of adults';
  p_A = f * pT_Am * sL2_bi; % J/d, mean assimilation of post-natals
  p_X = p_A/ kap_X;  J_X = p_X/ mu_X;    % J/d, mol/d, mean food intake of post-natals
  stat.(fldf).(fldt).(fldg).J_X = J_X * w_X/ d_X;  txtStat.units.J_X   = 'g/d';  txtStat.label.J_X = 'mean ingestion rate of wet food by post-natals';
  
  % yield coefficients
  p_P = p_X * kap_P; J_P = p_P/ mu_P;              % J/d, mol/d, mean faeces prod of post-natals
  Y_PX = J_P/ J_X;                                 % mol/mol, yield of faeces on food
  stat.(fldf).(fldt).(fldg).Y_PX = Y_PX; txtStat.units.Y_PX  = 'mol/mol'; txtStat.label.Y_PX  = 'yield of faeces on food';
  %
  %Y_VX = M_V * (del_an * S_b * R * L_b^3 + rL3_bi)/ J_X;           % mol/mol, yield of living structure on food
  Y_VX = sgr * M_V * L3_bi/ J_X;           % mol/mol, yield of living structure on food
  stat.(fldf).(fldt).(fldg).Y_VX = Y_VX; txtStat.units.Y_VX  = 'mol/mol'; txtStat.label.Y_VX  = 'yield of living structure on food';
  %Y_VX_dead = M_V * (del_an * (1 - S_b) * R * L_b^3 + hL3_bi)/ J_X;% mol/mol, yield of dead structure on food
  Y_VX_dead = hL3_bi * M_V/ J_X;% mol/mol, yield of dead structure on food
  stat.(fldf).(fldt).(fldg).Y_VX_d = Y_VX_dead; txtStat.units.Y_VX_d  = 'mol/mol'; txtStat.label.Y_VX_d  = 'yield of dead structure on food';
  %
  %Y_EX = f * E_m/ mu_E * (del_an * S_b * R * L_b^3 + rL3_bi)/ J_X; % mol/mol, yield of living reserve on food
  Y_EX = sgr * L3_bi * f * E_m/ mu_E/ J_X; % mol/mol, yield of living reserve on food
  stat.(fldf).(fldt).(fldg).Y_EX = Y_EX; txtStat.units.Y_EX  = 'mol/mol'; txtStat.label.Y_EX  = 'yield of living reserve on food';
  %Y_EX_dead = f * E_m/ mu_E * (del_an * (1 - S_b) * R * L_b^3 + hL3_bi)/ J_X; % mol/mol, yield of dead reserve on food
  Y_EX_dead = hL3_bi * f * E_m/ mu_E/ J_X; % mol/mol, yield of living reserve on food
  stat.(fldf).(fldt).(fldg).Y_EX_d = Y_EX_dead; txtStat.units.Y_EX_d  = 'mol/mol'; txtStat.label.Y_EX_d  = 'yield of dead reserve on food';
  % 
  n_O = nO_d2w(n_O, [d_X, d_V, d_E, d_P]); % -, chemical indices for organics (in cols)  X V V_dead E E_dead P
  Y_M = -(n_M\n_O) * [-1; Y_VX+Y_VX_dead; Y_EX+Y_EX_dead; Y_PX]; % mol/mol, yields for minerals on food
  Y_CX = Y_M(1); Y_HX = Y_M(2); Y_OX = Y_M(3); Y_NX = Y_M(4);
  %
  stat.(fldf).(fldt).(fldg).Y_CX = Y_CX; txtStat.units.Y_CX  = 'mol/mol'; txtStat.label.Y_CX  = 'yield of CO2 on food';
  stat.(fldf).(fldt).(fldg).Y_HX = Y_HX; txtStat.units.Y_HX  = 'mol/mol'; txtStat.label.Y_HX  = 'yield of H2O on food';
  stat.(fldf).(fldt).(fldg).Y_OX = Y_OX; txtStat.units.Y_OX  = 'mol/mol'; txtStat.label.Y_OX  = 'yield of O2 on food';
  stat.(fldf).(fldt).(fldg).Y_NX = Y_NX; txtStat.units.Y_NX  = 'mol/mol'; txtStat.label.Y_NX  = 'yield of N-waste on food';
  %
  mu_TX = mu_X - (Y_VX + Y_VX_dead) * mu_V - (Y_EX + Y_EX_dead) * mu_E - Y_PX * mu_P - Y_NX * mu_N; % J/mol, yield of heat on food
  stat.(fldf).(fldt).(fldg).mu_TX = mu_TX; txtStat.units.mu_TX  = 'J/mol';  txtStat.label.mu_TX  = 'yield of heat on food';

end

% event p_dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSL, t_p, varargin)
  value = [t - t_p; qhSL(3) - 1e-6];  % trigger 
  isterminal = [0 1];                 % terminate after last event
  direction  = [];                    % get all the zeros
end

function dqhSL = dget_qhSL(t, qhSL, a_b, t_p, sgr, f, v, L_b, L_p, L_m, r_j, s_G, h_a, h_Bbp, h_Bpi, thinning)
  q   = qhSL(1); % 1/d^2, aging acceleration
  h_A = qhSL(2); % 1/d, hazard rate due to aging
  S   = qhSL(3); % -, survival prob
  
  if t < t_p
    h_B = h_Bbp;
    L = L_b * exp(t * r_j/ 3);
    s_M = L/ L_b;
    r = r_j;
    h_X = thinning * r; % 1/d, hazard due to thinning
  else
    h_B = h_Bpi;
    L = L_p;
    s_M = L_p/ L_b;
    r = 0; % 1/d, spec growth rate of structure
    h_X = thinning * r * 2/3; % 1/d, hazard due to thinning
  end

  dq = (q * s_G * L^3/ L_m^3 + h_a) * f * (v * s_M/ L - r) - r * q;
  dh_A = q - r * h_A; % 1/d^2, change in hazard due to aging

  h = h_A + h_B + h_X; 
  dS = - h * S; % 1/d, change in survival prob
      
  dEL0 = exp(- sgr * (t + a_b)) * S; 
  % so dEL0(t)/EL0(infty) equals pdf of times since birth
  % division by EL0(infty) is done after integration
  dEL1 = L * dEL0; % d/dt L*pdf(t)
  dEL2 = L * dEL1; % d/dt L^2*pdf(t)
  dEL3 = L * dEL2; % d/dt L^3*pdf(t)
  
  dEL3_live = r * dEL3; % cm^3/d, production of living structure
  dEL3_dead = h * dEL3; % cm^3/d, production of dead structure
  dEsL2 = s_M * dEL2;   % % d/dt s_M*L^2*pdf(t)
  
  dqhSL = [dq; dh_A; dS; dEL0; dEL1; dEL2; dEL3; dEL3_live; dEL3_dead; dEsL2]; 
end

% fill fields with nan
function stat = setNaN(stat, fldf, fldt, fldg)
    stat.(fldf).(fldt).(fldg).L_bi = NaN;     stat.(fldf).(fldt).(fldg).L2_bi = NaN;  stat.(fldf).(fldt).(fldg).L3_bi = NaN;   
    stat.(fldf).(fldt).(fldg).L_pi = NaN;     stat.(fldf).(fldt).(fldg).L2_pi = NaN;  stat.(fldf).(fldt).(fldg).L3_pi = NaN;   
    stat.(fldf).(fldt).(fldg).Ww_bi = NaN;    stat.(fldf).(fldt).(fldg).Ww_pi = NaN;  
    stat.(fldf).(fldt).(fldg).S_b = NaN;      stat.(fldf).(fldt).(fldg).S_p = NaN; 
    stat.(fldf).(fldt).(fldg).a_b = NaN;      stat.(fldf).(fldt).(fldg).t_p = NaN;   
    stat.(fldf).(fldt).(fldg).tS = [NaN NaN]; stat.(fldf).(fldt).(fldg).tSs = [NaN NaN];
    stat.(fldf).(fldt).(fldg).R = NaN;        stat.(fldf).(fldt).(fldg).J_X = NaN; 
    stat.(fldf).(fldt).(fldg).theta_0b = NaN; stat.(fldf).(fldt).(fldg).theta_bp = NaN; stat.(fldf).(fldt).(fldg).theta_pi = NaN;   
    stat.(fldf).(fldt).(fldg).Y_VX = NaN;     stat.(fldf).(fldt).(fldg).Y_VX_d = NaN;   
    stat.(fldf).(fldt).(fldg).Y_EX = NaN;     stat.(fldf).(fldt).(fldg).Y_EX_d = NaN;   
    stat.(fldf).(fldt).(fldg).Y_PX = NaN;     stat.(fldf).(fldt).(fldg).Y_CX = NaN;   
    stat.(fldf).(fldt).(fldg).Y_HX = NaN;     stat.(fldf).(fldt).(fldg).Y_OX = NaN;   
    stat.(fldf).(fldt).(fldg).Y_NX = NaN;     stat.(fldf).(fldt).(fldg).mu_TX = NaN;   
end