%% statistics_st
% Computes implied properties of DEB models 

%%
function [stat txtStat] = statistics_st(model, par, T, f) 
% created 2000/11/02 by Bas Kooijman, modified 2014/03/17 
% modified 2015/03/25 by Starrlight Augustine & Goncalo Marques, 
% modified 2015/07/27 by Starrlight; 2015/08/06 by Dina Lika
% modified 2016/03/25 by Dina Lika & Goncalo Marques
% modified 2016/04/14 by Bas Kooijman, 2016/09/21 by Starrlight, 2016/09/22 by Bas Kooijman

%% Syntax
% [stat txtStat] = <statistics_st.m *statistics_st*>(model, par, T, f)

%% Description
% Computes quantites that depend on parameters, temperature and food level.
% The allowed models are: std, stf, stx, ssj, sbp, abj, asj, abp, hep, hex.
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
%     - s_H: altriciality index; all except hex
%     - s_Hbp: precociality coefficient; all
%     - r_j: exponential growth rate; all a- and h-models
%     - r_B: von Bertalannfy growth rate; all s- and a-models
%     - W_dWm: wet weight at max growth; all models
%     - dWm: max growth in wet weight; all models
%
%     - M_E*, U_H*, V_H*, u_H*, v_H* scaled maturities at all levels; all
%     - E_0: energy investment in egg/foetus; all
%     - M_E0: reserve invested in egg/foetus; all
%     - Ww_0: initial wet weight; all except stf, stx
%     - Wd_0: initial dry weight; all except stf, stx
%
%     - a_h: age at hatch; all if E_Hh exists
%     - L_h: structural length at hatch; all if E_Hh exists
%     - M_Vh: structural mass at hatch; all if E_Hh exists
%     - Ww_h: wet weight at hatch; all if E_Hh exists
%     - Wd_h: dry weight at hatch; all if E_Hh exists
%     - del_Uh: fraction of reserve left at hatch; all if E_Hh exists
%
%     - a_b: age at birth; all (called gestation for stf and stx)
%     - t_g: gestation time; stf, stx
%     - L_b: structural length at birth; all
%     - M_Vb: structural mass at birth; all
%     - Ww_b: wet weight at birth; all
%     - Wd_b: dry weight at birth; all
%     - del_Ub: fraction of reserve left at birth; all
%     - g_Hb: energy outvestment ratio at birth; all
%
%     - a_p: age at puberty; all
%     - L_p: structural length at puberty; all
%     - M_Vp: structural mass at puberty; all
%     - Ww_p: wet weight at puberty; all
%     - Wd_p: dry weight at puberty; all
%     - g_Hp: energy outvestment ratio at puberty; all
%
%     - L_i: ultimate structural length; all 
%     - M_Vi: ultimate structural mass; all
%     - Ww_i: ultimate structural weight; all
%     - Wd_i: ultimate structural dry weight; all
%     - del_V: fraction of max weight that is structure; all
%     - xi_WE: whole-body energy density (no reprod buffer) 
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
%     - GSI: gonado-somatic index for spawning once per yr: all except hep, hex
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
%     - p_A*, p_S*, p_J*, p_G*, p_R* : energy fluxes at b, p, i ; all
%     - J_Cb, J_Cp, J_Ci: carbon dioxide production at birth, puberty, ultimate; all
%     - J_Ob, J_Op, J_Oi: dioxygen consumption at birth, puberty, ultimate; all
%     - J_Nb, J_Np, J_Ni: nitrogen waste production at birth, puberty, ultimate; all
%
%     - RQ_b, RQ_p, RQ_i: respiration quotient; all
%     - UQ_b, UQ_p, UQ_i: urination quotient; all
%     - WQ_b, WQ_p, WQ_i: watering quotient; all
%     - SDA_b, SDA_p, SDA_i: specific dynamic action; all
%     - VO_b, VO_p, VO_i: dry-weight specific dioxygen use; all
%     - p_Tt_b, p_Tt_p, p_Tt_i: dissipating heat; all
%
% * txtStat: structure with units, labels for stat

%% Remarks
% Assumes that parameters are given in standard units (d, cm, mol, J, K); this is not checked!
% Buffer handling rules are species-specific, so ultimate reproduction rate Ri not always makes sense.
% Fermentation is supposed not to occur and dioxygen availebility is assumed to be unlimiting.
% Ages exclude initial delay of development, if it would exist.
% Body weights exclude possible contribution of the reproduction buffer.
% Temperature-dependent quantities are directly corrected for body temperature
% For required model-specific fields, see get_parfields.

%% Example of use
% load('results_species.mat'); [stat, txtStat] = statistics_st(metaPar.model, par); printstat_st(stat, txtStat)

  
  choices = {'std', 'stf', 'stx', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hex'};
  if ~any(strcmp(model,choices))
    fprintf('warning statistics_st: invalid model key \n')
    stat = []; txtStat = [];
    return;
  end    
     
  if ~exist('T', 'var') || isempty(T)
    T = C2K(20);
  end
 
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
  stat.f = f; units.f = '-'; label.f = 'scaled functional response'; 
  stat.T = K2C(T); units.T = 'C'; label.T = 'body temperature';
  pars_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    pars_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  TC = tempcorr(T, T_ref, pars_T);   % -, Temperature Correction factor
  stat.c_T = TC; units.c_T = '-'; label.c_T = 'Temperature Correction factor';
  
  % compound parameters as computed by parscomp_st (not depending on f)
  % conditional additions are copied from those in parscomp_st
  stat.p_Am = p_Am; units.p_Am = 'J/d.cm^2'; label.p_Am = '{p_Am}, spec assimilation flux'; % primary parameter, not a compound one
  stat.w_X = w_X; units.w_X = 'g/mol'; label.w_X = 'molecular weight for water-free food';
  stat.w_V = w_V; units.w_V = 'g/mol'; label.w_V = 'molecular weight for water-free structure';
  stat.w_E = w_E; units.w_E = 'g/mol'; label.w_E = 'molecular weight for water-free reserve';
  stat.w_P = w_P; units.w_P = 'g/mol'; label.w_P = 'molecular weight for water-free product (feaces)';
  stat.M_V = M_V; units.M_V = 'mol/cm^3'; label.M_V = '[M_V], volume-specific mass of structure';
  stat.y_V_E = y_V_E; units.y_V_E = 'mol/mol'; label.y_V_E = 'yield of structure on reserve';
  stat.y_E_V = y_E_V; units.y_E_V = 'mol/mol'; label.y_E_V = 'yield of reserve on structure';
  stat.k_M = k_M; units.k_M = '1/d'; label.k_M = 'somatic maintenance rate coefficient';
  stat.k = k; units.k = '-'; label.k = 'maintenance ratio';
  stat.E_m = E_m; units.E_m = 'J/cm^3'; label.E_m = '[E_m], reserve capacity'; 
  stat.m_Em = m_Em; units.m_Em = 'mol/mol'; label.m_Em = 'reserve capacity';
  stat.g = g; units.g = '-'; label.g = 'energy investment ratio';
  stat.L_m = L_m; units.L_m = 'cm'; label.L_m = 'maximum structural length';
  stat.L_T= L_T; units.L_T = 'cm'; label.L_T = 'heating length (also applies to osmotic work)';
  stat.l_T = l_T; units.l_T = '-'; label.l_T = 'scaled heating length';
  stat.w = w; units.w = '-'; label.w = '\omega, contribution of ash free dry mass of reserve to total ash free dry biomass';
  stat.J_E_Am = J_E_Am; units.J_E_Am = 'mol/d.cm^2'; label.J_E_Am = '{J_EAm}, max surface-spec assimilation flux';
  if exist('kap_X', 'var')
    stat.y_E_X = y_E_X; units.y_E_X = 'mol/mol'; label.y_E_X = 'yield of reserve on food';
    stat.y_X_E = y_X_E; units.y_X_E = 'mol/mol'; label.y_X_E = 'yield of food on reserve';
    stat.p_Xm = p_Xm;   units.p_Xm = 'J/d.cm^2'; label.p_Xm = 'max spec feeding power';
    stat.J_X_Am = J_X_Am; units.J_X_Am = 'mol/d.cm^2'; label.J_X_Am = '{J_XAm}, max surface-spec feeding flux';
  end
  if exist('kap_P', 'var')
    stat.y_P_X = y_P_X; units.y_P_X = 'mol/mol'; label.y_P_X = 'yield of faeces on food'; 
    stat.y_X_P = y_X_P; units.y_X_P = 'mol/mol'; label.y_X_P = 'yield of food on faeces';
  end
  if exist('kap_X', 'var') && exist('kap_P', 'var')
    stat.y_P_E = y_P_E; units.y_P_E = 'mol/mol'; label.y_P_E = 'yield of faeces on reserve';
    stat.eta_XA = eta_XA; units.eta_XA = 'mol/J'; label.eta_XA = 'mass-power couplers for food on assimilation';
    stat.eta_PA = eta_PA; units.eta_PA = 'mol/J'; label.eta_PA = 'mass-power couplers for product on assimlation';
    stat.eta_VG = eta_VG; units.eta_VG = 'mol/J'; label.eta_VG = 'mass-power couplers for structure on growth';
  end
  stat.J_E_M = J_E_M; units.J_E_M = 'mol/d.cm^3'; label.J_E_M = '[J_EM], vol-spec somatic  maint costs';
  stat.J_E_T = J_E_T; units.J_E_T = 'mol/d.cm^2'; label.J_E_T = '{J_ET}, surface-spec somatic  maint costs';
  stat.j_E_M = j_E_M; units.j_E_M = 'mol/d.mol'; label.j_E_M = 'mass-spec somatic  maint costs';
  stat.j_E_J = j_E_J; units.j_E_J = 'mol/d.mol'; label.j_E_J = 'mass-spec maturity maint costs';
  stat.kap_G = kap_G; units.kap_G = '-'; label.kap_G = '\kappa_G, growth efficiency';
  stat.E_V = E_V; units.E_V = 'J/cm^3'; label.E_V = '[E_V], volume-specific energy of structure';
  if exist('F_m', 'var')
    stat.K = K; units.K = 'mol X/l'; label.K = 'half-saturation coefficient';
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
        stat.M_Hh = M_Hh; units.M_Hh = 'mol'; label.M_Hh = 'maturity level at hatch';
        stat.U_Hh = U_Hh; units.U_Hh = 'cm^2.d'; label.U_Hh = 'scaled maturity level at hatch';
        stat.V_Hh = V_Hh; units.V_Hh = 'cm^2.d'; label.V_Hh = 'scaled maturity level at hatch';
        stat.u_Hh = u_Hh; units.u_Hh = '-'; label.u_Hh = 'scaled maturity level at hatch';
        stat.v_Hh = v_Hh; units.v_Hh = '-'; label.v_Hh = 'scaled maturity level at hatch';
      case 'b'
        stat.M_Hb = M_Hb; units.M_Hb = 'mol'; label.M_Hb = 'maturity level at birth';
        stat.U_Hb = U_Hb; units.U_Hb = 'cm^2.d'; label.U_Hb = 'scaled maturity level at birth';
        stat.V_Hb = V_Hb; units.V_Hb = 'cm^2.d'; label.V_Hb = 'scaled maturity level at birth';
        stat.u_Hb = u_Hb; units.u_Hb = '-'; label.u_Hb = 'scaled maturity level at birth';
        stat.v_Hb = v_Hb; units.v_Hb = '-'; label.v_Hb = 'scaled maturity level at birth';
      case 'x'
        stat.M_Hx = M_Hx; units.M_Hx = 'mol'; label.M_Hx = 'maturity level at weaning/fletching';
        stat.U_Hx = U_Hx; units.U_Hx = 'cm^2.d'; label.U_Hx = 'scaled maturity level at weaning/fletching';
        stat.V_Hx = V_Hx; units.V_Hx = 'cm^2.d'; label.V_Hx = 'scaled maturity level at weaning/fletching';
        stat.u_Hx = u_Hx; units.u_Hx = '-'; label.u_Hx = 'scaled maturity level at weaning/fletching';
        stat.v_Hx = v_Hx; units.v_Hx = '-'; label.v_Hx = 'scaled maturity level at weaning/fletching';
      case 's'
        if strcmp(model, 'ssj')
          stat.M_Hs = M_Hs; units.M_Hs = 'mol'; label.M_Hs = 'maturity level at S1/S2 transition';
          stat.U_Hs = U_Hs; units.U_Hs = 'cm^2.d'; label.U_Hs = 'scaled maturity level at S1/S2 transition';
          stat.V_Hs = V_Hs; units.V_Hs = 'cm^2.d'; label.V_Hs = 'scaled maturity level at S1/S2 transition';
          stat.u_Hs = u_Hs; units.u_Hs = '-'; label.u_Hs = 'scaled maturity level at S1/S2 transition';
          stat.v_Hs = v_Hs; units.v_Hs = '-'; label.v_Hs = 'scaled maturity level at S1/S2 transition';
        else % asj
          stat.M_Hs = M_Hs; units.M_Hs = 'mol'; label.M_Hs = 'maturity level at start acceleration';
          stat.U_Hs = U_Hs; units.U_Hs = 'cm^2.d'; label.U_Hs = 'scaled maturity level at start acceleration';
          stat.V_Hs = V_Hs; units.V_Hs = 'cm^2.d'; label.V_Hs = 'scaled maturity level at start acceleration';
          stat.u_Hs = u_Hs; units.u_Hs = '-'; label.u_Hs = 'scaled maturity level at start acceleration';
          stat.v_Hs = v_Hs; units.v_Hs = '-'; label.v_Hs = 'scaled maturity level at start acceleration';
        end
      case 'j'
        stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis';
        stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis';
        stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis';
        stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis';
        stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis';
      case 'p'
        stat.M_Hp = M_Hp; units.M_Hp = 'mol'; label.M_Hp = 'maturity level at puberty';
        stat.U_Hp = U_Hp; units.U_Hp = 'cm^2.d'; label.U_Hp = 'scaled maturity level at puberty';
        stat.V_Hp = V_Hp; units.V_Hp = 'cm^2.d'; label.V_Hp = 'scaled maturity level at puberty';
        stat.u_Hp = u_Hp; units.u_Hp = '-'; label.u_Hp = 'scaled maturity level at puberty';
        stat.v_Hp = v_Hp; units.v_Hp = '-'; label.v_Hp = 'scaled maturity level at puberty';
      case 'e' % hex
        stat.M_He = M_He; units.M_He = 'mol'; label.M_He = 'maturity level at emergence';
        stat.U_He = U_He; units.U_He = 'cm^2.d'; label.U_He = 'scaled maturity level at emergence';
        stat.V_He = V_He; units.V_He = 'cm^2.d'; label.V_He = 'scaled maturity level at emergence';
        stat.u_He = u_He; units.u_He = '-'; label.u_He = 'scaled maturity level at emergence';
        stat.v_He = v_He; units.v_He = '-'; label.v_He = 'scaled maturity level at emergence';
     end  
  end

  % other compound parameters (not depending on f)
  t_E      = L_m/ v/ TC;    % d, maximum reserve residence time
  stat.t_E = t_E; units.t_E  = 'd';  label.t_E = 'maximum reserve residence time';                      
  t_starve = E_m/ p_M/ TC;  % d, max survival time when starved  
  stat.t_starve  = t_starve; units.t_starve = 'd'; label.t_starve = 'maximum survival time when starved';               

  % life cycle
  switch model
    case 'std'
      if exist('E_Hx','var')
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
    case 'stx'
      pars_tx = [g k l_T v_Hb v_Hx v_Hp]; 
      [t_p, t_x, t_b, l_p, l_x, l_b, info] = get_tx(pars_tx, f);
      if info ~= 1              
        fprintf('warning in get_tx: invalid parameter value combination for t_p \n')
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
      stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; % is not a parameter of ssj
      stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis';
      stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis';
      stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis';
      stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis';
      stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis';
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
      stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; % is not a parameter of hep
      stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis';
      stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis';
      stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis';
      stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis';
      stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis';
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
      stat.E_Hj = E_Hj; units.E_Hj = 'J'; label.E_Hj = 'maturity level at metamorphosis'; % is not a parameter of hep
      stat.M_Hj = M_Hj; units.M_Hj = 'mol'; label.M_Hj = 'maturity level at metamorphosis';
      stat.U_Hj = U_Hj; units.U_Hj = 'cm^2.d'; label.U_Hj = 'scaled maturity level at metamorphosis';
      stat.V_Hj = V_Hj; units.V_Hj = 'cm^2.d'; label.V_Hj = 'scaled maturity level at metamorphosis';
      stat.u_Hj = u_Hj; units.u_Hj = '-'; label.u_Hj = 'scaled maturity level at metamorphosis';
      stat.v_Hj = v_Hj; units.v_Hj = '-'; label.v_Hj = 'scaled maturity level at metamorphosis';
    case 'hex'
      pars_tj = [g k v_Hb v_He s_j kap kap_V];
      [t_j, t_e, t_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee, info] = get_tj_hex(pars_tj, f);
      if info ~= 1              
        fprintf('warning in get_tj_hex: invalid parameter value combination for t_p \n')
      end
      l_i = l_j; s_M = l_j/ l_b; % notice that l_i is set to scaled length at pupation for hex
      stat.E_Hp = E_Hb+1e-8; units.E_Hp = 'J'; label.E_Hp = 'maturity level at puberty'; % is not a parameter of hex
      stat.M_Hp = M_Hb+1e-8; units.M_Hp = 'mol'; label.M_Hp = 'maturity level at puberty';
      stat.U_Hp = U_Hb+1e-8; units.U_Hp = 'cm^2.d'; label.U_Hp = 'scaled maturity level at puberty';
      stat.V_Hp = V_Hb+1e-8; units.V_Hp = 'cm^2.d'; label.V_Hp = 'scaled maturity level at puberty';
      stat.u_Hp = u_Hb+1e-8; units.u_Hp = '-'; label.u_Hp = 'scaled maturity level at puberty';
      stat.v_Hp = v_Hb+1e-8; units.v_Hp = '-'; label.v_Hp = 'scaled maturity level at puberty';
  end
  
  % life cycle statistics
  stat.s_M = s_M;   units.s_M = '-';           label.s_M = 'acceleration factor at f=1'; 
  if exist('rho_j', 'var')
    r_j = rho_j * k_M * TC;
    stat.r_j = r_j; units.r_j = '1/d';         label.r_j = 'exponential growth rate'; 
  end
  if exist('rho_B', 'var')
    r_B = rho_B * k_M * TC;
    stat.r_B = r_B;    units.r_B = '1/d';      label.r_B = 'von Bertalanffy growth rate'; 
  end  
  % maximum growth
  switch model
    case {'std', 'stf', 'stx', 'ssj'}
      L_dWm = 2/3 * (L_m - L_T); W_dWm = L_dWm^3 * (1 + w);
      dWm = TC * W_dWm * 4/ 27 * g * k_M * (1 - l_T)^3/ (1 + g);
    case 'sbp'
      L_dWm = 2/3 * (L_m - L_T); W_dWm = L_dWm^3 * (1 + w);
      dWm = TC * W_dWm * 4/ 27 * g * k_M * (1 - l_T)^3/ (1 + g);
      L_p = l_p * L_m;
      if L_p < L_dWm
        L_dWm = L_p; W_dWm = L_dWm^3 * (1 + w);
        dWm = TC * 3 * (1 + w) * L_dWm^2 * r_B * (L_m - L_T - L_dWm);
      end
    case {'abj', 'asj'}
      L_dWm = 2/3 * (s_M * L_m - L_T); W_dWm = L_dWm^3 * (1 + w);
      L_j = l_j * L_m;
      if L_j > L_dWm
        L_dWm = L_j; W_dWm = L_dWm^3 * (1 + w); 
        dWm = TC * W_dWm * r_j;
      else
        dWm = TC * W_dWm * 4/ 27 * g * k_M * (1 - l_T)^3/ (1 + g);
      end
    case 'abp'
      L_p = l_p * L_m;
      L_dWm = L_p; W_dWm = L_dWm^3 * (1 + w); 
      dWm = TC * W_dWm * r_j;      
    case 'hep'
      L_dWm = 2/3 * (s_M * L_m - L_T); W_dWm = L_dWm^3 * (1 + w);
      L_p = l_p * L_m;
      if L_p > L_dWm
        L_dWm = L_p; W_dWm = L_dWm^3 * (1 + w); 
        dWm = TC * W_dWm * r_j;
      else
        dWm = TC * W_dWm * 4/ 27 * g * k_M * (1 - l_T)^3/ (1 + g);
      end
    case 'hex'
      L_j = L_m * l_j;
      L_dWm = L_j; W_dWm = L_dWm^3 * (1 + w); 
      dWm = TC * W_dWm * r_j;
  end
  stat.W_dWm = W_dWm; units.W_dWm = 'g';  label.W_dWm = 'wet weight at maximum growth'; 
  stat.dWm = dWm;     units.dWm = 'g/d';  label.dWm = 'maximum growth in wet weight'; 

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
      stat.E_0 = E_0;   units.E_0 = 'J';       label.E_0 = 'reserve invested in foetus';
      M_E0 = J_E_Am * U_E0;
      stat.M_E0 = M_E0; units.M_E0 = 'mol';    label.M_E0 = 'reserve invested in foetus';
    otherwise % egg
      [U_E0, L_b, info] = initial_scaled_reserve(f, pars_E0); % d cm^2, initial scaled reserve
      u_E0 = U_E0 * v/ g/ L_m^3;
      if info ~= 1
        fprintf('warning in initial_scaled_reserve: invalid parameter value combination for egg \n')
      end
      stat.U_E0 = U_E0; units.U_E0 = 'cm^2.d'; label.U_E0 = 'scaled initial reserve';
      E_0 = p_Am * U_E0;
      stat.E_0 = E_0;   units.E_0 = 'J';       label.E_0 = 'initial reserve';
      M_E0 = J_E_Am * U_E0; Wd_0 = M_E0 * w_E; Ww_0 = Wd_0/ d_E;
      stat.M_E0 = M_E0; units.M_E0 = 'mol';    label.M_E0 = 'initial reserve';
      stat.Wd_0 = Wd_0; units.Wd_0 = 'g';      label.Wd_0 = 'initial dry weight';
      stat.Ww_0 = Ww_0; units.Ww_0 = 'g';      label.Ww_0 = 'initial wet weight';
  end
  
  % hatch
  if any(strcmp(mat_index,'h'))     % hatching 
    [U_H aUL] = ode45(@dget_aul, [0; U_Hh; U_Hb], [0 U_E0 1e-10], [], kap, v, k_J, g, L_m);
    t_h = aUL(2,1) * k_M;           % d, age at hatch at f and T
    M_Eh = J_E_Am * aUL(end,2);     % mol, reserve at hatch at f
    l_h = aUL(2,3)/L_m;             % cm, scaled structural length at f
    L_h = L_m * l_h; M_Vh = M_V * L_h^3; Ww_h = L_h^3 + w_E * M_Eh/ d_E; Wd_h = d_V * L_h^3 + w_E * M_Eh; 
    a_h = t_h/ k_M/ TC; del_Uh = M_Eh/ M_E0; % -, fraction of reserve left at hatch
    stat.l_h = l_h;   units.l_h = '-';    label.l_h = 'scaled structural length at hatch';
    stat.L_h = L_h;   units.L_h = 'cm';   label.L_h = 'structural length at hatch';
    stat.M_Vh = M_Vh; units.M_Vh = 'mol'; label.M_Vh = 'structural mass at hatch';
    stat.del_Uh = del_Uh; units.del_Uh = '-'; label.del_Uh = 'fraction of reserve left at hatch';
    stat.Ww_h = Ww_h; units.Ww_h = 'g';   label.Ww_h = 'wet weight at hatch';
    stat.Wd_h = Wd_h; units.Wd_h = 'g';   label.Wd_h = 'dry weight at hatch';
    stat.a_h = a_h; units.a_h = 'd';      label.a_h = 'age at hatch';
  end
  
  % birth
  L_b = L_m * l_b; 
  M_Vb = M_V * L_b^3; M_Eb = f * E_m * L_b^3/ mu_E; 
  Ww_b = L_b^3 * (1 + f * w); Wd_b = d_V * Ww_b; 
  a_b = t_b/ k_M/ TC; del_Ub = M_Eb/ M_E0; % -, fraction of reserve left at birth
  g_Hb = E_Hb/ L_b^3/ (1 - kap)/ E_m; 
  stat.l_b = l_b;   units.l_b = '-';      label.l_b = 'scaled structural length at birth';
  stat.L_b = L_b;   units.L_b = 'cm';     label.L_b = 'structural length at birth';
  stat.M_Vb = M_Vb; units.M_Vb = 'mol';   label.M_Vb = 'structural mass at birth';
  stat.del_Ub = del_Ub; units.del_Ub = '-'; label.del_Ub = 'fraction of reserve left at birth';
  stat.Ww_b = Ww_b; units.Ww_b = 'g';     label.Ww_b = 'wet weight at birth';
  stat.Wd_b = Wd_b; units.Wd_b = 'g';     label.Wd_b = 'dry weight at birth';
  stat.a_b = a_b;   units.a_b = 'd';      
  switch model
    case {'stf', 'stx'} % foetus
    label.a_b = 'gestation';
    if exist('t_0','var')==0
        t_0 = 0;
    end
    t_g = t_0 + a_b; % gestation/incubation time. Note that t_0 is always given at T_body!

    stat.t_g = t_g; units.t_g = 'd'; label.t_g = 'gestation time'; 
    otherwise
  label.a_b = 'age at birth';
  end
  stat.g_Hb = g_Hb; units.g_Hb = '-';     label.g_Hb = 'energy outvestment ratio at birth'; 
  
  %
  
  % start/end shrinking
  if strcmp(model, 'ssj')
    L_s = L_m * l_s; M_Vs = M_V * L_s^3; Ww_s = L_s^3 * (1 + w * f); Wd_s = d_V * Ww_s; a_s = t_s/ k_M/ TC; 
    stat.l_s = l_s;   units.l_s = '-';    label.l_s = 'scaled structural length at start strinking';
    stat.L_s = L_s;   units.L_s = 'cm';   label.L_s = 'structural length at start strinking';
    stat.M_Vs = M_Vs; units.M_Vs = 'mol'; label.M_Vs = 'structural mass at start strinking';
    stat.Ww_s = Ww_s; units.Ww_s = 'g';   label.Ww_s = 'wet weight at start strinking';
    stat.Wd_s = Wd_s; units.Wd_s = 'g';   label.Wd_s = 'dry weight at start strinking';
    stat.a_s = a_s;   units.a_s = 'd';    label.a_s = 'age at start strinking';
    M_Vj = M_V * L_j^3; Ww_j = L_j^3 * (1 + w * f); Wd_j = d_V * Ww_j; 
    stat.l_s = l_j;   units.l_j = '-';    label.l_j = 'scaled structural length at end strinking';
    stat.L_s = L_j;   units.L_j = 'cm';   label.L_j = 'structural length at end strinking';
    stat.M_Vj = M_Vj; units.M_Vj = 'mol'; label.M_Vj = 'structural mass at end strinking';
    stat.Ww_j = Ww_j; units.Ww_j = 'g';   label.Ww_j = 'wet weight at end strinking';
    stat.Wd_j = Wd_j; units.Wd_j = 'g';   label.Wd_j = 'dry weight at end strinking';
    stat.a_j = a_s + t_sj; units.a_j = 'd'; label.a_j = 'age at end strinking';
  end
  
  % start acceleration
  if strcmp(model, 'asj')
    L_s = L_m * l_s; M_Vs = M_V * L_s^3; Ww_s = L_s^3 * (1 + w * f); Wd_s = d_V * Ww_s; a_s = t_s/ k_M/ TC; 
    stat.l_s = l_s;   units.l_s = '-';     label.l_s = 'scaled structural length at start acceleration';
    stat.L_s = L_s;   units.L_s = 'cm';    label.L_s = 'structural length at start acceleration';
    stat.M_Vs = M_Vs; units.M_Vs = 'mol';  label.M_Vs = 'structural mass at start acceleration';
    stat.Ww_s = Ww_s; units.Ww_s = 'g';    label.Ww_s = 'wet weight at start acceleration';
    stat.Wd_s = Wd_s; units.Wd_s = 'g';    label.Wd_s = 'dry weight at start acceleration';
    stat.a_s = a_s;   units.a_s = 'd';     label.a_s = 'age at start acceleration';
  end
  
  if strcmp(model, 'hex')
    l_p = l_b; t_p = t_b; E_Hp = E_Hb; U_Hp = U_Hb; V_Hp = V_Hb; u_Hp = u_Hb; v_Hp = v_Hb;
  end
        
  % metamorphosis
  switch model
    case {'abj', 'asj', 'abp', 'hep', 'hex'}
      L_j = L_m * l_j; M_Vj = M_V * L_j^3; Ww_j = L_j^3 * (1 + w * f); Wd_j = d_V * Ww_j; a_j = t_j/ k_M/ TC; 
      stat.l_j = l_j;   units.l_j = '-';    label.l_j = 'scaled structural length at metamorphosis';
      stat.L_j = L_j;   units.L_j = 'cm';   label.L_j = 'structural length at metamorphosis';
      stat.M_Vj = M_Vj; units.M_Vj = 'mol'; label.M_Vj = 'structural mass at metamorphosis';
      stat.Ww_j = Ww_j; units.Ww_j = 'g';   label.Ww_j = 'wet weight at metamorphosis';
      stat.Wd_j = Wd_j; units.Wd_j = 'g';   label.Wd_j = 'dry weight at metamorphosis';
      stat.a_j = a_j;   units.a_j = 'd';    label.a_j = 'age at metamorphosis';
  end
  
  % puberty
  L_p = L_m * l_p; M_Vp = M_V * L_p^3; Ww_p = L_p^3 * (1 + w * f); Wd_p = d_V * Ww_p; a_p = t_p/ k_M/ TC; 
  g_Hp = E_Hp/ L_p^3/ (1 - kap)/ E_m; s_Hbp = g_Hb/ g_Hp;
  stat.l_p = l_p;      units.l_p = '-';     label.l_p = 'scaled structural length at puberty';
  stat.L_p = L_p;      units.L_p = 'cm';    label.L_p = 'structural length at puberty';
  stat.M_Vp = M_Vp;    units.M_Vp = 'mol';  label.M_Vp = 'structural mass at puberty';
  stat.Ww_p = Ww_p;    units.Ww_p = 'g';    label.Ww_p = 'wet weight at puberty';
  stat.Wd_p = Wd_p;    units.Wd_p = 'g';    label.Wd_p = 'dry weight at puberty';
  stat.a_p = a_p;      units.a_p = 'd';     label.a_p = 'age at puberty';
  stat.g_Hp = g_Hp;    units.g_Hp = '-';    label.g_Hp = 'energy outvestment ratio at puberty'; 
  stat.s_Hbp = s_Hbp;  units.s_Hbp = '-';   label.s_Hbp = 'precociality coefficient'; 
  
  if strcmp(model,'hex')== 0
  % altriciality index:
  stat.s_H = log10(E_Hp/E_Hb); units.s_H = '-'; label.s_H =  'log 10 altriciality index';
  end
  
  % emergence
  switch model
    case 'hep' % acceleration between a and p; emergence at j
      L_e = L_m * l_j; M_Ve = M_V * L_e^3; Ww_e = L_e^3 * (1 + f * w); Wd_e = d_V * Ww_e; a_e = t_j/ k_M/ TC; 
      stat.l_e = l_j;   units.l_e = '-';    label.l_e = 'scaled structural length at emergence';
      stat.L_e = L_e;   units.L_e = 'cm';   label.L_e = 'structural length at emergence';
      stat.M_Ve = M_Ve; units.M_Ve = 'mol'; label.M_Ve = 'structural mass at emergence';
      stat.Ww_e = Ww_e; units.Ww_e = 'g';   label.Ww_e = 'wet weight at emergence';
      stat.Wd_e = Wd_e; units.Wd_e = 'g';   label.Wd_e = 'dry weight at emergence';
      stat.a_e = a_e;   units.a_e = 'd';    label.a_e = 'age at emergence';
    case 'hex'
      L_e = L_m * l_e; M_Ve = M_V * L_e^3; Ww_e = L_e^3 + w_E * p_Am * u_Ee * v^2/ g^2/ k_M^3/ d_E; Wd_e = d_V * Ww_e; a_e = t_e/ k_M/ TC; 
      stat.l_e = l_e;   units.l_e = '-';    label.l_e = 'scaled structural length at emergence';
      stat.L_e = L_e;   units.L_e = 'cm';   label.L_e = 'structural length at emergence';
      stat.M_Ve = M_Ve; units.M_Ve = 'mol'; label.M_Ve = 'structural mass at emergence';
      stat.Ww_e = Ww_e; units.Ww_e = 'g';   label.Ww_e = 'wet weight at emergence';
      stat.Wd_e = Wd_e; units.Wd_e = 'g';   label.Wd_e = 'dry weight at emergence';
      stat.a_e = a_e;   units.a_e = 'd';    label.a_e = 'age at emergence';
 end
  
  % ultimate
  L_i = L_m * l_i; M_Vi = M_V * L_i^3; Ww_i = L_i^3 * (1 + w * f); Wd_i = d_V * Ww_i;
  if strcmp(model, 'hep') 
    Ww_i = Ww_e; Wd_i = Wd_e; 
  elseif strcmp(model, 'hex')
    Ww_i = Ww_j; Wd_i = Wd_j; % notice that Ww_i and Wd_i are set to wet weight at pupation for hex
  end
  del_Wb = Ww_b/ Ww_i; del_Wp = Ww_p/ Ww_i; 
  s_s = k_J * E_Hp * (p_M + p_T/ L_i)^2/ p_Am^3/ f^3/ s_M^3;
  stat.s_s = s_s;      units.s_s = '-';     label.s_s = 'supply stress'; 
  stat.l_i = l_i;      units.l_i = '-';     label.l_i = 'ultimate scaled structural length';
  stat.L_i = L_i;      units.L_i = 'cm';    label.L_i = 'ultimate structural length';
  stat.M_Vi = M_Vi;    units.M_Vi = 'mol';  label.M_Vi = 'ultimate structural mass';
  stat.Ww_i = Ww_i;    units.Ww_i = 'g';    label.Ww_i = 'ultimate wet weight';
  stat.Wd_i = Wd_i;    units.Wd_i = 'g';    label.Wd_i = 'ultimate dry weight';
  xi_WE = 1e-3 * (mu_V + mu_E * m_Em * f)/ (f * w);  % kJ/g, whole-body energy density (no reprod buffer) 
  stat.xi_WE  = xi_WE; units.xi_WE  = 'kJ/ g'; label.xi_WE   = '<E + E_V>, whole-body energy density (no reprod buffer)';   
  stat.del_Wb  = del_Wb; units.del_Wb = '-'; label.del_Wb   = 'birth weight as fraction of maximum weight';         
  stat.del_Wp  = del_Wp; units.del_Wp = '-'; label.del_Wp   = 'puberty weight as fraction of maximum weight';      
  del_V    = 1/(1 + f * w); % -, fraction of max weight that is structure
  stat.del_V  = del_V; units.del_V = '-';   label.del_V    = 'fraction of max weight that is structure';           
  h_W = TC * (h_a * f * v * s_M/ 6/ L_i)^(1/3); h_G = TC * s_G * f * v * s_M * L_i^2/ L_m^3;
  pars_tm  = [g; k; l_T; v_Hb; v_Hp; h_a/ (p_M/ E_G)^2; s_G];
  [t_m, S_b, S_p] = get_tm_s(pars_tm, f, L_b/ L_i, L_p/ L_i); a_m = t_m/ k_M/ TC;
  stat.h_W = h_W;      units.h_W = '1/d';   label.h_W = 'Weibull ageing rate';
  stat.h_G = h_G;      units.h_G = '1/d';   label.h_G = 'Gompertz aging rate';
  stat.a_m = a_m;      units.a_m = 'd';     label.a_m = 'life span';
  stat.S_b  = S_b;     units.S_b = '-';     label.S_b = 'survival probability at birth';   
  stat.S_p  = S_p;     units.S_p = '-';     label.S_p = 'survival probability at puberty';     
  if exist('r_B', 'var')
    a_99   = a_p + log((1 - L_p/ L_i)/(1 - 0.99))/ r_B;
    stat.a_99 = a_99;   units.a_99 = 'd';   label.a_99 = 'age at length 0.99 * L_i';
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
      N_i = cum_reprod(a_m * TC, f, pars_R) * R_i/ TC/ reprod_rate(L_i, f, pars_R);
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
    case 'hep'
      N_i = kap_R * (1 - kap) * v_Rj * l_j^3/ u_E0; % # of eggs at j
    case 'hex' 
      E_Rj = v_Rj * (1 - kap) * g * E_m * L_j^3; % J, reproduction buffer at pupation
      N_i = kap_R * E_Rj/ E_0;                   % #/d, ultimate reproduction rate at T
  end
  if exist('R_i','var')
    stat.R_i = R_i;  units.R_i = '1/d';  label.R_i = 'ultimate reproduction rate';  
  end
  stat.N_i = N_i;  units.N_i = '#';    label.N_i = 'life time reproductive output';  
 
  % feeding: std, stf, stx, ssj, sbp, abj, asj, abp, hep, hex
  switch model
    case {'std', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hex'} %  egg (not foetus)
      % min possible egg sizes as determined by the maternal effect rule (e = f)
      [eb_min, lb_min, uE0_min, info] = get_eb_min([g; k; v_Hb]); % growth, maturation cease at birth
      if info ~= 1
        fprintf('warning in get_eb_min: no convergence \n')
      end
      M_E0_min = L_m^3 * E_m * g * uE0_min/ mu_E; % mol, initial reserve (of embryo) at eb_min
      stat.M_E0_min_G = M_E0_min(1); units.M_E0_min_G = 'mol'; label.M_E0_min_G = 'egg mass whereby growth ceases at birth';   
      stat.M_E0_min_R = M_E0_min(2); units.M_E0_min_R = 'mol'; label.M_E0_min_R = 'egg mass whereby maturation ceases at birth';
      stat.eb_min_G = eb_min(1); units.eb_min_G = '-'; label.eb_min_G = 'scaled reserve density whereby growth ceases at birth';   
      stat.eb_min_R = eb_min(2); units.eb_min_R = '-'; label.eb_min_R = 'scaled reserve density whereby maturation ceases at birth';    
  end
  switch model
    case {'std', 'stf', 'stx', 'ssj', 'sbp'}
      ep_min  = get_ep_min([k; l_T; v_Hp]); % growth and maturation cease at puberty   
      stat.ep_min = ep_min; units.ep_min = '-'; label.ep_min = 'scaled reserve density whereby maturation and growth cease at puberty';    
      stat.sM_min = 1; units.sM_min = '-'; label.sM_min = 'acceleration factor whereby maturation ceases at puberty';    
    case {'abj', 'abp', 'hep'} 
      [ep_min, sM_min, info] = get_ep_min_j([g; k; l_T; v_Hb; v_Hj; v_Hp]); % growth and maturation cease at puberty   
      if info ~= 1
        fprintf('warning in get_ep_min_j: no convergence \n')
      end
      stat.ep_min = ep_min; units.ep_min = '-'; label.ep_min = 'scaled reserve density whereby maturation and growth cease at puberty'; 
      stat.sM_min = sM_min; units.sM_min = '-'; label.sM_min = 'acceleration factor whereby maturation ceases at puberty';    
    case 'asj'
      [ep_min, sM_min, info] = get_ep_min_s([g; k; l_T; v_Hb; v_Hs; v_Hj; v_Hp]); % growth and maturation cease at puberty   
      if info ~= 1
        fprintf('warning in get_ep_min_s: no convergence \n')
      end
      stat.ep_min = ep_min; units.ep_min = '-'; label.ep_min = 'scaled reserve density whereby maturation and growth cease at puberty'; 
      stat.sM_min = sM_min; units.sM_min = '-'; label.sM_min = 'acceleration factor whereby maturation ceases at puberty';    
    case 'hex'
      stat.ep_min = eb_min(2); units.ep_min = '-'; label.ep_min= 'minimum scaled functional response to reach pupation';    
      stat.sM_min = 1; units.sM_min = '-'; label.sM_min = 'acceleration factor at ep_min';    
  end
  if exist('kap_X', 'var') && exist('kap_P', 'var')
    p_Xb = TC * f * p_Xm * L_b^2; J_Xb = TC * f * J_X_Am * L_b^2; F_mb = F_m * L_b^2;       
    stat.p_Xb = p_Xb; units.p_Xb = 'J/d'; label.p_Xb = 'food intake at birth';    
    stat.J_Xb = J_Xb; units.J_Xb = 'mol/d'; label.J_Xb = 'food intake at birth';    
    stat.F_mb = F_mb; units.F_mb = 'l/d'; label.F_mb = 'max searching rate at birth';    
    p_Xp = TC * f * p_Xm * L_p^2; J_Xp = TC * f * J_X_Am * L_p^2; F_mp = F_m * L_p^2;         
    stat.p_Xp = p_Xp; units.p_Xp = 'J/d'; label.p_Xp = 'food intake at puberty';    
    stat.J_Xp = J_Xp; units.J_Xp = 'mol/d'; label.J_Xp = 'food intake at puberty';    
    stat.F_mp = F_mp; units.F_mp = 'l/d'; label.F_mp = 'max searching rate at puberty';    
    p_Xi = TC * f * p_Xm * L_i^2; J_Xi = TC * f * J_X_Am * L_i^2; F_mi = F_m * L_i^2;
    stat.p_Xi = p_Xi; units.p_Xi = 'J/d'; label.p_Xi = 'ultimate food intake';    
    stat.J_Xi = J_Xi; units.J_Xi = 'mol/d'; label.J_Xi = 'ultimate food intake';
    stat.F_mi = F_mi; units.F_mi = 'l/d'; label.F_mi = 'max ultimate searching rate';    
  end

  % powers
  p_ref = TC * p_Am * L_m^2;        % J/d, max assimilation power at max size
  switch model
    case {'std', 'stf', 'stx', 'ssj'}
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp];  
      p_ACSJGRD = p_ref * scaled_power([L_b + 1e-6; L_p; L_i], f, pars_power, l_b, l_p); 
    case 'sbp' % no growth, no kappa rule after p
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp];  
      p_ACSJGRD = p_ref * scaled_power([L_b + 1e-6; L_p; L_i], f, pars_power, l_b, l_p); 
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
    case 'hep' 
      pars_power = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hp; U_Hp + 1e-6]; 
      p_ACSJGRD = p_ref * scaled_power_j([L_b + 1e-6; L_p; L_i], f, pars_power, l_b, l_p, l_p);
    case 'hex' % birth and puberty coincide; ultimate is here mapped to pupation
      pars_power = [kap; kap_V; kap_R; g; k_J; k_M; v; U_Hb; U_He]; 
      p_ACSJGRD = p_ref * scaled_power_hex([L_b; L_b + 1e-6; L_j], f, pars_power, l_b, l_j, l_e, t_j);
  end
  stat.p_Ab = p_ACSJGRD(1,1); units.p_Ab = 'J/d'; label.p_Ab = 'assimilation at birth';    
  stat.p_Sb = p_ACSJGRD(1,3); units.p_Sb = 'J/d'; label.p_Sb = 'somatic maintenance at birth';    
  stat.p_Jb = p_ACSJGRD(1,4); units.p_Jb = 'J/d'; label.p_Jb = 'maturity maintenance at birth';    
  stat.p_Gb = p_ACSJGRD(1,5); units.p_Gb = 'J/d'; label.p_Gb = 'growth at birth';    
  stat.p_Rb = p_ACSJGRD(1,6); units.p_Rb = 'J/d'; label.p_Rb = 'maturation at birth';    
  stat.p_Ap = p_ACSJGRD(2,1); units.p_Ap = 'J/d'; label.p_Ap = 'assimilation at puberty';    
  stat.p_Sp = p_ACSJGRD(2,3); units.p_Sp = 'J/d'; label.p_Sp = 'somatic maintenance at puberty';    
  stat.p_Jp = p_ACSJGRD(2,4); units.p_Jp = 'J/d'; label.p_Jp = 'maturity maintenance at puberty';    
  stat.p_Gp = p_ACSJGRD(2,5); units.p_Gp = 'J/d'; label.p_Gp = 'growth at puberty';    
  stat.p_Rp = p_ACSJGRD(2,6); units.p_Rp = 'J/d'; label.p_Rp = 'reproduction at puberty';    
  stat.p_Ai = p_ACSJGRD(3,1); units.p_Ai = 'J/d'; label.p_Ai = 'ultimate assimilation';    
  stat.p_Si = p_ACSJGRD(3,3); units.p_Si = 'J/d'; label.p_Si = 'ultimate somatic maintenance';    
  stat.p_Ji = p_ACSJGRD(3,4); units.p_Ji = 'J/d'; label.p_Ji = 'ultimate maturity maintenance';    
  stat.p_Gi = p_ACSJGRD(3,5); units.p_Gi = 'J/d'; label.p_Gi = 'ultimate growth';    
  stat.p_Ri = p_ACSJGRD(3,6); units.p_Ri = 'J/d'; label.p_Ri = 'ultimate reproduction';    

  % mass fluxes (respiration)
  X_gas = T_ref/ T/ 24.4;       % M, mol of gas per litre at T_ref (= 20 C) and 1 bar 
  p_ADG = p_ACSJGRD(:,[1 7 5]); % J/d, assimilation, dissipation, growth powers
  J_O = eta_O * p_ADG'; J_M = - (n_M\n_O) * J_O; % rows: CHON, cols: bpi
  stat.J_Cb = J_M(1,1); units.J_Cb = 'mol/d'; label.J_Cb = 'CO2 flux at birth';    
  stat.J_Cp = J_M(1,2); units.J_Cp = 'mol/d'; label.J_Cp = 'CO2 flux at puberty';    
  stat.J_Ci = J_M(1,3); units.J_Ci = 'mol/d'; label.J_Ci = 'ultimate CO2 flux';    
  stat.J_Ob = -J_M(3,1); units.J_Ob = 'mol/d'; label.J_Ob = 'O2 flux at birth';    
  stat.J_Op = -J_M(3,2); units.J_Op = 'mol/d'; label.J_Op = 'O2 flux at puberty';    
  stat.J_Oi = -J_M(3,3); units.J_Oi = 'mol/d'; label.J_Oi = 'ultimate O2 flux';    
  stat.J_Nb = J_M(4,1); units.J_Nb = 'mol/d'; label.J_Nb = 'N-waste flux at birth';    
  stat.J_Np = J_M(4,2); units.J_Np = 'mol/d'; label.J_Np = 'N-waste flux at puberty';    
  stat.J_Ni = J_M(4,3); units.J_Ni = 'mol/d'; label.J_Ni = 'ultimate N-waste flux';    

  % mass flux ratios and heat
  mu_O = [mu_X; mu_V; mu_E; mu_P];% J/mol, chemical potentials of organics
  mu_M = [0; 0; 0; 0];            % J/mol, chemical potentials of minerals C: CO2, H: H2O, O: O2, N: NH3
  % at birth
  J_O = eta_O * diag(p_ADG(1,:)); % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
  J_M = - (n_M\n_O) * J_O;        % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
  stat.RQ_b = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3)); units.RQ_b = 'mol C/mol O'; label.RQ_b = 'resp quotient at birth';
  stat.UQ_b = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3)); units.UQ_b = 'mol N/mol O'; label.UQ_b = 'urine quotient at birth';
  stat.WQ_b = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3)); units.WQ_b = 'mol H/mol O'; label.WQ_b = 'water quotient at birth';
  stat.SDA_b = J_M(3,1)/ J_O(1,1); units.SDA_b = 'mol O/mol X'; label.SDA_b = 'specific dynamic action at birth';
  stat.VO_b = J_M(3,2)/ Wd_b/ 24/ X_gas; units.VO_b = 'L/g.h'; label.VO_b = 'dioxygen use per gram max dry weight, <J_OD> at birth';
  stat.p_Tt_b = sum(- J_O' * mu_O - J_M' * mu_M); units.p_Tt_b = 'J/d'; label.p_Tt_b = 'dissipating heat at birth';
  % at puberty
  J_O = eta_O * diag(p_ADG(2,:)); % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
  J_M = - (n_M\n_O) * J_O;        % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
  stat.RQ_p = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3)); units.RQ_p = 'mol C/mol O'; label.RQ_p = 'resp quotient at puberty';
  stat.UQ_p = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3)); units.UQ_p = 'mol N/mol O'; label.UQ_p = 'urine quotient at puberty';
  stat.WQ_p = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3)); units.WQ_p = 'mol H/mol O'; label.WQ_p = 'water quotient at puberty';
  stat.SDA_p = J_M(3,1)/ J_O(1,1); units.SDA_p = 'mol O/mol X'; label.SDA_p = 'specific dynamic action at puberty';
  stat.VO_p = J_M(3,2)/ Wd_p/ 24/ X_gas; units.VO_p = 'L/g.h'; label.VO_p = 'dioxygen use per gram max dry weight, <J_OD> at puberty';
  stat.p_Tt_p = sum(- J_O' * mu_O - J_M' * mu_M); units.p_Tt_p = 'J/d'; label.p_Tt_p = 'dissipating heat at puberty';
  % at ultimate
  J_O = eta_O * diag(p_ADG(3,:)); % mol/d, J_X, J_V, J_E, J_P in rows, A, D, G in cols
  J_M = - (n_M\n_O) * J_O;        % mol/d, J_C, J_H, J_O, J_N in rows, A, D, G in cols
  stat.RQ_i = -(J_M(1,2) + J_M(1,3))/ (J_M(3,2) + J_M(3,3)); units.RQ_i = 'mol C/mol O'; label.RQ_i = 'ultimate resp quotient';
  stat.UQ_i = -(J_M(4,2) + J_M(4,3))/ (J_M(3,2) + J_M(3,3)); units.UQ_i = 'mol N/mol O'; label.UQ_i = 'ultimate urine quotient';
  stat.WQ_i = -(J_M(2,2) + J_M(2,3))/ (J_M(3,2) + J_M(3,3)); units.WQ_i = 'mol H/mol O'; label.WQ_i = 'ultimate water quotient';
  stat.SDA_i = J_M(3,1)/ J_O(1,1); units.SDA_i = 'mol O/mol X'; label.SDA_i = 'ultimate specific dynamic action';
  stat.VO_i = J_M(3,2)/ Wd_i/ 24/ X_gas; units.VO_i = 'L/g.h'; label.VO_i = 'ultimate dioxygen use per gram max dry weight, <J_OD>';
  stat.p_Tt_i = sum(- J_O' * mu_O - J_M' * mu_M); units.p_Tt_i = 'J/d'; label.p_Tt_i = 'ultimate dissipating heat';

  % packing
  txtStat.units = units;
  txtStat.label = label;

end

%% subfunction

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