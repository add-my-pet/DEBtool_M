%% iget_pars_8_stf
% Obtains 8 data points from 8 DEB parameters at abundant food for the stf model

%%
function data = iget_pars_8_stf(par, fixed_par, chem_par)
  % created 2013/07/08 by Bas Kooijman; modified 2013/09/26
  
  %% Syntax
  % data = <../iget_pars_8_stf.m *iget_pars_8_stf*>(par, fixed_par, chem_par)
  
  %% Description
  % Obtains 8 data points from 8 DEB parameters at abundant food for the stf model
  %
  % Input
  %
  % * par: 8-vector with DEB parameters
  %
  %     p_Am: J/d.cm^2,  {p_Am}, max specific assimilation rate
  %     v: cm/d, energy conductance
  %     kap: -, allocation fraction to soma 
  %     p_M: J/d.cm^3, [p_M], specific somatic maintenance costs
  %     E_G: J/cm^3, [E_G] specific cost for structure
  %     E_Hb: J, E_H^b, maturity at birth 
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
  E_Hp = par(7); % J, E_H^p, maturity level at puberty
  h_a  = par(8); % 1/d^2, ageing acceleration

  
  % compound pars
  k_M = p_M/ E_G;                  % 1/d, somatic maintenance rate coefficient
  k = k_J/ k_M;                    % -, maintenance ratio

  d_V = kap_G * E_G * w_V/ mu_V;   % g/cm^3, specific density of structure 
  E_m = p_Am/ v;                   % J/cm^3, [E_m] reserve capacity 
  g = E_G/ kap/ E_m;               % -, energy investment ratio
  w = E_m * w_E/ d_V/ mu_E;        % -, contribution of reserve to weight

  L_m = v/ k_M/ g;                 % cm, maximum structural length

  % maturity at birth
  U_Hb = E_Hb/ p_Am;               % cm^2 d, scaled maturity at birth
  V_Hb = U_Hb/ (1 - kap);          % cm^2 d, scaled maturity at birth
  v_Hb = V_Hb * g^2 * k_M^3/ v^2;  % -, scaled maturity at birth
  % maturity at puberty
  U_Hp = E_Hp/ p_Am;               % cm^2 d, scaled maturity at puberty 
  V_Hp = U_Hp/ (1 - kap);          % cm^2 d, scaled maturity at puberty
  v_Hp = V_Hp * g^2 * k_M^3/ v^2;  % -, scaled maturity at puberty

  tau_b = fzero(@(tau_b) (g/3)^3/ k * ((1/k - 1) * (6/ k^2 * (exp(- k * tau_b) - 1) + 6/ k * tau_b - 3 * tau_b^2) + tau_b^3) - v_Hb, 0);
  a_b = tau_b/ k_M;
  l_b = g/ 3 * tau_b;

  l_p = get_lp1 ([g, k, 0, v_Hb, v_Hp, 1], 1, l_b);
  r_B = k_M/ 3 * g/ (1 + g);
  t_p = log((1 - l_b)/ (1 - l_p))/ r_B;  a_p = a_b + t_p;

  Ww_m = L_m^3 * (1 + w); % g, ultimate wet weight
  Ww_b = l_b^3 * Ww_m;
  Ww_p = l_p^3 * Ww_m;

  uE0 = l_b^3/ g * (1 + g + 3 * l_b/4);
  R_m = k_M * kap_R * (1 - kap) * (1 - k * v_Hp) / uE0; % #/d, maximum reprod rate

  a_m = (4.27/ h_a/ k_M/ g)^(1/3); % 1/d^2 ageing acceleration

  % pack data
  data = [d_V; a_b; a_p; a_m; Ww_b; Ww_p; Ww_m; R_m];
end

