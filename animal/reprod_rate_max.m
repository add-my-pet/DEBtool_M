%% reprod_rate_max
% gets reproduction rate at max length 
%%
function R_m = reprod_rate_max(mod, par)
  % created 2023/02/24 by Bas Kooijman
  
  %% Syntax
  % R_m = <../reprod_rate_max.m *reprod_rate_max*> (mod, par)
  
  %% Description
  % Calculates the max reproduction rate in number of offspring per time 
  % for an individual of length L_i and scaled reserve density f = 1, with l_T = 0;
  %
  % Input
  %
  % * mod: 3 character string with model name
  % * par: structure or vector with parameters kap, kap_R, p_Am, v, p_M, k_J, E_G, E_Hb, E_Hj, E_Hp, optionally s_M
  %  
  % Output
  %
  %  R: max reproduction rate
  
  %% Remarks
  % Theory is given in DEB3 section 2.7, Eqn (2.58)
  
  %% Example of use
  % p.kap=.4; p.kap_R=.95; p.p_Am=200; p.v=0.02; p.p_M=18; p.k_J=0.002;
  % p.E_G=5600; p.E_Hb=20; p.E_Hj=20.1; p.E_Hp=300; reprod_rate_max('std',p)
  
  % unpack parameters kap, kap_R, p_Am, v, p_M, k_J, E_G, E_Hb, E_Hj, E_Hp, s_M
  if isstruct(par)
    vars_pull(par); if ~exist('s_M','var'); s_M = 1; end
  else
    kap = par(1); kap_R = par(2); p_Am = par(3); v = par(4); p_M = par(5); 
    k_J = par(6); E_G = par(7); E_Hb = par(8); E_Hj = par(9); E_Hp = par(10); 
    if length(par)>10; s_M = par(11); else s_M = 1; end
  end
    
  E_m = p_Am/ v; % J/cm^3, reserve capacity
  g = E_G/ kap/ E_m; % -, energy investment ratio
  k_M = p_M/ E_G; % 1/d, som maintenance rate coeff
  k = k_J/ k_M; % -, maintenance ratio
  L = kap * p_Am/ p_M; % cm, max struct length
  v_Hb = E_Hb/ (1 - kap)/ g/ E_m/ L^3; % -, scaled maturity at birth
  
  % scaled with scaled reserve at t=0: U_E^0 g^2 k_M^3/ v^2 with U_E^0 = E_0/ p_Am
  if strcmp(mod,'stf') || strcmp(mod,'stx')
    E_0 = g * E_m * L^3 * get_ue0_foetus([g, k, v_Hb]); 
  else
    E_0 = g * E_m * L^3 * get_ue0([g, k, v_Hb]); 
  end
  
  switch mod
    case {'sbp','abp'}
      v_Hj = E_Hj/ (1 - kap)/ g/ E_m/ L^3; % -, scaled maturity at metam
      v_Hp = E_Hp/ (1 - kap)/ g/ E_m/ L^3; % -, scaled maturity at puberty
      [~, l_p] = get_lj([g, k, 0, v_Hb, v_Hj, v_Hp]); L = L * l_p; % cm, struc length
      R_m = kap_R * (L^2 * s_M * p_Am - p_M * L^3 - k_J * E_Hp)/ E_0; % 1/d, max reprod rate
    case {'std','stf','stx','ssj','abj','asj'}
      R_m = kap_R * ((1 - kap) * E_m * s_M^3 * L^2 * v - k_J * E_Hp)/ E_0; % 1/d, max reprod rate
    otherwise
      R_m = NaN;
  end
end
  