%% reprod_rate_i
% max reprod rate and lifetime reproductive output

%%
function [R_i N_i] = reprod_rate_i(model, par, T, f) 
% created 2016/06/08 by Bas Kooijman

%% Syntax
% [R_i N_i] = <reprod_rate_i.m *reprod_rate_i*>(model, par, T, f)

%% Description
% Computes max reprod rate, max reprod rate with optimized kap and optimized kap
%
% Input
%
% * model: string with name of model
% * par:   structure with primary parameters at reference temperature in time-length-energy frame
% * T:     optional scalar with temperature in Kelvin; default C2K(20)
% * f:     optional scalar scaled functional response; default 1
% 
% Output
% 
% * R_i:   scalar, max reprod rate (#/d)
% * N_i:   scalar, lifetime reproductive output (#)

%% Remarks
% Uses selected copy-paste from statistics_st

%% Example of use
% reprod_rate_i('std', par, C2K(20), 1) 

  
  choices = {'std', 'stf', 'stx', 'ssj', 'sbp', 'abj', 'asj', 'abp', 'hep', 'hex'};
  if ~any(strcmp(model,choices))
    fprintf('warning statistics_st: invalid model key \n')
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
  
  % extract parameters and compute compound parameters
  cPar = parscomp_st(par);
  vars_pull(cPar); vars_pull(par);

  % TC
  pars_T = T_A;
  if exist('T_L','var') && exist('T_AL','var')
    pars_T = [T_A; T_L; T_AL];
  end
  if exist('T_L','var') && exist('T_AL','var') && exist('T_H','var') && exist('T_AH','var')
    pars_T = [T_A; T_L; T_H; T_AL; T_AH]; 
  end
  TC = tempcorr(T, T_ref, pars_T);   % -, Temperature Correction factor
  
  % life cycle
  switch model
    case 'std'
      if exist('E_Hx','var')
        pars_tp = [g k l_T v_Hb v_Hp];
        [t_p, t_b, l_p, l_b] = get_tp(pars_tp, f, l_b);
      else
        pars_tp  = [g; k; l_T; v_Hb; v_Hp];  % parameters for get_tp
        [t_p, t_b, l_p, l_b, info] = get_tp(pars_tp, f); 
      end
      l_i = f - l_T;
    case 'stf'
      pars_tp  = [g; k; l_T; v_Hb; v_Hp];  % parameters for get_tp
      [t_p, t_b, l_p, l_b] = get_tp_foetus(pars_tp, f); 
      l_i = f - l_T;
    case 'stx'
      pars_tx = [g k l_T v_Hb v_Hx v_Hp]; 
      [t_p, t_x, t_b, l_p, l_x, l_b] = get_tx(pars_tx, f);
      l_i = f - l_T;
    case 'ssj'
      l_i = f - l_T;
    case 'sbp'
      pars_tp  = [g; k; l_T; v_Hb; v_Hp];  
      [t_p, t_b, l_p, l_b] = get_tp(pars_tp, f); 
      l_i = l_p;
    case 'abj' 
      pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp];
      [t_j, t_p, t_b, l_j, l_p, l_b, l_i] = get_tj(pars_tj, f);
    case 'asj'
      pars_ts = [g; k; l_T; v_Hb; v_Hs; v_Hj; v_Hp];
      [t_s, t_j, t_p, t_b, l_s, l_j, l_p, l_b, l_i] = get_ts(pars_ts, f);
    case 'abp'
      U_Hj = U_Hp - 1e-8; v_Hj = v_Hp - 1e-8;
      pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp];
      [t_j, t_p, t_b, l_j, l_p, l_b, l_i] = get_tj(pars_tj, f);
      l_i = l_p + 1e-6;
    case 'hep'
      v_Rj = kap/ (1 - kap) * E_Rj/ E_G; pars_tj = [g k v_Hb v_Hp v_Rj];
      [t_j, t_p, t_b, l_j, l_p, l_b, l_i] = get_tj_hep(pars_tj, f);
      U_Hj = U_Hp - 1e-8; 
    case 'hex'
      pars_tj = [g k v_Hb v_He s_j kap kap_V];
      [t_j, t_e, t_b, l_j, l_e, l_b, rho_j, v_Rj, u_Ee] = get_tj_hex(pars_tj, f);
      l_i = l_e;
      l_p = l_b; t_p = t_b; E_Hp = E_Hb; U_Hp = U_Hb; v_Hp = v_Hb;
 end
  
  % life event statistics
  
  % initial state
  pars_E0  = [V_Hb; g; k_J; k_M; v];   % initial_scaled_reserve
  switch model
    case {'stf', 'stx'} % foetus
      [U_E0, L_b] = initial_scaled_reserve_foetus(f, pars_E0); % d cm^2, initial scaled reserve
      u_E0 = U_E0 * v/ g/ L_m^3;
      E_0 = p_Am * U_E0;
    otherwise % egg
      [U_E0, L_b] = initial_scaled_reserve(f, pars_E0); % d cm^2, initial scaled reserve
      u_E0 = U_E0 * v/ g/ L_m^3;
      E_0 = p_Am * U_E0;
  end
  
  % birth
  L_b = L_m * l_b; 
          
  % metamorphosis
  switch model
    case {'abj', 'asj', 'abp', 'hep', 'hex'}
      L_j = L_m * l_j;  
  end
  
  % puberty
  L_p = L_m * l_p; a_p = t_p/ k_M/ TC; 
  
  % ultimate
  L_i = L_m * l_i; 

  pars_tm  = [g; k; l_T; v_Hb; v_Hp; h_a/ (p_M/ E_G)^2; s_G];
  t_m = get_tm_s(pars_tm, f, L_b/ L_i, L_p/ L_i); a_m = t_m/ k_M/ TC;

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
      R_i = [];
      N_i = kap_R * (1 - kap) * v_Rj * l_j^3/ u_E0; % # of eggs at j
    case 'hex' 
      R_i = [];
      E_Rj = v_Rj * (1 - kap) * g * E_m * L_j^3; % J, reproduction buffer at pupation
      N_i = kap_R * E_Rj/ E_0;                   % #/d, ultimate reproduction rate at T
  end
 

end
