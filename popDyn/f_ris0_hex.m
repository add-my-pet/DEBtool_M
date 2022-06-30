%% f_ris0_hex
% Gets scaled functional response at with the specific population growth rate is zero for the hex model

%%
function [f, info] = f_ris0_hex (par)
  % created 2019/08/01 by Bas Kooijman
  
  %% Syntax
  % [f, info] = <../f_ris0_hex.m *f_ris0_hex*> (par)
  
  %% Description
  % Obtains the scaled function response at which specific population growth rate for the hex model equals zero, 
  %   by solving the characteristic equation. We work at T_ref here.
  %
  % Input
  %
  % * par: structure with parameters for individual
  %
  % Output
  %
  % * f: scaled func response at which r = 0 for the hex model
  % * info: scalar with indicator for failure (0) or success (1)
  %
  %% Remarks
  % optional thinning (a boolean, default 1), and background hazards h_B0b, h_Bbj, h_Bje, h_Bei (default all 0) must be added to par before use, if necessary.
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
  if ~exist('h_Bbj', 'var')
    h_Bbj = 0;
  end
  if ~exist('h_Bje', 'var')
    h_Bje = 0;
  end
  if ~exist('h_Bei', 'var')
    h_Bei = 0;
  end
  
  if exist('v_Hx','var')
    v_Hb = v_Hx; % copy start of absorbtion by embryo to condition at birth (e.g. as in Venturia canescens)
  end
  
  % set lower boundary of f
  l_b = get_lb([g, k, v_Hb],1);
  f_0 = min(1, 1e-5 + max(l_b, s_j * l_b/ (s_j - 1 + l_b))); % -, scaled functional response at which puberty can just be reached
  if all([h_B0b h_Bbj h_Bje h_Bei] == [0 0 0 0])
      f = f_0; info = 1; return
  end
  i = 0;
  pars_charEq0 = {L_m, kap, kap_R, kap_V, k_M, v, g, k, E_G, E_m, v_Hb, v_He, s_j, s_G, h_a, h_B0b, h_Bbj, h_Bje, h_Bei, thinning};
  while charEq0(f_0, pars_charEq0{:}) > 0 && i < 20
    f_1 = f_0; f_0 = f_0/ 2; i = i + 1;
  end
  if i == 20
    fprintf('Warning from f_ris0_hex: no lower boundary for f found for which r = 0\n');
    info = 0; f = NaN; return
  end
  
  % set upper boundary of f if necessary
  pars_charEq0 = {L_m, kap, kap_R, kap_V, k_M, v, g, k, E_G, E_m, v_Hb, v_He, s_j, s_G, h_a, h_B0b, h_Bbj, h_Bje, h_Bei, thinning};
  if ~exist('f_1','var')
    f_1 = 1;         % upper boundary (lower boundary is f_0)
    if charEq0(f_1, pars_charEq0{:}) < 0
      fprintf('Warning from f_ris0_hex: no f detected for which r = 0\n');
      info = 0; f = f_0; return
    end
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
    fprintf('f_ris0_hex warning: no convergence for f in 18 steps\n')
  elseif f_1 - f_0 > 1e-4
    info = 0;
    fprintf('f_ris0_hex warning: interval for f < 1e-4, norm = %g\n', norm)
  else
    info = 1;
  end
  
end

function val = charEq0(f, L_m, kap, kap_R, kap_V, k_M, v, g, k, E_G, E_m, v_Hb, v_He, s_j, s_G, h_a, h_B0b, h_Bbj, h_Bje, h_Bei, thinning)
  % val = char eq in f, for r = 0
  pars_tj = [g k v_Hb v_He s_j kap kap_V];
  [tau_j, tau_e, tau_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee, info] = get_tj_hex(pars_tj, f);  
  if isempty(tau_j) || isempty(tau_e)
    val = -1; return
  end
  u_E0 = get_ue0([g k v_Hb], f); E_0 = u_E0 * E_G * L_m^3/ kap; % -, (scaled) cost for egg
  a_b = tau_b/ k_M; t_j = (tau_j - tau_b)/ k_M; t_e = (tau_e - tau_b)/ k_M; % unscale
  L_b = L_m * l_b; L_j = L_m * l_j;  L_e = L_m * l_e;  % unscale
  S_b = exp( - a_b * h_B0b); % - , survival prob at birth
  r_j = k_M * rho_j; % 1/d, growth rate
  
  % life span as imago
  pars_tm = [g; 0; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  tau_m = get_tm_s(pars_tm, f, l_b);  % -, scaled mean life span at T_ref
  t_im = tau_m/ k_M;                  % d, mean life span as imago
  
  % reproduction rate of imago
  E_Rj = v_Rj * (1 - kap) * g * E_m * L_j^3; % J,reprod buffer at pupation
  %E_R = E_Rj + u_Ee * v * E_m * L_m^2/ k_M - f * E_m * L_e^3; % J, total reserve for reprod
  N = kap_R * E_Rj/ E_0;               % #, number of eggs at emergence
  R = N/ t_im;                        % #/d, reproduction rate
  t_N0 = t_e + t_im;                  % d, time since birth at which all eggs are produced

  options = odeset('AbsTol',1e-9, 'RelTol',1e-9); 
  pars_qhSC = {f, kap, kap_R, k_M, v, g, k, R, L_b, L_j, L_e, L_m, t_j, t_e, t_N0, r_j, s_G, h_a, h_Bbj, h_Bje, h_Bei, thinning};
  [t, qhSC] = ode45(@dget_qhSC, [0; t_N0], [0, 0, S_b, 0], options, pars_qhSC{:});
  val = qhSC(end, 4) - 1;
end
    
function dqhSC = dget_qhSC(t, qhSC, f, kap, kap_R, k_M, v, g, k, R, L_b, L_j, L_e, L_m, t_j, t_e, t_N0, r_j, s_G, h_a, h_Bbj, h_Bje, h_Bei, thinning)  
  q   = max(0,qhSC(1)); % 1/d^2, aging acceleration
  h_A = max(0,qhSC(2)); % 1/d^2, hazard rate due to aging
  S   = max(0,qhSC(3)); % -, survival prob
  
  if t < t_j % larva
    h_B = h_Bbj;
    h_X = thinning * r_j; % 1/d, hazard due to thinning
    dq = 0;
    dh_A = 0;
  elseif t < t_e % pupa
    h_B = h_Bje;
    h_X = 0; % 1/d, hazard due to thinning
    dq = 0;
    dh_A = 0;
  else % imago
    h_B = h_Bei;
    s_M = L_j/ L_b;
    L = L_e;
    r = 0; % 1/d, spec growth rate of structure
    h_X = 0; % 1/d, hazard due to thinning
    %dq = (q * s_G * L^3/ L_m^3/ s_M^3 + h_a) * f * (v * s_M/ L - r) - r * q;
    dq = (q * s_G  + h_a) * f * v * s_M/ L;
    %dh_A = q - r * h_A; % 1/d^2, change in hazard due to aging
    dh_A = q; % 1/d^2, change in hazard due to aging
  end

  h = h_A + h_B + h_X; 
  dS = - h * S; % 1/d, change in survival prob
      
  dCharEq = (t > t_e) * (t < t_N0) * S * R; 

  dqhSC = [dq; dh_A; dS; dCharEq]; 
end

