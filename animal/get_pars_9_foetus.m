%% get_pars_9_foetus
%

%%
function par = get_pars_9_foetus(data, t_0, fixed_par, chem_par, T, T_A)
  % created 2014/06/14 by Bas Kooijman
  
  %% Syntax
  % par = <../get_pars_9_foetus *get_pars_9_foetus*> (data, t_0, T, T_A)
  
  %% Description
  % Obtains 9 DEB parameters from 9 data points at abundant food, see get_pars. 
  % See iget_pars_9_foetus for the inverse mapping
  % Similar to <get_pars_9.html *et_pars_9*>, but for foetal development with delay and no accelation
  %
  % Input
  %
  % * data: 9-vector with zero-variate data
  %
  %    d_V, g/cm^3 specific density of structure
  %    t_b, d, time at birth: t_0 + a_b
  %    t_x, d, time since birth at weaning: a_x - a_b 
  %    t_p, d, time since birth at puberty: a_p - a_b
  %    t_m, d, time since birth at death due to ageing
  %    W_b, g, wet weight at birth
  %    W_x, g, wet weight at weaning
  %    W_m, g,  maximum wet weight
  %    R_m, #/d, maximum reproduction rate
  %
  % * t_0: scalar with time at start development: a_b = t_b - t_0
  % * fixed_par: optional  vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  % * T: optional scalar with body temperature (default 293.15 K)
  % * T_A: optional scalar with Arrhenius temperature (default 8000 K)
  %
  % Output
  %
  % % par: 9-vector with DEB parameters
  %   p_Am, J/d.cm^2,  {p_Am}, max specific assimilation rate
  %   v, cm/d, energy conductance
  %   kap, -, allocation fraction to soma 
  %   p_M, J/d.cm^3, [p_M], specific somatic maintenance costs
  %   E_G, J/cm^3, [E_G] specific cost for structure
  %   E_Hb, J, E_H^b, maturity at birth 
  %   E_Hx, J, E_H^x, maturity at weaning 
  %   E_Hp, J, E_H^p, maturity at puberty 
  %   h_a, 1/d^2, ageing acceleration
  
  %% Remarks
  %  The theory behind get_pars_9 is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/Kooy2010_c.pdf comments to DEB3>.
  
  %% Example of use
  % See <../mydata_get_pars_9_foetus.m *mydata_get_pars_9_foetus*>
  
  %  assumptions:
  %  abundant food (f=1)
  %  t_0, a_b, a_x, a_p, a_m and R_m are temp-corrected to T_ref = 293 K
  if exist('fixed_par','var') == 0
     k_J = 0.002;  % 1/d, maturity maintenance rate coefficient 
     s_G = 0.5;    % -, Gopertz stress coefficient (= small)
     kap_R = 0.95; % -, reproduction efficiency
     kap_G = 0.80; % -, growth efficiency
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
  
% unpack data
d_V = data(1); % g/cm^3 specific density of structure
t_b = data(2); % d, time at birth
t_x = data(3); % d, time since birth at weaning
t_p = data(4); % d, time since birth at puberty
t_m = data(5); % d, age at death due to ageing
W_b = data(6); % g, wet weight at birth
W_x = data(7); % g, wet weight at weaning
W_m = data(8); % g,  maximum wet weight
R_m = data(9); % #/d, maximum reproduction rate

if exist('t_0', 'var') == 0
  t_0 = 0; % d, delay till start of development
end

% correct for temperature 
T_ref = 293.15;   % K, reference temperature
if ~exist('T', 'var')
  T = T_ref;      % K, body temperature
end
if ~exist('T_A', 'var')
  T_A = 8e3;      % K, Arrhenius temperature
end
TC = tempcorr(T, T_ref, T_A);
t_0 = t_0/ TC; t_b = t_b/ TC; t_x = t_x/ TC; t_p = t_p/ TC; t_m = t_m/ TC; 

a_b = max(1e-6, t_b - t_0); % d, age at birth
a_x = t_x + a_b; % d, age at weaning
a_p = t_p + a_b; % d, age at puberty
a_m = t_m + a_b; % d, age at death

l_b = (W_b/ W_m)^(1/3);  % -, scaled length at birth
l_x = (W_x/ W_m)^(1/3);  % -, scaled length at metamorphosis
r_B = log((1 - l_b)/ (1 - l_x))/ t_x;    % 1/d, von Bertalanffy growth rate
l_p = 1 - (1 - l_b) * exp(- r_B * t_p);  % -, scaled length at puberty

E_G = d_V * mu_V/ kap_G/ w_V;  % J/cm^3, [E_G] costs for structure
g = l_b/ r_B/ a_b - 1;         % -, energy investment ratio
k_M = 3 * l_b/ g/ a_b;         % 1/d, maintenance rate coefficient
k = k_J/ k_M;                  % -, maintenance ratio
p_M = E_G * k_M;               % J/d.cm^3, specific somatic maintenance costs

uE0 = (1 + g + l_b * 3/ 4) * l_b^3/ g; % -, scaled initial reserve
rho_m = R_m/ kap_R/ k_M; % -, scaled max reprod rate
kap = 1 - uE0 * R_m/ kap_R/ k_M/ (1 - l_p^3); % -, allocation fraction to soma
kap = fzero(@fnget_kap, kap, [], l_b, l_p, k, g, rho_m, uE0);
E_m = E_G/ kap/ g;       % J/cm^3, (max) reserve capacity 
w = E_m * w_E/ d_V/ mu_E;% -, contribution of reserve to weight

L_m = (W_m/ (1 + w))^(1/3); % cm, maximum structural length
v = L_m * k_M * g;       % cm/d, energy conductance
p_Am = v * E_m;          % J/d.cm^2, max spec assimilation rate

options = odeset('RelTol', 1e-10);
[l u_H] = ode45(@dget_uH, [1e-8; l_b; l_x; l_p], 0, options, l_b, kap, k, g);
E_Hb = u_H(2,1) * g * E_m * L_m^3; % J, maturity level at birth
E_Hx = u_H(3,1) * g * E_m * L_m^3; % J, maturity level at weaning
E_Hp = u_H(4,1) * g * E_m * L_m^3; % J, maturity level at puberty

h_G = s_G * g * k_M;    % 1/d, Gompertz ageing rate
t_G = a_m * h_G;        % -, scaled Gompertz ageing rate
h_a = - s_G * h_G^2 * log(2)/ (1 - exp(t_G) + t_G + t_G^2/ 2); % 1/d^2, ageing acceleration

% pack par at T_ref
par = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hx; E_Hp; h_a];
end

% subfunctions

function f = fnget_kap(kap, l_b, l_p, k, g, rho_m, u_E0)
  % rho_m: scaled max reprod rate: R_m/ k_M/ kap_R
  kap = max(1e-4,min(kap, 1-1e-4));

  options = odeset('RelTol', 1e-10);
  [l u_H] = ode45(@dget_uH, [0; l_p], 0, options, l_b, kap, k, g);
  v_Hp = u_H(end,1)/ (1 - kap); % -, scaled maturity at puberty
  % set f to zero
  f = rho_m - (1 - kap) * (1 - k * v_Hp)/ u_E0;
end

function duH = dget_uH(l, uH, l_b, kap, k, g)
  % forward integration of u_H  l = 0 to l_p
  % unpack states
  
  if l < l_b
    dl = g/ 3;
    duH = (1 - kap) * l^2 * (g + l) - k * uH;
  else
    dl = g/ 3 * (1 - l)/ (1 + g);                         % -, d/dtau l, change in scaled length 
    duH = (1 - kap) * l^2 * (g + l)/ (g + 1) - k * uH;    % -, d/dtau u_H, change in scaled maturity
  end
  
  duH = duH/ dl; % -, change in scaled maturity d/dl u_H
end
