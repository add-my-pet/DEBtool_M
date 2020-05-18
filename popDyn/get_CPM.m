%% get_CPM
% get cohort trajectories

%%
function [txN, txL, txL2, txL3, txW, M_N, M_L, M_L2, M_L3, M_W, info] = get_CPM(model, par, tT, tJX, x_0, V_X, n_R, t_R)
% created 2020/03/03 by Bob Kooi & Bas Kooijman, modified 2020/05/05
  
%% Syntax
% [txN, txL, txL2, txL3, txW, M_N, M_L, M_L2, M_L3, M_W, info] = <../get_CPM.m *get_CPM*> (model, par, tT, tJX, x_0, V_X, n_R, t_R)
  
%% Description
% integrates cohorts with synchronized reproduction events, called by CPM, 
%
% variables to be integrated, packed in xvars:
%  X/K: scaled food density
%    for each cohort:
%  q: 1/d^2, aging acceleration
%  h_a: 1/d, hazard for aging
%  L: cm, struc length
%  E: J/cm^3, reserve density [E]
%  E_R: J, reprod buffer
%  E_H: J, maturity
%  N: #, number of individuals in cohort
%
% number of current cohorts n_c = (length(xvars) - 1)/8
% n_c increases for 1 till some max value, determined by number of oldest cohort < 1e-4, which depends on ageing and other hazards  
%
% Input:
%
% * model: character-string with name of model
% * par: structure with parameter values
% * tT: (nT,2)-array with time and temperature in Kelvin; time scaled between 0 (= start) and 1 (= end of cycle)
% * tJX: (nX,2)-array with time and food supply; time scaled between 0 (= start) and 1 (= end of cycle)
% * x_0: scalar with scaled initial food density 
% * V_X: scalar with volume of reactor
% * n_R: scalar with number of reproduction events to be simulated
% * t_R: scalar with time period between reproduction events 
%
% Output:
%
% * txN: (n,m)-array with times, scaled food density and number of individuals in the various cohorts
% * txL: (n,m)-array with times, scaled food density and structural length of the various cohorts
% * txL2: (n,m)-array with times, scaled food density and structural surface area of the various cohorts
% * txL3: (n,m)-array with times, scaled food density and structural volume of the various cohorts
% * txW: (n,m)-array with times, scaled food density and total wet weights of the various cohorts
% * M_N: (n_c,n_c)-array with map for N: N(t+t_R) = M_N * N(t), where N(t) is the vector of numbers of individuals in the cohorts at t
% * M_L: (n_c,n_c)-array with map for L: L(t+t_R) = M_L * L(t), where L(t) is the vector of total structural lengths in the cohorts at t
% * M_L2: (n_c,n_c)-array with map for L: L^2(t+t_R) = M_L2 * L^2(t), where L^2(t) is the vector of total structural surface areas in the cohorts at t
% * M_L2: (n_c,n_c)-array with map for V: L^3(t+t_R) = M_L3 * L^3(t), where L^3(t) is the vector of total structural volumes in the cohorts at t
% * M_W: (n_c,n_c)-array with map for W: W(t+t_R) = M_W * W(t), where W(t) is the vector of total wet weights in the cohorts at t
% * info: boolean with failure (0) or success (1)

%% Remarks
% The last 5 outputs (the maps for N, L, L^2, L^3 and W) are only not-empty if the number of cohorts did not change long enough.

  options = odeset('Events',@puberty, 'AbsTol',1e-8, 'RelTol',1e-8);
  info = 1;
  
  % unpack par and compute compound pars
  vars_pull(par); vars_pull(parscomp_st(par));  
  
  % temperature correction
  par_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    par_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    par_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  % unscale knots for temperature, and convert to temp correction factors
  if length(tT) == 1
     TC = tempcorr(tT, T_ref, par_T); tTC = TC; % Temperature Correction factor
  else
     tTC = [tT(:,1) * t_R, tempcorr(tT(:,2), T_ref, par_T)]; TC = tTC(1,2); % Temperature Correction factor
  end
  % unscale knots for food density in supply flux
  if length(tJX) > 1
    tJX(:,1) = tJX(:,1) * t_R; % unscale tJX
  end
  
  % initial reserve and states at birth appended to par
  switch model
    case {'stf','stx'}        
      [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b] = get_Sb_foetus([g k v_Hb h_a s_G h_B0b 0]); 
    otherwise
      [S_b, q_b, h_Ab, tau_b, tau_0b, u_E0, l_b] = get_Sb([g k v_Hb h_a s_G h_B0b 0]);
  end
  E_0 = g * E_m * L_m^3 * u_E0; % J, initial reserve
  if length(tTC)==1
    kT_M = k_M * TC; aT_b = tau_b/ kT_M; % d, age at birth (temp corrected)
  else
    kT_M = k_M * TC; aT_b = tau_b/ kT_M; % d, age at birth (temp corrected)
  end
  L_b = l_b * L_m; % cn, length at birth
  
  switch model
    case 'abj'
      [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj([g k l_T v_Hb v_Hj v_Hp]); % -, scaled ages and lengths
      L_j = l_j * L_m;
    case 'asj'
      [tau_s, tau_j, tau_p, tau_b, l_s, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_ts([g, k, 0, v_Hb, v_Hs, v_Hj, v_Hp]); 
      L_s = l_s * L_m; L_j = l_j * L_m;
    case 'abp'
      [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj([g k l_T v_Hb v_Hp-1e-6 v_Hp]); % -, scaled ages and lengths
      L_p = l_j * L_m;
  end
  
  if t_R < aT_b
    fprintf('Warning from get_CPM: age at birth is larger than reproduction interval\n');
    info = 0; txN = []; txL = []; txL2 = []; txL3 = []; txW = []; M_N = []; M_L = []; M_L2 = []; M_L3 = []; M_W = []; return
  end
  if strcmp(model,'ssj')
    pars_ts = [g k 0 v_Hb v_Hs]; [tau_s, tau_b, l_s, l_b] = get_tp(pars_ts, 1);
    tT_s = tau_s/ kT_M; tT_j = tT_s + t_sj; kT_E = k_E * TC;
    if t_R < tT_j
      fprintf('Warning from get_CPM: age at metam is larger than reproduction interval\n');
      info = 0; txN = []; txL = []; txL2 = []; txL3 = []; txW = []; M_N = []; M_L = []; M_L2 = []; M_L3 = []; M_W = []; return
    end
  end
  
  % initial states with number of cohorts n_c = 1;
  xvars_0 = [x_0; 0; 0; L_b; E_m; 0; E_Hb; 1]; % x q h L [E] E_R E_H N
  txN = [0, x_0, 1]; txL = [0, x_0, 0]; txL2 = [0, x_0, 0]; txL3 = [0, x_0, 0]; txW = [0, x_0, E_0/ mu_E * w_E/ d_E];% initialise output
  
  for i = 1:n_R
    switch model
      case {'std','stf'}
        par_std = {E_Hp, E_Hb, tTC, tJX, V_X, h_X, h_J, q_b, h_Ab, h_Bbp, h_Bpi, h_a, s_G, thin, S_b, aT_b, ...
            L_b, L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G};
        [t, xvars] = ode45(@dCPMstd, [0; aT_b; t_R], xvars_0, options, par_std{:});
      case 'stx'
        par_stx = {E_Hp, E_Hx, E_Hb, tTC, tJX, V_X, h_X, h_J, q_b, h_Ab, h_Bbx, h_Bxp, h_Bpi, h_a, s_G, thin, S_b, aT_b, ...
            L_b, L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G};
        [t, xvars] = ode45(@dCPMstx, [0; aT_b; t_R], xvars_0, options, par_stx{:});
      case 'ssj'
        par_ssj = {E_Hp, E_Hs, E_Hb, tTC, tJX, V_X, h_X, h_J, q_b, h_Ab, h_Bbs, h_Bjp, h_Bpi, h_a, s_G, thin, S_b, aT_b, ...
            L_b, L_m, E_m, k_E, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G};
        % treat shrinking at E_H(t) = E_Hs of first cohort as event
        [t, xvars] = ode45(@dCPMssj, [0; aT_b; tT_s], xvars_0, options, par_ssj{:});
        [x, q, h_A, L, L_max, E, E_R, E_H, N] = CPMunpack(xvars(end,:)); 
        L(1) = L(1) * exp(- t_sj * kT_E/ 3); N(1) = N(1) * exp( - t_sj * h_Bsj);
        xvars_0 = max(0,[x; q; h_A; L; L_max; E; E_R; E_H; N]); % pack state vars
        [t, xvars] = ode45(@dCPMssj, [tT_s; t_R], xvars_0, options, par_ssj{:});
      case 'sbp'
        par_sbp = {E_Hp, E_Hb, tTC, tJX, V_X, h_X, h_J, q_b, h_Ab, h_Bbp, h_Bpi, h_a, s_G, thin, S_b, aT_b, ...
            L_b, L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G};
        [t, xvars] = ode45(@dCPMsbp, [0; aT_b; t_R], xvars_0, options, par_sbp{:});
      case 'abj'
        par_abj = {E_Hp, E_Hj, E_Hb, tTC, tJX, V_X, h_X, h_J, q_b, h_Ab, h_Bbj, h_Bjp, h_Bpi, h_a, s_G, thin, S_b, aT_b, ...
            L_b, L_j, L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G};
        [t, xvars] = ode45(@dCPMabj, [0; aT_b; t_R], xvars_0, options, par_abj{:});
      case 'asj'
        par_asj = {E_Hp, E_Hj, E_Hs, E_Hb, tTC, tJX, V_X, h_X, h_J, q_b, h_Ab, h_Bbs, h_Bsj, h_Bjp, h_Bpi, h_a, s_G, thin, S_b, aT_b, ...
            L_b, L_j, L_s, L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G};
        [t, xvars] = ode45(@dCPMasj, [0; aT_b; t_R], xvars_0, options, par_asj{:});
      case 'abp'
        par_abp = {E_Hp, E_Hb, tTC, tJX, V_X, h_X, h_J, q_b, h_Ab, h_Bbp, h_Bpi, h_a, s_G, thin, S_b, aT_b, ...
            L_b, L_p, L_m, E_m, k_J, k_JX, v, g, p_M, p_Am, J_X_Am, K, kap, kap_G};
        [t, xvars] = ode45(@dCPMabp, [0; aT_b; t_R], xvars_0, options, par_abp{:});
      case {'hep','hex'}
        fprintf('Warning from get_CPM: this species does not sport periodic reproduction\n');
        info = 0; txN = []; txL = []; txL2 = []; txL3 = []; txW = []; M_N = []; M_L = []; M_L2 = []; M_L3 = []; M_W = []; return
    end
    % catenate output and possibly insert new cohort
    [t, xvars_0, txN, txL, txL2, txL3, txW] = cohorts(t(end), xvars(end,:), txN, txL, txL2, txL3, txW, t_R, E_0, kap_R, L_b, E_m, E_Hb, mu_E, w_E, d_E); 
    n_c = floor(length(xvars_0)-1)/7; % number of cohorts
    [i, n_c]
  end
  
  % maps
  if length(txN) > n_c && i > n_c
    M_N = txN(end-n_c:end,3:end)'/txN(end-n_c-1:end-1,3:end)';
    M_L = txL(end-n_c:end,3:end)'/txL(end-n_c-1:end-1,3:end)';
    M_L2 = txL2(end-n_c:end,3:end)'/txL2(end-n_c-1:end-1,3:end)';
    M_L3 = txL3(end-n_c:end,3:end)'/txL3(end-n_c-1:end-1,3:end)';
    M_W = txW(end-n_c:end,3:end)'/txW(end-n_c-1:end-1,3:end)';
  else
    M_N = []; M_L = []; M_L2 = []; M_L3 = []; M_W = []; 
  end
end


function [t, xvars_0, txN, txL, txL2, txL3, txW] = cohorts(t, xvars, txN, txL, txL2, txL3, txW, t_R, E_0, kap_R, L_b, E_m, E_Hb, mu_E, w_E, d_E)
  t = txN(end,1) + t_R; xvars_t = xvars(end,:); % last value of t, xvars
  [x, q, h_A, L, E, E_R, E_H, N] = CPMunpack(xvars_t);

  % reproduction event
  dN = kap_R * sum(N .* floor(E_R/ E_0)); % #, number of new eggs
  E_R = mod(E_R, E_0); % reduce reprod buffer to fractions of eggs
    
  % build new initial state vectors and append t, x, N, L, L2, L3 and W to output
  q = [0; q]; h_A = [0; h_A]; L = [L_b; L]; E = [E_m; E]; E_R = [0; E_R]; E_H = [E_Hb; E_H]; N = [dN; N]; 
  % most values for cohort 0 will be overwritten in dget_mod during embryo stage
  NL = N .* L; % cm/L, structural length
  NL2 = N .* L.^2; % cm^2/L, structural surface area
  NL3 = N .* L.^3; % cm^3/L, structural volume
  NW = NL3 .* (1 + E/ mu_E * w_E/ d_E); % g, wet weights excluding reprod buffer 
  if N(end) > 1e-4 % add new youngest cohort
    txN = [[txN, zeros(size(txN,1),1)]; [t, x, N']]; % append to output
    txL = [[txL, zeros(size(txL,1),1)]; [t, x, NL']]; % append to output
    txL2 = [[txL2, zeros(size(txL2,1),1)]; [t, x, NL2']]; % append to output
    txL3 = [[txL3, zeros(size(txL3,1),1)]; [t, x, NL3']]; % append to output
    txW = [[txW, zeros(size(txW,1),1)]; [t, x, NW']]; % append to output
  else % add new youngest cohort and remove oldest
    q(end)=[]; h_A(end)=[]; L(end)=[]; E(end)=[]; E_R(end)=[]; E_H(end)=[]; N(end)=[]; NL(end)=[]; NL2(end)=[]; NL3(end)=[]; NW(end)=[];
    txN = [txN; [t, x, N']]; % append to output
    txL = [txL; [t, x, NL']]; % append to output
    txL2 = [txL2; [t, x, NL2']]; % append to output
    txL3 = [txL3; [t, x, NL3']]; % append to output
    txW = [txW; [t, x, NW']]; % append to output
  end
  xvars_0 = max(0,[x; q; h_A; L; E; E_R; E_H; N]); % pack state vars
end

function [value,isterminal,direction] = puberty(t, xvars, E_Hp, varargin)
  % xvars: [x, q, h_A, L, E, E_R, E_H, N]
  n_c = (length(xvars) - 1)/ 7; % #, number of cohorts
  E_H = xvars(1+5*n_c+(1:n_c)); % J, maturities, cf CPMunpack
  value = min(abs(E_H - E_Hp)); % trigger 
  isterminal = 0;  % continue after event
  direction  = []; % get all the zeros
end

function [value,isterminal,direction] = leptoPub(t, xvars, E_Hp, E_Hs, varargin)
  % xvars: [x, q, h_A, L, E, E_R, E_H, N]
  n_c = (length(xvars) - 1)/ 7; % #, number of cohorts
  E_H = xvars(1+5*n_c+(1:n_c)); % J, maturities, cf CPMunpack
  value = [E_H(1) - E_Hs,  min(abs(E_H - E_Hp))]; % triggers 
  isterminal = [1 1];  % stop at event
  direction  = []; % get all the zeros
end

