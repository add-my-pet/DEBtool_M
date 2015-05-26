%% get_pars_9_new
% Obtains 9 DEB parameters from 9 data points at abundant food

%%
function par = get_pars_9_new(data, fixed_par, chem_par)
  % created 2013/07/08 by Bas Kooijman; modified 2015/03/23 by Goncalo Marques
  
  %% Syntax
  % par = <../get_pars_9.m *get_pars_9*> (data, fixed_par, chem_par)
  
  %% Description
  % Obtains 9 DEB parameters from 9 data points at abundant food.
  % Accounts for type M acceleration
  %
  % Input
  %
  %  data: 9-vector with zero-variate data
  %
  %    d_V: g/cm^3 specific density of structure
  %    a_b: d, age at birth
  %    a_p: d, age at puberty
  %    a_m: d, age at death due to ageing
  %    W_b: g, wet weight at birth
  %    W_j: g, wet weight at metamorphosis
  %    W_p: g, wet weight at puberty
  %    W_m: g,  maximum wet weight
  %    R_m: #/d, maximum reproduction rate
  %
  % * fixed_par: optional  vector with k_J, s_G, kap_R, kap_G
  % * chem_par: optional 4 vector with w_V, w_E, mu_V, mu_E
  %  
  % Output
  %
  % * par: 9-vector with DEB parameters
  %
  %   p_Am: J/d.cm^2,  {p_Am}, max specific assimilation rate
  %   v: cm/d, energy conductance
  %   kap: -, allocation fraction to soma 
  %   p_M: J/d.cm^3, [p_M], specific somatic maintenance costs
  %   E_G: J/cm^3, [E_G] specific cost for structure
  %   E_Hb: J, E_H^b, maturity at birth 
  %   E_Hj: J, E_H^j, maturity at metamorphosis 
  %   E_Hp: J, E_H^p, maturity at puberty 
  %   h_a: 1/d^2, ageing acceleration
  
  %% Remarks
  % The theory behind this mapping is discussed in 
  %    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2014.html LikaAugu2014>.
  % See <iget_pars_9.html *iget_pars_9*> for the inverse mapping and 
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
  %  See <../mydata_get_par_9.m *mydata_get_par_9*>
  
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
W_j = data(6); % g, wet weight at metamorphosis
W_p = data(7); % g, wet weight at puberty
W_m = data(8); % g,  maximum wet weight
R_m = data(9); % #/d, maximum reproduction rate

s_M = (W_j/ W_b)^(1/3);        % -, acceleration factor
l_b = s_M * (W_b/ W_m)^(1/3);  % -, scaled length at birth
l_j = s_M * (W_j/ W_m)^(1/3);  % -, scaled length at metamorphosis
l_p = s_M * (W_p/ W_m)^(1/3);  % -, scaled length at puberty

s = (1/ l_b - 1) * log((s_M - l_j)/ (s_M - l_p)); % -, help var
a_j = (a_p * log(s_M) + a_b * s)/ (log(s_M) + s); % d, age at metam

E_G = d_V * mu_V/ kap_G/ w_V;  % J/cm^3, [E_G] costs for structure
r_B = log((s_M - l_j)/(s_M - l_p))/ (a_p - a_j); % 1/d, von Bertalanffy growth rate

t_Em = a_b/ 3.7/ l_b;    % d, max reserve residence time
p_M = 3 * r_B * E_G/ (1 - 3 * r_B * t_Em);   % J/d.cm^3, spec somatic maintenance
k_M = p_M/ E_G;         % 1/d, somatic maintenance rate coefficient
g = r_B/ (k_M/ 3 - r_B); % -, energy investment ratio
g = fzero(@fnget_g, g, [], l_b, a_b, r_B, k_J); % 1/d, somatic maintenance rate coefficient
k_M = 3 * r_B * (1 + 1/g);
p_M = E_G * k_M;  % J/d.cm^3, spec somatic maintenance

%D10
x_b = g/ (1 + g);        % -, see Tab 2.1 of DEB3
alpha_b = 3 * g * x_b^(1/3)/ l_b; % -, see Tab 2.1 of DEB3
uE0 = (3 * g/ (alpha_b - beta0(0, x_b)))^3; % -, see (2.42) of DEB3
tau_b = a_b * k_M;

%D11
k = k_J/ k_M;
luv0 = [0, uE0, 0];
options = odeset('RelTol', 1e-10);
[t luv] = ode45(@dget_luv, [1e-8; tau_b], luv0, options, g, k);
vHb = luv(end, 3);

%D12
rj = g/(1 + g) * (1 - l_b)/ l_b;
vHj = l_b^3 * (1/l_b - rj/g)/ (k + rj) * (s_M^3 - s_M^(-3*k/rj)) + vHb * s_M^(-3*k/rj);
% or
% tau_j = (a_j - a_b) * k_M;
% vHj = l_b^3 * (1/l_b - rj/g)/ (k + rj) * (exp(rj * tau_j) - exp(-k * tau_j)) + vHb * exp(-k * tau_j);

%D13
li = s_M;        % -, scaled ultimate length
ld = li - l_j;   % s_M * (1 - l_b)
rB = r_B / k_M;

% d/d tau vH = b2 l^2 + b3 l^3 - k vH
b3 = 1/ (1 + g); 
b2 = s_M - b3 * li; % = s_M * g/ (1 + g)  
% vH(t) = - a0 - a1 exp(- rB t) - a2 exp(- 2 rB t) - a3 exp(- 3 rB t) +
%         + (vHb + a0 + a1 + a2 + a3) exp(-kt)
a0 = - (b2 + b3 * li) * li^2/ k;
a1 = li * ld * (2 * b2 + 3 * b3 * li)/ (k - rB);
a2 = - ld^2 * (b2 + 3 * b3 * li)/ (k - 2*rB);
a3 = b3 * ld^3 / (k - 3*rB);

% tau_p = 1/rB * log((li - l_j)/(li - l_p))
% % or
% % tau_p = (a_p - a_j) * k_M
% vHp = - a0 - a1 * exp(-rB * tau_p) - a2 * exp(-2 * rB * tau_p) ...
%       - a3 * exp(-3 * rB * tau_p) + (vHj + a0 + a1 + a2 + a3) * exp(-k * tau_p);

tjrB = (li - l_p)/ (li - l_j);
tjk = tjrB^(k/ rB);
vHp = - a0 - a1 * tjrB - a2 * tjrB^2 - a3 * tjrB^3 + (vHj + a0 + a1 + a2 + a3) * tjk;

%D14
kap = 1 - R_m * uE0/ (k_M * kap_R * (s_M^3 - k * vHp));

%D15
E_m = E_G/ kap/ g;        % J/cm^3, (max) reserve capacity 
w = E_m * w_E/ d_V/ mu_E; % -, contribution of reserve to weight

%D16/17/18
L_m = (W_m/ (1 + w))^(1/3)/ s_M; % cm, maximum structural length
v = L_m * g * k_M;            % cm/d, energy conductance
p_Am = v * E_m;           % J/d.cm^2, max spec assimilation rate

%D19/D20/D21
E_Hb = vHb * (1 - kap) * g * E_m * L_m^3;
E_Hj = vHj * (1 - kap) * g * E_m * L_m^3;
E_Hp = vHp * (1 - kap) * g * E_m * L_m^3;

%D22
h_a = 4.27/ a_m^3/ k_M/ g; % 1/d^2 ageing acceleration

% pack par
par = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hj; E_Hp; h_a];
end

%% subfunctions

function f = fnget_g(g, l_b, a_b, r_B, k_J)
  k_M = 3 * r_B * (1 + 1/g);
  
  xb = g/ (1 + g); % f = e_b 
  alphab = 3 * g * xb^(1/ 3)/ l_b; % \alpha_b
  uE0 = (3 * g/ (alphab - beta0(0, xb)))^3; % -, see (2.42) of DEB3

  k = k_J/ k_M;
  luv0 = [0, uE0, 0];
  options = odeset('RelTol', 1e-12, 'Events', @(t, vars)event_mat_eff(t, vars, 1, g));
  [t luv] = ode45(@(t, luv)dget_luv(t, luv, g, k), [1e-8; 2], luv0, options);
  tb = t(end);
  
  f = a_b - tb/ k_M; % set f to zero
end

function [value, isterm, dir] = event_mat_eff(t, vars, etarget, g)
%% stop integrating when e = etarget
 %% unpack vars
 l = vars(1);
 u = vars(2);
 value = l^3 * etarget - g * u;
 isterm = 1;
 dir = 1;
end