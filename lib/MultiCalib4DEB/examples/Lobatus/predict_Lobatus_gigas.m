function [prdData, info] = predict_Lobatus_gigas(par, data, auxData)
  
  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);
  
  
  % compute temperature correction factors
  TC    = tempcorr(temp.am, T_ref, T_A);
  
  % zero-variate data

  % life cycle
  pars_tj = [g k l_T v_Hb v_Hj v_Hp];
  [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj(pars_tj, f);
    
  % birth
  L_b = L_m * l_b;                  % cm, structural length at birth
  Ww_b = L_b^3 * (1 + f * w);       % g, wet weight at birth
  aT_b = t_b/ k_M/ TC;              % d, age at birth
    
  % metam
  tT_j = (t_j - t_b)/ k_M/ TC;      % d, time since birth at metam
  L_j = L_m * l_j;                  % cm, structural length at metam at f
  
  % puberty 
  tT_p = (t_p - t_b)/ k_M/ TC;      % d, time since birth at puberty at f and T
  L_p = L_m * l_p;                  % cm, structural length at puberty at f
  Ww_p = L_p^3 * (1 + f * w);       % g, tissue wet weight at puberty

  % ultimate
  L_i = L_m * l_i;                  % cm, ultimate structural length at f
  Ww_i = L_i^3 * (1 + f * w);       % g, ultimate tissue wet weight
  
  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC;                  % d, mean life span at T
      
  % sreproduction
  pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp]; % compose parameter vector at T
  RT_i = TC *  reprod_rate_j(L_i, f, pars_R); % #/d, max reproduction rate

  % pack to output
  prdData.ab = aT_b;
  prdData.tj = tT_j;
  prdData.tp = tT_p;
  prdData.am = aT_m;
  prdData.Wwb = Ww_b;
  prdData.Wwp = Ww_p;
  prdData.Wwi = Ww_i;
  prdData.Ri = RT_i;
  
  % uni-variate data
    

  % time-weight
  rT_B = TC * k_M * rho_B; % 1/d, von Bert growth rate
  L = L_i - (L_i - L_p) * exp( - rT_B * tW_f(:,1)); % cm, structural length at time
  EWw_f = L.^3 * (1 + f * w); % g, wet tissue weight
  L = L_i - (L_i - L_p) * exp( - rT_B * tW_m(:,1)); % cm, structural length at time
  EWw_m = L.^3 * (1 + f * w); % g, wet tissue weight
  
  
  % pack to output
  prdData.tW_f = EWw_f;
  prdData.tW_m = EWw_m;
  
  
