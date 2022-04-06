%% f_ris0_hep
% Gets scaled functional response at with the specific population growth rate is zero for the hep model

%%
function [f, info] = f_ris0_hep (par)
  % created 2019/07/30 by Bas Kooijman
  
  %% Syntax
  % [f, info] = <../f_ris0_hep.m *f_ris0_hep*> (par)
  
  %% Description
  % Obtains the scaled function response at which specific population growth rate for the hep model equals zero, 
  %   by solving the characteristic equation. We work at T_ref here.
  %
  % Input
  %
  % * par: structure with parameters for individual
  %
  % Output
  %
  % * f: scaled func response at which r = 0 for the hep model
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % optional thinning (a boolean, default 1), and background hazards h_B0b, h_Bbp, h_Bpi (default all 0) must be added to par before use, if necessary.
  % par.reprodCode must exist.
  % Only imago's lay eggs, but do not allocate to reprod, at a rate of reprod buffer at j per expected life time as imago, till buffer is finished.

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  
  if strcmp(reprodCode,'O') && strcmp(genderCode,'D')
    kap_R = kap_R/2; % take cost of male production into account
  end

  % defaults
  if ~exist('thinning','var')
    thinning = 1;
  end
  if ~exist('h_B0b', 'var')
    h_B0b = 0;
  end
  if ~exist('h_Bbp', 'var')
    h_Bbp = 0;
  end
  if ~exist('h_Bpj', 'var')
    h_Bpj = 0;
  end
  if ~exist('h_Bji', 'var')
    h_Bji = 0;
  end
  
  % set lower boundary of f
  f_0 = 1e-5 + get_ep_min_j([g, k, l_T, v_Hb, (v_Hp-1e-8), v_Hp]); % -, scaled functional response at which puberty can just be reached
  if all([h_B0b h_Bbp h_Bpj h_Bji] == [0 0 0 0])
      f = f_0; info = 1; return
  end
  pars_charEq0 = {L_m, kap, kap_R, k_M, v, g, k, E_Rj, E_G, v_Hb, v_Hp, s_G, h_a, h_B0b, h_Bbp, h_Bpj, h_Bji, thinning};
  if charEq0(f_0, pars_charEq0{:}) > 0
    fprintf('Warning from f_ris0_hep: f for which r = 0 is very close to that for R_i = 0\n');
    f = f_0; info = 1; return
  end
  
  % set upper boundary of f
  f_1 = 1;         % upper boundary (lower boundary is f_0)
  if charEq0(f_1, pars_charEq0{:}) < 0
    fprintf('Warning from f_ris0_hep: no f detected for which r = 0\n');
    info = 0; f = f_0; return
  end
  
  % get f at r = 0
  norm = 1; i = 0; % initialize norm and counter
  % 2^-18 = 4e-6: min accuracy of f_min, starting from worst-case (0,1)
  while i < 18 && norm^2 > 1e-16 && f_1 - f_0 > 1e-5 % bisection method
    i = i + 1;
    f = (f_0 + f_1)/ 2;
    norm = charEq0(f, pars_charEq0{:});
    %[i f_0 f f_1 norm] % show progress
    if norm > 0
      f_1 = f;
    else
      f_0 = f;
    end
  end

  if i == 18 
    info = 0;
    fprintf('f_ris0_hep warning: no convergence for f in 18 steps\n')
  elseif f_1 - f_0 > 1e-4
    info = 0;
    fprintf('f_ris0_hep warning: interval for f < 1e-4, norm = %g\n', norm)
  else
    info = 1;
  end
  
end

function val = charEq0(f, L_m, kap, kap_R, k_M, v, g, k, E_Rj, E_G, v_Hb, v_Hp, s_G, h_a, h_B0b, h_Bbp, h_Bpj, h_Bji, thinning)
  % val = char eq in f, for r = 0
  u_E0 = get_ue0([g k v_Hb], f); E_0 = u_E0 * E_G * L_m^3/ kap; % -, (scaled) cost for egg
  v_Rj = kap/ (1 - kap) * E_Rj/ E_G; pars_tj = [g k v_Hb v_Hp v_Rj];
  [tau_j, tau_p, tau_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj_hep(pars_tj, f); 
  if isempty(tau_j)
    val = -1; return
  end
  a_b = tau_b/ k_M; t_p = (tau_p - tau_b)/ k_M; t_j = (tau_j - tau_b)/ k_M; % unscale
  L_b = L_m * l_b; L_p = L_m * l_p; L_j = L_m * l_j;  L_i = L_m * l_i;  % unscale
  S_b = exp( - a_b * h_B0b); % - , survival prob at birth
  r_j = k_M * rho_j; r_B = k_M * rho_B; % 1/d, growth rates
  
  % life span as imago
  pars_tm = [g; 0; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  tau_m = get_tm_s(pars_tm, f, l_b);  % -, scaled mean life span at T_ref
  t_im = tau_m/ k_M;                  % d, mean life span as imago
  
  % reproduction rate of imago
  N = kap_R * E_Rj * L_j^3/ E_0;      % #, number of eggs at emergence
  R = N/ t_im;                        % #/d, reproduction rate
  t_N0 = t_j + t_im;                  % d, time since birth at which all eggs are produced

  options = odeset('AbsTol',1e-9, 'RelTol',1e-9); 
  pars_qhSC = {f, k_M, v, g, k, R, L_b, L_p, L_j, L_i, L_m, t_p, t_j, t_N0, r_j, r_B, v_Hp, s_G, h_a, h_Bbp, h_Bpj, h_Bji, thinning};
  [t, qhSC] = ode45(@dget_qhSC, [0; t_N0], [0, 0, S_b, 0], options, pars_qhSC{:});
  val = qhSC(end, 4) - 1;
end
    
function dqhSC = dget_qhSC(t, qhSC, f, k_M, v, g, k, R, L_b, L_p, L_j, L_i, L_m, t_p, t_j, t_N0, r_j, r_B, v_Hp, s_G, h_a, h_Bbp, h_Bpj, h_Bji, thinning)  
  q   = max(0,qhSC(1)); % 1/d^2, aging acceleration
  h_A = max(0,qhSC(2)); % 1/d^2, hazard rate due to aging
  S   = max(0,qhSC(3)); % -, survival prob
  
  if t < t_p
    h_B = h_Bbp;
    L = L_b * exp(t * r_j/ 3);
    r = r_j;
    h_X = thinning * r; % 1/d, hazard due to thinning
    dq = 0;
    dh_A = 0;
  elseif t < t_j
    h_B = h_Bpj;
    L = L_i - (L_i - L_p) * exp(-r_B * (t - t_p));
    r = 3 * r_B * (L_i/ L - 1); % 1/d, spec growth rate of structure
    h_X = thinning * r * 2/3; % 1/d, hazard due to thinning
    dq = 0;
    dh_A = 0;
  else % imago
    h_B = h_Bji;
    s_M = L_p/ L_b;
    L = L_j;
    r = 0; % 1/d, spec growth rate of structure
    h_X = 0; % 1/d, hazard due to thinning
    dq = (q * s_G * L^3/ L_m^3/ s_M^3 + h_a) * f * (v * s_M/ L - r) - r * q;
    dh_A = q - r * h_A; % 1/d^2, change in hazard due to aging
  end

  h = h_A + h_B + h_X; 
  dS = - h * S; % 1/d, change in survival prob
      
  dCharEq = (t > t_j) * (t < t_N0) * S * R; 

  dqhSC = [dq; dh_A; dS; dCharEq]; 
end

