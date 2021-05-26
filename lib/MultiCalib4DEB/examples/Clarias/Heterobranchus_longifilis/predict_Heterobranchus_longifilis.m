function [prdData, info] = predict_Heterobranchus_longifilis(par, data, auxData)
  
  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);
      
  % compute temperature correction factors
  TC_25 = tempcorr(temp.ab25, T_ref, T_A);
  TC_33 = tempcorr(temp.ab33, T_ref, T_A);
  TC = tempcorr(temp.am, T_ref, T_A);
    
  % zero-variate data

  % life cycle
  pars_tj = [g k l_T v_Hb v_Hj v_Hp];
  [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj(pars_tj, f);
    
  % birth
  L_b = L_m * l_b;                  % cm, structural length at birth at f
  a25_b = t_b/ k_M/ TC_25;          % d, age at birth at f and T
  a33_b = t_b/ k_M/ TC_33;          % d, age at birth at f and T
  Ww_b = L_b^3 * (1 + f * w);       % g, wet weight at birth
    
  % metam
  s_M = l_j/ l_b;                   % -, acceleration factor

  % puberty 
  L_p = L_m * l_p;                  % cm, structural length at puberty at f
  Ww_p = L_p^3 * (1 + f * f_tW);    % g, wet weight at puberty at t_tW

  % ultimate
  L_i = L_m * l_i;                  % cm, ultimate structural length at f
  Lw_i = L_i/ del_M;                % cm, ultimate total length at f
  Ww_i = L_i^3 * (1 + f * w);       % g, ultimate wet weight 
   
  % reproduction
  GSI = TC * 365 * k_M * g/ f^3/ (f + kap * g * y_V_E);
  GSI = GSI * ((1 - kap) * f^3 - k_M^2 * g^2 * k_J * U_Hp/ v^2/ s_M^3); % mol E_R/ mol W
  
  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC;               % d, mean life span at T
  
  % pack to output
  prdData.ab25 = a25_b;
  prdData.ab33 = a33_b;
  prdData.am = aT_m;
  prdData.Li = Lw_i;
  prdData.Wwb = Ww_b;
  prdData.Wwp = Ww_p;
  prdData.Wwi = Ww_i;
  prdData.GSI = GSI;
  
  %% uni-variate data

  % time-weight after
  [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B] = get_tj(pars_tj, f_tW);
  kT_M = k_M * TC; rT_j = rho_j * kT_M; rT_B = rho_B * kT_M; tT_j = (t_j - t_b)/ kT_M;  
  L_b = l_b * L_m;  L_j = l_j * L_m; L_i = l_i * L_m; % cmstruc length
  L_bj = L_b * exp(rT_j * tW(tW(:,1) < tT_j,1)/ 3); % cm, struc length 
  L_ji = L_i - (L_i - L_j) * exp( - rT_B * (tW(tW(:,1) >= tT_j,1)- tT_j)); % cm, struc length 
  EWw = [L_bj; L_ji].^3 * (1 + f_tW * w); % g, wet weight

  %% pack to output
  prdData.tW = EWw;
