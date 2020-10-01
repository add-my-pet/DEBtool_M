%% Demonstrates the use of get_EVH_AF
% for pregnant females with upregulation, one litter

% created by Dina Lika 2019/06/11
%% set parameters

  del_upreg = 22.28; K_del = 8; % need for S_eff determination
  p_Am = 7.2e3;      % J/d.cm^2, max surface-spec assimilation flux
  p_FAm = 3.4e4;     % J/d.cm^2, foetal-specific assimilation parameter
  v = 0.02;          % cm/d, energy conductance
  v_F = 0.04;        % cm/d, foetal energy conductance
  kap = 0.96;        % -, allocation fraction to soma
  kap_R = 0.95;      % -, reproduction efficiency of the mother, and repro reserve assimilation efficiency of the foetus
  kap_RL = 0.95;     % -, milk production efficiency of the mother, and milk assimilation efficiency of the foetus
  p_M = 3663;        % J/d.cm^3, vol-spec somatic maint
  k_J = 0.002;       % 1/d, maturity maint rate coefficient
  E_G = 7831;        % J/cm^3, spec cost for structure
  E_Hb = 754.3;      % J, maturity at birth
  E_Hx = 1e4;        % J, maturity at weaning
  E_Hp = 4e4;        % J, maturity at puberty
  E_m = p_Am/v;      % J/cm^3, reserve capacity 
  t_0 = 12.7;        % d, time at start development (since mating) 
  Npups = 10;        % -, number of foetuses
  f = 1;             % -, scaled functional response
  
  T_ref = 293.15;    % K, Reference temperature
  T_A = 8000;        % K, Arrhenius temperature 
  T = C2K(37);       % K, body temp
  
  w_E = 23.9;        % g/mol, mol-weights for (unhydrated) reserves
  d_V = 0.3;         % g/cm^3, specific density of structure
  mu_E = 550000;     % J/ mol, chemical potential of structure 
  w_X = 23.9;        % g/mol, mol-weights for (unhydrated) food
  d_X = 0.37;        % g/cm^3, specific density of food
  mu_X = 523080;     % J/ mol, chemical potential of structure 
  p_Xm = p_Am/0.8;   % J/d.cm^2, max spec feeding power
  
%%
  % compose vector of compound parameters
  pars_tx = [0.016 0.003 0 0.0432 2.185 6.298]; % q = [g k l_T v_Hb v_Hx v_Hp]
  [tau_p, tau_x, tau_b, l_p, l_x, l_b] = get_tx(pars_tx, f);
  
  % effective placenta surface area coefficient
  S_eff = del_upreg./(K_del + Npups);  % decreases with Npups
  % S_eff = del_upreg;                 % independent of Npups 

  % compute temperature correction factors
  TC = tempcorr(T, T_ref, T_A);
 
  % temp-correct pars 
  pT_Am = p_Am * TC;  pT_FAm = TC * p_FAm; 
  vT = v * TC; vT_F = TC * v_F;
  pT_M = p_M * TC; kT_J = k_J * TC; 
  
  % puberty 
  L_m = kap * p_Am/p_M;        % cm, maximum lenght
  L_p = L_m * l_p;             % cm, structural length at puberty at f
  k_M = p_M/E_G;               % 1/d; somatic maintenance rate coefficient
  aT_p = tau_p / k_M / TC;     % d, age at puberty at f and T
  
  t_mate = aT_p;               % d, age at mating; assume that mating happens at puberty

  a = linspace(aT_p, aT_p + 50, 100); % d, vector with ages starting at puberty
   
  % compose vector of parameters
  p = [pT_Am, pT_FAm, vT, vT_F, kap, kap_R, kap_RL, pT_M, kT_J, E_G, E_Hb, E_Hx, E_Hp, E_m, t_0, S_eff, Npups, f, t_mate]; % temp-correct and pack pars for dget_EVR_AF
 
  EVH_AF_0 = [E_m * L_p^3, L_p^3, 0, 0, 1e-8, 0]; % initial conditions, assume max reserve density at puberty
  prd = get_EVH_AF(a, EVH_AF_0, p);               % integration stops at weaning

  % output gestation and weaning periods
  txt = [{'gestation time, d:'}; {'time since birth at weaning, d:'}];
  data = [prd.a_g; prd.t_x];
  print_txt_var(txt, data);
  
  % predictions for 
  EWw_mother = prd.EVH_AF(:,2) + (prd.EVH_AF(:,1)+ prd.EVH_AF(:,3))* w_E/d_V/mu_E;  % g, expected wet weight-at-age of the mother without foetuses
  EWw_foetpup = prd.EVH_AF(:,5) + prd.EVH_AF(:,4)* w_E/d_V/mu_E;         % g, foetus, wet weight at time expected 
  EWw = EWw_mother + (prd.a < prd.a(1) + prd.a_g).* EWw_foetpup * Npups; % g, wet weight of mother plus foetuses
% 
  index = find(prd.a >= t_mate & prd.a < t_mate + prd.a_g + prd.t_x); % indices for gestation & lactation period
  t_aux = prd.a(index); t_f = t_aux - t_aux(1); % extract time and start at 0
  Ww_foetpup = EWw_foetpup(index);         % g, wet weight of foetus
  Lw_foetpup = prd.EVH_AF(index,5).^(1/3); % g, structural length of foetus
% 
  upreg_period = (prd.a > t_mate & prd.a < t_mate + prd.a_g + prd.t_x); % find period of upregulation
  L2_mother = prd.EVH_AF(:,2).^(2/3);  L2_foetus = prd.EVH_AF(:,5).^(2/3); 
  EJX = (p_Xm * w_X/ mu_X/ d_X) * f * (L2_mother + upreg_period * Npups * S_eff .* L2_foetus) ; % g/d, wet weight of food

% plots
  subplot(2,2,1)
  plot(prd.a, EWw)
  set(gca, 'FontSize', 12, 'Box', 'on')
  xlabel('age, d')  
  ylabel('mother''s wet weight, g')

  subplot(2,2,2)
  plot(prd.a, EJX)
  set(gca, 'FontSize', 12, 'Box', 'on')
  xlabel('age, d')  
  ylabel('mother''s feeding rate, g/d')

  subplot(2,2,3)
  plot(t_f, Ww_foetpup)
  set(gca, 'FontSize', 12, 'Box', 'on')
  xlabel('age, d')  
  ylabel('foetus/pup wet weight, g')

  subplot(2,2,4)
  plot(t_f, Lw_foetpup)
  set(gca, 'FontSize', 12, 'Box', 'on')
  xlabel('age, d')  
  ylabel('foetus/pup structural length, cm')
  
  