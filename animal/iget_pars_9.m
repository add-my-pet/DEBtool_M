%% iget_pars_9
% Obtains 9 data points from 9 DEB parameters at abundant food

%%
function data = iget_pars_9(par, fixed_par, chem_par)
  % created 2013/07/08 by Bas Kooijman; modified 2013/09/26
  
  %% Syntax
  % data = <../iget_pars_9.m *iget_pars_9*>(par, fixed_par, chem_par)
  
  %% Description
  % Obtains 9 data points from 9 DEB parameters at abundant food 
  %
  % Input
  %
  % * par: 9-vector with DEB parameters
  %
  %     p_Am: J/d.cm^2,  {p_Am}, max specific assimilation rate
  %     v: cm/d, energy conductance
  %     kap: -, allocation fraction to soma 
  %     p_M: J/d.cm^3, [p_M], specific somatic maintenance costs
  %     E_G: J/cm^3, [E_G] specific cost for structure
  %     E_Hb: J, E_H^b, maturity at birth 
  %     E_Hj: J, E_H^j, maturity at metamorphosis 
  %     E_Hp: J, E_H^p, maturity at puberty 
  %     h_a: 1/d^2, ageing acceleration
  %
  % * fixed_par: optional 4 vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %  
  % Output
  %
  % * data: 9-vector with zero-variate data
  %
  %     d_V: g/cm^3 specific density of structure
  %     a_b: d, age at birth
  %     a_p: d, age at puberty
  %     a_m: d, age at death due to ageing
  %     W_b: g, wet weight at birth
  %     W_j: g, wet weight at metamorphosis
  %     W_p: g, wet weight at puberty
  %     W_m: g, maximum wet weight
  %     R_m: #/d, maximum reproduction rate
  
  %% Remarks
  % The theory behind this mapping is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2014.html LikaAugu2014>.
  % See <get_pars_9.html *get_pars_9*> for the inverse mapping
  
  %% Example of use
  % See <../mydata_get_pars_9.html *mydata_get_pars_9*>
  
  % assumptions:
  % abundant food (f=1)
  % a_b, a_p, a_m and R_m are temp-corrected to T_ref = 293 K
  p_T = 0; % J/d,  {p_T} = 0  J/d.cm^2, surf-spec som maint
  if exist('fixed_par','var') == 0
     k_J = 0.002;         % 1/d, maturity maintenance rate coefficient
     s_G = 1e-4;          % -, Gopertz stress coefficient (= small)
     kap_R = 0.95;        % -, reproduction efficiency
     kap_G = 0.8;         % -, growth efficiency
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

  % compound pars
  k_M = p_M/ E_G;                  % 1/d, somatic maintenance rate coefficient
  k = k_J/ k_M;                    % -, maintenance ratio

  d_V = kap_G * E_G * w_V/ mu_V;   % g/cm^3, specific density of structure 
  E_m = p_Am/ v;                   % J/cm^3, [E_m] reserve capacity 
  g = E_G/ kap/ E_m;               % -, energy investment ratio
  w = E_m * w_E/ d_V/ mu_E;        % -, contribution of reserve to weight

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

  % obtain predictions

  pars_tj = [g; k; l_T; v_Hb; v_Hj; v_Hp]; % compose parameter vector for get_tj
  [t_j t_p t_b l_j l_p l_b l_i] = get_tj(pars_tj, 1);

  a_b = t_b/ k_M;  % d, age at birth
% a_j = t_j/ k_M  % d, age at metamorphosis
  a_p = t_p/ k_M;  % d, age at puberty

  L_b = l_b * L_m; % cm, structural length at birth
  L_j = l_j * L_m; % cm, structural length at metamorphosis
  L_p = l_p * L_m; % cm, structural length at puberty
  L_i = l_i * L_m; % cm, ultimate structural length

  Ww_b = L_b^3 * (1 + w); % g, wet weight at birth
  Ww_j = L_j^3 * (1 + w); % g, wet weight at metamorphosis
  Ww_p = L_p^3 * (1 + w); % g, wet weight at puberty
  Ww_m = L_i^3 * (1 + w); % g, ultimate wet weight

  pars_Rm = [kap; kap_R; g; k_J; k_M; L_T; v; U_Hb; U_Hj; U_Hp]; % compose par vector
  R_m = reprod_rate_j(L_i, 1, pars_Rm); % #/d, maximum reprod rate

  pars_tm = [g; l_T; h_a/ k_M^2; s_G];     % compose parameter vector
  t_m = get_tm_s(pars_tm, 1);              % -, scaled mean life span
  a_m = t_m/ k_M;                          % d, mean life span at T

  % pack data
  data = [d_V; a_b; a_p; a_m; Ww_b; Ww_j; Ww_p; Ww_m; R_m];
