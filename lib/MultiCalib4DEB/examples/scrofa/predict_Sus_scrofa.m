function [prdData, info] = predict_Sus_scrofa(par, data, auxData)
  
  % unpack par, data, auxData
  cPar = parscomp_st(par); vars_pull(par); 
  vars_pull(cPar);  vars_pull(data);  vars_pull(auxData);

  if E_Hb >= E_Hx || E_Hx >= E_Hp || kap_X + kap_P > 1
      prdData = []; info = 0; return
  end
  
  % compute temperature correction factors
  TC = tempcorr(temp.tg, T_ref, T_A);
  
  % zero-variate data

  % life cycle
  pars_tx = [g k l_T v_Hb v_Hx v_Hp]; 
  [t_p, t_x, t_b, l_p, l_x, l_b, info] = get_tx(pars_tx, f);
  if info == 0
    prdData = []; return;
  end
 
  % birth
  L_b = L_m * l_b;                  % cm, structural length at birth at f
  Ww_b = L_b^3 * (1 + f * w);       % g, wet weight at birth at f 
  tT_g = t_0 + t_b/ k_M/ TC;        % d, gestation time at f and T

  % weaning
  L_x = L_m * l_x;                  % cm, structural length at weaning
  Ww_x = L_x^3 * (1 + f * w);       % g, wet weight at weaning
  tT_x = (t_x - t_b)/ k_M/ TC;      % d, time since birth at fledging at f and T
  
  % puberty 
  tT_p = (t_p - t_b)/ k_M/ TC;      % d, time since birth at puberty at f and T
 
  % ultimate
  L_i = L_m * f;
  
  % reproduction
  pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp]; % compose parameter vector at T
  RT_i = TC * reprod_rate_foetus(L_i, f, pars_R);         % #/d, ultimate reproduction rate at T

  % life span
  pars_tm = [g; l_T; h_a/ k_M^2; s_G];  % compose parameter vector at T_ref
  t_m = get_tm_s(pars_tm, f, l_b);      % -, scaled mean life span at T_ref
  aT_m = t_m/ k_M/ TC;                  % d, mean life span at T
  
  % males
  p_Am_m = z_m * p_M/ kap;             % J/d.cm^2, {p_Am} spec assimilation flux
  E_m_m = p_Am_m/ v;                   % J/cm^3, reserve capacity [E_m]
  g_m = E_G/ (kap* E_m_m);             % -, energy investment ratio
  m_Em_m = y_E_V * E_m_m/ E_G;         % mol/mol, reserve capacity 
  w_m = m_Em_m * w_E/ w_V;             % -, contribution of reserve to weight
  L_mm = v/ k_M/ g_m;                  % cm, max struct length
  pars_txm = [g_m k l_T v_Hb v_Hx v_Hp 1]; 
  [t_pm, t_xm, t_bm, l_pm, l_xm, l_bm] = get_tx(pars_txm, f);
  L_im = f * L_mm; L_bm = l_bm * L_mm; L_xm = l_xm * L_mm; % cm, structural lengths
  Ww_im = L_im^3 * (1 + f * w_m);      % g, ultimate wet weight
  
  % pack to output
  prdData.tg = tT_g;
  prdData.tx = tT_x;
  prdData.tp = tT_p;
  prdData.am = aT_m;
  prdData.Wwb = Ww_b;
  prdData.Wwx = Ww_x;
  prdData.Wwim = Ww_im;
  prdData.Ri = RT_i;
  
  % uni-variate data
  
  % t-Ww data
  f = f_tW; [t_p, t_x, t_b, l_p, l_x, l_b, info] = get_tx(pars_tx, f);
  if info == 0
    prdData = []; return;
  end
  L_b = l_b * L_m; L_i = f * L_m;
  ir_B = 3/ k_M + 3 * f * L_m/ v; rT_B = TC/ ir_B;  % d, 1/von Bert growth rate
  L = L_i - (L_i - L_b) * exp( - rT_B * tW_f(:,1)); % cm, struct length
  EWw_f = L.^3 * (1 + w * f)/ 1e3; % kg, total weight female
  % 
  [t_pm, t_xm, t_bm, l_pm, l_xm, l_bm] = get_tx(pars_txm, f);
  L_bm = l_bm * L_mm; L_im = f * L_mm;
  ir_B = 3/ k_M + 3 * f * L_m/ v; rT_B = TC/ ir_B; % d, 1/von Bert growth rate
  L = L_im - (L_im - L_bm) * exp( - rT_B * tW_m(:,1)); % cm, struct length
  EWw_m = L.^3 * (1 + f * w)/ 1e3; % kg, total weight male
  
  % pack to output
  prdData.tW_f = EWw_f;
  prdData.tW_m = EWw_m;
