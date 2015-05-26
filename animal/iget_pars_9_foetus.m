%% iget_pars_9_foetus
%

%%
function data = iget_pars_9_foetus (par, t_0, fixed_par, chem_par, T, T_A)
  % created 2014_06_16 by Bas Kooijman
  
  %% Syntax
  % data = <../iget_pars_9_foetus.m *iget_pars_9_foetus*> (par, t_0, T, T_A)
  
  %% Description
  % Obtains 9 data points from 9 DEB parameters at abundant food fro foetal development.
  % No acceleration. Time at start development is an extra parameter.
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
  %     E_Hx, J, E_H^x, maturity at weaning
  %     E_Hp, J, E_H^p, maturity at puberty 
  %     h_a, 1/d^2, ageing acceleration
  %
  % * t_0: scalar with delay till start development: a_b = t_b - t_0
  % * fixed_par: optional 4 vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  % * T: optional scalar with body temperature (default 293.15 K)
  % * T_A: optional scalar with Arrhenius temperature (default 8000 K)
  %  
  % Output
  %
  % * data: 9-vector with zero-variate data
  %
  %     d_V, g/cm^3 specific density of structure
  %     t_b, d, time at birth
  %     t_x, d, time since birth at weaning
  %     t_p, d, time since birth at puberty
  %     t_m, d, time since birth at death due to ageing
  %     W_b, g, wet weight at birth
  %     W_x, g, wet weight at weaning
  %     W_m, g, maximum wet weight
  %     R_m, #/d, maximum reproduction rate
  
  %% Remarks
  % The theory behind iget_pars_9 is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.pdf comments to DEB3>.
  % See <get_pars_9_foetus.html *get_pars_9_foetus*> for inverse mapping.
  % See <iget_pars_9.html *iget_pars_9_foetus*> for egg development.
  
  %% Example of use
  % See <../mydata_get_pars_9_foetus.m *mydata_get_pars_9_foetus*>
  
  % assumptions:
  % abundant food (f=1)
  p_T = 0; % J/d,  {p_T} = 0  J/d.cm^2, surf-spec som maint
  if exist('fixed_par','var') == 0
     k_J = 0.002;         % 1/d, maturity maintenance rate coefficient
     s_G = 0.5;           % -, Gopertz stress coefficient (= small)
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
  E_Hx = par(7); % J, E_H^x, maturity level at weaning
  E_Hp = par(8); % J, E_H^p, maturity level at puberty
  h_a  = par(9); % 1/d^2, ageing acceleration

  % correct for temperature using 
  T_ref = 293.15; % K, reference temperature
  if ~exist('T', 'var')
    T = T_ref;    % K, body temperature
  end
  if ~exist('T_A', 'var')
    T_A = 8e3;    % K, Arrhenius temperature
  end
  TC = tempcorr(T, T_ref, T_A);
  p_Am = p_Am * TC; v = v * TC; p_M = p_M * TC; h_a = h_a * TC^2;

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
  l_i = 1 - l_T;                   % -, scaled ulitmate length

  % maturity at birth
  U_Hb = E_Hb/ p_Am;               % cm^2 d, scaled maturity at birth
  V_Hb = U_Hb/ (1 - kap);          % cm^2 d, scaled maturity at birth
  v_Hb = V_Hb * g^2 * k_M^3/ v^2;  % -, scaled maturity at birth
  % maturity at weaning
  U_Hx = E_Hx/ p_Am;               % cm^2 d, scaled maturity at weaning
  V_Hx = U_Hx/ (1 - kap);          % cm^2 d, scaled maturity at weaning
  v_Hx = V_Hx * g^2 * k_M^3/ v^2;  % -, scaled maturity at weaning
  % maturity at puberty
  U_Hp = E_Hp/ p_Am;               % cm^2 d, scaled maturity at puberty 
  V_Hp = U_Hp/ (1 - kap);          % cm^2 d, scaled maturity at puberty
  v_Hp = V_Hp * g^2 * k_M^3/ v^2;  % -, scaled maturity at puberty

  % obtain predictions

  pars_tx = [g; k; l_T; v_Hb; v_Hx; v_Hp]; % compose parameter vector for get_tj
  [t_p t_x t_b l_p l_x l_b] = get_tx(pars_tx, 1);

  a_b = t_b/ k_M;  % d, age at birth
  a_x = t_x/ k_M;  % d, age at weaning
  a_p = t_p/ k_M;  % d, age at puberty
  
  L_b = l_b * L_m; % cm, structural length at birth
  L_x = l_x * L_m; % cm, structural length at weaning
  %L_p = l_p * L_m; % cm, structural length at puberty
  L_i = l_i * L_m; % cm, ultimate structural length

  Ww_b = L_b^3 * (1 + w); % g, wet weight at birth
  Ww_x = L_x^3 * (1 + w); % g, wet weight at weaning
  %Ww_p = L_p^3 * (1 + w); % g, wet weight at puberty
  Ww_m = L_i^3 * (1 + w); % g, ultimate wet weight

  u_E0 = (1 + g + l_b * 3/ 4) * l_b^3/ g; % -, scaled initial reserve
  R_m = (1 - kap) * kap_R * k_M * (1 - k * v_Hp)/ u_E0;

  pars_tm = [g; l_T; h_a/ k_M^2; s_G];     % compose parameter vector
  t_m = get_tm_s(pars_tm, 1);              % -, scaled mean life span
  a_m = t_m/ k_M;                          % d, mean life span at T
  h_G = s_G * k_M * g;                     % 1/d, Gompertz aging rate
  a_m = fzero(@fnget_am, a_m, [], h_G, s_G^3 * g^2 * k_M^2/ h_a);

  t_b = a_b + t_0; % d, time at birth
  t_x = a_x - a_b; % d, time since birth at weaning
  t_p = a_p - a_b; % d, time since birth at puberty
  t_m = a_m - a_b; % d, time since birth at death

  % pack data
  data = [d_V; t_b; t_x; t_p; t_m; Ww_b; Ww_x; Ww_m; R_m];

end

% subfunctions
function f = fnget_am(a_m, h_G, t_W)
  t_G = a_m * h_G;
  f = 1 - exp(t_G) + t_G + t_G^2/2 + t_W * log(2);
end
    
       