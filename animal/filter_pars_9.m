%% filter_pars_9
% Filters parameter values for possible conversion to data

%%
function [filter flag] = filter_pars_9 (par, fixed_par, chem_par)
  % created 2014/01/22 by Bas Kooijman; modified 2015/01/15
  
  %% Syntax
  % [filter flag] = <../filter_pars_9.m *filter_pars_9*> (par, fixed_par, chem_par)
  
  %% Description
  % Filters parameter values for possible conversion to data
  %   of standard DEB model with acceleration.
  %
  % Input
  %
  % * par: 9-vector with DEB parameters
  %
  %     p_Am, J/d.cm^2,  {p_Am}, max specific assimilation rate
  %     v, cm/d, energy conductance
  %     kap, -, allocation fraction to soma 
  %     p_M, J/d.cm^3, [p_M], specific somatic maintenance costs
  %     E_G, J/cm^3, [E_G] specific cost for structure
  %     E_Hb, J, E_H^b, maturity at birth 
  %     E_Hj, J, E_H^j, maturity at metamorphosis 
  %     E_Hp, J, E_H^p, maturity at puberty 
  %     h_a, 1/d^2, ageing acceleration
  %
  % * fixed_par: optional 4 vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %  
  % Output
  %
  % * filter: 0 for hold, 1 for pass
  % * flag: indicator for reason for holding
  %
  %     0: filter passes parameters
  %     1: some parameter is negative
  %     2: kappa larger than 1
  %     3: maturity levels do not increase during life cycle
  %     4: birth cannot be reached
  %     5: supply stress is too much
  %     6: puberty cannot be reached because of allocation
  %     7: puberty cannot be reached because of ageing
  %     8: numerical problems in get_lb
  %     9: numerical problems in get_tj
  
  %% Remarks
  % The theory behind iget_pars_9 is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html LikaAugu2013>.
  % Meant to run prior to <iget_pars_9.html *iget_pars_9*>.
  % Without acceleration, see <filter_par_8.html *filter_par_8*>.
  
  %% Example of use
  % See <../mydata_get_pars_9.m *mydata_get_pars_9*>
  
  % assumptions:
  % abundant food (f=1)
  % a_b, a_p, a_m and R_m are temp-corrected to T_ref = 293 K
  p_T = 0;         % J/d.cm^2, {p_T}, surface-spec som maint cost
  if exist('fixed_par','var') == 0
     k_J = 0.002;          % 1/d, maturity maintenance rate coefficient 
     s_G = 1e-4;           % -, Gopertz stress coefficient (= small)
     kap_R = 0.95;         % -, reproduction efficiency
     kap_G = 0.80;         % -, growth efficiency
  else
     k_J   = fixed_par(1); % 1/d, maturity maintenance rate coefficient 
     s_G   = fixed_par(2); % -, Gopertz stress coefficient (= small)
     kap_R = fixed_par(3); % -, reproduction efficiency
     kap_G = fixed_par(4); % -, growth efficiency
  end
  if exist('chem_par', 'var') == 0
  %  C:H:O:N = 1:1.8:0.5:0.15
     w_V = 23.9;   % g/C-mol, molecular weight of structure
     w_E = 23.9;   % g/C-mol, molecular weight of reserve
     mu_V = 5E5;   % J/C-mol, chemical potential of structure
     mu_E = 5.5E5; % J/C-mol, chemical potential of reserve
  else
     w_V = chem_par(1); w_E = chem_par(2); mu_V = chem_par(3); mu_E = chem_par(4);
  end
 
  % unpack par
  p_Am = par(1); % J/d.cm^2, {p_Am}, max specific assimilation rate 
  v    = par(2); % cm/d, energy conductance
  kap  = par(3); % -, allocation fraction to soma
  p_M  = par(4); % J/d.cm^3, [p_M], specific somatic maintenance costs
  E_G  = par(5); % J/cm^3, [E_G], specific cost for structure  
  E_Hb = par(6); % J, E_H^b, maturity level at birth 
  E_Hj = par(7); % J, E_H^j, maturity level at metamorphosis
  E_Hp = par(8); % J, E_H^p, maturity level at puberty
  h_a  = par(9); % 1/d^2, ageing acceleration

  filter = 1; flag = 0; % default setting of filter and flag
  
  if sum(par > 0) ~= 9
    filter = 0;
    flag = 1;
    return
  elseif kap >= 1
    filter = 0;
    flag = 2;
    return
  elseif E_Hb > E_Hj || E_Hj > E_Hp 
    filter = 0;
    flag = 3;
    return
  end

  % compound pars
  k_M = p_M/ E_G;                  % 1/d, somatic maintenance rate coefficient
  k = k_J/ k_M;                    % -, maintenance ratio

  %d_V = E_G * kap_G * w_V/ mu_V;  % g/cm^3, specific density of structure 
  E_m = p_Am/ v;                   % J/cm^3, [E_m] reserve capacity 
  g = E_G/ kap/ E_m;               % -, energy investment ratio
  %w = E_m * w_E/ d_V/ mu_E;       % -, contribution of reserve to weight

  L_m = v/ k_M/ g;                 % cm, maximum structural length
  L_T = p_T/ p_M;                  % cm, heating length (also applies to osmotic work)
  l_T = L_T/ L_m;                  % -, scaled heating length

  % maturity at birth
  U_Hb = E_Hb/ p_Am;               % cm^2 d, scaled maturity at birth
  V_Hb = U_Hb/ (1 - kap);          % cm^2 d, scaled maturity at birth
  v_Hb = V_Hb * g^2 * k_M^3/ v^2;  % -, scaled maturity at birth
  % maturity at metamorphosis
  U_Hj = E_Hj/ p_Am;               % cm^2 d, scaled maturity at metamorphosis
  V_Hj = U_Hj/ (1 - kap);          % cm^2 d, scaled maturity at metamorphosis
  v_Hj = V_Hj * g^2 * k_M^3/ v^2;  % -, scaled maturity at metamorphosis
  % maturity at puberty
  U_Hp = E_Hp/ p_Am;               % cm^2 d, scaled maturity at puberty 
  V_Hp = U_Hp/ (1 - kap);          % cm^2 d, scaled maturity at puberty
  v_Hp = V_Hp * g^2 * k_M^3/ v^2;  % -, scaled maturity at puberty

  if k * v_Hb >= 1 % birth cannot be reached
    filter = 0;
    flag = 4;
    return
  end
  
  if v_Hb > get_vHb([g; k]) % l_b > 0
    filter = 0;
    flag = 4;
    return
  end

  pars_lb = [g; k; v_Hb];
  [l_b info] = get_lb(pars_lb);
  if info ~= 1
    filter = 0;
    flag = 8;
    return
  end
  
  pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp]; % compose parameter vector for get_tj
  [t_j t_p t_b l_j l_p l_b l_i rj rB info] = get_tj(pars_tj, 1, l_b);
  if info ~= 1
    filter = 0;
    flag = 9;
    return
  end
  
  s_M = l_j/ l_b;                          % -, acceleration factor
  s_s = k_J * E_Hp * p_M^2/ s_M^3/ p_Am^3; % -, supply stress
  if s_s >= 4/27 % outside the supply-demand spectrum
    filter = 0;
    flag = 5;
    return
  end

  if s_s >= kap^2 * (1 - kap)
    filter = 0; % puberty cannot be reached
    flag = 6;
    return
  end      

  pars_tm = [g; l_T; h_a/ k_M^2; s_G];     % compose parameter vector
  t_m = get_tm_s(pars_tm, 1);              % -, scaled mean life span

  if t_m < t_p % ageing is too fast to reproduce
    filter = 0;
    flag = 7;
    return
  end

