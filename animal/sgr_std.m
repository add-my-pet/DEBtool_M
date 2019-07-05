%% sgr_std
% Gets specific population growth rate for the std model

%%
function [r info t_b t_p l_b l_p u_E0] = sgr_std (par, f)
  % created 2019/07/01 by Bas Kooijman
  
  %% Syntax
  % [r info t_b t_p l_b l_p u_E0] = <../sgr_iso.m *sgr_std*> (par, f)
  
  %% Description
  % Specific population growth rate for the std model;
  % Hazard includes thinning, stage-specific background (optional, default: 0; otherwise specified in par.h_B0b, par.h_Bbj, par.h_Bji), and ageing
  % Buffer handling rule: produce an egg as soon as buffer allows
  % Food density and temperature are assumed to be constant; temperature is specified in par.T_typical.
  % The resulting specific growth rate r is solved from the characteristic equation 1 = \int_0^a_max S(a) R(a) exp(- r a) da, where 
  %   R(a) consists of Dirac delta functions and R(a) = 0 for a < a_p,
  %   and a_max is approximated with 10 times mean life span a_m
  %
  % Input
  %
  % * par: structure with parameters for individual
  % * f: optional scalar with scaled functional response (default 1)
  %
  % Output
  %
  % * r: scalar with specific population growth rate
  % * info: scalar with indicator for failure (0) or success (1) or large tm (2)
  % * tb: scalar with scaled age at birth ab/kM 
  % * tp_out: scalar with scaled age at puberty ap/kM 
  % * lb: scalar with scaled length at birth
  % * lp_out: scalar with scaled length at puberty
  % * uE0: scalar with scaled initial reserve
  
  %% Remarks
  % See <ssd_std.html *ssd_std*> for mean age, length, squared length, cubed length.
  % See <f_ris0_std.html *f_ris0_std*> for f at which r = 0
  
  %% Example of use
  % cd to entries/Passer_domesticus/; load results.Passer_domesticus; 
  % [r info tb tp lb lp uE0] = sgr_std(par)

  % unpack par and compute statisitics
  cPar = parscomp_st(par); vars_pull(par);  vars_pull(cPar);  

  if ~exist('f','var')
    f = 1;
  end

  l_i = f - lT;
  r_B = k_M/ 3/ (1 + f/ g); % 1/d, von Bert growth rate
  hW = (ha * g/ 6/ kM^2)^(1/3); % hW/ kM
  hG = sG * g * f^3; % hG/ kM
  hWG3 = (hW/ hG)^3;
  pars_tm = [g; k; l_T; v_Hb; v_Hp; h_a/ k_M^2; s_G]; % compose parameter vector
  t_m = get_tm_s(pars_tm, f);                         % -, scaled median life span

  [u_E0 l_b info] = get_ue0([g k v_Hb], f);
  if info == 0
    r = NaN; l_p = NaN; t_p = NaN; t_b = NaN;
    fprintf('sgr_iso std warning: u_E0 could not be obtained\n');
    return
  end
  rho_0 = kap_R * (1 - kap)/ u_E0;

  [t_p, t_b, l_p, l_b, info] = get_tp([g k l_T v_Hb v_Hp], f, l_b);
  if l_p > f || info == 0 || t_p < 0
    r = 0;
    info = 0;
    fprintf('sgr_std warning: l_p > f\n');
    t_p = 0; l_p = 0;
    return
  end

  % initialize range for r/k_M
  rho_0 = 1e-8; 
  norm_0 = fnsgr_iso(f, rho_0, rho0, rhoB, lT, lp, li, tp, g, k, vHp, hWG3, hW, hG, tm);
  rho_1 = reprod_rate(f * Lm, f, p, lb * Lm)/kM; % R_i/ k_M
  norm_1 = fnsgr_iso(f, rho_1, rho0, rhoB, lT, lp, li, tp, g, k, vHp, hWG3, hW, hG, tm);
  if norm_0 < 0 || norm_1 > 0
    %fprintf('sgr_iso warning: invalid parameter combination\n')
    %printpar({'lower boundary'; 'upper boundary'}, [rho_0; rho_1], [norm_0; norm_1], 'r, char eq'); 
    rho = fzero(@(rho) exp(-rho * tp) - exp(rho/ rho_1) + 1, 1e-8); % see (9.22) of DEB3
    r = rho * kM; % spec pop growth rate
    info = 2;
    lp_out = lp; tp_out = tp; 
    return
  end
  norm = 1; i = 0; % initialize norm and counter

  while i < 200 && norm^2 > 1e-20 % bisection method
    i = i + 1;
    rho = (rho_0 + rho_1)/ 2;
    norm = fnsgr_iso(f, rho, rho0, rhoB, lT, lp, li, tp, g, k, vHp, hWG3, hW, hG, tm);
    if norm > 0
        rho_0 = rho;
    else
        rho_1 = rho;
    end
  end

  r = rho * kM; % spec pop growth rate

  if i == 200
    info = 0;
    fprintf('sgr_iso warning: no convergence for r in 200 steps\n')
  else
    info = 1;
    %fprintf(['sgr_iso warning: successful convergence for r in ', num2str(i), ' steps\n'])
  end

  lp_out = lp; % copy lp to output
  tp_out = tp; % copy tp to output
  
end
