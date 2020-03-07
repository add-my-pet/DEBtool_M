%% get_cpm
% get cohort trajectories

%%
function [tXN, tXW] = get_cpm(model, par, tT, tx, x_0, n_R, t_R)
% created 2020/03/03 by Bob Kooi & Bas Kooijman
  
%% Syntax
% [tXN, tXW] = <../get_cpm.m *get_cpm*> (model, par, tT, tx, x_0, n_R, t_R)
  
%% Description
% integrates cohorts with synchronized reproduction events, called by cpm, 
%
% variables to be integrated, packed in Xvars:
%  X: mol/vol or mol/surface, food density
%    for each cohort:
%  q: 1/d^2, aging acceleration
%  h_a: 1/d, hazard for aging
%  L: cm, struc length
%  L_max: cm, struc length before start shrinking
%  E: J/cm^3, reserve density
%  E_R: J, reprod buffer
%  E_H: J, maturity
%  N: #, number of individuals in cohort
%
% number of current cohorts n_c = (length(Xvars) - 1)/8
% n_c increases for 1 till some max value, determined by number of oldest cohort < 1e-4, which depends on ageing and other hazards  
%
% Input:
%
% * model: character-string with name of model
% * par: structure with parameter values
% * tT: (nT,2)-array with time and temperature in Kelvin; time scaled between 0 (= start) and 1 (= end of cycle)
% * tx: (nX,2)-array with time and food density in supply as fraction of half saturation constant K; time scaled between 0 (= start) and 1 (= end of cycle)
% * x_0: scalar with scaled initial food density 
% * n_R: scalar with number of reproduction events to be simulated
% * t_R: scalar with time period between reproduction events 
%
% Output:
%
% * tXN: (n,m)-array with times, food density and number of individuals in the various cohorts
% * tXW: (n,m)-array with times, food density and total wet weights of the various cohorts

  options = odeset('Events',@birth, 'AbsTol',1e-9, 'RelTol',1e-9);
  
  % unpack par and compute compound pars
  vars_pull(par); vars_pull(parscomp_st(par));  
  
  % initial reserve at f = 1
  switch model
    case {'stf','stx'}
      E_0 = p_Am * initial_scaled_reserve_foetus(1, [V_Hb, g, k_J, k_M, v]);
    otherwise
      E_0 = p_Am * initial_scaled_reserve(1, [V_Hb, g, k_J, k_M, v]);
  end

  % temperature correction
  pars_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    pars_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  % % unscale knots for temperature, and convert to temp correction coeff
  tTC = [tT(:,1) * t_R, tempcorr(tT(:,2), T_ref, pars_T)]; % uTemperature Correction factor
  % unscale knots for food density in supply flux
  tX = [tx(:,1) * t_R, tx(:,2) * K]; % unscale tx
  
  % initial states with n_c = 1;
  X_0 = x_0 * K; % unscale initial food density
  dt = 1e-6; % d, time increment to avoid [E](0) = infty
  dL = dt * v/ 3;
  dE = E_0/ dL^3;
  Xvars_0 = [X_0 0 1 dL dL dE 0 0 1]; % X q h S L L_max [E] E_R E_H N
  tXN = [0 X_0 1]; tXW = [0 X_0 E_0/ mu_E * w_E/ d_E];% initialise output
  
  for i = 1:n_R
    feval(['[t, Xvars] = ode45(@dcpm_', model , ', [0 t_R], Xvars_0, options, par, tTC, tX);']);
%     switch model
%       case 'std'
%         [t, Xvars] = ode45(@dcpm_std, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'stf'
%         [t, Xvars] = ode45(@dcpm_stf, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'stx'
%         [t, Xvars] = ode45(@dcpm_stx, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'ssj'
%         [t, Xvars] = ode45(@dcpm_ssj, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'sbp'
%         [t, Xvars] = ode45(@dcpm_sbp, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'abj'
%         [t, Xvars] = ode45(@dcpm_abj, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'asj'
%         [t, Xvars] = ode45(@dcpm_asj, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'abp'
%         [t, Xvars] = ode45(@dcpm_abp, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'hep'
%         [t, Xvars] = ode45(@dcpm_hep, [0 t_R], Xvars_0, options, par, tTC, tX);
%       case 'hex'
%         [t, Xvars] = ode45(@dcpm_hex, [0 t_R], Xvars_0, options, par, tTC, tX);
%     end
    [t, Xvars_0, tXN, tXW] = cohorts(t, Xvars, tXN, tXW, E_0, dL, dE, mu_E, w_E, d_E); % catenate output and possibly insert new cohort
  end
end

function [X, q, h_a, L, L_max, E, E_R, E_H, N] = unpack_Xvars(Xvars)
  n_c = (length(Xvars) - 1)/ 8; % #, current number of cohorts

  coh = 1:n_c; % cohorts 1 till n_c
  X = max(0,Xvars(1)); 
  q = max(0,Xvars(1+coh));       h_a = max(0,Xvars(1+n_c+coh));   L = max(0,Xvars(1+2*n_c+coh));   L_max = max(0,Xvars(1+3*n_c+coh)); 
  E = max(0,Xvars(1+4*n_c+coh)); E_R = max(0,Xvars(1+5*n_c+coh)); E_H = max(0,Xvars(1+6*n_c+coh)); N = max(0,Xvars(1+7*n_c+coh));
end

function [t, Xvars_0, tXN, tXW] = cohorts(t, Xvars, tXN, tXW, E_0, dL, dE, mu_E, w_E, d_E)
  t = t(end); Xvars_t = Xvars(end,:); % last value of t, Xvars
  [X, q, h_a, L, L_max, E, E_R, E_H, N] = unpack_Xvars(Xvars_t);

  % reproduction event
  dN = sum(N .* floor(E_R/ E_0)); % #, number of new eggs
  E_R = mod(E_R, E_0); % reduce reprod buffer to fractions of eggs
  
  % build new initial state vectors and append to output
  q = [0, q]; h_a = [0, h_a]; L = [dL, L]; L_max = [dL, L_max]; E = [dE, E]; E_R = [0, E_R]; E_H = [0, E_H]; N = [dN, N]; 
  W = N .* L.^3 .* (1 + E/ mu_E * w_E/ d_E) + E_R/ mu_E * w_E/ d_E; % g, wet weights
  if N(end) < 1e-4 % add new youngest cohort
    Xvars_0 = [X, q, h_a, L, L_max, E, E_R, E_H, N]; % pack state vars
    tXN = [[tXN, zeros(size(tXN,1),1)]; [t, X, N]]; % append to output
    tXW = [[tXW, zeros(size(tXW,1),1)]; [t, X, W]]; % append to output
  else % add new youngest cohort and remove oldest
    q(end)=[]; h_a(end)=[]; L(end)=[]; L_max(end)=[]; E(end)=[]; E_R(end)=[]; E_H(end)=[]; N(end)=[];
    Xvars_0 = [X, q, h_a, L, L_max, E, E_R, E_H, N]; % pack state vars
    tXN = [tXN; [t, X, N]]; % append to output
    tXW = [tXW; [t, X, W]]; % append to output
  end
  t = t + t_R;
end

function [value,isterminal,direction] = birth(t, Xvars, par, tT, tx)
  n_c = (length(Xvars) - 1)/ 8; % #, number of cohorts
  E_H0 = Xvars(1 + 7 * n_c); % J, maturity of youngest cohort, assuming a_b < t_R
  value = E_H0 - par.E_Hb;  % trigger 
  isterminal = 0; % terminate after the first event
  direction  = []; % get all the zeros
end

function dXvars = dcpm_std(t, Xvars, par, tT, tX)
  vars_pull(par);  % unpack pars
  K = J_X_Am/ F_m; % c-mol X/l, half-saturation coefficient
  k_M = p_M/ E_G;  % 1/d, maintenance rate coefficient
  [X, q, h_a, S, L, L_max, E, E_R, E_H, N] = unpack_Xvars(Xvars); e = E./ E_m; L2 = L .* L; L3 = L .* L2; 
  
  X_I = spline1(t, tX); % food density in supply flux
  TC = spline1(t, tTC); % temperature
  
  % temp correction
  kT_M = k_M * TC; kT_J = k_J * TC; kT_JX = k_JX * TC; vT = v * TC; hT_a = h_a * TC^2; 
  hT_I = h_I * TC; hT_D = h_D * TC; 
  
  f = X/ (X + K); % -, scaled func response
  dX = hT_I * X_I - hT_D * X - JT_Xm * f * sum(N .* L.^2); % food dynamics

  % aging
  dq = (q * s_G * L.^3/ L_m^3 + hT_a) * e .* (vT ./ L - r) - r .* q;
  dh_A = q - r * h_A; % 1/d, aging hazard
    
  pT_A = (E_H >= E_Hb) .* pT_Am * f .* L2;
  dE = pT_A ./ L3 - vT * E ./ L; % J/d.cm^3, change in reserve density
  if L > e * L_m % shrinking
    r = vT * (e./ L - 1/ L_m)/ (e + kap_G * g); % 1/d, spec growth rate of structure
  else % not shrinking
    r = vT * (e./ L - 1/ L_m)/ (e + g); % 1/d, spec growth rate of structure
  end
  dL = r * L/3; % cm/d, growth rate of structure
  dL_max = max(0, dL);
  
  p_J = kT_J * E_H; % J/d, maturity maintenance
  p_R = (1 - kap) * (p_A - L3 .* (dE + E .* r)) - p_J; % J/d, flux to maturation/ reprod
  if p_R < 0 && E < E_Hp
    dE_H = p_J + p_R - kT_JX * E_H;
    dE_R = 0;
  elseif p_R < 0 && E_R >= 0
    dE_H = 0;
    dE_R = p_R;
    dL = 0; dL_max = 0; % overwrite dL and dL_max
  elseif p_R < 0 && E_R == 0
    dE_H = p_J + p_R - kT_JX * E_H;
    dE_R = 0;
  elseif E < E_Hp % p_R > 0
    dE_H = p_R;
    dE_R = 0;
  else % p_R > 0
    dE_H = 0;
    dE_R = p_R;
  end
  
  % stage-specific background hazards
  if E_H < E_Hb
    h_B = h_B0b;
  elseif E_H < E_Hp
    h_B = h_Bbp;
  else
    h_B = h_Bpi;
  end
  h_X = thin * r * 2/3; % thinning hazard
  % using hazard of 1 per day in case shrinking exceeds max fraction of del_X
  h = h_A + h_B + h_X + hT_J * max(0, - p_R ./ p_J) + (L ./ L_max < del_X); 
  dN = - h .* N;

  dXvars = [dX; dq; dh_A; dS; dL; dL_max; dE; dE_R; dE_H; dN]; % pack output
end

