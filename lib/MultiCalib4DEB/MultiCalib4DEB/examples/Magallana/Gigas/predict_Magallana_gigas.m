function [prdData, info] = predict_Magallana_gigas(par, data, auxData)
  
global tN2 tN3 tN4 tN5 tN6 tN7 % d,cells/dm^3
% these tX data for tL, tWw and tJX are global, because, if passed as auxiliary, no in-between times are plotted and errors result 

  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);
  
  % compute temperature correction factors
  TC_ab = tempcorr(temp.ab, T_ref, T_A);
  TC_tj = tempcorr(temp.tj, T_ref, T_A);
  TC_tp = tempcorr(temp.tp, T_ref, T_A);
  TC_am = tempcorr(temp.am, T_ref, T_A);
  TC_Ri = tempcorr(temp.Ri, T_ref, T_A);
  TC_GSI = tempcorr(temp.GSI, T_ref, T_A);
  TC_BAC = tempcorr(temp.tL2, T_ref, T_A);
  TC_17 = tempcorr(temp.tL_T17, T_ref, T_A);
  TC_22 = tempcorr(temp.tL_T22, T_ref, T_A);
  TC_25 = tempcorr(temp.tL_T25, T_ref, T_A);
  TC_27 = tempcorr(temp.tL_T27, T_ref, T_A);
  TC_32 = tempcorr(temp.tL_T32, T_ref, T_A);  
  TC_CollBoud1999 = tempcorr(temp.tL_CollBoud1999, T_ref, T_A);
  TC_f = tempcorr(temp.tL_f010, T_ref, T_A);  
  TC_18 = tempcorr(temp.tWw_T18_Mark2011, T_ref, T_A);
  TC_28 = tempcorr(temp.tWw_T28_Mark2011, T_ref, T_A);
  TC_FabiHuve2005 = tempcorr(temp.tWw_FabiHuve2005, T_ref, T_A);
  TC_GoulWolo2004 = tempcorr(temp.LJO_GoulWolo2004, T_ref, T_A);
  
  % zero-variate data

  % life cycle
  pars_ts = [g k l_T v_Hb v_Hs v_Hj v_Hp];
  [t_s, t_j, t_p, t_b, l_s, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_ts(pars_ts, f);
    
  % birth
  L_b = L_m * l_b;                  % cm, structural length at birth at f
  Lw_b = L_b/ del_Mb;               % cm, total length at birth at f
  Wd_b = L_b^3 *d_V * (1 + f * w);  % g, dry weight at birth
  aT_b = t_b/ k_M/ TC_ab;           % d, age at birth at f and T

  % start acceleration
  L_s = L_m * l_s;                  % cm, structural length at start acceleration
  %Lw_s = L_s/ del_Mb;               % cm, shell length at start acceleration
  
  % metam (= end acceleration)
  L_j = L_m * l_j;                  % cm, structural length at metam
  Lw_j = L_j/ del_Mj;                % cm, total length at metam at f
  Wd_j = L_j^3 * d_V * (1 + f * w); % g, dry weight at metam
  tT_j = (t_j - t_b)/ k_M/ TC_tj;   % d, time since birth at metam
  s_M = L_j/ L_s;                   % -, acceleration factor
  
  % puberty 
  L_p = L_m * l_p;                  % cm, structural length at puberty at f
  Lw_p = L_p/ del_Mj;               % cm, total length at puberty at f
  Ww_p = L_p^3 *(1 + f * w);        % g, wet weight at puberty 
  tT_p = (t_p - t_b)/ k_M/ TC_tp;   % d, time since birth at puberty at f and T

  % ultimate
  L_i = L_m * l_i;                  % cm, ultimate structural length at f
  Lw_i = L_i/ del_Mj;               % cm, ultimate total length at f
  Ww_i = L_i^3 * (1 + f * w);       % g, ultimate wet weight 
 
  % reproduction
  pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hs; U_Hj; U_Hp]; % compose parameter vector at T
  RT_i = TC_Ri * reprod_rate_s(L_i, f, pars_R);                 % #/d, ultimate reproduction rate at T

  % max gonado-somatic index of fully grown individual that spawns once per year see (4.89) of DEB3
  GSI = 365 * k_M * g/ f^3/ (f + kap * g * y_V_E);
  GSI = TC_GSI * GSI * ((1 - kap) * f^3 - k_J * U_Hp/ L_m^2/ s_M^2); % mol E_R/ mol W

  % half saturation constant
  K_V = 6e-3 * K * V_X/ M_X;            % µm3/ dm^3, half saturation coefficient

  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC_am;               % d, mean life span at T
  
  % pack to output
  prdData.ab = aT_b;
  prdData.tj = tT_j;
  prdData.tp = tT_p;
  prdData.am = aT_m;
  prdData.Lb = Lw_b;
  prdData.Lj = Lw_j;
  prdData.Lp = Lw_p;
  prdData.Li = Lw_i;
  prdData.Wdb = Wd_b;
  prdData.Wdj = Wd_j;
  prdData.Wwp = Ww_p;
  prdData.Wwi = Ww_i;
  prdData.Ri = RT_i;
  prdData.GSI = GSI;
  prdData.KV = K_V;
  
  % uni-variate data
  
 % tLi, tWwi tWdi in BAC2-BAC7 for adults
 vT = v * TC_BAC * s_M; kJ_EHp = k_J * E_Hp; kTJ_EHp = TC_BAC * kJ_EHp; L_m_j = L_m * s_M;
 %
 tX2 = [tN2(:,1), tN2(:,2) * E_X/ mu_X]; % mol/dm^3, algal density for BAC2 
 [t eLR] = ode45(@dget_eLR, tL2(:,1), [e_0; L_0; 0], [], K, vT, L_T, L_m_j, g, kap, E_m, kTJ_EHp, tX2);
 e = eLR(:,1); L2 = eLR(:,2); E_R = eLR(:,3);
 ELw_2 = L2/ del_Mj; % cm, physical length in BAC2
 EWw_2 = L2.^3 .* (1 + e * w) + E_R * w_E/ mu_E/ d_E; 
 EWd_2 = d_V * EWw_2; % g, wet and dry weight in BAC2
 EWw_2 = s_H * EWw_2; % correct for lack of body fluids
 %
 tX3 = [tN3(:,1), tN3(:,2) * E_X/ mu_X]; % mol/dm^3, algal density for BAC3 
 [t eLR] = ode45(@dget_eLR, tL3(:,1), [e_0; L_0; 0], [], K, vT, L_T, L_m_j, g, kap, E_m, kTJ_EHp, tX3);
 e = eLR(:,1); L3 = eLR(:,2); E_R = eLR(:,3);
 ELw_3 = L3/ del_Mj;  % cm, physical length in BAC3
 EWw_3 = L3.^3 .* (1 + e * w) + E_R * w_E/ mu_E/ d_E; 
 EWd_3 = d_V * EWw_3; % g, wet and dry weight in BAC3
 EWw_3 = s_H * EWw_3; % correct for lack of body fluids
 %
 tX4 = [tN4(:,1), tN4(:,2) * E_X/ mu_X]; % mol/dm^3, algal density for BAC4 
 [t eLR] = ode45(@dget_eLR, tL4(:,1), [e_0; L_0; 0], [], K, vT, L_T, L_m_j, g, kap, E_m, kTJ_EHp, tX4);
 e = eLR(:,1); L4 = eLR(:,2); E_R = eLR(:,3);
 ELw_4 = L4/ del_Mj;  % cm, physical length in BAC4
 EWw_4 = L4.^3 .* (1 + e * w) + E_R * w_E/ mu_E/ d_E; 
 EWd_4 = d_V * EWw_4; % g, wet and dry weight in BAC4
 EWw_4 = s_H * EWw_4; % correct for lack of body fluids
 %
 tX5 = [tN5(:,1), tN5(:,2) * E_X/ mu_X]; % mol/dm^3, algal density for BAC5 
 [t eLR] = ode45(@dget_eLR, tL5(:,1), [e_0; L_0; 0], [], K, vT, L_T, L_m_j, g, kap, E_m, kTJ_EHp, tX5);
 e = eLR(:,1); L5 = eLR(:,2); E_R = eLR(:,3);
 ELw_5 = L5/ del_Mj;  % cm, physical length in BAC5
 EWw_5 = L5.^3 .* (1 + e * w) + E_R * w_E/ mu_E/ d_E; 
 EWd_5 = d_V * EWw_5;  % g, wet and dry weight in BAC5
 EWw_5 = s_H * EWw_5; % correct for lack of body fluids
 %
 tX6 = [tN6(:,1), tN6(:,2) * E_X/ mu_X]; % mol/dm^3, algal density for BAC6 
 [t eLR] = ode45(@dget_eLR, tL6(:,1), [e_0; L_0; 0], [], K, vT, L_T, L_m_j, g, kap, E_m, kTJ_EHp, tX6);
 e = eLR(:,1); L6 = eLR(:,2); E_R = eLR(:,3);
 ELw_6 = L6/ del_Mj;  % cm, physical length in BAC6
 EWw_6 = L6.^3 .* (1 + e * w) + E_R * w_E/ mu_E/ d_E; 
 EWd_6 = d_V * EWw_6; % g, wet and dry weight in BAC6
 EWw_6 = s_H * EWw_6; % correct for lack of body fluids
 %
 tX7 = [tN7(:,1), tN7(:,2) * E_X/ mu_X]; % mol/dm^3, algal density for BAC7 
 [t eLR] = ode45(@dget_eLR, tL7(:,1), [e_0; L_0; 0], [], K, vT, L_T, L_m_j, g, kap, E_m, kTJ_EHp, tX7);
 e = eLR(:,1); L7 = eLR(:,2); E_R = eLR(:,3);
 ELw_7 = L7/ del_Mj;  % cm, physical length in BAC7
 EWw_7 = L7.^3 .* (1 + e * w) + E_R * w_E/ mu_E/ d_E; 
 EWd_7 = d_V * EWw_7; % g, wet and dry weight in BAC7
 EWw_7 = s_H * EWw_7; % correct for lack of body fluids

 % ingestion rates
 pT_Xm_j = TC_BAC * p_Xm * s_M; % J/d.cm^2, {p_Xm} after metamorphosis
 X2 = spline1(tJX2(:,1), tX2); f2 = X2 ./ (K + X2); L2_pX = spline1(tJX2(:,1), [tL2(:,1), L2]);
 EJT_X2 = L2_pX .^ 2 .* f2 * pT_Xm_j/ E_X/ 24; % #/h, feeding rate per individual
 %
 X3 = spline1(tJX3(:,1), tX3); f3 = X3 ./ (K + X3); L3_pX = spline1(tJX3(:,1), [tL3(:,1), L3]);
 EJT_X3 = L3_pX .^ 2 .* f3 * pT_Xm_j/ E_X/ 24; % #/h, feeding rate per individual
 %
 X4 = spline1(tJX4(:,1), tX4); f4 = X4 ./ (K + X4); L4_pX = spline1(tJX4(:,1), [tL4(:,1), L4]);
 EJT_X4 = L4_pX .^ 2 .* f4 * pT_Xm_j/ E_X/ 24; % #/h, feeding rate per individual
 %
 X5 = spline1(tJX5(:,1), tX5); f5 = X5 ./ (K + X5); L5_pX = spline1(tJX5(:,1), [tL5(:,1), L5]);
 EJT_X5 = L5_pX .^ 2 .* f5 * pT_Xm_j/ E_X/ 24; % #/h, feeding rate per individual
 %
 X6 = spline1(tJX6(:,1), tX6); f6 = X6 ./ (K + X6); L6_pX = spline1(tJX6(:,1), [tL6(:,1), L6]);
 EJT_X6 = L6_pX .^ 2 .* f6 * pT_Xm_j/ E_X/ 24; % #/h, feeding rate per individual
 %
 X7 = spline1(tJX7(:,1), tX7); f7 = X7 ./ (K + X7); L7_pX = spline1(tJX7(:,1), [tL7(:,1), L7]);
 EJT_X7 = L7_pX .^ 2 .* f7 * pT_Xm_j/ E_X/ 24; % #/h, feeding rate per individual

 % clearance rates
 EFT_2 = EJT_X2 ./ X2 * E_X/ mu_X; % dm^3/h
 EFT_3 = EJT_X3 ./ X3 * E_X/ mu_X; % dm^3/h
 EFT_4 = EJT_X4 ./ X4 * E_X/ mu_X; % dm^3/h
 EFT_5 = EJT_X5 ./ X5 * E_X/ mu_X; % dm^3/h
 EFT_6 = EJT_X6 ./ X6 * E_X/ mu_X; % dm^3/h
 EFT_7 = EJT_X7 ./ X7 * E_X/ mu_X; % dm^3/h
 
 % CollBoud1999-data on tL of embryo/larva
 UE0 = get_ue0([g, k, v_Hb], 1) * v^2/ g^2/ k_M^3;
 vT = v * TC_CollBoud1999; kT_J = k_J * TC_CollBoud1999; UTE0 = UE0/ TC_CollBoud1999;
 [a LUH] = ode45(@dget_LUH_bs, tL_CollBoud1999(:,1), [1e-8; UTE0; 0], [], kap, vT, kT_J, g, L_m, f_Rico, L_b, L_s, L_j);
 ELw_CollBoud1999 = 1e4 * LUH(:,1)/ del_Mb; % µm, physical length

 % RicoPouv2009: larval growth at different temperatures before start V1-morphy
 % till a = 2 d at 25 C
 [t_s t_j t_p t_b l_s l_j l_p l_b l_i r_j r_B] = get_ts(pars_ts, f_Rico);
 L_b = l_b * L_m; L_s = l_s * L_m; L_j = l_j * L_m;
 %
 vT = v * TC_17; kT_J = k_J * TC_17; UTE0 = UE0/ TC_17;
 [a LUH] = ode45(@dget_LUH_bs, tL_T17(:,1), [1e-8; UTE0; 0], [], kap, vT, kT_J, g, L_m, f_Rico, L_b, L_s, L_j);
 ELw_17 = 1e4 * LUH(:,1)/ del_Mb; % µm, physical length
 %
 vT = v * TC_22; kT_J = k_J * TC_22; UTE0 = UE0/ TC_22;
 [a LUH] = ode45(@dget_LUH_bs, tL_T22(:,1), [1e-8; UTE0; 0], [], kap, vT, kT_J, g, L_m, f_Rico, L_b, L_s, L_j);
 ELw_22 = 1e4 * LUH(:,1)/ del_Mb; % µm, physical length
 %
 vT = v * TC_25; kT_J = k_J * TC_25; UTE0 = UE0/ TC_25;
 [a LUH] = ode45(@dget_LUH_bs, tL_T25(:,1), [1e-8; UTE0; 0], [], kap, vT, kT_J, g, L_m, f_Rico, L_b, L_s, L_j);
 ELw_25 = 1e4 * LUH(:,1)/ del_Mb; % µm, physical length
 %
 vT = v * TC_27; kT_J = k_J * TC_27; UTE0 = UE0/ TC_27;
 [a LUH] = ode45(@dget_LUH_bs, tL_T27(:,1), [1e-8; UTE0; 0], [], kap, vT, kT_J, g, L_m, f_Rico, L_b, L_s, L_j);
 ELw_27 = 1e4 * LUH(:,1)/ del_Mb; % µm, physical length
 %
 vT = v * TC_32; kT_J = k_J * TC_32; UTE0 = UE0/ TC_32;
 [a LUH] = ode45(@dget_LUH_bs, tL_T32(:,1), [1e-8; UTE0; 0], [], kap, vT, kT_J, g, L_m, f_Rico, L_b, L_s, L_j);
 ELw_32 = 1e4 * LUH(:,1)/ del_Mb; % µm, physical length
 %
 % Rico2010: growth at different food densities
 % assume instantaneus adaptation of e and before start of acceleration
 L_2d = L_2d * del_Mb; % cm, convert shell to structural length
 %
 f = 0.010; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f010(:,1) - 2));
 ELw_f010 = 1e4 * L/ del_Mb; % µm, physical length
 %
 f = 0.017; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f017(:,1) - 2));
 ELw_f017 = 1e4 * L/ del_Mb; % µm, physical length
 %
 f = 0.36; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f360(:,1) - 2));
 ELw_f360 = 1e4 * L/ del_Mb; % µm, physical length
 %
 f = 0.710; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f710(:,1) - 2));
 ELw_f710 = 1e4 * L/ del_Mb; % µm, physical length
 %
 f = 0.730; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f730(:,1) - 2));
 ELw_f730 = 1e4 * L/ del_Mb; % µm, physical length
 %
 f = 0.900; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f900(:,1) - 2));
 ELw_f900 = 1e4 * L/ del_Mb; % µm, physical length
 %
 f = 0.920; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f920(:,1) - 2));
 ELw_f920 = 1e4 * L/ del_Mb; % µm, physical length
 %
 f = 0.960; rT_B = TC_f * k_M/ 3/ (1 + f/ g); L_i = f * L_m;
 L = L_i - (L_i - L_2d) * exp( - rT_B * (tL_f960(:,1) - 2));
 ELw_f960 = 1e4 * L/ del_Mb; % µm, physical length

 % Mark2011-data
 % juvenile growth: age 25 d at start at 25 C (post metamorphosis); f = 1
 % wet weights include the shell !!
 [t_s t_j t_p t_b l_s l_j l_p l_b l_i rho_j rho_B] = get_ts(pars_ts, f_Mark); 
 r_B = k_M * rho_B; % 1/d, von Bert growth rate
 L_b = l_b * L_m; L_s = l_s * L_m; L_j = l_j * L_m; L_i = l_i * L_m;
 % growth at different temperatures
 L = L_i - (L_i - L_25d) * exp(- tWw_T18_Mark2011(:,1) * r_B * TC_18); 
 EWw_18_Mark2011 = 1e3 * L.^3 * (1 + del_sh + w); % mg, wet weight at 18 C
 L = L_i - (L_i - L_25d) * exp(- tL_T18_Mark2011(:,1) * r_B * TC_18); 
 ELw_18_Mark2011 = 10 * L/ del_Mj; % mm, length at 18 C
 %
 L = L_i - (L_i - L_25d) * exp(- tWw_T22_Mark2011(:,1) * r_B * TC_22); 
 EWw_22_Mark2011 = 1e3 * L.^3 * (1 + del_sh + w); % mg, wet weight at 22 C
 L = L_i - (L_i - L_25d) * exp(- tL_T22_Mark2011(:,1) * r_B * TC_22); 
 ELw_22_Mark2011 = 10 * L/ del_Mj; % mm, length at 22 C
 %
 L = L_i - (L_i - L_25d) * exp(- tWw_T25_Mark2011(:,1) * r_B * TC_25); 
 EWw_25_Mark2011 = 1e3 * L.^3 * (1 + del_sh + w); % mg, wet weight at 25 C
 L = L_i - (L_i - L_25d) * exp(- tL_T25_Mark2011(:,1) * r_B * TC_25); 
 ELw_25_Mark2011 = 10 * L/ del_Mj; % mm, length at 25 C
 %
 L = L_i - (L_i - L_25d) * exp(- tWw_T28_Mark2011(:,1) * r_B * TC_28); 
 EWw_28_Mark2011 = 1e3 * L.^3 * (1 + del_sh + w); % mg, wet weight at 28 C
 L = L_i - (L_i - L_25d) * exp(- tL_T28_Mark2011(:,1) * r_B * TC_28); 
 ELw_28_Mark2011 = 10 * L/ del_Mj; % mm, length at 28 C

 %% FabiHuve2005-data on Ww, WwR and L as functions of time
 f = f_Fabi; L = L_Fabi * del_Mj;
 tX = tWw_FabiHuve2005(:,[1 1]); tX(:,2) = 1; K = 1/ f - 1; % algal density & sat coeff for FabiHuve2005
 vT = v * TC_FabiHuve2005; kTJ_EHp = TC_FabiHuve2005 * kJ_EHp; 
 [t eLR] = ode45(@dget_eLR, tWw_FabiHuve2005(:,1) - 15, [f; L; 0], [], K, vT, L_T, L_m_j, g, kap, E_m, kTJ_EHp, tX);
 e = eLR(:,1); L = eLR(:,2); E_R = eLR(:,3);
 ELw_FabiHuve2005 = L/ del_Mj;                           % cm, physical length for Fabi2005
 EWw_R_FabiHuve2005 = E_R * w_E/ mu_E/ d_E;              % g, gonad weight for Fabi2005
 EWw_FabiHuve2005 = L.^3 .* (1 + del_sh + e * w) + EWw_R_FabiHuve2005; % g, wet weight for Fabi2005
 
 %% GoulWolo2004-data on LJO and LWd
 vT = v * TC_GoulWolo2004; kT_J = k_J * TC_GoulWolo2004; UTE0 = UE0/ TC_GoulWolo2004;
 [L UH] = ode45(@dget_UH_bs, 1e-4 * LJO_GoulWolo2004(:,1) * del_Mb, [UTE0; 0], [], kap, vT, kT_J, g, L_m, f_Goul, L_b, L_s, L_j);
 e = J_E_Am * UH(:,1) ./ (L.^3 * M_V)/ m_Em; l = L/ L_m;
 EWd_GoulWolo2004 = 1e6 * L.^3 * d_V .* (1 + e * w);               % mg, dry weight
 pA = 0 * (UH(:,2) > U_Hb) .* l .^ 2;                              % -, scaled assimilation power: excluded
 pD = kap * l .^3  + (1 - kap) * e .* l .^2 .* (g + l) ./ (g + e); % -, scaled dissapating power (page 78 DEB book)
 pG = kap * l.^2.* (e - l)./(1 + e/g);                             % -, scaled growth power (page 78 DEB book)
 p_ref = L_m^2 * p_Am;                                             % J/d, reference power
 JM = - (n_M\n_O) * eta_O * p_ref * [pA'; pD'; pG'];               % mol/d, mineral fluxes
 EJT_O_GoulWolo2004 = - TC_GoulWolo2004 * 24.4e9/ 24 * JM(3,:)';   % nL/h, O2-consumption
  
  % pack to output
  prdData.tL2 = ELw_2;
  prdData.tL3 = ELw_3;
  prdData.tL4 = ELw_4;
  prdData.tL5 = ELw_5;
  prdData.tL6 = ELw_6;
  prdData.tL7 = ELw_7;
  prdData.tWw2 = EWw_2;
  prdData.tWw3 = EWw_3;
  prdData.tWw4 = EWw_4;
  prdData.tWw5 = EWw_5;
  prdData.tWw6 = EWw_6;
  prdData.tWw7 = EWw_7;
  prdData.tWd2 = EWd_2;
  prdData.tWd3 = EWd_3;
  prdData.tWd4 = EWd_4;
  prdData.tWd5 = EWd_5;
  prdData.tWd6 = EWd_6;
  prdData.tWd7 = EWd_7;
  prdData.tJX2 = EJT_X2;
  prdData.tJX3 = EJT_X3;
  prdData.tJX4 = EJT_X4;
  prdData.tJX5 = EJT_X5;
  prdData.tJX6 = EJT_X6;
  prdData.tJX7 = EJT_X7;
  prdData.tF2 = EFT_2;
  prdData.tF3 = EFT_3;
  prdData.tF4 = EFT_4;
  prdData.tF5 = EFT_5;
  prdData.tF6 = EFT_6;
  prdData.tF7 = EFT_7;
  prdData.tL_T32 = ELw_32;
  prdData.tL_T27 = ELw_27;
  prdData.tL_T25 = ELw_25;
  prdData.tL_CollBoud1999 = ELw_CollBoud1999;
  prdData.tL_T22 = ELw_22;
  prdData.tL_T17 = ELw_17;
  prdData.tL_f960 = ELw_f960;
  prdData.tL_f920 = ELw_f920;
  prdData.tL_f900 = ELw_f900;
  prdData.tL_f730 = ELw_f730;
  prdData.tL_f710 = ELw_f710;
  prdData.tL_f360 = ELw_f360;
  prdData.tL_f017 = ELw_f017;
  prdData.tL_f010 = ELw_f010;
  prdData.tL_T28_Mark2011 = ELw_28_Mark2011;
  prdData.tL_T25_Mark2011 = ELw_25_Mark2011;
  prdData.tL_T22_Mark2011 = ELw_22_Mark2011;
  prdData.tL_T18_Mark2011 = ELw_18_Mark2011;
  prdData.tWw_T28_Mark2011 = EWw_28_Mark2011;
  prdData.tWw_T25_Mark2011 = EWw_25_Mark2011;
  prdData.tWw_T22_Mark2011 = EWw_22_Mark2011;
  prdData.tWw_T18_Mark2011 = EWw_18_Mark2011;
  prdData.tWw_FabiHuve2005 = EWw_FabiHuve2005;
  prdData.tL_FabiHuve2005 = ELw_FabiHuve2005;
  prdData.tWwR_FabiHuve2005 = EWw_R_FabiHuve2005;
  prdData.LWd_GoulWolo2004 = EWd_GoulWolo2004;
  prdData.LJO_GoulWolo2004 = EJT_O_GoulWolo2004;

end

% %% subfunctions

function deL = dget_eLR(t, eLR, K, v, L_T, L_m, g, kap, E_m, kJ_EHp, tX)
 
  ee = eLR(1); L = eLR(2); ER = eLR(3); % unpack variables
  r = v * (ee/L - (1 + L_T/ L)/ L_m)/ (ee + g); % 1/d, spec growth rate
  p_C = (v/ L - r) * ee * E_m * L^3;
  X = spline1(t, tX); % -, food density at t
  f = X/(K + X);
  de = (f - ee) * v/ L; % 1/d, change in scaled reserve density e
  dL = L * r/ 3; % cm/d, change in structural length L
  dER = (1 - kap) * p_C - kJ_EHp; % J/d, change in reproduction buffer
  deL = [de; dL; dER]; % pack output
  
end

function dLUH = dget_LUH_bs(a, LUH, kap, v, kJ, g, Lm, f, Lb, Ls, Lj)
  % dLUH = dget_LUH_bs(a, LUH, kap, v, kJ, g, Lm, f, Lb, Ls, Lj)
  % a: scalar with age
  % LUH: 3-vector with (L, U= M_E/{J_EAm}, H = M_H/{J_EAm}) of embryo
  % dLUH: 3-vector with (dL/da, dU/da, dH/da)
  
  L = LUH(1); % structural length
  U = LUH(2); % scaled reserve M_E/{J_EAm}
  H = LUH(3); % scaled maturity M_H/{J_EAm}
  
  L_m_j = Lm * Lj/ Ls;
  s = min(Lj/ Ls, max(1, L/ Ls)); % -, shape corr
  e = s * v * U/ L^3; % -, scaled reserve density
  r = s * v * (e/ L - 1/L_m_j)/ (e + g); % 1/d, spec growth rate
  SC = U * (s * v/ L - r); % d.cm^2, scaled mobilisation
  
  % generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * SC - kJ * H;
  dU = (L > Lb) * s * f * L^2 - SC;
  dL = r * L/3;
  
  % pack dL/da, dU/da, dH/da, 
  dLUH = [dL; dU; dH];
end
  
function dUH = dget_UH_bs(L, UH, kap, v, kJ, g, Lm, f, Lb, Ls, Lj)
  % dUH = dget_UH_bs(L, UH, kap, v, kJ, g, Lm, f, Lb, Ls, Lj)
  % L: scalar with length
  % UH: 2-vector with (U= M_E/{J_EAm}, H = M_H/{J_EAm}) of embryo
  % dUH: 2-vector with (dU/dL, dH/dL)
  
  U = UH(1); % scaled reserve M_E/{J_EAm}
  H = UH(2); % scaled maturity M_H/{J_EAm}
  
  L_m_j = Lm * Lj/ Ls;
  s = min(Lj/ Ls, max(1, L/ Ls)); % -, shape corr
  e = s * v * U/ L^3; % -, scaled reserve density
  r = s * v * (e/ L - 1/L_m_j)/ (e + g); % 1/d, spec growth rate
  SC = U * (s * v/ L - r); % d.cm^2, scaled mobilisation
  
  % generate dH/dt, dE/dt, dL/dt
  dH = (1 - kap) * SC - kJ * H;
  dU = (L > Lb) * s * f * L^2 - SC;
  dL = r * L/3;
  
  % pack dU/dL, dH/dL, 
  dUH = [dU; dH]/ dL;
    
end