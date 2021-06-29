%% sgr_abj
% Gets specific population growth rate for the abj model

%%
function [r, info] = sgr_abj (par, T_pop, f_pop)
  % created 2019/07/06 by Bas Kooijman, modified 2021/06/27
  
  %% Syntax
  % [r, info] = <../sgr_abj.m *sgr_abj*> (par, T_pop, f_pop)
  
  %% Description
  % Specific population growth rate for the abj model.
  % Hazard includes 
  %
  %  * thinning (optional, default: 1; otherwise specified in par.thinning), 
  %  * stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbj, par.h_Bjp, par.h_Bpi)
  %  * ageing (controlled by par.h_a and par.s_G)
  %
  % With thinning the hazard rate is such that the feeding rate of a cohort does not change during growth, in absence of other causes of death.
  % Survival of embryo due to ageing is taken for sure
  % Buffer handling rule: continuous reproduction is used in the abj model.
  % Food density and temperature are assumed to be constant; temperature is specified in par.T_typical.
  % Male production is taken into account by dividing kap_R by two.
  % For semelparous reproduction, the specific growth rate is r = log(S_m N)/ a_m
  % For iteroparous reproduction, the specific growth rate r is solved from the characteristic equation 1 = \int_0^a_max S(a) R(a) exp(- r a) da
  %   with a_max such that S(a_max) = 1e-6
  % 
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
  % See <ssd_abj.html *ssd_abj*> for mean age, length, squared length, cubed length and other statistics.
  % See <f_ris0_mod.html *f_ris0_mod*> for f at which r = 0.
  % par.thinning, par.h_B0b, par.h_Bbj, par.h_Bjp and par.h_Bpi are not standard in structure par; Add them before use if necessary.
  % par.reprodCode is not standard in structure par. Add it before use. If missing, "O" is assumed.

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par); vars_pull(cPar);  

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
  if ~exist('h_Bbj', 'var')
    h_Bbj = 0;
  end
  if ~exist('h_Bjp', 'var')
    h_Bjp = 0;
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

  if (~exist('reprodCode', 'var') || strcmp(reprodCode(1), 'O')) && (~exist('genderCode', 'var') || strcmp(genderCode(1), 'D'))
    kap_R = kap_R/2; % take cost of male production into account
  end
  
  if exist('reprodCode', 'var') && strcmp(reprodCode, 'Os') % semelparous reprod
    info = 1; % correct result is for sure
    
    % life cycle
    pars_tj = [g k l_T v_Hb v_Hj v_Hp];
    [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj(pars_tj, f);
    rT_j = rho_j * kT_M; rT_B = rho_B * kT_M;
    tT_0b = tau_b/ kT_M; tT_bj = (tau_j - tau_b)/ kT_M; tT_jp = (tau_p - tau_j)/ kT_M;
  
    % life span
    pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
    tau_m = get_tm_s(pars_tm, f, l_b);    % -, scaled mean life span at T_ref
    tT_0i = max(tau_p+0.1,tau_m)/ kT_M;   % d, mean life span at T
    tT_pi = max(0,tau_m - tau_p)/ kT_M;   % d, time since puberty at death

    % total fecundity
    pars_R = [kap; kap_R; g; TC*k_J; TC*k_M; L_T; TC*v; U_Hb/TC; U_Hj/TC; U_Hp/TC]; % compose parameter vector
    NT_i = cum_reprod_j(tT_0i, f, pars_R); % #, cum no of eggs at death
  
    if thinning
      fn = @(t,r_B,l) 2*r_B*(1./(1-(1-l)*exp(-r_B*t))-1);
      S_0j = exp(- tT_0b*h_B0b - tT_bj*(h_Bbj+rT_j));         % -, survivor prob between 0 and j
      S_jp = exp(- tT_jp*h_Bjp - integral(@(t)fn(t,rT_B,l_j/l_i),0,tT_jp));  % -, survivor prob between j and p
      S_pi = exp(- tT_pi*h_Bpi - integral(@(t)fn(t,rT_B,l_p/l_i),0,tT_pi));  % -, survivor prob between p and 1
    else % no thinning
      S_0j = exp(- tT_0b*h_B0b - tT_bj*h_Bbj);                % -, survivor prob between 0 and j
      S_jp = exp(- tT_jp*h_Bjp);                              % -, survivor prob between j and p
      S_pi = exp(- tT_pi*h_Bpi);                              % -, survivor prob between p and 1
    end
    S_m =  S_0j * S_jp * S_pi;                                % -, survivor prob between 0 and i

    r = log(S_m * NT_i)/ tT_0i;                               % 1/d, spec pop growth rate
  
  else % iteroparous reprod
    % supporting statistics
    u_E0 = get_ue0([g k v_Hb], f); % -, scaled cost for egg
    pars_tj = [g k l_T v_Hb v_Hj v_Hp];
    [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj(pars_tj, f); % -, scaled ages and lengths
    aT_b = tau_b/ kT_M; tT_j = (tau_j - tau_b)/ kT_M; tT_p = (tau_p - tau_b)/ kT_M; % d, age at birth, time since birth at metam, puberty
    L_b = L_m * l_b; L_j = L_m * l_j; L_i = L_m * l_i; s_M = l_j/ l_b; % cm, struc length at birth, metam, puberty, ultimate
    S_b = exp(-aT_b * h_B0b);          % -, survivor prob at birth
    rT_j = kT_M * rho_j; rT_B = kT_M * rho_B; % 1/d, expo, von Bert growth rate
    pars_qhSC = {f, kap, kap_R, kT_M, vT, g, k, u_E0, L_b, L_j, L_i, rT_j, rT_B, v_Hp, s_G, hT_a, h_Bbj, h_Bjp, h_Bpi, thinning};
  
    % ceiling for r
    R_i = kap_R * (1 - kap) * kT_M * (f/ (f + g) * l_i^2 * (g * s_M + l_i) - k * v_Hp)/ u_E0; % #/d, ultimate reproduction rate at T eq (2.56) of DEB3 for l_T = 0 and l = f
    char_eq = @(rho, rho_p) 1 + exp(- rho * rho_p) - exp(rho); % see DEB3 eq (9.22): exp(-r*a_p) = exp(r/R) - 1 
    [rho_max, info] = nmfzero(@(rho) char_eq(rho, R_i * tT_p), 1); 
    r_max = rho_max * R_i; % 1/d, pop growth rate for eternal surivival and ultimate reproduction rate since puberty
    
    % find r from char eq 1 = \int_0^infty S(t) R(t) exp(-r*t) dt
    if charEq(0, S_b, tT_j, tT_p, pars_qhSC{:}) > 0 
      fprintf(['Warning from sgr_abj: no root for the characteristic equation, thinning = ', num2str(thinning), '\n']);
      r = NaN; info = 0; % no positive r exists
    elseif charEq(r_max, S_b, tT_j, tT_p, pars_qhSC{:}) < 0
      [r, ~, info] = fzero(@charEq, [0 2*r_max], [], S_b, tT_j, tT_p, pars_qhSC{:});
    else 
      if charEq(r_max, S_b, tT_j, tT_p, pars_qhSC{:}) > 0.95
        [r, ~, info] = fzero(@charEq, [0 r_max], [], S_b, tT_j, tT_p, pars_qhSC{:});
      else
        [r, info] = nmfzero(@charEq, r_max, [], S_b, tT_j, tT_p, pars_qhSC{:});
      end
    end
  end
  
  if r<0 % do not accept negative growth rates
    info = 0;
  end
end

% event dead_for_sure
function [value,isterminal,direction] = dead_for_sure(t, qhSC, sgr, t_j, t_p, varargin)
  value = [t - t_j, t - t_p, qhSC(3) - 1e-6];  % trigger 
  isterminal = [0, 0, 1];  % terminate at dead_for_sure
  direction  = [];         % get all the zeros
end

% reproduction is continuous
function dqhSC = dget_qhSC(t, qhSC, sgr, t_j, t_p, f, kap, kap_R, k_M, v, g, k, u_E0, L_b, L_j, L_i, r_j, r_B, v_Hp, s_G, h_a, h_Bbj, h_Bjp, h_Bpi, thinning)
  % t: time since birth

  % although option NonNegative is used, variables can become negative
  q   = max(0,qhSC(1)); % 1/d^2, aging acceleration
  h_A = max(0,qhSC(2)); % 1/d^2, hazard rate due to aging
  S   = max(0,qhSC(3)); % -, survival prob
  
  if t < t_j
    h_B = h_Bbj;
    L = L_b * exp(t * r_j/ 3);
    s_M = L/ L_b;
    r = r_j;
    h_X = thinning * r; % 1/d, hazard due to thinning
  else
    h_B = (t < t_p) * h_Bjp + (t > t_p) * h_Bpi;
    L = L_i - (L_i - L_j) * exp(- r_B * (t - t_j));
    s_M = L_j/ L_b;
    r = 3 * r_B * (L_i/ L - 1); % 1/d, spec growth rate of structure
    h_X = thinning * r * 2/3; % 1/d, hazard due to thinning
  end

  L_m = v/ k_M/ g; % cm, "max" structural length
  dq = (q * s_G * L^3/ L_m^3/ s_M^3 + h_a) * f * (v * s_M/ L - r) - r * q;
  dh_A = q - r * h_A; % 1/d^2, change in hazard due to aging

  h = h_A + h_B + h_X; 
  dS = - h * S; % 1/d, change in survival prob
    
  l = L/ L_m; 
  R = (t > t_p) * kap_R * k_M * (f/ (f + g) * l^2 * (g * s_M + l) - k * v_Hp) * (1 - kap)/ u_E0;
  dCharEq = S * R * exp(- sgr * t);
  
  dqhSC = [dq; dh_A; dS; dCharEq]; 
end

function value = charEq (sgr, S_b, t_j, t_p, f, kap, kap_R, k_M, v, g, k, u_E0, L_b, L_j, L_i, r_j, r_B, v_Hp, s_G, h_a, h_Bbj, h_Bjp, h_Bpi, thinning)
  options = odeset('Events',@dead_for_sure, 'NonNegative',ones(4,1), 'AbsTol',1e-9, 'RelTol',1e-9);  
  [t, qhSC, te, qhSCe, ie] = ode45(@dget_qhSC, [0 1e8], [0 0 S_b 0], options, sgr, t_j, t_p, f, kap, kap_R, k_M, v, g, k, u_E0, L_b, L_j, L_i, r_j, r_B, v_Hp, s_G, h_a, h_Bbj, h_Bjp, h_Bpi, thinning);
  qhSC = qhSC(cumsum(qhSC(:,3)<0)==0,:);  % the case of Pteria_sterna shows that S can become negative
  if qhSC(end,3) > 2e-6
    [t, qhSC] = ode45(@dget_qhSC, [0 1e6], [0 0 S_b 0], [], sgr, t_j, t_p, f, kap, kap_R, k_M, v, g, k, u_E0, L_b, L_j, L_i, r_j, r_B, v_Hp, s_G, h_a, h_Bbj, h_Bjp, h_Bpi, thinning);
    qhSC = qhSC(cumsum(qhSC(:,3)<0)==0,:);  % the case of Pteria_sterna shows that S can become negative
  end
  value = 1 - qhSC(end,4);
end
