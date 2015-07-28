%% get_pars_8_stf
% Obtains 8 DEB parameters from 8 data points at abundant food for the stf model

%%
function par = get_pars_8_stf(data, fixed_par, chem_par)
  % created 2015/05/29 by Goncalo Marques
  
  %% Syntax
  % par = <../get_pars_8_stf.m *get_pars_8_stf*> (data, fixed_par, chem_par)
  
  %% Description
  % Obtains 8 DEB parameters from 8 data points at abundant food for the stf model
  %
  % Input
  %
  %  data: 8-vector with zero-variate data
  %
  %    d_V: g/cm^3 specific density of structure
  %    a_b: d, age at birth
  %    a_p: d, age at puberty
  %    a_m: d, age at death due to ageing
  %    W_b: g, wet weight at birth
  %    W_p: g, wet weight at puberty
  %    W_m: g,  maximum wet weight
  %    R_m: #/d, maximum reproduction rate
  %
  % * fixed_par: optional  vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %  
  % Output
  %
  % * par: 8-vector with DEB parameters
  %
  %   p_Am: J/d.cm^2,  {p_Am}, max specific assimilation rate
  %   v: cm/d, energy conductance
  %   kap: -, allocation fraction to soma 
  %   p_M: J/d.cm^3, [p_M], specific somatic maintenance costs
  %   E_G: J/cm^3, [E_G] specific cost for structure
  %   E_Hb: J, E_H^b, maturity at birth 
  %   E_Hp: J, E_H^p, maturity at puberty 
  %   h_a: 1/d^2, ageing acceleration
  
  %% Remarks
  % The theory behind this mapping is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2014.html LikaAugu2014>.
  % See <iget_pars_8_stf.html *iget_pars_8_stf*> for the inverse mapping and 
  %  <get_pars_2a.html *get_pars_2a*>,
  %  <get_pars_3.html *get_pars_3*>,
  %  <get_pars_4.html *get_pars_4*>,
  %  <get_pars_5.html *get_pars_5*>,
  %  <get_pars_6.html *get_pars_6*>,
  %  <get_pars_6a.html *get_pars_6a*>,
  %  <get_pars_7.html *get_pars_7*>,
  %  <get_pars_8.html *get_pars_8*>,
  %  <get_pars_98.html *get_pars_98*>.
  
  %% Example of use
  %  See <../mydata_get_par_8_stf.m *mydata_get_par_8_stf*>
  
  %  assumptions:
  %  abundant food (f = 1)
  %  a_b, a_p, a_m and R_m are temp-corrected to T_ref = 293 K
  %  p_T = 0;      % J/d.cm^2, {p_T}, surf-spec som maint
  if exist('fixed_par','var') == 0
     k_J = 0.002;  % 1/d, maturity maintenance rate coefficient 
     s_G = 1e-4;   % -, Gopertz stress coefficient (= small)
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
a_b = data(2); % d, age at birth
a_p = data(3); % d, age at puberty
a_m = data(4); % d, age at death due to ageing
W_b = data(5); % g, wet weight at birth
W_p = data(6); % g, wet weight at puberty
W_m = data(7); % g,  maximum wet weight
R_m = data(8); % #/d, maximum reproduction rate


t_p = a_p - a_b; 

%D2
E_G = mu_V * d_V/ w_V/ kap_G;

%D1
l_b = (W_b/ W_m)^(1/3);
l_p = (W_p/ W_m)^(1/3);

%D3/D4/D5
r_B = 1/t_p * log((1 - l_b)/ (1 - l_p));
g = l_b/ a_b/ r_B - 1;
k_M = 3 * (1 + g)/ g * r_B;
p_M = k_M * E_G;

%D6
uE0 = l_b^3/ g * (1 + g + 3 * l_b/4);

%D7
k = k_J/ k_M;
tau_b = a_b * k_M;
vHb = (g/3)^3/ k * ((1/k - 1) * (6/ k^2 * (exp(- k * tau_b) - 1) + 6/ k * tau_b - 3 * tau_b^2) + tau_b^3);

%D8
ld = 1 - l_b;   % s_M * (1 - l_b)
rB = r_B / k_M;

% d/d tau vH = b2 l^2 + b3 l^3 - k vH
b3 = 1/ (1 + g); 
b2 = g/ (1 + g); 
% vH(t) = - a0 - a1 exp(- rB t) - a2 exp(- 2 rB t) - a3 exp(- 3 rB t) +
%         + (vHb + a0 + a1 + a2 + a3) exp(-kt)
a0 = - 1 / k;
a1 = ld * (2 * b2 + 3 * b3)/ (k - rB);
a2 = - ld^2 * (b2 + 3 * b3)/ (k - 2*rB);
a3 = b3 * ld^3 / (k - 3*rB);

tau_p = t_p * k_M;
vHp = - a0 - a1 * exp(-rB * tau_p) - a2 * exp(-2 * rB * tau_p) ...
      - a3 * exp(-3 * rB * tau_p) + (vHb + a0 + a1 + a2 + a3) * exp(-k * tau_p);

%D9
kap = 1 - R_m * uE0/ (k_M * kap_R * (1 - k * vHp));

%D10
E_m = E_G/ kap/ g;        % J/cm^3, (max) reserve capacity 
w = E_m * w_E/ d_V/ mu_E; % -, contribution of reserve to weight

%D11/12/13
L_m = (W_m/ (1 + w))^(1/3); % cm, maximum structural length
v = L_m * g * k_M;            % cm/d, energy conductance
p_Am = v * E_m;           % J/d.cm^2, max spec assimilation rate

%D14
E_Hb = vHb * (1 - kap) * g * E_m * L_m^3;
E_Hp = vHp * (1 - kap) * g * E_m * L_m^3;

%D15
h_a = 4.27/ a_m^3/ k_M/ g; % 1/d^2 ageing acceleration

% pack par
par = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hp; h_a];
end
