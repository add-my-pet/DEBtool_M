%% get_pars_7
% Obtains 7 DEB parameters from 7 data points at abundant food

%%
function par = get_pars_7(data, fixed_par, chem_par)
  % created 2015/01/19 by Bas Kooijman
  
  %% Syntax
  % par = <../get_pars_7.m *get_pars_7*> (data, fixed_par, chem_par)
  
  %% Description
  % Obtains 7 DEB parameters from 7 data points at abundant food
  %
  % Input
  %
  % * data: 7-vector with zero-variate data
  %
  %    d_V: g/cm^3 specific density of structure
  %    a_b: d, age at birth
  %    a_p: d, age at puberty
  %    W_b: g, wet weight at birth
  %    W_p: g, wet weight at puberty
  %    W_m: g,  maximum wet weight
  %    R_m: #/d, maximum reproduction rate
  %
  % * fixed_par: optional 3 vector with k_J, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %  
  % Output
  %
  % * par: 7-vector with DEB parameters
  %
  %     p_Am: J/d.cm^2,  {p_Am}, max specific assimilation rate
  %     v: cm/d, energy conductance
  %     kap: -, allocation fraction to soma 
  %     p_M: J/d.cm^3, [p_M], specific somatic maintenance costs
  %     E_G: J/cm^3, [E_G] specific cost for structure
  %     E_Hb: J, E_H^b, maturity at birth 
  %     E_Hp: J, E_H^p, maturity at puberty 
  
  %% Remarks
  % Assumes absence of acceleration
  % The theory behind this mapping is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2014.html LikaAugu2014>.
  % See also 
  %  <get_pars_2a.html *get_pars_2a*>,
  %  <get_pars_3.html *get_pars_3*>,
  %  <get_pars_4.html *get_pars_4*>,
  %  <get_pars_5.html *get_pars_5*>,
  %  <get_pars_6.html *get_pars_6*>,
  %  <get_pars_6a.html *get_pars_6a*>,
  %  <get_pars_7.html *get_pars_7*>,
  %  <get_pars_8.html *get_pars_8*>,
  %  <get_pars_9.html *get_pars_9*>.
  
  %% Example of use
  %  See <../mydata_get_par_2_9.m *mydata_get_par_2_9*>
  
  %  assumptions:
  %  abundant food (f = 1)
  %  a_b, a_p, a_m and R_m are temp-corrected to T_ref = 293 K
  %  absence of acceleration
  %  {p_T} = 0     % J/d.cm^2, surf-spec som maint
  if exist('fixed_par','var') == 0
     k_J = 0.002;           % 1/d, maturity maintenance rate coefficient 
     kap_R = 0.95;          % -, reproduction efficiency
     kap_G = 0.80;          % -, growth efficiency
  else
     k_J   = fixed_par(1);  % 1/d, maturity maintenance rate coefficient 
     kap_R = fixed_par(2);  % -, reproduction efficiency
     kap_G = fixed_par(3);  % -, growth efficiency
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

% unpack data
d_V = data(1); % g/cm^3 specific density of structure
a_b = data(2); % d, age at birth
a_p = data(3); % d, age at puberty
W_b = data(4); % g, wet weight at birth
W_p = data(5); % g, wet weight at puberty
W_m = data(6); % g,  maximum wet weight
R_m = data(7); % #/d, maximum reproduction rate

l_b = (W_b/ W_m)^(1/3);  % -, scaled length at birth
l_p = (W_p/ W_m)^(1/3);  % -, scaled length at puberty

E_G = d_V * mu_V/ kap_G/ w_V;                % J/cm^3, [E_G] costs for structure
r_B = log((1 - l_b)/(1 - l_p))/ (a_p - a_b); % 1/d, von Bertalanffy growth rate

t_Em = a_b/ 3.7/ l_b;    % d, max reserve residence time
p_M = 3 * r_B * E_G/ (1 - 3 * r_B * t_Em);   % J/d.cm^3, spec somatic maintenance
k_M = p_M/ E_G;         % 1/d, somatic maintenance rate coefficient
k_M = fzero(@fnget_kM, k_M, [], l_b, a_b, r_B); % 1/d, somatic maintenance rate coefficient
p_M = E_G * k_M;  % J/d.cm^3, spec somatic maintenance
g = r_B/ (k_M/ 3 - r_B); % -, energy investment ratio
t_Em = 1/ g/ k_M;        % d, max reserve residence time

kap = 1 - R_m * l_b^3 * (1.75/ g + 1)/ (0.95 * k_M); % -, allocation fraction to soma
kap = fzero(@fnget_kap, kap, [], w_E, d_V, mu_E, g, E_G, l_b, l_p, W_m, t_Em, p_M, k_J, kap_R, R_m);
E_m = E_G/ kap/ g;       % J/cm^3, (max) reserve capacity 
w = E_m * w_E/ d_V/ mu_E;% -, contribution of reserve to weight

L_m = (W_m/ (1 + w))^(1/3); % cm, maximum structural length
v = L_m/ t_Em;           % cm/d, energy conductance
p_Am = v * E_m;          % J/d.cm^2, max spec assimilation rate

L_b = l_b * L_m;         % cm, structural length at birth
L_p = l_p * L_m;         % cm, structural length at puberty

x_b = g/ (1 + g);        % -, see Tab 2.1 of DEB3
alpha_b = 3 * g * x_b^(1/3)/ l_b; % -, see Tab 2.1 of DEB3
uE0 = (3 * g/ (alpha_b - beta0(0, x_b)))^3; % -, see (2.42) of DEB3
E_0 = uE0 * L_m^3 * E_G/ kap; % J, initial reserve

options = odeset('RelTol', 1e-10);
[L HE] = ode45(@dget_HE, [1e-8; L_b; L_p], [0; E_0], options, L_b, E_m, v, p_M, E_G, kap, k_J);
E_Hb = HE(2,1); E_Hp = HE(3,1); % J, maturity levels


% pack par
par = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hp];
end

% subfunctions

function f = fnget_kM(k_M, l_b, a_b, r_B)
  k_M = max(k_M, 3 * r_B + 1e-10);
  g = r_B/ (k_M/ 3 - r_B); % -, energy investment ratio
  f = a_b - get_tb(g, 1, l_b)/ k_M; % set f to zero
end

function f = fnget_kap(kap, w_E, d_V, mu_E, g, E_G, l_b, l_p, W_m, t_Em, p_M, k_J, kap_R, R_m)
  k_M = p_M/ E_G;          % 1/d, somatatic maintenance rate coefficient
  E_m = E_G/ kap/ g;       % J/cm^3, (max) reserve capacity 
  w = E_m * w_E/ d_V/ mu_E;% -, contribution of reserve to weight

  L_m = (W_m/ (1 + w))^(1/3); % cm, maximum structural length
  v = L_m/ t_Em;           % cm/d, energy conductance

  L_b = l_b * L_m;         % cm, structural length at birth
  L_p = l_p * L_m;         % cm, structural length at puberty

  x_b = g/ (1 + g);        % -, see Tab 2.1 of DEB3
  alpha_b = 3 * g * x_b^(1/3)/ l_b; % -, see Tab 2.1 of DEB3
  uE0 = (3 * g/ (alpha_b - beta0(0, x_b)))^3; % -, see (2.42) of DEB3
  E_0 = uE0 * L_m^3 * E_G/ kap; % J, initial reserve

  options = odeset('RelTol', 1e-10);
  [L HE] = ode45(@dget_HE, [1e-8; L_b; L_p], [0; E_0], options, L_b, E_m, v, p_M, E_G, kap, k_J);
  E_Hp = HE(3,1); % J, maturity at puberty
  % set f to zero
  f = R_m - kap_R * (L_m^3 * k_M * E_G * (1 - kap)/ kap - k_J * E_Hp)/ E_0;
end

function dHE = dget_HE(L, EH, L_b, E_m, v, p_M, E_G, kap, k_J)
  % forward integration of E_H and E from L = 0 to L_p, without acceleration
  % unpack states
  E_H = EH(1); % J, maturity
  E = EH(2);   % J, reserve
  
  V = L^3; % cm^3, structural volume
  if L < L_b % embryo
    r = (E * v/ L - p_M * V/ kap)/ (E + E_G * V/ kap); % 1/d, specific growth rate
    p_C = E * (v/ L - r); % J/d, mobilisation rate
    dE_H = (1 - kap) * p_C - k_J * E_H; % J/d, d/dt E_H, change in maturity
    dE = - p_C;     % J/d, d/dt E, change in reserve
    dL = L * r/ 3;  % cm/d, d/dt L, change in length
  else % juvenile, post metam
    r = (E * v/ L - p_M * V/ kap)/ (E + E_G * V/ kap); % 1/d, specific growth rate
    p_C = E * (v/ L - r); % J/d, mobilisation rate
    dE_H = (1 - kap) * p_C - k_J * E_H;% J/d, d/dt E_H, change in maturity
    dL = L * r/ 3;  % cm/d, d/dt L, change in length  
    dE = E_m * 3 * L^2 * dL;  % J/d, d/dt E, change in reserve
  end
  
  dHE = [dE_H; dE]/ dL; % J/cm, change in maturity and reserve
end
