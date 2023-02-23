%% statistics_st
% Computes implied properties of DEB models 

%%
function [stat, txtStat] = statistics_st(model, par, T, f) 
% created 2000/11/02 by Bas Kooijman, modified 2014/03/17 
% modified 2015/03/25 by Starrlight Augustine & Goncalo Marques, 
% modified 2015/07/27 by Starrlight; 2015/08/06 by Dina Lika
% modified 2016/03/25 by Dina Lika & Goncalo Marques
% modified 2016/04/14 by Bas Kooijman, 2016/09/21 by Starrlight, 
% modified 2016/09/22, 2017/01/05, 2017/10/17, 2017/11/20 by Bas Kooijman
% modified 2018/08/18, 2018/08/22, 2019/04/25, 2021/10/05, 2021/10/24, 2022/01/31, 2023/02/23 by Bas Kooijman

%% Syntax
% [stat, txtStat] = <statistics_st.m *statistics_st*>(model, par, T, f)

%% Description
% Computes quantities that depend on parameters, temperature and food level.
% The allowed models are: std, stf, stx, ssj, sbp, abj, asj, abp, hep, hax, hex.
%
% Input
%
% * model: string with name of model
% * par :  structure with primary parameters at reference temperature in time-length-energy frame
% * T:     optional scalar with temperature in Kelvin; default C2K(20)
% * f:     optional scalar scaled functional response; default 1
% 
% Output
% 
% * stat: structure with statistics (see under remarks) with fields, labels and models 
%
%     - f: scaled function response (set by input); all
%     - T: absolute temperature (set by input); all
%     - TC: temperature correction factor; all
%
%     - w_X, w_E, w_V, w_P: molecular weights; all
%
%     - p_Am: specific max assimilation flux; all
%     - L_m: maximum structural length; all 
%     - k_M: maintenance rate coefficient; all
%     - k: maintenance ratio; all
%     - j_E_M, j_E_J, J_E_M, J_E_T: (mass-spec) somatic/maturity maint costs; all
%     - l_T, L_T: (scaled) heating length; all
%     - E_m, m_Em: reserve capacity; all
%     - E_V: volume-specific energy of structure; all
%     - M_V: volume-specific mass of structure; all
%     - w: contribution of ash free dry mass of reserve to total ash free dry biomass; all
%     - g: energy investment ratio; all
%     - y_E_X, y_X_E: yield of food on reserve; all if kap_X exists
%     - y_V_E, y_E_V, yield of structure on reserve; all
%     - p_Xm: max spec feeding power; all if kap_P exists
%     - J_X_Am: max surface-spec feeding flux; all if kap_X exists
%     - y_P_X, y_X_P: yield of food on faeces; all if kap_P exists
%     - y_P_E: yield of faeces on reserve; all if kap_P and kap_P exist
%     - eta_XA, eta_PA, eta_VG: mass-power couplers for organics; all if kap_P and kap_P exist
%     - kap_G: growth efficiency; all
%     - t_E: maximum reserve residence time; all
%
%     - s_M, sM_min: acceleration factor; but sM_min not for hex
%     - s_s: supply stress; all
%     - s_Hbp: maturity ratio; all
%     - s_HLbp: maturity density ratio; all
%     - r_j: exponential growth rate; all a- and h-models
%     - r_B: von Bertalannfy growth rate; all s- and a-models
%     - : wet weight at max growth; all models
%     - dWm: max growth in wet weight; all models
%
%     - E_H*, U_H*, V_H*, u_H*, v_H* scaled maturities at all levels; all
%     - E_0: energy investment in egg/foetus; all
%     - M_E0: reserve invested in egg/foetus; all
%     - Ww_0: initial wet weight; all except stf, stx
%     - Wd_0: initial dry weight; all except stf, stx
%
%     - a_h: age at hatch; all if E_Hh exists
%     - L_h: structural length at hatch; all if E_Hh exists
%     - M_Vh: structural mass at hatch; all if E_Hh exists
%     - M_Eh: reserve mass at hatch; all if E_Hh exists
%     - Ww_h: wet weight at hatch; all if E_Hh exists
%     - Wd_h: dry weight at hatch; all if E_Hh exists
%     - E_Wh: energy content at hatch; all if E_Hh exists
%     - del_Uh: fraction of reserve left at hatch; all if E_Hh exists
%
%     - a_b: age at birth; all (called gestation for stf and stx)
%     - t_g: gestation time; stf, stx
%     - L_b: structural length at birth; all
%     - M_Vb: structural mass at birth; all
%     - M_Eb: reserve mass at birth; all
%     - Ww_b: wet weight at birth; all
%     - Wd_b: dry weight at birth; all
%     - E_Wb: energy content at birth; all
%     - del_Ub: fraction of reserve left at birth; all
%     - g_Hb: energy divestment ratio at birth; all
%
%     - a_x: age at weaning/fledge; std, stx
%     - t_x: gestation time; std, stx
%     - L_x: structural length at weaning/fledge; std, stx
%     - M_Vx: structural mass at weaning/fledge; std, stx
%     - M_Ex: reserve mass at weaning/fledge; std, stx
%     - Ww_x: wet weight at weaning/fledge; std, stx
%     - Wd_x: dry weight at weaning/fledge; std, stx
%     - E_Wx: energy content at weaning/fledge; std, stx
%
%     - a_p: age at puberty; all
%     - L_p: structural length at puberty; all
%     - M_Vp: structural mass at puberty; all
%     - M_Ep: reserve mass at puberty; all
%     - Ww_p: wet weight at puberty; all
%     - Wd_p: dry weight at puberty; all
%     - E_Wp: energy content at puberty; all
%     - g_Hp: energy divestment ratio at puberty; all
%
%     - L_i: ultimate structural length; all 
%     - M_Vi: ultimate structural mass; all
%     - M_Ei: ultimate reserve mass; all
%     - Ww_i: ultimate structural weight; all
%     - Wd_i: ultimate structural dry weight; all
%     - E_Wi: ultimate energy content; all
%     - del_V: fraction of max weight that is structure; all
%     - xi_WE: whole-body energy density of dry biomass (no reprod buffer) 
%     - del_Wb: birth weight as fraction of maximum weight       
%     - del_Wp: puberty weight as fraction of maximum weight      
%
%     - a_m: age at death; all
%     - S_b: survival probability at birth; all
%     - S_p: survival probability at puberty; all
%     - h_W: Weibull aging rate; all
%     - h_G: Gompertz aging rate; all
%
%     - N_i: life-time reproductive output; all
%     - R_i: ultimate reproduction rate: all except hep, hex
%
%     - K: half saturation coefficient; all if F_m exists
%     - F_mb: max searching rate at birth; all  if F_m exists
%     - F_mp: max searching rate at puberty; all if F_m exists
%     - F_mi: max ultimate searching rate; all if F_m exists
%     - J_Xb: food intake at birth; all if kap_X exists
%     - J_Xp: food intake at puberty; all if kap_X exists
%     - J_Xi: ultimate food intake; all if kap_X exists
%     - eb_min_G: scaled func. resp. such that growth ceases at birth; all
%     - eb_min_R: scaled func. resp. such that maturation ceases at birth; all
%     - ep_min: scaled func. resp. such that growth ceases at puberty; all
%     - t_starve: maximum survival time when starved; all
%
%     - p_A*, p_C*, p_S*, p_J*, p_G*, p_R*, p_D* : energy fluxes at b, p, i ; all
%     - J_Cb, J_Cp, J_Ci: carbon dioxide production at birth, puberty, ultimate; all
%     - J_Hb, J_Hp, J_Hi: water production at birth, puberty, ultimate; all
%     - J_Ob, J_Op, J_Oi: dioxygen consumption at birth, puberty, ultimate; all
%     - J_Nb, J_Np, J_Ni: nitrogen waste production at birth, puberty, ultimate; all
%
%     - RQ_b, RQ_p, RQ_i: respiration quotient; all
%     - UQ_b, UQ_p, UQ_i: urination quotient; all
%     - WQ_b, WQ_p, WQ_i: watering quotient; all
%     - SDA_b, SDA_p, SDA_i: specific dynamic action; all
%     - VO_b, VO_p, VO_i: dry-weight specific dioxygen use; all
%     - p_Tb, p_Tp, p_Ti: total heat; all
%
% * txtStat: structure with temp, fresp, units, labels for stat

%% Remarks
% Assumes that parameters are given in standard units (d, cm, mol, J, K); this is not checked!
% Buffer handling rules are species-specific, so ultimate reproduction rate Ri doest not always make sense.
% Fermentation is supposed not to occur and dioxygen availability is assumed to be unlimiting.
% Ages exclude initial delay of development, if it would exist.
% Body weights exclude possible contribution of the reproduction buffer.
% If argument T is not specified or is empty, then temperature-dependent quantities are presented at reference temperature.
% The output values are for females; males might have deviating parameters, which are frequently also available.
%
% For required model-specific fields, see <get_parfields.html *get_parfields*>.

%% Example of use
% load('results_species.mat'); [stat, txtStat] = statistics_st(metaPar.model, par); printstat_st(stat, txtStat)

  
  choices = {'std', 'stf', 'stx', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hax', 'hex'};
  if ~any(strcmp(model,choices))
    fprintf('warning statistics_st: invalid model key \n')
    stat = []; txtStat = [];
    return;
  end    
     
  if ~exist('T', 'var') || isempty(T)
    T = C2K(20);   % K, body temperature
  end
  T_ref = C2K(20); % K, reference temperature
 
  if ~exist('f', 'var') || isempty(f) % overwrite f in par
    par.f = 1;
  else
    par.f = f; 
  end
  
  % test parameter setting on validity
  filternm = ['filter_', model]; 
  [pass, flag]  = feval(filternm, par);
  if ~pass 
    stat = []; txtStat = [];
    print_filterflag(flag);
    error('The parameter set is not realistic');
  end

  % extract parameters and compute compound parameters
  cPar = parscomp_st(par);
  vars_pull(cPar); vars_pull(par);

  % initiate output with f, T, TC
  stat.f = f; units.f = '-'; label.f = 'scaled functional response'; temp.f = NaN; fresp.f  = f;
  stat.T = K2C(T); units.T = 'C'; label.T = 'body temperature'; temp.T = T; fresp.T = NaN;
  pars_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    pars_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  TC = tempcorr(T, T_ref, pars_T);   % -, Temperature Correction factor
  stat.c_T = TC; units.c_T = '-'; label.c_T = 'Temperature Correction factor'; temp.c_T = T; fresp.c_T = NaN;
  
  % compound parameters as computed by parscomp_st (not depending on f)
  % conditional additions are copied from those in parscomp_st
  stat.p_Am = p_Am; units.p_Am = 'J/d.cm^2'; label.p_Am = '{p_Am}, spec assimilation flux'; temp.p_Am = T_ref; fresp.p_Am = NaN; % primary parameter, not a compound one
  stat.w_X = w_X; units.w_X = 'g/mol'; label.w_X = 'molecular weight for water-free food'; temp.w_X = NaN; fresp.w_X = NaN;
  stat.w_V = w_V; units.w_V = 'g/mol'; label.w_V = 'molecular weight for water-free structure'; temp.w_V = NaN; fresp.w_V = NaN;
  stat.w_E = w_E; units.w_E = 'g/mol'; label.w_E = 'molecular weight for water-free reserve'; temp.w_E = NaN; fresp.w_E = NaN;
  stat.w_P = w_P; units.w_P = 'g/mol'; label.w_P = 'molecular weight for water-free product (feaces)'; temp.w_P = NaN; fresp.w_P = NaN;
  stat.M_V = M_V; units.M_V = 'mol/cm^3'; label.M_V = '[M_V], volume-specific mass of structure'; temp.M_V = NaN; fresp.M_V = NaN;
  stat.y_V_E = y_V_E; units.y_V_E = 'mol/mol'; label.y_V_E = 'yield of structure on reserve'; temp.y_V_E = NaN; fresp.y_V_E = NaN;
  stat.y_E_V = y_E_V; units.y_E_V = 'mol/mol'; label.y_E_V = 'yield of reserve on structure'; temp.y_E_V = NaN; fresp.y_E_V = NaN;
  stat.k_M = k_M; units.k_M = '1/d'; label.k_M = 'somatic maintenance rate coefficient'; temp.k_M = T_ref; fresp.k_M = NaN;
  stat.k = k; units.k = '-'; label.k = 'maintenance ratio'; temp.k = NaN; fresp.k = NaN;
  stat.E_m = E_m; units.E_m = 'J/cm^3'; label.E_m = '[E_m], reserve capacity'; temp.E_m = NaN; fresp.E_m = NaN;
  stat.m_Em = m_Em; units.m_Em = 'mol/mol'; label.m_Em = 'reserve capacity'; temp.m_Em = NaN; fresp.m_Em = NaN;
  stat.g = g; units.g = '-'; label.g = 'energy investment ratio'; temp.g = NaN; fresp.g = NaN;
  stat.L_m = L_m; units.L_m = 'cm'; label.L_m = 'maximum structural length'; temp.L_m = NaN; fresp.L_m = NaN;
  stat.L_T = L_T; units.L_T = 'cm'; label.L_T = 'heating length (also applies to osmotic work)'; temp.L_T = NaN; fresp.L_T = NaN;
  stat.l_T = l_T; units.l_T = '-'; label.l_T = 'scaled heating length'; temp.l_T = NaN; fresp.l_T = NaN;
  stat.ome = ome; units.ome = '-'; label.ome = '\omega, contribution of ash free dry mass of reserve to total ash free dry biomass'; temp.ome = NaN; fresp.ome = NaN;
  stat.J_E_Am = J_E_Am; units.J_E_Am = 'mol/d.cm^2'; label.J_E_Am = '{J_EAm}, max surface-spec assimilation flux'; temp.J_E_Am = T_ref; fresp.J_E_Am = NaN;
  if exist('kap_X', 'var')
    stat.y_E_X = y_E_X; units.y_E_X = 'mol/mol'; label.y_E_X = 'yield of reserve on food'; temp.y_E_X = NaN; fresp.y_E_X = NaN;
    stat.y_X_E = y_X_E; units.y_X_E = 'mol/mol'; label.y_X_E = 'yield of food on reserve'; temp.y_X_E = NaN; fresp.y_X_E = NaN;
    stat.p_Xm = p_Xm;   units.p_Xm = 'J/d.cm^2'; label.p_Xm = '{p_Xm}, max spec feeding power'; temp.p_Xm = T_ref; fresp.p_Xm = NaN;
    stat.J_X_Am = J_X_Am; units.J_X_Am = 'mol/d.cm^2'; label.J_X_Am = '{J_XAm}, max surface-spec feeding flux'; temp.J_X_Am = T_ref; fresp.J_X_Am = NaN;
  end
  if exist('kap_P', 'var')
    stat.y_P_X = y_P_X; units.y_P_X = 'mol/mol'; label.y_P_X = 'yield of faeces on food'; temp.y_P_X = NaN; fresp.y_P_X = NaN;
    stat.y_X_P = y_X_P; units.y_X_P = 'mol/mol'; label.y_X_P = 'yield of food on faeces'; temp.y_X_P = NaN; fresp.y_X_P = NaN;
  end
  if exist('kap_X', 'var') && exist('kap_P', 'var')
    stat.y_P_E = y_P_E; units.y_P_E = 'mol/mol'; label.y_P_E = 'yield of faeces on reserve'; temp.y_P_E = NaN; fresp.y_P_E = NaN;
    stat.eta_XA = eta_XA; units.eta_XA = 'mol/J'; label.eta_XA = 'mass-power couplers for food on assimilation'; temp.eta_XA = NaN; fresp.eta_XA = NaN;
    stat.eta_PA = eta_PA; units.eta_PA = 'mol/J'; label.eta_PA = 'mass-power couplers for product on assimlation'; temp.eta_PA = NaN; fresp.eta_PA = NaN;
    stat.eta_VG = eta_VG; units.eta_VG = 'mol/J'; label.eta_VG = 'mass-power couplers for structure on growth'; temp.eta_VG = NaN; fresp.eta_VG = NaN;
  end
  stat.J_E_M = J_E_M; units.J_E_M = 'mol/d.cm^3'; label.J_E_M = '[J_EM], vol-spec somatic  maint costs'; temp.J_E_M = T_ref; fresp.J_E_M = NaN;
  stat.J_E_T = J_E_T; units.J_E_T = 'mol/d.cm^2'; label.J_E_T = '{J_ET}, surface-spec somatic  maint costs'; temp.J_E_T = T_ref; fresp.J_E_T = NaN;
  stat.j_E_M = j_E_M; units.j_E_M = 'mol/d.mol'; label.j_E_M = 'mass-spec somatic  maint costs'; temp.j_E_M = T_ref; fresp.j_E_M = NaN;
  stat.j_E_J = j_E_J; units.j_E_J = 'mol/d.mol'; label.j_E_J = 'mass-spec maturity maint costs'; temp.j_E_J = T_ref; fresp.j_E_J = NaN;
  stat.kap_G = kap_G; units.kap_G = '-'; label.kap_G = '\kappa_G, growth efficiency'; temp.kap_G = NaN; fresp.kap_G = NaN;
  stat.E_V = E_V; units.E_V = 'J/cm^3'; label.E_V = '[E_V], volume-specific energy of structure'; temp.E_V = NaN; fresp.E_V = NaN;
  if exist('F_m', 'var')
    stat.K = K; units.K = 'mol X/l'; label.K = 'half-saturation coefficient'; temp.K = NaN; fresp.K = NaN;
  end
  % * M_H*, U_H*, V_H*, v_H*, u_H*: scaled maturities computed from all unscaled ones: E_H*
  par_names = fields(par);   % extract field names for parameters
  mat_level = par_names(strncmp(par_names, 'E_H', 3));
  mat_index = strrep(mat_level, 'E_H', '');  % maturity levels' indices
  % set maturity labels
  j = 1; % ignore maturity levels with more than one index
  for i = 1:length(mat_index)
    if length(mat_index{i}) > 1
      continue
    end
    mat_index{j} = mat_index{i};
    j = j + 1;
  end
  % 
  for i = 1:length(mat_index)
    switch mat_index{i}
      case 'h'
        stat.E_Hh = M_Hh; units.E_Hh = 'J'; label.E_Hh = 'maturity level at hatch'; temp.E_Hh = NaN; fresp.E_Hh = NaN;
        stat.M_Hh = M_Hh; units.M_Hh = 'mol'; label.M_Hh = 'maturity level at hatch'; temp.M_Hh = NaN; fresp.M_Hh = NaN;
        stat.U_Hh = U_Hh; units.U_Hh = 'cm^2.d'; label.U_Hh = 'scaled maturity level at hatch'; temp.U_Hh = T_ref; fresp.U_Hh = NaN;
        stat.V_Hh = V_Hh; units.V_Hh = 'cm^2.d'; label.V_Hh = 'scaled maturity level at hatch'; temp.V_Hh = T_ref; fresp.V_Hh = NaN;
        stat.u_Hh = u_Hh; units.u_Hh = '-'; label.u_Hh = 'scaled maturity level at hatch'; temp.u_Hh = NaN; fresp.u_Hh = NaN;
        stat.v_Hh = v_Hh; units.v_Hh = '-'; label.v_Hh = 'scaled maturity level at hatch'; temp.v_Hh = NaN; fresp.v_Hh = NaN;
      case 'b'
        stat.E_Hb = E_Hb; units.E_Hb = 'J'; label.E_Hb = 'maturity level at birth'; temp.E_Hb = NaN; fresp.E_Hb = NaN;
        stat.M_Hb = M_Hb; units.M_Hb = 'mol'; label.M_Hb = 'maturity level at birth'; temp.M_Hb = NaN; fresp.M_Hb = NaN;
        stat.U_Hb = U_Hb; units.U_Hb = 'cm^2.d'; label.U_Hb = 'scaled maturity level at birth'; temp.U_Hb = T_ref; fresp.U_Hb = NaN;
        stat.V_Hb = V_Hb; units.V_Hb = 'cm^2.d'; label.V_Hb = 'scaled maturity level at birth'; temp.V_Hb = T_ref; fresp.V_Hb = NaN;
        stat.u_Hb = u_Hb; units.u_Hb = '-'; label.u_Hb = 'scaled maturity level at birth'; temp.u_Hb = NaN; fresp.u_Hb = NaN;
        stat.v_Hb = v_Hb; units.v_Hb = '-'; label.v_Hb = 'scaled maturity level at birth'; temp.v_Hb = NaN; fresp.v_Hb = NaN;
      case 'x'
        stat.E_Hx = E_Hx; units.E_Hx = 'J'; label.E_Hx = 'maturity level at weaning/fletching'; temp.E_Hx = NaN; fresp.E_Hx = NaN;
        stat.M_Hx = M_Hx; units.M_Hx = 'mol'; label.M_Hx = 'maturity level at weaning/fletching'; temp.M_Hx = NaN; fresp.M_Hx = NaN;
        stat.U_Hx = U_Hx; units.U_Hx = 'cm^2.d'; label.U_Hx = 'scaled maturity level at weaning/fletching'; temp.U_Hx = T_ref; fresp.U_Hx = NaN;
        stat.V_Hx = V_Hx; units.V_Hx = 'cm^2.d'; label.V_Hx = 'scaled maturity level at weaning/fletching'; temp.V_Hx = T_ref; fresp.V_Hx = NaN;
        stat.u_Hx = u_Hx; units.u_Hx = '-'; label.u_Hx = 'scaled maturity level at weaning/fletching'; temp.u_Hx = NaN; fresp.u_Hx = NaN;
        stat.v_Hx = v_Hx; units.v_Hx = '-'; label.v_Hx = 'scaled maturity level at weaning/fletching'; temp.v_Hx = NaN; fresp.v_Hx = NaN;
      case 's'
        if strcmp(model, 'ssj')
          stat.E_Hs = E_Hs; units.E_Hs = 'J'; label.E_Hs = 'maturity level at S1/S2 transition'; temp.E_Hs = NaN; fresp.E_Hs = NaN;
          stat.M_Hs = M_Hs; units.M_Hs = 'mol'; label.M_Hs = 'maturity level at S1/S2 transition'; temp.M_Hs = NaN; fresp.M_Hs = NaN;
          stat.U_Hs = U_Hs; units.U_Hs = 'cm^2.d'; label.U_Hs = 'scaled maturity level at S1/S2 transition'; temp.U_Hs = T_ref; fresp.U_Hs = NaN;
          stat.V_Hs = V_Hs; units.V_Hs = 'cm^2.d'; label.V_Hs = 'scaled maturity level at S1/S2 transition'; temp.V_Hs = T_ref; fresp.V_Hs = NaN;
          stat.u_Hs = u_Hs; units.u_Hs = '-'; label.u_Hs = 'scaled maturity level at S1/S2 transition'; temp.u_Hs = NaN; fresp.u_Hs = NaN;
          stat.v_Hs = v_Hs; units.v_Hs = '-'; label.v_Hs = 'scaled maturity level at S1/S2 transition'; temp.v_Hs = NaN; fresp.v_Hs = NaN;
        else % asj
          stat.E_Hs = E_Hs; units.E_Hs = 'J'; label.E_Hs = 'maturity level at start acceleration'; temp.E_Hs = NaN; fresp.E_Hs = NaN;
          stat.M_Hs = M_Hs; units.M_Hs = 'mol'; label.M_Hs = 'maturity level at start acceleration'; temp.M_Hs = NaN; fresp.M_Hs = NaN;
          stat.U_Hs = U_Hs; units.U_Hs = 'cm^2.d'; label.U_Hs = 'scaled maturity level at start acceleration'; temp.U_Hs = T_ref; fresp.U_Hs = NaN;
          stat.V_Hs = V_Hs; units.V_Hs = 'cm^2.d'; label.V_Hs = 'scaled maturity level at start acceleration'; temp.V_Hs = T_ref; fresp.V_Hs = NaN;
          stat.u_Hs = u_Hs; units.u_Hs = '-'; label.u_Hs = 'scaled maturity level at start acceleration'; temp.u_Hs = NaN; fresp.u_Hs = NaN;
          stat.v_Hs = v_Hs; units.v_Hs = '-'; label.v_Hs = 'scaled maturity level at start acceleration'; temp.v_Hs = NaN; fresp.v_Hs = NaN;
        end
      case 'j'
        stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; temp.E_Hj = NaN; fresp.E_Hj = NaN;
        stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis'; temp.M_Hj = NaN; fresp.M_Hj = NaN;
        stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis'; temp.U_Hj = T_ref; fresp.U_Hj = NaN;
        stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis'; temp.V_Hj = T_ref; fresp.V_Hj = NaN;
        stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis'; temp.u_Hj = NaN; fresp.u_Hj = NaN;
        stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis'; temp.v_Hj = NaN; fresp.v_Hj = NaN;
      case 'p'
        stat.E_Hp = E_Hp; units.E_Hp = 'J'; label.E_Hp = 'maturity level at puberty'; temp.E_Hp = NaN; fresp.E_Hp = NaN;
        stat.M_Hp = M_Hp; units.M_Hp = 'mol'; label.M_Hp = 'maturity level at puberty'; temp.M_Hp = NaN; fresp.M_Hp = NaN;
        stat.U_Hp = U_Hp; units.U_Hp = 'cm^2.d'; label.U_Hp = 'scaled maturity level at puberty'; temp.U_Hp = T_ref; fresp.U_Hp = NaN;
        stat.V_Hp = V_Hp; units.V_Hp = 'cm^2.d'; label.V_Hp = 'scaled maturity level at puberty'; temp.V_Hp = T_ref; fresp.V_Hp = NaN;
        stat.u_Hp = u_Hp; units.u_Hp = '-'; label.u_Hp = 'scaled maturity level at puberty'; temp.u_Hp = NaN; fresp.u_Hp = NaN;
        stat.v_Hp = v_Hp; units.v_Hp = '-'; label.v_Hp = 'scaled maturity level at puberty'; temp.v_Hp = NaN; fresp.v_Hp = NaN;
      case 'e' % hex
        stat.E_He = E_He; units.E_He = 'J'; label.E_He = 'maturity level at emergence'; temp.E_He = NaN; fresp.E_He = NaN;
        stat.M_He = M_He; units.M_He = 'mol'; label.M_He = 'maturity level at emergence'; temp.M_He = NaN; fresp.M_He = NaN;
        stat.U_He = U_He; units.U_He = 'cm^2.d'; label.U_He = 'scaled maturity level at emergence'; temp.U_He = T_ref; fresp.U_He = NaN;
        stat.V_He = V_He; units.V_He = 'cm^2.d'; label.V_He = 'scaled maturity level at emergence'; temp.V_He = T_ref; fresp.V_He = NaN;
        stat.u_He = u_He; units.u_He = '-'; label.u_He = 'scaled maturity level at emergence'; temp.u_He = NaN; fresp.u_He = NaN;
        stat.v_He = v_He; units.v_He = '-'; label.v_He = 'scaled maturity level at emergence'; temp.v_He = NaN; fresp.v_He = NaN;
     end  
  end

  % other compound parameters (not depending on f)
  t_E      = L_m/ v/ TC;    % d, maximum reserve residence time
  stat.t_E = t_E; units.t_E  = 'd';  label.t_E = 'maximum reserve residence time';  temp.t_E = T; fresp.t_E = NaN;                    
  t_starve = E_m/ p_M/ TC;  % d, max survival time when starved  
  stat.t_starve  = t_starve; units.t_starve = 'd'; label.t_starve = 'maximum survival time when starved';  temp.t_starve = T; fresp.t_starve = 0;             

  % life cycle
  switch model
    case 'std'
      if exist('E_Hx','var') % egg development
        pars_tx = [g k l_T v_Hb v_Hx];
        [t_x, t_b, l_x, l_b] = get_tp(pars_tx, f);
        pars_tp = [g k l_T v_Hb v_Hp];
        [t_p, t_b, l_p, l_b, info] = get_tp(pars_tp, f, l_b);
      else
        pars_tp  = [g; k; l_T; v_Hb; v_Hp];  % parameters for get_tp
        [t_p, t_b, l_p, l_b, info] = get_tp(pars_tp, f); 
      end
      if info ~= 1              
        fprintf('warning in get_tp: invalid parameter value combination for t_p \n')
      end
      l_i = f - l_T; s_M = 1; 
      rho_B = 1/ 3/ (1 + f/ g);
    case 'stf'
      pars_tp  = [g; k; l_T; v_Hb; v_Hp];  % parameters for get_tp
      [t_p, t_b, l_p, l_b, info] = get_tp_foetus(pars_tp, f); 
      if info ~= 1              
        fprintf('warning in get_tp_foetus: invalid parameter value combination for t_p \n')
      end
      l_i = f - l_T; s_M = 1;
      rho_B = 1/ 3/ (1 + f/ g);
    case 'stx' % foetal development
      pars_tx = [g k l_T v_Hb v_Hx v_Hp]; 
      [t_p, t_x, t_b, l_p, l_x, l_b, info] = get_tx(pars_tx, f);
      if info ~= 1              
        fprintf('warning in get_tx: invalid parameter value combination for pars_tx \n')
      end
      l_i = f - l_T; s_M = 1;
      rho_B = 1/ 3/ (1 + f/ g);
    case 'ssj'
      pars_lb = [g; k; v_Hb];            % birth     
      [t_b, l_b] = get_tb(pars_lb, f); 
      pars_ts = [g; k; l_T; v_Hb; v_Hs]; % S1/S2 transition
      [t_s t_bb l_s l_bb] = get_tp(pars_ts, f, l_b); 
      % S2/S3 transition to no-feeding; t_sj is primary parameter
      L_s = L_m * l_s;
      [t eLH] = ode45 (@dget_eLH, [0; t_sj], [1; L_s; E_Hs], [], kap, TC * v, g, L_m, TC * k_J, E_m);
      L_j = eLH(end,2);  l_j = L_j/ L_m; 
      E_Hj = eLH(end,3);                 % J, maturity at S3/juv transition
      M_Hj = E_Hj/ mu_E;                 % mol, maturity at S3/juv transition
      U_Hj = E_Hj/ p_Am;                 % cm^2 d, scaled maturity at S3/juv transition
      u_Hj = U_Hj * g^2 * k_M^3/ v^2;    % -, scaled maturity at S3/juv transition
      V_Hj = U_Hj/ (1 - kap);            % cm^2 d, scaled maturity at S3/juv transition
      v_Hj = V_Hj * g^2 * k_M^3/ v^2;    % -, scaled maturity at S3/juv transition
      stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; temp.E_Hj = NaN; fresp.E_Hj = NaN; % is not a parameter of ssj
      stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis'; temp.M_Hj = NaN; fresp.M_Hj = NaN;
      stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis'; temp.U_Hj = T_ref; fresp.U_Hj = NaN;
      stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis'; temp.V_Hj = T_ref; fresp.V_Hj = NaN;
      stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis'; temp.u_Hj = NaN; fresp.u_Hj = NaN;
      stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis'; temp.v_Hj = NaN; fresp.v_Hj = NaN;
      pars_tp = [g; k; l_T; v_Hj; v_Hp]; % puberty 
      [t_p t_jj l_p l_jj info] = get_tp(pars_tp, f, l_j); % -, scaled length at birth at f
      if info ~= 1              
        fprintf('warning in get_tp: invalid parameter value combination for t_p \n')
      end
      l_i = f - l_T; s_M = 1;
      rho_B = 1/ 3/ (1 + f/ g);
    case 'sbp'
      pars_tp  = [g; k; l_T; v_Hb; v_Hp];  
      [t_p, t_b, l_p, l_b, info] = get_tp(pars_tp, f); 
      if info ~= 1              
        fprintf('warning in get_tp: invalid parameter value combination for t_p \n')
      end
      l_i = l_p; s_M = 1;
      rho_B = 1/ 3/ (1 + f/ g);
    case 'abj' 
      pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp];
      [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj(pars_tj, f);
      if info ~= 1              
        fprintf('warning in get_tj: invalid parameter value combination for t_p \n')
      end  
      s_M = l_j/ l_b;
    case 'asj'
      pars_ts = [g; k; l_T; v_Hb; v_Hs; v_Hj; v_Hp];
      [t_s, t_j, t_p, t_b, l_s, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_ts(pars_ts, f);
      if info ~= 1              
        fprintf('warning in get_ts: invalid parameter value combination for t_p \n')
      end
      s_M = l_j/ l_s;
    case 'abp'
      E_Hj = E_Hp - 1e-8; M_Hj = M_Hp - 1e-8; U_Hj = U_Hp - 1e-8; V_Hj = V_Hp - 1e-8; u_Hj = u_Hp - 1e-8; v_Hj = v_Hp - 1e-8;
      stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; temp.E_Hj = NaN; fresp.E_Hj = NaN;
      stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis'; temp.M_Hj = NaN; fresp.M_Hj = NaN;
      stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis'; temp.U_Hj = T_ref; fresp.U_Hj = NaN;
      stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis'; temp.V_Hj = T_ref; fresp.V_Hj = NaN;
      stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis'; temp.u_Hj = NaN; fresp.u_Hj = NaN;
      stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis'; temp.v_Hj = NaN; fresp.v_Hj = NaN;
      pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp];
      [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj(pars_tj, f);
      if info ~= 1              
        fprintf('warning in get_tj: invalid parameter value combination for t_p \n')
      end  
      s_M = l_p/ l_b; l_i = l_p + 1e-6;
   case 'hep'
      v_Rj = kap/ (1 - kap) * E_Rj/ E_G; pars_tj = [g k v_Hb v_Hp v_Rj];
      [t_j, t_p, t_b, l_j, l_p, l_b, l_i, rho_j, rho_B, info] = get_tj_hep(pars_tj, f);
      if info ~= 1              
        fprintf('warning in get_tj_hep: invalid parameter value combination for t_p \n')
      end  
      s_M = l_p/ l_b; E_Hj = E_Hp - 1e-8; M_Hj = M_Hp - 1e-8; U_Hj = U_Hp - 1e-8; V_Hj = V_Hp - 1e-8; u_Hj = u_Hp - 1e-8; v_Hj = v_Hp - 1e-8;
      stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; temp.E_Hj = NaN; fresp.E_Hj = NaN; % is not a parameter of hep
      stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis'; temp.M_Hj = NaN; fresp.M_Hj = NaN;
      stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis'; temp.U_Hj = T_ref; fresp.U_Hj = NaN;
      stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis'; temp.V_Hj = T_ref; fresp.V_Hj = NaN;
      stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis'; temp.u_Hj = NaN; fresp.u_Hj = NaN;
      stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis'; temp.v_Hj = NaN; fresp.v_Hj = NaN;
   case 'hax'
      v_Rj = kap/ (1 - kap) * E_Rj/ E_G; pars_tj = [g, k, v_Hb, v_Hp, v_Rj, v_He, kap, kap_V];
      [t_j, t_e, t_p, t_b, l_j, l_e, l_p, l_b, l_i, r_j, r_B, u_Ee, info] = get_tj_hax(pars_tj, f);
      if info ~= 1              
        fprintf('warning in get_tj_hax: invalid parameter value combination for t_p \n')
      end  
      s_M = l_p/ l_b; E_Hj = E_Hp - 1e-8; M_Hj = M_Hp - 1e-8; U_Hj = U_Hp - 1e-8; V_Hj = V_Hp - 1e-8; u_Hj = u_Hp - 1e-8; v_Hj = v_Hp - 1e-8;
      stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; temp.E_Hj = NaN; fresp.E_Hj = NaN; % is not a parameter of hax
      stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis'; temp.M_Hj = NaN; fresp.M_Hj = NaN;
      stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis'; temp.U_Hj = T_ref; fresp.U_Hj = NaN;
      stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis'; temp.V_Hj = T_ref; fresp.V_Hj = NaN;
      stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis'; temp.u_Hj = NaN; fresp.u_Hj = NaN;
      stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis'; temp.v_Hj = NaN; fresp.v_Hj = NaN;
    case 'hex'
      pars_tj = [g k v_Hb v_He s_j kap kap_V];
      [t_j, t_e, t_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee, info] = get_tj_hex(pars_tj, f);
      if info ~= 1              
        fprintf('warning in get_tj_hex: invalid parameter value combination for t_p \n')
      end
      l_i = l_j; s_M = l_j/ l_b; % notice that l_i is set to scaled length at pupation for hex
      stat.E_Hp = E_Hb+1e-8; units.E_Hp = 'J'; label.E_Hp = 'maturity level at puberty'; temp.E_Hp = NaN; fresp.E_Hp = NaN; % is not a parameter of hex
      stat.M_Hp = M_Hb+1e-8; units.M_Hp = 'mol'; label.M_Hp = 'maturity level at puberty'; temp.M_Hp = NaN; fresp.M_Hp = NaN;
      stat.U_Hp = U_Hb+1e-8; units.U_Hp = 'cm^2.d'; label.U_Hp = 'scaled maturity level at puberty'; temp.U_Hp = T_ref; fresp.U_Hp = NaN;
      stat.V_Hp = V_Hb+1e-8; units.V_Hp = 'cm^2.d'; label.V_Hp = 'scaled maturity level at puberty'; temp.V_Hp = T_ref; fresp.V_Hp = NaN;
      stat.u_Hp = u_Hb+1e-8; units.u_Hp = '-'; label.u_Hp = 'scaled maturity level at puberty'; temp.u_Hp = NaN; fresp.u_Hp = NaN;
      stat.v_Hp = v_Hb+1e-8; units.v_Hp = '-'; label.v_Hp = 'scaled maturity level at puberty'; temp.v_Hp = NaN; fresp.v_Hp = NaN;
  end
  
  % life cycle statistics
  stat.s_M = s_M;   units.s_M = '-';           label.s_M = 'acceleration factor at f=1'; temp.s_M = NaN; fresp.s_M = 1;
  if exist('rho_j', 'var')
    r_j = rho_j * k_M * TC;
    stat.r_j = r_j; units.r_j = '1/d';         label.r_j = 'exponential growth rate'; temp.r_j = T; fresp.r_j = f;
  end
  if exist('rho_B', 'var')
    r_B = rho_B * k_M * TC;
    stat.r_B = r_B;    units.r_B = '1/d';      label.r_B = 'von Bertalanffy growth rate'; temp.r_B = T; fresp.r_B = f;
  end  
  % maximum growth % see comments on DEB3 section 2.6
  switch model
    case {'std', 'stf', 'stx', 'ssj'}
      L_dWm = 2/3 * (L_m - L_T); W_dWm = L_dWm^3 * (1 + w);
      dWm = TC * W_dWm * r_B * 3/ 2;
    case 'sbp'
      L_dWm = 2/3 * (L_m - L_T); W_dWm = L_dWm^3 * (1 + w);
      dWm = TC * W_dWm * r_B * 3/ 2;
      L_p = l_p * L_m;
      if L_p < L_dWm
        L_dWm = L_p; W_dWm = L_dWm^3 * (1 + w);
        dWm = 3 * (1 + w) * L_dWm^2 * r_B * (L_m - L_T - L_dWm);
      end
    case {'abj', 'asj'}
      L_dWm = 2/3 * (s_M * L_m - L_T); W_dWm = L_dWm^3 * (1 + w);
      L_j = l_j * L_m;
      L_dWm = L_j; W_dWm = L_dWm^3 * (1 + w); 
      dWm = TC * W_dWm * r_j;
    case 'abp'
      L_p = l_p * L_m;
      L_dWm = L_p; W_dWm = L_dWm^3 * (1 + w); 
      dWm = TC * W_dWm * r_j;      
    case {'hep', 'hax'}
      L_p = l_p * L_m;
      L_dWm = L_p; W_dWm = L_dWm^3 * (1 + w); 
      dWm = TC * W_dWm * r_j;
    case 'hex'
      L_j = L_m * l_j;
      L_dWm = L_j; W_dWm = L_dWm^3 * (1 + w); 
      dWm = TC * W_dWm * r_j;
  end
  stat.W_dWm = W_dWm; units.W_dWm = 'g';  label.W_dWm = 'wet weight at maximum growth'; temp.W_dWm = NaN; fresp.W_dWm = f;
  stat.dWm = dWm;     units.dWm = 'g/d';  label.dWm = 'maximum growth in wet weight'; temp.dWm = T; fresp.dWm = f;

  % life event statistics
  
  % initial state
  pars_E0  = [V_Hb; g; k_J; k_M; v];   % initial_scaled_reserve
  switch model
    case {'stf', 'stx'} % foetus
      [U_E0, L_b, info] = initial_scaled_reserve_foetus(f, pars_E0); % d cm^2, initial scaled reserve
      u_E0 = U_E0 * v/ g/ L_m^3;
      if info ~= 1
        fprintf('warning in initial_scaled_reserve_foetus: invalid parameter value combination for foetus \n')
      end
      E_0 = p_Am * U_E0;
      stat.E_0 = E_0;   units.E_0 = 'J';       label.E_0 = 'reserve invested in foetus';  temp.E_0 = NaN; fresp.E_0 = f;
      M_E0 = J_E_Am * U_E0;
      stat.M_E0 = M_E0; units.M_E0 = 'mol';    label.M_E0 = 'reserve invested in foetus'; temp.M_E0 = NaN; fresp.M_E0 = f;
    otherwise % egg
      [U_E0, L_b, info] = initial_scaled_reserve(f, pars_E0); % d cm^2, initial scaled reserve
      u_E0 = U_E0 * v/ g/ L_m^3;
      if info ~= 1
        fprintf('warning in initial_scaled_reserve: invalid parameter value combination for egg \n')
      end
      stat.U_E0 = U_E0; units.U_E0 = 'cm^2.d'; label.U_E0 = 'scaled initial reserve'; temp.U_E0 = T_ref; fresp.U_E0 = f;
      E_0 = p_Am * U_E0;
      stat.E_0 = E_0;   units.E_0 = 'J';       label.E_0 = 'initial reserve';         temp.E_0 = NaN; fresp.E_0 = f;
      M_E0 = J_E_Am * U_E0; Wd_0 = M_E0 * w_E; Ww_0 = Wd_0/ d_E;
      stat.M_E0 = M_E0; units.M_E0 = 'mol';    label.M_E0 = 'initial reserve';        temp.M_E0 = NaN; fresp.M_E0 = f;
      stat.Wd_0 = Wd_0; units.Wd_0 = 'g';      label.Wd_0 = 'initial dry weight';     temp.Wd_0 = NaN; fresp.Wd_0 = f;
      stat.Ww_0 = Ww_0; units.Ww_0 = 'g';      label.Ww_0 = 'initial wet weight';     temp.Ww_0 = NaN; fresp.Ww_0 = f;
  end
  
  % hatch
  if any(strcmp(mat_index,'h'))       % hatching 
    [U_H aUL] = ode45(@dget_aul, [0; U_Hh; U_Hb], [0 U_E0 1e-10], [], kap, v, k_J, g, L_m);
    t_h = aUL(2,1) * k_M;             % -, scaled age at hatch at f and T
    M_Eh = J_E_Am * aUL(end,2);       % mol, reserve at hatch at f
    l_h = aUL(2,3)/L_m;               % cm, scaled structural length at f
    L_h = L_m * l_h; M_Vh = M_V * L_h^3; E_Wh = M_Vh * mu_V + M_Eh * mu_E; % J, energy content at hatch
    Ww_h = L_h^3 + w_E * M_Eh/ d_E; Wd_h = d_V * L_h^3 + w_E * M_Eh; 
    a_h = t_h/ k_M/ TC; del_Uh = M_Eh/ M_E0; % -, fraction of reserve left at hatch
    stat.l_h = l_h;   units.l_h = '-';    label.l_h = 'scaled structural length at hatch'; temp.l_h = NaN; fresp.l_h = f;
    stat.L_h = L_h;   units.L_h = 'cm';   label.L_h = 'structural length at hatch'; temp.L_h = NaN; fresp.L_h = f;
    stat.M_Vh = M_Vh; units.M_Vh = 'mol'; label.M_Vh = 'structural mass at hatch'; temp.M_Vh = NaN; fresp.M_Vh = f;
    stat.M_Eh = M_Eh; units.M_Eh = 'mol'; label.M_Eh = 'reserve mass at hatch'; temp.M_Eh = NaN; fresp.M_Eh = f;
    stat.del_Uh = del_Uh; units.del_Uh = '-'; label.del_Uh = 'fraction of reserve left at hatch'; temp.del_Uh = NaN; fresp.del_Uh = f;
    stat.Ww_h = Ww_h; units.Ww_h = 'g';   label.Ww_h = 'wet weight at hatch'; temp.Ww_h = NaN; fresp.Ww_h = f;
    stat.Wd_h = Wd_h; units.Wd_h = 'g';   label.Wd_h = 'dry weight at hatch'; temp.Wd_h = NaN; fresp.Wd_h = f;
    stat.E_Wh = E_Wh; units.E_Wh = 'J';   label.E_Wh = 'energy content at hatch'; temp.E_Wh = NaN; fresp.E_Wh = f;
    stat.a_h = a_h; units.a_h = 'd';      label.a_h = 'age at hatch'; temp.a_h = T; fresp.a_h = f;
  end
  
  % birth
  L_b = L_m * l_b; 
  M_Vb = M_V * L_b^3; M_Eb = f * E_m * L_b^3/ mu_E; 
  Ww_b = L_b^3 * (1 + f * w); Wd_b = d_V * Ww_b; E_Wb = M_Vb * mu_V + M_Eb * mu_E;
  a_b = t_b/ k_M/ TC; del_Ub = M_Eb/ M_E0; % -, fraction of reserve left at birth
  g_Hb = E_Hb/ L_b^3/ (1 - kap)/ E_m; 
  stat.l_b = l_b;   units.l_b = '-';      label.l_b = 'scaled structural length at birth'; temp.l_b = NaN; fresp.l_b = f;
  stat.L_b = L_b;   units.L_b = 'cm';     label.L_b = 'structural length at birth'; temp.L_b = NaN; fresp.L_b = f;
  stat.M_Vb = M_Vb; units.M_Vb = 'mol';   label.M_Vb = 'structural mass at birth'; temp.M_Vb = NaN; fresp.M_Vb = f;
  stat.del_Ub = del_Ub; units.del_Ub = '-'; label.del_Ub = 'fraction of reserve left at birth'; temp.del_Ub = NaN; fresp.del_Ub = f;
  stat.Ww_b = Ww_b; units.Ww_b = 'g';     label.Ww_b = 'wet weight at birth'; temp.Ww_b = NaN; fresp.Ww_b = f;
  stat.Wd_b = Wd_b; units.Wd_b = 'g';     label.Wd_b = 'dry weight at birth'; temp.Wd_b = NaN; fresp.Wd_b = f;
  stat.E_Wb = E_Wb; units.E_Wb = 'J';     label.E_Wb = 'energy content at birth';   temp.E_Wb = NaN; fresp.E_Wb = f;
  stat.a_b = a_b;   units.a_b = 'd';      label.a_b = 'age at birth';    temp.a_b = T; fresp.a_b = f;
  stat.g_Hb = g_Hb; units.g_Hb = '-';     label.g_Hb = 'energy divestment ratio at birth'; temp.g_Hb = NaN; fresp.g_Hb = NaN;
  if strcmp(model, 'stf') || strcmp(model, 'stx') % foetus or budding
        if exist('t_0','var')==0
        t_0 = 0;
        end
    t_g = t_0 + a_b; % gestation/incubation time. Note that t_0 is always given at T_body!
    stat.t_g = t_g; units.t_g = 'd'; label.t_g = 'gestation time'; temp.t_g = T; fresp.t_g = f;
  end  
  
  % weaning/fledging
  if exist('E_Hx','var') && (strcmp(model, 'std') || strcmp(model, 'stx'))
    L_x = L_m * l_x; 
    M_Vx = M_V * L_x^3; M_Ex = f * E_m * L_x^3/ mu_E; 
    Ww_x = L_x^3 * (1 + f * w); Wd_x = d_V * Ww_x; E_Wx = M_Vx * mu_V + M_Ex * mu_E;
    a_x = t_x/ k_M/ TC; 
    stat.l_x = l_x;   units.l_x = '-';      label.l_x = 'scaled structural length at weaning/fledging'; temp.l_x = NaN; fresp.l_x = f;
    stat.L_x = L_x;   units.L_x = 'cm';     label.L_x = 'structural length at weaning/fledging'; temp.L_x = NaN; fresp.L_x = f;
    stat.M_Vx = M_Vx; units.M_Vx = 'mol';   label.M_Vx = 'structural mass at weaning/fledging'; temp.M_Vx = NaN; fresp.M_Vx = f;
    stat.Ww_x = Ww_x; units.Ww_x = 'g';     label.Ww_x = 'wet weight at weaning/fledging'; temp.Ww_x = NaN; fresp.Ww_x = f;
    stat.Wd_x = Wd_x; units.Wd_x = 'g';     label.Wd_x = 'dry weight at weaning/fledging'; temp.Wd_x = NaN; fresp.Wd_x = f;
    stat.E_Wx = E_Wx; units.E_Wx = 'J';     label.E_Wx = 'energy content at weaning/fledging';   temp.E_Wx = NaN; fresp.E_Wx = f;
    stat.a_x = a_x;   units.a_x = 'd';      label.a_x = 'age at weaning/fledging';    temp.a_x = T; fresp.a_x = f;
  end  
  
  % start/end shrinking
  if strcmp(model, 'ssj')
    L_s = L_m * l_s; M_Vs = M_V * L_s^3; M_Es = f * E_m * L_s^3/ mu_E; E_Ws = M_Vs * mu_V + M_Es * mu_E;
    Ww_s = L_s^3 * (1 + w * f); Wd_s = d_V * Ww_s; a_s = t_s/ k_M/ TC; 
    stat.l_s = l_s;   units.l_s = '-';    label.l_s = 'scaled structural length at start strinking'; temp.l_s = NaN; fresp.l_s = f;
    stat.L_s = L_s;   units.L_s = 'cm';   label.L_s = 'structural length at start strinking'; temp.L_s = NaN; fresp.L_s = f;
    stat.M_Vs = M_Vs; units.M_Vs = 'mol'; label.M_Vs = 'structural mass at start strinking'; temp.M_Vs = NaN; fresp.M_Vs = f;
    stat.M_Es = M_Es; units.M_Es = 'mol'; label.M_Es = 'reserve mass at start strinking'; temp.M_Es = NaN; fresp.M_Es = f;
    stat.Ww_s = Ww_s; units.Ww_s = 'g';   label.Ww_s = 'wet weight at start strinking'; temp.Ww_s = NaN; fresp.Ww_s = f;
    stat.Wd_s = Wd_s; units.Wd_s = 'g';   label.Wd_s = 'dry weight at start strinking'; temp.Wd_s = NaN; fresp.Wd_s = f;
    stat.E_Ws = E_Ws; units.E_Ws = 'J';   label.E_Ws = 'energy content at start strinking'; temp.E_Ws = NaN; fresp.E_Ws = f;
    stat.a_s = a_s;   units.a_s = 'd';    label.a_s = 'age at start strinking'; temp.a_s = T; fresp.a_s = f;
    M_Vj = M_V * L_j^3; M_Ej = f * E_m * L_j^3/ mu_E; E_Wj = M_Vj * mu_V + M_Ej * mu_E; 
    Ww_j = L_j^3 * (1 + w * f); Wd_j = d_V * Ww_j; 
    stat.l_s = l_j;   units.l_j = '-';    label.l_j = 'scaled structural length at end strinking'; temp.l_j = NaN; fresp.l_j = f;
    stat.L_s = L_j;   units.L_j = 'cm';   label.L_j = 'structural length at end strinking'; temp.L_j = NaN; fresp.L_j = f;
    stat.M_Vj = M_Vj; units.M_Vj = 'mol'; label.M_Vj = 'structural mass at end strinking'; temp.M_Vj = NaN; fresp.M_Vj = f;
    stat.M_Ej = M_Ej; units.M_Ej = 'mol'; label.M_Ej = 'reserve mass at end strinking'; temp.M_Ej = NaN; fresp.M_Ej = f;
    stat.Ww_j = Ww_j; units.Ww_j = 'g';   label.Ww_j = 'wet weight at end strinking'; temp.Ww_j = NaN; fresp.Ww_j = f;
    stat.Wd_j = Wd_j; units.Wd_j = 'g';   label.Wd_j = 'dry weight at end strinking'; temp.Wd_j = NaN; fresp.Wd_j = f;
    stat.E_Wj = E_Wj; units.E_Wj = 'J';   label.E_Wj = 'energy content at end strinking'; temp.E_Wj = NaN; fresp.E_Wj = f;
    stat.a_j = a_s + t_sj; units.a_j = 'd'; label.a_j = 'age at end strinking'; temp.a_j = T; fresp.a_j = f;
  end
  
  % start acceleration
  if strcmp(model, 'asj')
    L_s = L_m * l_s; M_Vs = M_V * L_s^3; M_Es = f * E_m * L_s^3/ mu_E; E_Ws = M_Vs * mu_V + M_Es * mu_E;
    Ww_s = L_s^3 * (1 + w * f); Wd_s = d_V * Ww_s; a_s = t_s/ k_M/ TC; 
    stat.l_s = l_s;   units.l_s = '-';     label.l_s = 'scaled structural length at start acceleration'; temp.l_s = NaN; fresp.l_s = f;
    stat.L_s = L_s;   units.L_s = 'cm';    label.L_s = 'structural length at start acceleration'; temp.L_s = NaN; fresp.L_s = f;
    stat.M_Vs = M_Vs; units.M_Vs = 'mol';  label.M_Vs = 'structural mass at start acceleration'; temp.M_Vs = NaN; fresp.M_Vs = f;
    stat.M_Es = M_Es; units.M_Es = 'mol';  label.M_Es = 'reserve mass at start acceleration'; temp.M_Es = NaN; fresp.M_Es = f;
    stat.Ww_s = Ww_s; units.Ww_s = 'g';    label.Ww_s = 'wet weight at start acceleration'; temp.Ww_s = NaN; fresp.Ww_s = f;
    stat.Wd_s = Wd_s; units.Wd_s = 'g';    label.Wd_s = 'dry weight at start acceleration'; temp.Wd_s = NaN; fresp.Wd_s = f;
    stat.E_Ws = E_Ws; units.E_Ws = 'J';    label.E_Ws = 'energy content at start acceleration'; temp.E_Ws = NaN; fresp.E_Ws = f;
    stat.a_s = a_s;   units.a_s = 'd';     label.a_s = 'age at start acceleration'; temp.a_s = T; fresp.a_s = f;
  end
  
  if strcmp(model, 'hex')
    l_p = l_b; t_p = t_b; E_Hp = E_Hb; U_Hp = U_Hb; V_Hp = V_Hb; u_Hp = u_Hb; v_Hp = v_Hb;
  end
        
  % metamorphosis
  switch model
    case {'abj', 'asj', 'abp', 'hep', 'hax', 'hex'}
      L_j = L_m * l_j; M_Vj = M_V * L_j^3; M_Ej = f * E_m * L_j^3/ mu_E; E_Wj = M_Vj * mu_V + M_Ej * mu_E;
      Ww_j = L_j^3 * (1 + w * f); Wd_j = d_V * Ww_j; a_j = t_j/ k_M/ TC; 
      stat.l_j = l_j;   units.l_j = '-';    label.l_j = 'scaled structural length at metamorphosis'; temp.l_j = NaN; fresp.l_j = f;
      stat.L_j = L_j;   units.L_j = 'cm';   label.L_j = 'structural length at metamorphosis'; temp.L_j = NaN; fresp.L_j = f;
      stat.M_Vj = M_Vj; units.M_Vj = 'mol'; label.M_Vj = 'structural mass at metamorphosis'; temp.M_Vj = NaN; fresp.M_Vj = f;
      stat.M_Ej = M_Vj; units.M_Ej = 'mol'; label.M_Ej = 'reserve mass at metamorphosis'; temp.M_Ej = NaN; fresp.M_Ej = f;
      stat.Ww_j = Ww_j; units.Ww_j = 'g';   label.Ww_j = 'wet weight at metamorphosis'; temp.Ww_j = NaN; fresp.Ww_j = f;
      stat.Wd_j = Wd_j; units.Wd_j = 'g';   label.Wd_j = 'dry weight at metamorphosis'; temp.Wd_j = NaN; fresp.Wd_j = f;
      stat.E_Wj = E_Wj; units.E_Wj = 'J';   label.E_Wj = 'energy content at metamorphosis'; temp.E_Wj = NaN; fresp.E_Wj = f;
      stat.a_j = a_j;   units.a_j = 'd';    label.a_j = 'age at metamorphosis'; temp.a_j = T; fresp.a_j = f;
  end

  
  % puberty
  L_p = L_m * l_p; M_Vp = M_V * L_p^3; M_Ep = f * E_m * L_p^3/ mu_E; E_Wp = M_Vp * mu_V + M_Ep * mu_E;
  Ww_p = L_p^3 * (1 + w * f); Wd_p = d_V * Ww_p; a_p = t_p/ k_M/ TC; 
  g_Hp = E_Hp/ L_p^3/ (1 - kap)/ E_m; 
  if strcmp(model,'hex')== 0
    stat.s_Hbp  = E_Hb/ E_Hp;                 units.s_Hbp  = '-'; label.s_Hbp  = 'maturity ratio'; temp.s_Hbp = NaN; fresp.s_Hbp = NaN;
    stat.s_HLbp =  stat.s_Hbp * (L_p/ L_b)^3; units.s_HLbp = '-'; label.s_HLbp = 'maturity density ratio at f=1'; temp.s_HLbp = NaN; fresp.s_HLbp = 1;
  else
    stat.s_Hbp = 1;                           units.s_Hbp  = '-'; label.s_Hbp  = 'maturity ratio'; temp.s_Hbp = NaN; fresp.s_Hbp = NaN;
    stat.s_HLbp = 1;                          units.s_HLbp = '-'; label.s_HLbp = 'maturity density ratio at f=1'; temp.s_HLbp = NaN; fresp.s_HLbp = 1;
  end
  stat.l_p = l_p;      units.l_p = '-';     label.l_p = 'scaled structural length at puberty'; temp.l_p = NaN; fresp.l_p = f;
  stat.L_p = L_p;      units.L_p = 'cm';    label.L_p = 'structural length at puberty'; temp.L_p = NaN; fresp.L_p = f;
  stat.M_Vp = M_Vp;    units.M_Vp = 'mol';  label.M_Vp = 'structural mass at puberty'; temp.M_Vp = NaN; fresp.M_Vp = f;
  stat.M_Ep = M_Ep;    units.M_Ep = 'mol';  label.M_Ep = 'reserve mass at puberty'; temp.M_Ep = NaN; fresp.M_Ep = f;
  stat.Ww_p = Ww_p;    units.Ww_p = 'g';    label.Ww_p = 'wet weight at puberty'; temp.Ww_p = NaN; fresp.Ww_p = f;
  stat.Wd_p = Wd_p;    units.Wd_p = 'g';    label.Wd_p = 'dry weight at puberty'; temp.Wd_p = NaN; fresp.Wd_p = f;
  stat.E_Wp = E_Wp;    units.E_Wp = 'J';    label.E_Wp = 'energy content at puberty'; temp.E_Wp = NaN; fresp.E_Wp = f;
  stat.a_p = a_p;      units.a_p = 'd';     label.a_p = 'age at puberty'; temp.a_p = T; fresp.a_p = f;
  stat.g_Hp = g_Hp;    units.g_Hp = '-';    label.g_Hp = 'energy divestment ratio at puberty';  temp.g_Hp = NaN; fresp.g_Hp = NaN;
  %
  if stat.c_T * p_Am * s_M * L_p^2 * (1 - kap) * f * a_p < E_Hp % p_Am at T_ref, but a_p at T_typical
    fprintf('Warning from statistics_st: (1 - kap) * f * s_M * {p_Am} * L_p^2  * a_p < E_Hp \n');
  end
   
  % emergence
  switch model
    case 'hep' % acceleration between a and p; emergence at j
      L_e = L_m * l_j; M_Ve = M_V * L_e^3; M_Ee = f * E_m * L_e^3/ mu_E; E_We = M_Ve * mu_V + M_Ee * mu_E;
      Ww_e = L_e^3 * (1 + f * w); Wd_e = d_V * Ww_e; a_e = t_j/ k_M/ TC; 
      stat.l_e = l_j;   units.l_e = '-';    label.l_e = 'scaled structural length at emergence'; temp.l_e = NaN; fresp.l_e = f;
      stat.L_e = L_e;   units.L_e = 'cm';   label.L_e = 'structural length at emergence'; temp.L_e = NaN; fresp.L_e = f;
      stat.M_Ve = M_Ve; units.M_Ve = 'mol'; label.M_Ve = 'structural mass at emergence'; temp.M_Ve = NaN; fresp.M_Ve = f;
      stat.M_Ee = M_Ee; units.M_Ee = 'mol'; label.M_Ee = 'reserve mass at emergence'; temp.M_Ee = NaN; fresp.M_Ee = f;
      stat.Ww_e = Ww_e; units.Ww_e = 'g';   label.Ww_e = 'wet weight at emergence'; temp.Ww_e = NaN; fresp.Ww_e = f;
      stat.Wd_e = Wd_e; units.Wd_e = 'g';   label.Wd_e = 'dry weight at emergence'; temp.Wd_e = NaN; fresp.Wd_e = f;
      stat.E_We = E_We; units.E_We = 'J';   label.E_We = 'energy content at emergence (excl rep buffer)'; temp.E_We = NaN; fresp.E_We = f;
      stat.a_e = a_e;   units.a_e = 'd';    label.a_e = 'age at emergence'; temp.a_e = T; fresp.a_e = f;
    case {'hax', 'hex'}
      L_e = L_m * l_e; M_Ve = M_V * L_e^3; M_Ee = p_Am * u_Ee * v^2/ g^2/ k_M^3; E_We = M_Ve * mu_V + M_Ee * mu_E;
      Ww_e = L_e^3 + w_E * p_Am * u_Ee * v^2/ g^2/ k_M^3/ d_E; Wd_e = d_V * Ww_e; a_e = t_e/ k_M/ TC; 
      stat.l_e = l_e;   units.l_e = '-';    label.l_e = 'scaled structural length at emergence'; temp.l_e = NaN; fresp.l_e = f;
      stat.L_e = L_e;   units.L_e = 'cm';   label.L_e = 'structural length at emergence'; temp.L_e = NaN; fresp.L_e = f;
      stat.M_Ve = M_Ve; units.M_Ve = 'mol'; label.M_Ve = 'structural mass at emergence'; temp.M_Ve = NaN; fresp.M_Ve = f;
      stat.M_Ee = M_Ee; units.M_Ee = 'mol'; label.M_Ee = 'reserve mass at emergence'; temp.M_Ee = NaN; fresp.M_Ee = f;
      stat.Ww_e = Ww_e; units.Ww_e = 'g';   label.Ww_e = 'wet weight at emergence'; temp.Ww_e = NaN; fresp.Ww_e = f;
      stat.Wd_e = Wd_e; units.Wd_e = 'g';   label.Wd_e = 'dry weight at emergence'; temp.Wd_e = NaN; fresp.Wd_e = f;
      stat.E_We = E_We; units.E_We = 'J';   label.E_We = 'energy content at emergence (excl rep buffer)'; temp.E_We = NaN; fresp.E_We = f;
      stat.a_e = a_e;   units.a_e = 'd';    label.a_e = 'age at emergence'; temp.a_e = T; fresp.a_e = f;
 end
  
  % ultimate
  L_i = L_m * l_i; M_Vi = M_V * L_i^3; M_Ei = f * E_m * L_i^3/ mu_E; E_Wi = M_Vi * mu_V + M_Ei * mu_E;
  Ww_i = L_i^3 * (1 + w * f); Wd_i = d_V * Ww_i;
  switch model
    case {'hep', 'hax'} 
      Ww_i = Ww_e; Wd_i = Wd_e; 
    case 'hex'
      Ww_i = Ww_j; Wd_i = Wd_j; % notice that Ww_i and Wd_i are set to wet weight at pupation for hex
  end
  del_Wb = Ww_b/ Ww_i; del_Wp = Ww_p/ Ww_i; 
  s_s = k_J * E_Hp * (p_M + p_T/ L_i)^2/ p_Am^3/ f^3/ s_M^3;
  stat.s_s = s_s;      units.s_s = '-';     label.s_s = 'supply stress'; temp.s_s = NaN; fresp.s_s = f;
  stat.l_i = l_i;      units.l_i = '-';     label.l_i = 'ultimate scaled structural length'; temp.l_i = NaN; fresp.l_i = f;
  stat.L_i = L_i;      units.L_i = 'cm';    label.L_i = 'ultimate structural length'; temp.L_i = NaN; fresp.L_i = f;
  stat.M_Vi = M_Vi;    units.M_Vi = 'mol';  label.M_Vi = 'ultimate structural mass'; temp.M_Vi = NaN; fresp.M_Vi = f;
  stat.M_Ei = M_Ei;    units.M_Ei = 'mol';  label.M_Ei = 'ultimate reserve mass'; temp.M_Ei = NaN; fresp.M_Ei = f;
  stat.Ww_i = Ww_i;    units.Ww_i = 'g';    label.Ww_i = 'ultimate wet weight'; temp.Ww_i = NaN; fresp.Ww_i = f;
  stat.Wd_i = Wd_i;    units.Wd_i = 'g';    label.Wd_i = 'ultimate dry weight'; temp.Wd_i = NaN; fresp.Wd_i = f;
  stat.E_Wi = E_Wi;    units.E_Wi = 'J';    label.E_Wi = 'ultimate energy content'; temp.E_Wi = NaN; fresp.E_Wi = f;
  xi_WE = 1e-3 * ((f * E_m + mu_V * M_V)/ (d_V + f * E_m * w_E/ mu_E));  % kJ/g dry weight, whole-body energy density (no reprod buffer) 
  stat.xi_WE  = xi_WE; units.xi_WE  = 'kJ/ g'; label.xi_WE   = 'whole-body energy density of dry biomass (no reprod buffer)'; temp.xi_WE = NaN; fresp.xi_WE = f;  
  stat.del_Wb  = del_Wb; units.del_Wb = '-'; label.del_Wb   = 'birth weight as fraction of maximum weight'; temp.del_Wb = NaN; fresp.del_Wb = f;        
  stat.del_Wp  = del_Wp; units.del_Wp = '-'; label.del_Wp   = 'puberty weight as fraction of maximum weight'; temp.del_Wp = NaN; fresp.del_Wp = f;
  del_V    = 1/(1 + f * w); % -, fraction of max weight that is structure
  stat.del_V  = del_V; units.del_V = '-';   label.del_V    = 'fraction of max weight that is structure'; temp.del_V = NaN; fresp.del_V = f;     
  
  % aging
  h_W = TC * (h_a * f * v * s_M/ 6/ L_i)^(1/3); h_G = TC * s_G * f * v * s_M * L_i^2/ L_m^3; h_a = h_a/ k_M^2; % overwrite of h_a!!!
  stat.h_W = h_W;      units.h_W = '1/d';   label.h_W = 'Weibull ageing rate'; temp.h_W = T; fresp.h_W = f;
  stat.h_G = h_G;      units.h_G = '1/d';   label.h_G = 'Gompertz aging rate'; temp.h_G = T; fresp.h_G = f;
  switch model
    case {'std','stf','sbp','abp'}
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_p = S(2); 
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty'; temp.S_p = NaN; fresp.S_p = f;    
    case 'stx'
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_x = S(2); S_p = S(3); 
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_x  = S_x;     units.S_x = '-';     label.S_x = 'survival probability at weaning'; temp.S_x = NaN; fresp.S_x = f;  
      stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty'; temp.S_p = NaN; fresp.S_p = f;    
    case 'ssj'
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_s = S(2); S_p = S(3);      
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_s  = S_s;     units.S_s = '-';     label.S_s = 'survival probability at metam'; temp.S_s = NaN; fresp.S_s = f;  
      stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty'; temp.S_p = NaN; fresp.S_p = f;    
    case 'abj'
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_j = S(2); S_p = S(3);      
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_j  = S_j;     units.S_j = '-';     label.S_j = 'survival probability at metam'; temp.S_j = NaN; fresp.S_j = f;  
      stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty'; temp.S_p = NaN; fresp.S_p = f;    
    case 'asj'
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_s = S(2); S_j = S(3); S_p = S(4);      
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_s  = S_s;     units.S_s = '-';     label.S_s = 'survival probability at start acceleration'; temp.S_s = NaN; fresp.S_s = f;  
      stat.S_j  = S_j;     units.S_j = '-';     label.S_j = 'survival probability at end acceleration'; temp.S_j = NaN; fresp.S_j = f;  
      stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty'; temp.S_p = NaN; fresp.S_p = f;    
    case 'hep'
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_p = S(2); S_j = S(3);     
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty'; temp.S_p = NaN; fresp.S_p = f;    
      stat.S_j  = S_j;     units.S_j = '-';     label.S_j = 'survival probability at metam'; temp.S_j = NaN; fresp.S_j = f;  
    case 'hax'
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_p = S(2); S_j = S(3); S_e = S(4);     
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty'; temp.S_p = NaN; fresp.S_p = f;    
      stat.S_j  = S_j;     units.S_j = '-';     label.S_j = 'survival probability at metam'; temp.S_j = NaN; fresp.S_j = f;  
      stat.S_e  = S_e;     units.S_e = '-';     label.S_e = 'survival probability at emergence'; temp.S_e = NaN; fresp.S_e = f;  
    case 'hex'
      [tau_m, S] = get_tm_mod(model, par, f); S_b = S(1); S_j = S(2); S_e = S(3);     
      stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth'; temp.S_b = NaN; fresp.S_b = f;  
      stat.S_j  = S_j;     units.S_j = '-';     label.S_j = 'survival probability at metam'; temp.S_j = NaN; fresp.S_j = f;  
      stat.S_e  = S_e;     units.S_e = '-';     label.S_e = 'survival probability at emergence'; temp.S_e = NaN; fresp.S_e = f;  
  end
  a_m = tau_m/ k_M/ TC;
  stat.a_m = a_m;      units.a_m = 'd';     label.a_m = 'life span'; temp.a_m = T; fresp.a_m = f;

  % growth period
  if exist('r_B', 'var')
    switch model
      case {'std', 'stx'}
        a_99   = a_b + log((1 - L_b/ L_i)/(1 - 0.99))/ r_B; % endotherms sometimes have L_p very close to L_i
        stat.a_99 = a_99;   units.a_99 = 'd';   label.a_99 = 'age at length 0.99 * L_i'; temp.a_99 = T; fresp.a_99 = f;
      otherwise
        a_99   = a_p + log((1 - L_p/ L_i)/(1 - 0.99))/ r_B;
        stat.a_99 = a_99;   units.a_99 = 'd';   label.a_99 = 'age at length 0.99 * L_i'; temp.a_99 = T; fresp.a_99 = f;
    end
  end

  % reproduction
  switch model
    case {'std', 'ssj'}
      pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp]; 
      R_i = TC * reprod_rate(L_i, f, pars_R);
      N_i = cum_reprod(a_m * TC, f, pars_R);
    case 'sbp'
      R_i = TC * kap_R * (p_Am * L_p^2 - p_M * L_p^3 - k_J * E_Hp)/ E_0; 
      N_i = R_i * (a_m - a_p);
    case {'stf', 'stx'}
      pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp]; 
      R_i = TC * reprod_rate_foetus(L_i, f, pars_R);   
      N_i = cum_reprod(a_m * TC, f, pars_R);
    case 'abj'
      pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp]; 
      R_i = TC * reprod_rate_j(L_i, f, pars_R);                    
      N_i = cum_reprod_j(a_m * TC, f, pars_R);
    case 'asj'
      pars_R = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hs; U_Hj; U_Hp]; 
      R_i = TC * reprod_rate_s(L_i, f, pars_R); 
      N_i = cum_reprod_s(a_m * TC, f, pars_R);
    case 'abp'
      R_i = TC * kap_R * (p_Am * s_M * L_p^2 - p_M * L_p^3 - k_J * E_Hp)/ E_0; 
      N_i = R_i * (a_m - a_p);
    case {'hep','hax'}
      N_i = kap_R * (1 - kap) * v_Rj * l_j^3/ u_E0; % # of eggs at j
    case 'hex' 
      E_Rj = v_Rj * (1 - kap) * g * E_m * L_j^3; % J, reproduction buffer at pupation
      N_i = kap_R * E_Rj/ E_0;                   % #/d, ultimate reproduction rate at T
  end
  if exist('R_i','var')
    stat.R_i = R_i;  units.R_i = '1/d';  label.R_i = 'ultimate reproduction rate';  temp.R_i = T; fresp.R_i = f;
  end
  stat.N_i = N_i;  units.N_i = '#';    label.N_i = 'life time reproductive output';  temp.N_i = NaN; fresp.N_i = f;
 
  % feeding: std, stf, stx, ssj, sbp, abj, asj, abp, hep, hex
  switch model
    case {'std', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hax', 'hex'} %  egg (not foetus)
      % min possible egg sizes as determined by the maternal effect rule (e = f)
      [eb_min, lb_min, uE0_min, info] = get_eb_min([g; k; v_Hb]); % growth, maturation cease at birth
      if info ~= 1
        fprintf('warning in get_eb_min: no convergence \n')
      end
      M_E0_min = L_m^3 * E_m * g * uE0_min/ mu_E; % mol, initial reserve (of embryo) at eb_min
      stat.M_E0_min_G = M_E0_min(1); units.M_E0_min_G = 'mol'; label.M_E0_min_G = 'egg mass whereby growth ceases at birth'; temp.M_E0_min_G = NaN; fresp.M_E0_min_G = NaN;  
      stat.M_E0_min_R = M_E0_min(2); units.M_E0_min_R = 'mol'; label.M_E0_min_R = 'egg mass whereby maturation ceases at birth'; temp.M_E0_min_R = NaN; fresp.M_E0_min_R = NaN;
      stat.eb_min_G = eb_min(1); units.eb_min_G = '-'; label.eb_min_G = 'scaled reserve density whereby growth ceases at birth'; temp.eb_min_G = NaN; fresp.eb_min_G = NaN;
      stat.eb_min_R = eb_min(2); units.eb_min_R = '-'; label.eb_min_R = 'scaled reserve density whereby maturation ceases at birth'; temp.eb_min_R = NaN; fresp.eb_min_R = NaN;   
  end
  switch model
    case {'std', 'stf', 'stx', 'ssj', 'sbp'}
      ep_min  = get_ep_min([k; l_T; v_Hp]); % growth and maturation cease at puberty   
      stat.ep_min = ep_min; units.ep_min = '-'; label.ep_min = 'scaled reserve density whereby maturation and growth cease at puberty'; temp.ep_min = NaN; fresp.ep_min = NaN;   
      stat.sM_min = 1; units.sM_min = '-'; label.sM_min = 'acceleration factor whereby maturation ceases at puberty'; temp.sM_min = NaN; fresp.sM_min = NaN;   
    case {'abj', 'abp', 'hep', 'hax'} 
      [ep_min, sM_min, info] = get_ep_min_j([g; k; l_T; v_Hb; v_Hj; v_Hp]); % growth and maturation cease at puberty   
      if info ~= 1
        fprintf('warning in get_ep_min_j: no convergence \n')
      end
      stat.ep_min = ep_min; units.ep_min = '-'; label.ep_min = 'scaled reserve density whereby maturation and growth cease at puberty'; temp.ep_min = NaN; fresp.ep_min = NaN;
      stat.sM_min = sM_min; units.sM_min = '-'; label.sM_min = 'acceleration factor whereby maturation ceases at puberty'; temp.sM_min = NaN; fresp.sM_min = NaN;   
    case 'asj'
      [ep_min, sM_min, info] = get_ep_min_s([g; k; l_T; v_Hb; v_Hs; v_Hj; v_Hp]); % growth and maturation cease at puberty   
      if info ~= 1
        fprintf('warning in get_ep_min_s: no convergence \n')
      end
      stat.ep_min = ep_min; units.ep_min = '-'; label.ep_min = 'scaled reserve density whereby maturation and growth cease at puberty'; temp.ep_min = NaN; fresp.ep_min = NaN;
      stat.sM_min = sM_min; units.sM_min = '-'; label.sM_min = 'acceleration factor whereby maturation ceases at puberty'; temp.sM_min = NaN; fresp.sM_min = NaN;   
    case 'hex'
      stat.ep_min = eb_min(2); units.ep_min = '-'; label.ep_min= 'minimum scaled functional response to reach pupation'; temp.ep_min = NaN; fresp.ep_min = NaN;   
      stat.sM_min = 1; units.sM_min = '-'; label.sM_min = 'acceleration factor at ep_min'; temp.sM_min = NaN; fresp.sM_min = NaN;   
  end
  if exist('kap_X', 'var') && exist('kap_P', 'var')
    p_Xb = TC * f * p_Xm * L_b^2; J_Xb = TC * f * J_X_Am * L_b^2; F_mb = TC * F_m * L_b^2;       
    stat.p_Xb = p_Xb; units.p_Xb = 'J/d'; label.p_Xb = 'food intake at birth'; temp.p_Xb = T; fresp.p_Xb = f; 
    stat.J_Xb = J_Xb; units.J_Xb = 'mol/d'; label.J_Xb = 'food intake at birth';  temp.J_Xb = T; fresp.J_Xb = f;  
    stat.F_mb = F_mb; units.F_mb = 'l/d'; label.F_mb = 'max searching rate at birth'; temp.F_mb = T; fresp.F_mb = f;   
    p_Xp = TC * f * p_Xm * L_p^2; J_Xp = TC * f * J_X_Am * L_p^2; F_mp = TC * F_m * L_p^2;         
    stat.p_Xp = p_Xp; units.p_Xp = 'J/d'; label.p_Xp = 'food intake at puberty'; temp.p_Xp = T; fresp.p_Xp = f;   
    stat.J_Xp = J_Xp; units.J_Xp = 'mol/d'; label.J_Xp = 'food intake at puberty';  temp.J_Xp = T; fresp.J_Xp = f;  
    stat.F_mp = F_mp; units.F_mp = 'l/d'; label.F_mp = 'max searching rate at puberty'; temp.F_mp = T; fresp.F_mp = f;   
    p_Xi = TC * f * p_Xm * L_i^2; J_Xi = TC * f * J_X_Am * L_i^2; F_mi = TC * F_m * L_i^2;
    stat.p_Xi = p_Xi; units.p_Xi = 'J/d'; label.p_Xi = 'ultimate food intake'; temp.p_Xi = T; fresp.p_Xi = f;  
    stat.J_Xi = J_Xi; units.J_Xi = 'mol/d'; label.J_Xi = 'ultimate food intake'; temp.J_Xi = T; fresp.J_Xi = f;
    stat.F_mi = F_mi; units.F_mi = 'l/d'; label.F_mi = 'max ultimate searching rate'; temp.F_mi = T; fresp.F_mi = f;   
  end

  % powers
  p_ref = TC * p_Am * L_m^2;        % J/d, max assimilation power at max size
  switch model
    case {'std', 'stf', 'stx', 'ssj'}
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp]; 
      if L_i < L_p || L_i - L_p < 1e-8
        p_ACSJGRD = p_ref * scaled_power([L_b + 1e-6; L_p; L_p + 1e-8], f, pars_power, l_b, l_p);
      else
        p_ACSJGRD = p_ref * scaled_power([L_b + 1e-6; L_p; L_i], f, pars_power, l_b, l_p);
      end
    case 'sbp' % no growth, no kappa rule after p
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp];  
      p_ACSJGRD = p_ref * scaled_power([L_b + 1e-6; L_p; L_i + 1e-8], f, pars_power, l_b, l_p); 
      p_ACSJGRD(3,6) = sum(p_ACSJGRD(3,[5 6]),2); p_ACSJGRD(3,5) = 0;
    case 'abp'% no growth, no kappa rule after p
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp; U_Hp + 1e-6];  
      p_ACSJGRD = p_ref * scaled_power_j([L_b + 1e-6; L_p; L_i], f, pars_power, l_b, l_j, l_p);
      p_ACSJGRD(3,6) = sum(p_ACSJGRD(3,[5 6]),2); p_ACSJGRD(3,5) = 0;
    case 'abj'
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp];  
      p_ACSJGRD = p_ref * scaled_power_j([L_b + 1e-6; L_p; L_i], f, pars_power, l_b, l_j, l_p);
    case 'asj'
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hs; U_Hj; U_Hp];  
      p_ACSJGRD = p_ref * scaled_power_s([L_b + 1e-6; L_p; L_i], f, pars_power, l_b, l_s, l_j, l_p); 
    case 'hep' % ultimate is here mapped to metam
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp; U_Hp + 1e-8]; 
      p_ACSJGRD = p_ref * scaled_power_j([L_b + 1e-6; L_p; L_j], f, pars_power, l_b, l_p, l_j);
    case 'hax' % ultimate is here mapped to pupation
      pars_power = [kap; kap_V; kap_R; g; k_J; k_M; v; U_Hb; U_Hp; U_He]; 
      p_ACSJGRD = p_ref * scaled_power_hax([L_b; L_p; L_j], f, pars_power, l_b, l_p, l_j, l_e, t_j);
    case 'hex' % birth and puberty coincide; ultimate is here mapped to pupation
      pars_power = [kap; kap_V; kap_R; g; k_J; k_M; v; U_Hb; U_He]; 
      p_ACSJGRD = p_ref * scaled_power_hex([L_b; L_b + 1e-6; L_j], f, pars_power, l_b, l_j, l_e, t_j);
  end
  stat.p_Ab = p_ACSJGRD(1,1); units.p_Ab = 'J/d'; label.p_Ab = 'assimilation at birth'; temp.p_Ab = T; fresp.p_Ab = f;   
  stat.p_Cb = p_ACSJGRD(1,2); units.p_Cb = 'J/d'; label.p_Cb = 'mobilisation at birth'; temp.p_Cb = T; fresp.p_Cb = f;   
  stat.p_Sb = p_ACSJGRD(1,3); units.p_Sb = 'J/d'; label.p_Sb = 'somatic maintenance at birth'; temp.p_Sb = T; fresp.p_Sb = f;    
  stat.p_Jb = p_ACSJGRD(1,4); units.p_Jb = 'J/d'; label.p_Jb = 'maturity maintenance at birth'; temp.p_Jb = T; fresp.p_Jb = f;   
  stat.p_Gb = p_ACSJGRD(1,5); units.p_Gb = 'J/d'; label.p_Gb = 'growth at birth'; temp.p_Gb = T; fresp.p_Gb = f;   
  stat.p_Rb = p_ACSJGRD(1,6); units.p_Rb = 'J/d'; label.p_Rb = 'maturation at birth'; temp.p_Rb = T; fresp.p_Rb = f;   
  stat.p_Db = p_ACSJGRD(1,7); units.p_Db = 'J/d'; label.p_Db = 'dissipation at birth'; temp.p_Db = T; fresp.p_Db = f;  
  stat.p_Ap = p_ACSJGRD(2,1); units.p_Ap = 'J/d'; label.p_Ap = 'assimilation at puberty'; temp.p_Ap = T; fresp.p_Ap = f;   
  stat.p_Cp = p_ACSJGRD(2,2); units.p_Cp = 'J/d'; label.p_Cp = 'mobilisation at puberty'; temp.p_Cp = T; fresp.p_Cp = f;   
  stat.p_Sp = p_ACSJGRD(2,3); units.p_Sp = 'J/d'; label.p_Sp = 'somatic maintenance at puberty';  temp.p_Sp = T; fresp.p_Sp = f;  
  stat.p_Jp = p_ACSJGRD(2,4); units.p_Jp = 'J/d'; label.p_Jp = 'maturity maintenance at puberty';  temp.p_Jp = T; fresp.p_Jp = f;  
  stat.p_Gp = p_ACSJGRD(2,5); units.p_Gp = 'J/d'; label.p_Gp = 'growth at puberty';  temp.p_Gp = T; fresp.p_Gp = f;  
  stat.p_Rp = p_ACSJGRD(2,6); units.p_Rp = 'J/d'; label.p_Rp = 'reproduction at puberty'; temp.p_Rp = T; fresp.p_Rp = f;   
  stat.p_Dp = p_ACSJGRD(2,7); units.p_Dp = 'J/d'; label.p_Dp = 'dissipation at puberty'; temp.p_Dp = T; fresp.p_Dp = f;   
  stat.p_Ai = p_ACSJGRD(3,1); units.p_Ai = 'J/d'; label.p_Ai = 'ultimate assimilation'; temp.p_Ai = T; fresp.p_Ai = f;   
  stat.p_Ci = p_ACSJGRD(3,2); units.p_Ci = 'J/d'; label.p_Ci = 'ultimate mobilisation'; temp.p_Ci = T; fresp.p_Ci = f;   
  stat.p_Si = p_ACSJGRD(3,3); units.p_Si = 'J/d'; label.p_Si = 'ultimate somatic maintenance'; temp.p_Si = T; fresp.p_Si = f;    
  stat.p_Ji = p_ACSJGRD(3,4); units.p_Ji = 'J/d'; label.p_Ji = 'ultimate maturity maintenance'; temp.p_Ji = T; fresp.p_Ji = f;   
  stat.p_Gi = p_ACSJGRD(3,5); units.p_Gi = 'J/d'; label.p_Gi = 'ultimate growth';  temp.p_Gi = T; fresp.p_Gi = f;  
  stat.p_Ri = p_ACSJGRD(3,6); units.p_Ri = 'J/d'; label.p_Ri = 'ultimate reproduction'; temp.p_Ri = T; fresp.p_Ri = f;   
  stat.p_Di = p_ACSJGRD(3,7); units.p_Di = 'J/d'; label.p_Di = 'ultimate dissipation'; temp.p_Di = T; fresp.p_Di = f;   

  % mass fluxes (respiration)
  X_gas = T_ref/ T/ 24.4;       % M, mol of gas per litre at T_ref (= 20 C) and 1 bar 
  p_ADG = p_ACSJGRD(:,[1 7 5]); % J/d, assimilation, dissipation, growth powers
  n_Ow = n_O; x = (1 - [d_X d_V d_E d_P])/ 18; n_Ow(2,:) = n_O(2,:) + 2 * x; n_Ow(3,:) = n_O(3,:) + x; % convert dry to wet mass
  J_O = eta_O * p_ADG'; J_M = - (n_M\n_Ow) * J_O; % rows: CHON, cols: bpi
  stat.J_Cb = J_M(1,1); units.J_Cb = 'mol/d'; label.J_Cb = 'CO2 flux at birth'; temp.J_Cb = T; fresp.J_Cb = f;   
  stat.J_Cp = J_M(1,2); units.J_Cp = 'mol/d'; label.J_Cp = 'CO2 flux at puberty'; temp.J_Cp = T; fresp.J_Cp = f;   
  stat.J_Ci = J_M(1,3); units.J_Ci = 'mol/d'; label.J_Ci = 'ultimate CO2 flux';temp.J_Ci = T; fresp.J_Ci = f;    
  stat.J_Hb = J_M(2,1); units.J_Hb = 'mol/d'; label.J_Hb = 'water flux at birth'; temp.J_Hb = T; fresp.J_Hb = f;   
  stat.J_Hp = J_M(2,2); units.J_Hp = 'mol/d'; label.J_Hp = 'water flux at puberty'; temp.J_Hp = T; fresp.J_Hp = f;   
  stat.J_Hi = J_M(2,3); units.J_Hi = 'mol/d'; label.J_Hi = 'ultimate water flux'; temp.J_Hi = T; fresp.J_Hi = f;    
  stat.J_Ob = -J_M(3,1); units.J_Ob = 'mol/d'; label.J_Ob = 'O2 flux at birth'; temp.J_Ob = T; fresp.J_Ob = f;   
  stat.J_Op = -J_M(3,2); units.J_Op = 'mol/d'; label.J_Op = 'O2 flux at puberty'; temp.J_Op = T; fresp.J_Op = f;   
  stat.J_Oi = -J_M(3,3); units.J_Oi = 'mol/d'; label.J_Oi = 'ultimate O2 flux'; temp.J_Oi = T; fresp.J_Oi = f;   
  stat.J_Nb = J_M(4,1); units.J_Nb = 'mol/d'; label.J_Nb = 'N-waste flux at birth'; temp.J_Nb = T; fresp.J_Nb = f;   
  stat.J_Np = J_M(4,2); units.J_Np = 'mol/d'; label.J_Np = 'N-waste flux at puberty'; temp.J_Np = T; fresp.J_Np = f;   
  stat.J_Ni = J_M(4,3); units.J_Ni = 'mol/d'; label.J_Ni = 'ultimate N-waste flux';  temp.J_Ni = T; fresp.J_Ni = f;  

  % mass flux ratios and heat
  mu_O = [mu_X; mu_V; mu_E; mu_P];% J/mol, chemical potentials of organics
  mu_M = [0; 0; 0; 0];            % J/mol, chemical potentials of minerals C: CO2, H: H2O, O: O2, N: NH3
  % at birth
  J_O = eta_O * diag(p_ADG(1,:)); % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
  J_M = - (n_M\n_O) * J_O;        % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
  stat.RQ_b = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3)); units.RQ_b = 'mol C/mol O'; label.RQ_b = 'resp quotient at birth'; temp.RQ_b = NaN; fresp.RQ_b = f;
  stat.UQ_b = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3)); units.UQ_b = 'mol N/mol O'; label.UQ_b = 'urine quotient at birth'; temp.UQ_b = NaN; fresp.UQ_b = f;
  stat.WQ_b = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3)); units.WQ_b = 'mol H/mol O'; label.WQ_b = 'water quotient at birth'; temp.WQ_b = NaN; fresp.WQ_b = f;
  stat.SDA_b = J_M(3,1)/ J_O(1,1); units.SDA_b = 'mol O/mol X'; label.SDA_b = 'specific dynamic action at birth'; temp.SDA_b = NaN; fresp.SDA_b = f;
  stat.VO_b = J_M(3,2)/ Wd_b/ 24/ X_gas; units.VO_b = 'L/h.g'; label.VO_b = 'dioxygen use per gram max dry weight, <J_OD> at birth'; temp.VO_b = T; fresp.VO_b = f;
  stat.p_Tb = sum(- J_O' * mu_O - J_M' * mu_M); units.p_Tb = 'J/d'; label.p_Tb = 'total heat at birth'; temp.p_Tb = T; fresp.p_Tb = f;
  % at puberty
  J_O = eta_O * diag(p_ADG(2,:)); % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
  J_M = - (n_M\n_O) * J_O;        % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
  stat.RQ_p = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3)); units.RQ_p = 'mol C/mol O'; label.RQ_p = 'resp quotient at puberty'; temp.RQ_p = NaN; fresp.RQ_p = f;
  stat.UQ_p = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3)); units.UQ_p = 'mol N/mol O'; label.UQ_p = 'urine quotient at puberty'; temp.UQ_p = NaN; fresp.UQ_p = f;
  stat.WQ_p = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3)); units.WQ_p = 'mol H/mol O'; label.WQ_p = 'water quotient at puberty'; temp.WQ_p = NaN; fresp.WQ_p = f;
  stat.SDA_p = J_M(3,1)/ J_O(1,1); units.SDA_p = 'mol O/mol X'; label.SDA_p = 'specific dynamic action at puberty'; temp.SDA_p = NaN; fresp.SDA_p = f;
  stat.VO_p = J_M(3,2)/ Wd_p/ 24/ X_gas; units.VO_p = 'L/h.g'; label.VO_p = 'dioxygen use per gram max dry weight, <J_OD> at puberty'; temp.VO_p = T; fresp.VO_p = f;
  stat.p_Tp = sum(- J_O' * mu_O - J_M' * mu_M); units.p_Tp = 'J/d'; label.p_Tp = 'total heat at puberty'; temp.p_Tp = T; fresp.p_Tp = f;
  % at ultimate
  J_O = eta_O * diag(p_ADG(3,:)); % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
  J_M = - (n_M\n_O) * J_O;        % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
  stat.RQ_i = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3)); units.RQ_i = 'mol C/mol O'; label.RQ_i = 'ultimate resp quotient'; temp.RQ_i = NaN; fresp.RQ_i = f;
  stat.UQ_i = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3)); units.UQ_i = 'mol N/mol O'; label.UQ_i = 'ultimate urine quotient'; temp.UQ_i = NaN; fresp.UQ_i = f;
  stat.WQ_i = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3)); units.WQ_i = 'mol H/mol O'; label.WQ_i = 'ultimate water quotient'; temp.WQ_i = NaN; fresp.WQ_i = f;
  stat.SDA_i = J_M(3,1)/ J_O(1,1); units.SDA_i = 'mol O/mol X'; label.SDA_i = 'ultimate specific dynamic action'; temp.SDA_i = NaN; fresp.SDA_i = f;
  stat.VO_i = J_M(3,2)/ Wd_i/ 24/ X_gas; units.VO_i = 'L/h.g'; label.VO_i = 'ultimate dioxygen use per gram max dry weight, <J_OD>'; temp.VO_i = T; fresp.VO_i = f;
  stat.p_Ti = sum(- J_O' * mu_O - J_M' * mu_M); units.p_Ti = 'J/d'; label.p_Ti = 'ultimate total heat'; temp.p_Ti = T; fresp.p_Ti = f;

  % packing
  txtStat.units = units;
  txtStat.label = label;
  txtStat.temp  = temp;
  txtStat.fresp = fresp;

end

% subfunction

function deLH = dget_eLH(t, eLH, kap, v, g, Lm, kJ, Em)
  % growth while f = 0
  % unpack state vars
  e = eLH(1);   % -, scaled reserve density
  L = eLH(2);   % cm, structural length
  EH = eLH(3); % J, maturity
  
  de = - e * v/ L;

  r = v * (e/ L - 1/ Lm)/ (e + g);
  dL = L * r/ 3;

  pC = - (de + e * r) * Em * L^3;
  dH = (1 - kap) * pC - kJ * EH;

  % pack derivatives
  deLH = [de; dL; dH];
end