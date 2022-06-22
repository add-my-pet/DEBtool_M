function [prdData, info] = predict_Pleurobrachia_bachei(par, data, auxData)
  
  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);
  
  % compute temperature correction factors
  TC_ab = tempcorr(temp.ab, T_ref, T_A);
  TC_tp = tempcorr(temp.tp, T_ref, T_A);
  TC_am = tempcorr(temp.am, T_ref, T_A);
  TC_Ri = tempcorr(temp.Ri, T_ref, T_A);
  TC = tempcorr(temp.tL_A, T_ref, T_A);
  TC_13 = tempcorr(temp.LJO_13, T_ref, T_A);
  TC_11 = tempcorr(temp.LJO_11, T_ref, T_A);
  
  % zero-variate data

  % life cycle
  pars_tj = [g k l_T v_Hb v_Hj v_Hp];
  [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj(pars_tj, f);
  
  % initial
  pars_UE0 = [V_Hb; g; k_J; k_M; v]; % compose parameter vector
  U_E0 = initial_scaled_reserve(f, pars_UE0); % d.cm^2, initial scaled reserve
  E_0 = U_E0 * p_Am; WC_0 = E_0 * 12e6/ mu_E; % µg, initial carbon mass
  
  % birth
  L_b = L_m * l_b;                  % cm, structural length at birth at f
  Lw_b = L_b/ del_M;                % cm, total length at birth at f
  aT_b = t_b/ k_M/ TC_ab;           % d, age at birth at f and T
  
  % puberty 
  L_p = L_m * l_p;                  % cm, structural length at puberty at f
  Lw_p = L_p/ del_M;                % cm, total length at puberty at f
  tT_p = (t_p - t_b)/ k_M/ TC_tp;   % d, time since birth at puberty at f and T

  % ultimate
  L_i = L_m * l_i;                  % cm, ultimate structural length at f
  Lw_i = L_i/ del_M;                % cm, ultimate total length at f
  Wd_i = 1e3 * L_i^3 * d_V * (1 + f * w); % mg, ultimate ashfree dry weight 
 
  % reproduction
  pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb;U_Hj;  U_Hp]; % compose parameter vector at T
  RT_i = TC_Ri * reprod_rate_j(L_i, f, pars_R);                 % #/d, ultimate reproduction rate at T

  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC_am;               % d, mean life span at T
  
  % pack to output
  prdData.ab = aT_b;
  prdData.tp = tT_p;
  prdData.am = aT_m;
  prdData.Lb = Lw_b;
  prdData.Lp = Lw_p;
  prdData.Li = Lw_i;
  prdData.WC0 = WC_0;
  prdData.Wdi = Wd_i;
  prdData.Ri = RT_i;
  
  % uni-variate data
  
  % time-length, reprod
  LEHN_0 = [L_b; E_m * L_b^3; E_Hb; 0; L_b]; 
  [t LEHN] = ode45(@dget_LEHN, [0; tL_A(:,1)], LEHN_0, [], tJX.tJX_A, L_b, TC * p_Am, kap, kap_R, TC * v, TC * k_J, TC * p_M, E_G, E_Hj, E_Hp, E_m, E_0, kap_X, mu_X);
  ELw_A = 10 * LEHN(2:end,1)/ del_M;
  [t LEHN] = ode45(@dget_LEHN, tN_A(:,1), LEHN_0, [], tJX.tJX_A, L_b, TC * p_Am, kap, kap_R, TC * v, TC * k_J, TC * p_M, E_G, E_Hj, E_Hp, E_m, E_0, kap_X, mu_X);
  EN_A = LEHN(:,4); EJX_A = tJX.tJX_A(:,2);
  %
  [t LEHN] = ode45(@dget_LEHN, [0; tL_B(:,1)], LEHN_0, [], tJX.tJX_B, L_b, TC * p_Am, kap, kap_R, TC * v, TC * k_J, TC * p_M, E_G, E_Hj, E_Hp, E_m, E_0, kap_X, mu_X);
  ELw_B = 10 * LEHN(2:end,1)/ del_M;
  [t LEHN] = ode45(@dget_LEHN, tN_B(:,1), LEHN_0, [], tJX.tJX_B, L_b, TC * p_Am, kap, kap_R, TC * v, TC * k_J, TC * p_M, E_G, E_Hj, E_Hp, E_m, E_0, kap_X, mu_X);
  EN_B = LEHN(:,4); EJX_B = tJX.tJX_B(:,2);
  %
  [t LEHN] = ode45(@dget_LEHN, [0; tL_C(:,1)], LEHN_0, [], tJX.tJX_C, L_b, TC * p_Am, kap, kap_R, TC * v, TC * k_J, TC * p_M, E_G, E_Hj, E_Hp, E_m, E_0, kap_X, mu_X);
  ELw_C = 10 * LEHN(2:end,1)/ del_M;
  [t LEHN] = ode45(@dget_LEHN, tN_C(:,1), LEHN_0, [], tJX.tJX_C, L_b, TC * p_Am, kap, kap_R, TC * v, TC * k_J, TC * p_M, E_G, E_Hj, E_Hp, E_m, E_0, kap_X, mu_X);
  EN_C = LEHN(:,4); EJX_C = tJX.tJX_C(:,2);
  
  % lenght-weight
  EWd = del_W * d_V * (LWd(:,1) * del_M).^3 * (1 + w * f); % mg, dry weight
  EWd_ThibBowe2004 = del_W * d_V * (LWd_ThibBowe2004(:,1) * del_MP).^3 * (1 + w * f); % mg, dry weight
  
  % length-respiration
  pars_p = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp]; % compose pars
  p_ref = p_Am * L_m^2; % J/d, max assimilation power at max size
  pACSJGRD = p_ref * scaled_power_j(0.1 * LJO_13(:,1) * del_M, f, pars_p, l_b, l_j, l_p); % J/d, powers
  J_M = - (n_M\n_O) * eta_O * pACSJGRD(:, [1 7 5])';  % mol/d: J_C, J_H, J_O, J_N in rows
  EJT_O13 = - J_M(3,:)' * TC_13 * 24.4e6/ 24;         % µl O2/h, O2 consumption 
  %
  pACSJGRD = p_ref * scaled_power_j(0.1 * LJO_11(:,1) * del_M, f, pars_p, l_b, l_j, l_p); % J/d, powers
  J_M = - (n_M\n_O) * eta_O * pACSJGRD(:, [1 7 5])';  % mol/d: J_C, J_H, J_O, J_N in rows
  EJT_O11 = - J_M(3,:)' * TC_11 * 24.4e6/ 24;         % µl O2/h, O2 consumption 

  % pack to output
  prdData.tJX_A = EJX_A;
  prdData.tJX_B = EJX_B;
  prdData.tJX_C = EJX_C;
  prdData.tL_A = ELw_A;
  prdData.tL_B = ELw_B;
  prdData.tL_C = ELw_C;
  prdData.tN_A = EN_A;
  prdData.tN_B = EN_B;  
  prdData.tN_C = EN_C;  
  prdData.LWd = EWd;
  prdData.LWd_ThibBowe2004 = EWd_ThibBowe2004;
  prdData.LJO_13 = EJT_O13;
  prdData.LJO_11 = EJT_O11;
  
end

% %%% subfunction
%% subfunction for computing the length and cumulative reproduction against age data

function dLEHN = dget_LEHN(t, LEH, tJX, Lb, p_Am, kap, kap_R, v, k_J, p_M, E_G, E_Hj, E_Hp, E_m, E_0, kap_X, mu_X)
  % t: scalar with time since birth
  % LEH: 5-vector with (L, E, E_H, E_R, LM) of juvenile and adult
  % dLEH: 5-vector with (dL/dt, dE/dt, dH/dt, dER/dt, dLM/dt)
  
  % unpack
  L = LEH(1);     % cm, structural length
  E = LEH(2);     % J, reserve E
  E_H = LEH(3);   % J, maturity E_H
  %N = LEH(4);    % #/d, cum reproductive output
  LM = LEH(5);    % cm, morphological length
  
  JX = spline1(t,tJX,0);  % µg/d, observed ingestion rate at time t
  JX = 1e-6 * JX/ 12;     % molC/d, observed ingestion rate at time t
  pA = kap_X * mu_X * JX; % J/d, assimilation rate at time t
  v = v * LM/ Lb;         % cm/d, conductance

  L2  = L * L; L3 = L2 * L; L4 = L3 * L;
  r   = (E * v/ L4 - p_M/ kap)/ (E/ L3 + E_G/ kap);
  pC = E * (v/ L - r);
  
  % generate derivatives
  dE_H  = ((1 - kap) * pC - k_J * E_H) * (E_H<E_Hp);
  dE_R =  ((1 - kap) * pC - k_J * E_H) * (E_H>=E_Hp);
  dN = kap_R * dE_R/ E_0; % #/d, cum reproductive output
  dE     = pA - pC;
  dL     = L * r/ 3;
  dLM  = dL * (E_H <= E_Hj);
  
  dLEHN = [dL; dE; dE_H; dN; dLM]; % pack output 

end