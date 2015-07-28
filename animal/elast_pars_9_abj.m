% created 2015/05/30 by Goncalo Marques

function elast_pars_9_abj

% set data according to generalised animal (see mydata_my_pet, but kap_G = 0.8)
%  assume T = T_ref; f = 1
d_V = 0.1;
a_b = 115.8;         % d, age at birth
a_p = 464.1;         % d, age at puberty
a_m = 1288;          % d, life span
W_b = 2.156;         % g, wet weight at birth
W_j = 20.39;         % g, wet weight at metamorphosis
W_p = 316;           % g, wet weight at puberty
W_m = 55700;         % g, ultimate wet weight
R_m = 7.23;          % #/d, ultimate reproduction rate


% % set parameters according to generalised animal (see mydata_my_pet, but kap_G = 0.8)
% %  assume T = T_ref; f = 1
% d_V = 0.1;           % g/cm^3, specific density of structure
% z = 1;               %  -, zoom factor
% v = 0.02;            % 2 cm/d, energy conductance
% kap = 0.8;           % 3 -, allocation fraction to soma = growth + somatic maintenance
% p_M = 18;            % 4 J/d.cm^3, [p_M], vol-specific somatic maintenance
% p_Am = z * p_M/ kap; % 1 J/d.cm^2, max specific assimilation rate
% E_G = 2.6151e4 * d_V;% 5 J/cm^3, [E_G], spec cost for structure: d_V * mu_V/ kap_G/ w_V 
% E_Hb = z^3 * .275;   % 6 J, E_H^b, maturity at birth
% E_Hj = 10 * E_Hb;    % 7 J, E_H^j, maturity at metamorphosis
% E_Hp = z^3 * 50;     % 8 J, E_H^p, maturity at puberty
% h_a = 1e-6;          % 9 1/d^2, Weibull aging acceleration

txt_par = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate';
 '2 v, cm/d, energy conductance';
 '3 kap, -, allocation fraction to soma';
 '4 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance';
 '5 E_G, J/cm^3, [E_G], spec cost for structure';
 '6 E_Hb, J, E_H^b, maturity at birth';
 '7 E_Hj, J, E_H^j, maturity at metamorphosis';
 '8 E_Hp, J, E_H^p, maturity at puberty';
 '9 h_a, 1/d^2, Weibull aging acceleration'};

txt_data = { ...
 '1 d_V, g/cm^3, specific density of structure';
 '2 a_b, d, age at birth';
 '3 a_p, d, age at puberty';
 '4 a_m, d, age at death due to ageing';
 '5 W_b, g, wet weight at birth';
 '6 W_j, g, wet weight at metamorphosis';
 '7 W_p, g, wet weight at puberty';
 '8 W_m, g, maximum wet weight';
 '9 R_m, #/d, maximum reproduction rate'};

% % pack par
% par = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hj; E_Hp; h_a];

% set fixed parameters
k_J = 0.002;  % 1/d, maturity maintenance rate coefficient (or 0 for kap)
s_G = 1e-4;   % -, Gopertz stress coefficient (= small; only required for filters)
kap_R = 0.95; % -, reproduction efficiency
kap_G = 0.80; % -, growth efficiency
% fixed_par = [k_J; s_G; kap_R; kap_G]; % pack fixed pars

% set chemical parameters
w_V = 23.9;   % g/C-mol, molecular weight of structure
w_E = 23.9;   % g/C-mol, molecular weight of reserve
mu_V = 5E5;   % J/C-mol, chemical potential of structure
mu_E = 5.5E5; % J/C-mol, chemical potential of reserve
% chem_par = [w_V; w_E; mu_V; mu_E]; % pack chem pars

% [fil_p fl_p] = filter_pars_9(par, fixed_par, chem_par); % run parameter filter
% if fil_p == 0
%   fprintf(['pars do not pass filter with flag ', num2str(fl_p),'\n'])
%   return
% end
% 
% % run iget_pars_9 and get_pars_9
% data = iget_pars_9(par, fixed_par, chem_par);   % map par to data
% Epar = get_pars_9(data, fixed_par, chem_par);   % map data to par
% Edata = iget_pars_9(Epar, fixed_par, chem_par); % map par to data

s_M = (W_j/ W_b)^(1/3);        % -, acceleration factor
l_b = s_M * (W_b/ W_m)^(1/3);  % -, scaled length at birth
l_j = s_M * (W_j/ W_m)^(1/3);  % -, scaled length at metamorphosis
l_p = s_M * (W_p/ W_m)^(1/3);  % -, scaled length at puberty

s = ((s_M - l_j)/ (s_M - l_p))^(1/ l_b - 1); % -, help var
a_j = (a_p * log(s_M) + a_b * log(s))/ (log(s_M) + log(s)); % d, age at metam

E_G = d_V * mu_V/ kap_G/ w_V;  % J/cm^3, [E_G] costs for structure
r_B = log((s_M - l_j)/(s_M - l_p))/ (a_p - a_j); % 1/d, von Bertalanffy growth rate

t_Em = a_b/ 3.7/ l_b;    % d, max reserve residence time
p_M = 3 * r_B * E_G/ (1 - 3 * r_B * t_Em);   % J/d.cm^3, spec somatic maintenance
k_M = p_M/ E_G;         % 1/d, somatic maintenance rate coefficient
g = r_B/ (k_M/ 3 - r_B); % -, energy investment ratio
g = fzero(@fnget_g, g, [], l_b, a_b, r_B); % 1/d, somatic maintenance rate coefficient
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
% vHj = l_b^3 * (1/l_b - rj/g)/ (k + rj) * (s_M^3 - s_M^(-3*k/rj)) + vHb * s_M^(-3*k/rj);
% or
tau_j = (a_j - a_b) * k_M;
vHj = l_b^3 * (1/l_b - rj/g)/ (k + rj) * (exp(rj * tau_j) - exp(-k * tau_j)) + vHb * exp(-k * tau_j);

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
tau_p = (a_p - a_j) * k_M;
vHp = - a0 - a1 * exp(-rB * tau_p) - a2 * exp(-2 * rB * tau_p) ...
      - a3 * exp(-3 * rB * tau_p) + (vHj + a0 + a1 + a2 + a3) * exp(-k * tau_p);
  
% tjrB = (li - l_p)/ (li - l_j);
% tjk = tjrB^(k/ rB);
% vHp = - a0 - a1 * tjrB - a2 * tjrB^2 - a3 * tjrB^3 + (vHj + a0 + a1 + a2 + a3) * tjk;

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


% [d_V; a_b; a_p; a_m; W_b; W_j; W_p; W_m; R_m];

%D1 - s_M
elast_sM = zeros(9,1);
elast_sM_Wb = -1/3;            elast_sM(5) = elast_sM_Wb;
elast_sM_Wj = 1/3;             elast_sM(6) = elast_sM_Wj;
Elast_sM = elast_sM;

%D2 - l_b, l_j, l_p
elast_lb = zeros(9,1);
elast_lb_Wb = 1/3;             elast_lb(5) = elast_lb_Wb;
elast_lb_Wm = -1/3;            elast_lb(8) = elast_lb_Wm;
elast_lb_sM = 1;
Elast_lb = elast_lb + elast_lb_sM * Elast_sM;

elast_lj = zeros(9,1);
elast_lj_Wj = 1/3;             elast_lj(6) = elast_lj_Wj;
elast_lj_Wm = -1/3;            elast_lj(8) = elast_lj_Wm;
elast_lj_sM = 1;
Elast_lj = elast_lj + elast_lj_sM * Elast_sM;

elast_lp = zeros(9,1);
elast_lp_Wp = 1/3;             elast_lp(7) = elast_lp_Wp;
elast_lp_Wm = -1/3;            elast_lp(8) = elast_lp_Wm;
elast_lp_sM = 1;
Elast_lp = elast_lp + elast_lp_sM * Elast_sM;

%D3 - a_j
elast_s_lb = - log((s_M - l_j)/ (s_M - l_p))/ l_b;
elast_s_lj = 1;
elast_s_lp = l_p/ (s_M - l_p) * (1/ l_b - 1);
elast_s_sM = - s_M * (l_p - l_j)/ (s_M - l_j)/ (s_M - l_p) * (1/ l_b - 1);
Elast_s = elast_s_lb * Elast_lb + elast_s_lj * Elast_lj + elast_s_lp * Elast_lp + elast_s_sM * Elast_sM;
Elast_s(5) = 0; % because numerical errors are giving 1E-17 when it should be zero

elast_aj = zeros(9,1);
elast_aj_ab = a_b * log(s)/ (a_p * log(s_M) + a_b * log(s));        elast_aj(2) = elast_aj_ab;
elast_aj_ap = a_p * log(s_M)/ (a_p * log(s_M) + a_b * log(s));      elast_aj(3) = elast_aj_ap;
elast_aj_sM = log(s)/ a_j * (a_p - a_b)/ (log(s_M) + log(s))^2; 
elast_aj_s = - elast_aj_sM * log(s_M)/ log(s);
Elast_aj = elast_aj + elast_aj_sM * Elast_sM + elast_aj_s * Elast_s;

%D4 - E_G
elast_EG = zeros(9,1);
elast_EG_dV = 1;               elast_EG(1) = elast_EG_dV;
Elast_EG = elast_EG;

%D5 - r_B
elast_rB = zeros(9,1);
elast_rB_aj = a_j/ (a_p - a_j);
elast_rB_ap = -a_p/ (a_p - a_j);        elast_rB(3) = elast_rB_ap;
xi = log((s_M - l_j)/(s_M - l_p));
elast_rB_lj = -l_j/ (s_M - l_j)/ xi; 
elast_rB_lp = l_p/ (s_M - l_p)/ xi;
elast_rB_sM = - s_M * (l_p - l_j)/ (s_M - l_j)/ (s_M - l_p)/ xi;
Elast_rB = elast_rB + elast_rB_aj * Elast_aj + elast_rB_lj * Elast_lj + elast_rB_lp * Elast_lp + elast_rB_sM * Elast_sM;

%D6 - g
xi = quad(@(x) 1./ x.^(2/3)./ (1 - x)./ (alpha_b - beta0(0, x_b) + beta0(0, x)).^2, 1E-18, x_b, 1E-14) ...
                + 3 * 1E-6/ (alpha_b - beta0(0, x_b))^2; % 3 * delta^(1/3)/ (alpha_b - beta0(0, x_b)) where delta the start of integration of quad
dfdg = -1/(1 + g) * ( (a_b * r_B + l_b/ 3)/ g - xi * alpha_b * ((1 - x_b) * (1 - l_b)/ 3 + 1) );
elast_g = zeros(9,1);
elast_g_ab = - a_b * r_B/ g/ dfdg;      elast_g(2) = elast_g_ab;
elast_g_rB = elast_g_ab;
elast_g_lb = x_b * alpha_b * xi/ g/ dfdg;
Elast_g = elast_g + elast_g_rB * Elast_rB + elast_g_lb * Elast_lb;

%D7 - pM
elast_kM_rB = 1;
elast_kM_g = -1/(1 + g);
Elast_kM = elast_kM_rB * Elast_rB + elast_kM_g * Elast_g;

elast_pM_kM = 1;
elast_pM_EG = 1;
Elast_pM = elast_pM_kM * Elast_kM + elast_pM_EG * Elast_EG;

%D8 - uE0
elast_xb_g = 1/ (1 + g);
Elast_xb = elast_xb_g * Elast_g;

elast_alphab_g = 1;
elast_alphab_xb = 1/3;
elast_alphab_lb = -1;
Elast_alphab = elast_alphab_g * Elast_g + elast_alphab_xb * Elast_xb + elast_alphab_lb * Elast_lb;

elast_uE0_g = 3;
xi = alpha_b - beta0(0, x_b);
elast_uE0_alphab = -3 * alpha_b/ xi;
elast_uE0_xb = alpha_b * l_b/ xi;
Elast_uE0 = elast_uE0_g * Elast_g + elast_uE0_alphab * Elast_alphab + elast_uE0_xb * Elast_xb;

%D9 - vHb %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Needs to be done properly
elast_taub = zeros(9,1);
elast_taub_ab = 1;              elast_taub(2) = elast_taub_ab;
elast_taub_kM = 1;
Elast_taub = elast_taub + elast_taub_kM * Elast_kM;

elast_k_kM = -1;
Elast_k = elast_k_kM * Elast_kM;

del = 1e-6;
luv0 = [0, uE0, 0];
options = odeset('RelTol', 1e-10);

[t luv] = ode45(@dget_luv, [1e-8; tau_b], luv0, options, g + del, k);
vHb_g = luv(end, 3);

[t luv] = ode45(@dget_luv, [1e-8; tau_b], luv0, options, g, k + del);
vHb_k = luv(end, 3);

[t luv] = ode45(@dget_luv, [1e-8; tau_b + del], luv0, options, g, k);
vHb_taub = luv(end, 3);

elast_vHb_g = g/ vHb * (vHb_g - vHb)/ del;
elast_vHb_k = k/ vHb * (vHb_k - vHb)/ del;
elast_vHb_taub = tau_b/ vHb * (vHb_taub - vHb)/ del;
Elast_vHb = elast_vHb_g * Elast_g + elast_vHb_k * Elast_k + elast_vHb_taub * Elast_taub;

%D10 - vHj
elast_rj_xb = 1;
elast_rj_lb = -1/ (1 - l_b);
Elast_rj = elast_rj_xb * Elast_xb + elast_rj_lb * Elast_lb;

tau_j = (a_j - a_b) * k_M;

elast_tauj = zeros(9,1);
elast_tauj_ab = -a_b/ (a_j - a_b);      elast_tauj(2) = elast_tauj_ab;
elast_tauj_aj = a_j/ (a_j - a_b);
elast_tauj_kM = 1;
Elast_tauj = elast_tauj + elast_tauj_aj * Elast_aj + elast_tauj_kM * Elast_kM;

elast_vHj_vHb = vHb/ vHj * exp(-k * tau_j);
xi = (1 - elast_vHj_vHb)/ (1/ l_b - rj/ g);
elast_vHj_lb = (2/ l_b - 3 * rj/ g) * xi;
elast_vHj_g = rj/ g * xi;
elast_vHj_rj = l_b^3/ vHj * rj/ (k + rj) * ((-1/ g - (1/l_b - rj/g)/ (k + rj)) * (exp(rj * tau_j) - exp(-k * tau_j)) + (1/l_b - rj/g) * tau_j * exp(rj * tau_j));
elast_vHj_k = -k/ vHj * (l_b^3 * (1/l_b - rj/g)/ (k + rj) * ((exp(rj * tau_j) - exp(-k * tau_j))/ (k + rj) - tau_j * exp(-k * tau_j)) + vHb * tau_j * exp(-k * tau_j));
elast_vHj_tauj = tau_j/ vHj * (l_b^3 * (1/l_b - rj/g)/ (k + rj) * (rj * exp(rj * tau_j) + k * exp(-k * tau_j)) - vHb * k * exp(-k * tau_j));
Elast_vHj = elast_vHj_lb * Elast_lb + elast_vHj_vHb * Elast_vHb + elast_vHj_g * Elast_g + elast_vHj_rj * Elast_rj + elast_vHj_k * Elast_k + elast_vHj_tauj * Elast_tauj;

%D11 - vHp  
% don't forget li = sM 
elast_ld_lj = - l_j/ ld;
elast_ld_sM = s_M/ ld;
Elast_ld = elast_ld_lj * Elast_lj + elast_ld_sM * Elast_sM;

elast_rBkM_rB = 1;
elast_rBkM_kM = -1;
Elast_rBkM = elast_rBkM_rB * Elast_rB + elast_rBkM_kM * Elast_kM;

elast_b3_g = -g/ (1 + g);
Elast_b3 = elast_b3_g * Elast_g;

elast_b2_g = 1/ (1 + g);
elast_b2_sM = 1;
Elast_b2 = elast_b2_g * Elast_g + elast_b2_sM * Elast_sM;

elast_a0_b2 = b2/ (b2 + b3 * s_M);
elast_a0_b3 = b3 * s_M/ (b2 + b3 * s_M);
elast_a0_sM = elast_a0_b3 + 2;
elast_a0_k = -1;
Elast_a0 = elast_a0_b2 * Elast_b2 + elast_a0_b3 * Elast_b3 + elast_a0_sM * Elast_sM + elast_a0_k * Elast_k;

elast_a1_b2 = 2 * b2/ (2 * b2 + 3 * b3 * s_M);
elast_a1_b3 = 3 * b3 * s_M/ (2 * b2 + 3 * b3 * s_M);
elast_a1_sM = elast_a1_b3 + 1;
elast_a1_ld = 1;
elast_a1_k = -k/ (k - rB);
elast_a1_rBkM = rB/ (k - rB);
Elast_a1 = elast_a1_b2 * Elast_b2 + elast_a1_b3 * Elast_b3 + elast_a1_sM * Elast_sM + elast_a1_ld * Elast_ld + elast_a1_k * Elast_k + elast_a1_rBkM * Elast_rBkM;

elast_a2_b2 = b2/ (b2 + 3 * b3 * s_M);
elast_a2_b3 = 3 * b3 * s_M/ (b2 + 3 * b3 * s_M);
elast_a2_sM = elast_a2_b3;
elast_a2_ld = 2;
elast_a2_k = -k/ (k - 2*rB);
elast_a2_rBkM = 2*rB/ (k - 2*rB);
Elast_a2 = elast_a2_b2 * Elast_b2 + elast_a2_b3 * Elast_b3 + elast_a2_sM * Elast_sM + elast_a2_ld * Elast_ld + elast_a2_k * Elast_k + elast_a2_rBkM * Elast_rBkM;

elast_a3_b3 = 1;
elast_a3_ld = 3;
elast_a3_k = -k/ (k - 3*rB);
elast_a3_rBkM = 3*rB/ (k - 3*rB);
Elast_a3 = elast_a3_b3 * Elast_b3 + elast_a3_ld * Elast_ld + elast_a3_k * Elast_k + elast_a3_rBkM * Elast_rBkM;

% tau_p = (a_p - a_j) * k_M;
elast_taup = zeros(9,1);
elast_taup_ap = a_p/ (a_p - a_j);      elast_taup(3) = elast_taup_ap;
elast_taup_aj = -a_j/ (a_p - a_j);
elast_taup_kM = 1;
Elast_taup = elast_taup + elast_taup_aj * Elast_aj + elast_taup_kM * Elast_kM;

% vHp = - a0 - a1 * exp(-rB * tau_p) - a2 * exp(-2 * rB * tau_p) ...
%       - a3 * exp(-3 * rB * tau_p) + (vHj + a0 + a1 + a2 + a3) * exp(-k * tau_p)

elast_vHp_vHj = vHj/ vHp * exp(-k * tau_p);
elast_vHp_rBkM = rB/ vHp * tau_p * (a1 * exp(-rB * tau_p) + 2* a2 * exp(-2 * rB * tau_p) + 3* a3 * exp(-3 * rB * tau_p));
elast_vHp_taup = tau_p/ vHp * (rB * (a1 * exp(-rB * tau_p) + 2* a2 * exp(-2 * rB * tau_p) ...
     + 3* a3 * exp(-3 * rB * tau_p)) - k * (vHj + a0 + a1 + a2 + a3) * exp(-k * tau_p));
elast_vHp_k = -k/ vHp * tau_p * (vHj + a0 + a1 + a2 + a3) * exp(-k * tau_p);
elast_vHp_a0 = a0/ vHp * (- 1 + exp(-k * tau_p));
elast_vHp_a1 = a1/ vHp * (- exp(-rB * tau_p) + exp(-k * tau_p));
elast_vHp_a2 = a2/ vHp * (- exp(-2 * rB * tau_p) + exp(-k * tau_p));
elast_vHp_a3 = a3/ vHp * (- exp(-3 * rB * tau_p) + exp(-k * tau_p));
Elast_vHp = elast_vHp_vHj * Elast_vHj + elast_vHp_rBkM * Elast_rBkM + elast_vHp_taup * Elast_taup + elast_vHp_k * Elast_k ...
     + elast_vHp_a0 * Elast_a0 + elast_vHp_a1 * Elast_a1 + elast_vHp_a2 * Elast_a2 + elast_vHp_a3 * Elast_a3;
 
elast_kap = zeros(9,1);
elast_kap_Ri = -(1-kap)/ kap;            elast_kap(9) = elast_kap_Ri;
elast_kap_uE0 = -(1-kap)/ kap;
elast_kap_kM = (1-kap)/ kap;
elast_kap_k = -(1-kap)/ kap * k * vHp/ (s_M^3 - k * vHp);
elast_kap_vHp = -(1-kap)/ kap * k * vHp/ (s_M^3 - k * vHp);
elast_kap_sM = (1-kap)/ kap * 3 * s_M^3/ (s_M^3 - k * vHp);
Elast_kap = elast_kap + elast_kap_uE0 * Elast_uE0 + elast_kap_kM * Elast_kM + elast_kap_k * Elast_k + elast_kap_vHp * Elast_vHp + elast_kap_sM * Elast_sM;

elast_Em_EG = 1;
elast_Em_kap = -1;
elast_Em_g = -1;
Elast_Em = elast_Em_EG * Elast_EG + elast_Em_kap * Elast_kap + elast_Em_g * Elast_g;

elast_w = zeros(9,1);
elast_w_Em = 1;
elast_w_dV = -1;               elast_w(1) = elast_w_dV;
Elast_w = elast_w + elast_w_Em * Elast_Em;

elast_Lm = zeros(9,1);
elast_Lm_Wi = 1/3;             elast_Lm(8) = elast_Lm_Wi;
elast_Lm_w = -1/3 * w/ (1 + w);
elast_Lm_sM = -1;
Elast_Lm = elast_Lm + elast_Lm_w * Elast_w + elast_Lm_sM * Elast_sM;

elast_v_Lm = 1;
elast_v_g = 1;
elast_v_kM = 1;
Elast_v = elast_v_Lm * Elast_Lm + elast_v_g * Elast_g + elast_v_kM * Elast_kM;

elast_pAm_v = 1;
elast_pAm_Em = 1;
Elast_pAm = elast_pAm_v * Elast_v + elast_pAm_Em * Elast_Em;

elast_EHb_vHb = 1;
elast_EHb_kap = -kap/ (1 - kap);
elast_EHb_g = 1;
elast_EHb_Em = 1;
elast_EHb_Lm = 3;
Elast_EHb = elast_EHb_vHb * Elast_vHb + elast_EHb_kap * Elast_kap + elast_EHb_g * Elast_g + elast_EHb_Em * Elast_Em + elast_EHb_Lm * Elast_Lm;

elast_EHj_vHj = 1;
elast_EHj_kap = -kap/ (1 - kap);
elast_EHj_g = 1;
elast_EHj_Em = 1;
elast_EHj_Lm = 3;
Elast_EHj = elast_EHj_vHj * Elast_vHj + elast_EHj_kap * Elast_kap + elast_EHj_g * Elast_g + elast_EHj_Em * Elast_Em + elast_EHj_Lm * Elast_Lm;

elast_EHp_vHp = 1;
elast_EHp_kap = -kap/ (1 - kap);
elast_EHp_g = 1;
elast_EHp_Em = 1;
elast_EHp_Lm = 3;
Elast_EHp = elast_EHp_vHp * Elast_vHp + elast_EHp_kap * Elast_kap + elast_EHp_g * Elast_g + elast_EHp_Em * Elast_Em + elast_EHp_Lm * Elast_Lm;

elast_ha = zeros(9,1);
elast_ha_am = -3;              elast_ha(4) = elast_ha_am;
elast_ha_kM = -1;
elast_ha_g = -1;
Elast_ha = elast_ha + elast_ha_kM * Elast_kM + elast_ha_g * Elast_g;

% code used to check th elasticities
% del = 1e-6;
% % E_Hb = vHb * (1 - kap) * g * E_m * L_m^3;
% EHb_del = vHb * (1 - kap) * g * (E_m + del) * L_m^3;
% E_m/ E_Hb * (EHb_del - E_Hb)/ del

% printpar(txt_par, par, Epar, 'name, pars, back-estimated pars')
% fprintf('\n'); % insert blank line
% printpar(txt_data, data, Edata, 'name, data, back-estimated data')
% 
% MRE_par = sum(abs(par - Epar) ./ par)/9;
% MRE_data = sum(abs(data - Edata) ./ data)/9;
% printpar({'mean relative error of par and data'}, MRE_par, MRE_data, '')

% [d_V; a_b; a_p; a_m; W_b; W_p; W_i; R_i];
% [p_Am; v; kap; p_M; E_G; E_Hb; E_Hp; h_a];

fprintf('[d_V; a_b; a_p; a_m; W_b; W_j; W_p; W_i; R_i]\n');
fprintf('p_Am\n')
fprintf('v\n')
fprintf('kap\n')
fprintf('p_M\n')
fprintf('E_G\n')
fprintf('E_Hb\n')
fprintf('E_Hj\n')
fprintf('E_Hp\n')
fprintf('h_a\n')

ep = [Elast_pAm, Elast_v, Elast_kap, Elast_pM, Elast_EG, Elast_EHb, Elast_EHj, Elast_EHp, Elast_ha]'

det(ep)

ed = inv(ep)

%ed(2, 8) = 0; ed(4, 5) = 0; ed(4, 6) = 0; ed(4, 7) = 0; ed(4, 8) = 0; ed(5, 8) = 0; ed(6, 8) = 0; ed(8, 8) = 0

ed * ep - eye(9)

end


function f = fnget_g(g, l_b, a_b, r_B)  
  xb = g/ (1 + g); % e_b = f = 1 
  alphab = 3 * g * xb^(1/ 3)/ l_b; 

  tb = 3 * (quad(@(x) 1./ x.^(2/3)./ (1 - x)./ (alphab - beta0(0, xb) + beta0(0, x)), 1E-18, xb, 1E-14) ...
                + 3 * 1E-6/ (alphab - beta0(0, xb))); % 3 * delta^(1/3)/ (alpha_b - beta0(0, x_b)) where delta the start of integration of quad
 
  f = a_b * r_B - tb/ 3 * g/ (1 + g); % set f to zero
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
