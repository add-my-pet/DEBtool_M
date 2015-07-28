% created 2015/05/29 by Goncalo Marques; modified 2015/05/30 by Goncalo Marques

% set parameters based on Balaenoptera 
d_V = 0.3;           % g/cm^3, specific density of structure
a_b = 36;            % d, time at birth
t_p = 2555;          % d, time at puberty
a_m = 29200;         % d, life span
W_b = 2.75e6;        % g, weight at birth
W_p = W_b + 30e6;    % g, weight at weaning
W_i = 160e6;         % g, weight at death
R_i = 0.0011;        % 1/d, reproduction rate
data = [d_V; a_b; a_b + t_p; a_m; W_b; W_p; W_i; R_i];

txt_par = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate';
 '2 v, cm/d, energy conductance';
 '3 kap, -, allocation fraction to soma';
 '4 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance';
 '5 E_G, J/cm^3, [E_G], spec cost for structure';
 '6 E_Hb, J, E_H^b, maturity at birth';
 '7 E_Hp, J, E_H^p, maturity at puberty';
 '8 h_a, 1/d^2, Weibull aging acceleration'};

txt_data = { ...
 '1 d_V, g/cm^3, specific density of structure';
 '2 t_b, d, time at birth';
 '3 a_p, d, age at puberty';
 '4 a_m, d, life span';
 '5 W_b, g, wet weight at birth';
 '6 W_x, g, wet weight at weaning';
 '7 W_i, g, maximum wet weight';
 '8 R_i, #/d, maximum reproduction rate'};

% to be changed when there is a filter_data_stf
% [fil_d fl_d] = filter_data_9(data); % run data filter
% if fil_d == 0
%   fprintf(['data do not pass filter with flag ', num2str(fl_d),'\n'])
% end

% assumptions
k_J = 0.002;  % 1/d, maturity maintenance rate coefficient 
s_G = 1e-4;   % -, Gopertz stress coefficient (= small)
kap_R = 0.95; % -, reproduction efficiency
kap_G = 0.80; % -, growth efficiency

w_V = 23.9;   % g/C-mol, molecular weight of structure
w_E = 23.9;   % g/C-mol, molecular weight of reserve
mu_V = 5E5;   % J/C-mol, chemical potential of structure
mu_E = 5.5E5; % J/C-mol, chemical potential of reserve


% run iget_pars_8_stf and get_pars_8_stf
par = get_pars_8_stf(data);   % map data to par
Edata = iget_pars_8_stf(par);   % map par to data
Epar = get_pars_8_stf(Edata);   % map data to par

%D2
E_G = mu_V * d_V/ w_V/ kap_G;

%D1
l_b = (W_b/ W_i)^(1/3);
l_p = (W_p/ W_i)^(1/3);

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
kap = 1 - R_i * uE0/ (k_M * kap_R * (1 - k * vHp));

%D10
E_m = E_G/ kap/ g;        % J/cm^3, (max) reserve capacity 
w = E_m * w_E/ d_V/ mu_E; % -, contribution of reserve to weight

%D11/12/13
L_m = (W_i/ (1 + w))^(1/3); % cm, maximum structural length
v = L_m * g * k_M;            % cm/d, energy conductance
p_Am = v * E_m;           % J/d.cm^2, max spec assimilation rate

%D14
E_Hb = vHb * (1 - kap) * g * E_m * L_m^3;
E_Hp = vHp * (1 - kap) * g * E_m * L_m^3;

%D15
h_a = 4.27/ a_m^3/ k_M/ g; % 1/d^2 ageing acceleration

% [d_V; a_b; a_p; a_m; W_b; W_p; W_i; R_i];

elast_lb = zeros(8,1);
elast_lb_Wb = 1/3;             elast_lb(5) = elast_lb_Wb;
elast_lb_Wi = -1/3;            elast_lb(7) = elast_lb_Wi;
Elast_lb = elast_lb;

elast_lp = zeros(8,1);
elast_lp_Wp = 1/3;             elast_lp(6) = elast_lp_Wp; 
elast_lp_Wi = -1/3;            elast_lp(7) = elast_lp_Wi;
Elast_lp = elast_lp;

elast_EG = zeros(8,1);
elast_EG_dV = 1;               elast_EG(1) = elast_EG_dV;
Elast_EG = elast_EG;

elast_rB = zeros(8,1);
a_p = a_b + t_p;
elast_rB_ab = -a_b/ t_p;       elast_rB(2) = elast_rB_ab;
elast_rB_ap = a_p/ t_p;        elast_rB(3) = elast_rB_ap;
xi = (1 - l_b)/(1 - l_p);
elast_rB_lb = -l_b/ xi/ log(xi);  
elast_rB_lp = l_p/ xi/ log(xi);
Elast_rB = elast_rB + elast_rB_lb * Elast_lb + elast_rB_lp * Elast_lp;

elast_g = zeros(8,1);
elast_g_ab = -(g + 1)/g;       elast_g(2) = elast_g_ab;
elast_g_lb = (g + 1)/g;
elast_g_rB = -(g + 1)/g;
Elast_g = elast_g + elast_g_lb * Elast_lb + elast_g_rB * Elast_rB;

elast_kM_rB = 1;
elast_kM_g = -1/(1 + g);
Elast_kM = elast_kM_rB * Elast_rB + elast_kM_g * Elast_g;

elast_pM_kM = 1;
elast_pM_EG = 1;
Elast_pM = elast_pM_kM * Elast_kM + elast_pM_EG * Elast_EG;

elast_taub = zeros(8,1);
elast_taub_ab = 1;            elast_taub(2) = elast_taub_ab;
elast_taub_kM = 1;
Elast_taub = elast_taub + elast_taub_kM * Elast_kM;

elast_k_kM = -1;
Elast_k = elast_k_kM * Elast_kM;

elast_vHb_g = 3;
elast_vHb_k = -1 - g^3/ 27/ vHb/ k^2 * ((vHb * 27 * k/ g^3 - tau_b^3)/ (1/ k - 1) + (1/ k - 1)* 6* (2/ k * (exp(-k* tau_b) - 1) + tau_b * (exp(-k* tau_b) + 1)));
elast_vHb_taub = tau_b/ vHb * g^3/ 9/ k *( 2* (1/ k - 1)*((exp(-k* tau_b) - 1)/ k - tau_b) + 3 * tau_b^2);
Elast_vHb = elast_vHb_g * Elast_g + elast_vHb_k * Elast_k + elast_vHb_taub * Elast_taub;

elast_uE0_lb = 3 * ( 1 + l_b^4/ 4/ g/ uE0);
elast_uE0_g = -1 + l_b^3/ uE0;
Elast_uE0 = elast_uE0_lb * Elast_lb + elast_uE0_g * Elast_g;

% for vHp
elast_ld_lb = - l_b/ ld;
Elast_ld = elast_ld_lb * Elast_lb;

elast_rBkM_rB = 1;
elast_rBkM_kM = -1;
Elast_rBkM = elast_rBkM_rB * Elast_rB + elast_rBkM_kM * Elast_kM;

elast_a0_k = -1;
Elast_a0 = elast_a0_k * Elast_k;

elast_a1_k = -k/ (k - rB);
elast_a1_rBkM = rB/ (k - rB);
elast_a1_ld = 1;
elast_a1_g = g/ (1 + g)/ (2 + 3*g);
Elast_a1 = elast_a1_k * Elast_k + elast_a1_rBkM * Elast_rBkM + elast_a1_ld * Elast_ld + elast_a1_g * Elast_g;

elast_a2_k = -k/ (k - 2*rB);
elast_a2_rBkM = 2*rB/ (k - 2*rB);
elast_a2_ld = 2;
elast_a2_g = 2*g/ (1 + g)/ (1 + 3*g);
Elast_a2 = elast_a2_k * Elast_k + elast_a2_rBkM * Elast_rBkM + elast_a2_ld * Elast_ld + elast_a2_g * Elast_g;

elast_a3_k = -k/ (k - 3*rB);
elast_a3_rBkM = 3*rB/ (k - 3*rB);
elast_a3_ld = 3;
elast_a3_g = -1/ (1 + g);
Elast_a3 = elast_a3_k * Elast_k + elast_a3_rBkM * Elast_rBkM + elast_a3_ld * Elast_ld + elast_a3_g * Elast_g;

elast_taup = zeros(8,1);
elast_taup_ap = a_p/ (a_p - a_b);      elast_taup(3) = elast_taup_ap;
elast_taup_ab = -a_b/ (a_p - a_b);     elast_taup(2) = elast_taup_ab;
elast_taup_kM = 1;
Elast_taup = elast_taup + elast_taup_kM * Elast_kM;

vHp = - a0 - a1 * exp(-rB * tau_p) - a2 * exp(-2 * rB * tau_p) ...
      - a3 * exp(-3 * rB * tau_p) + (vHb + a0 + a1 + a2 + a3) * exp(-k * tau_p);

elast_vHp_vHb = vHb/ vHp * exp(-k * tau_p);
elast_vHp_taup = tau_p/ vHp * (rB * ( a1 * exp(-rB * tau_p) + 2* a2 * exp(-2 * rB * tau_p) ...
     + 3* a3 * exp(-3 * rB * tau_p)) - k * (vHb + a0 + a1 + a2 + a3) * exp(-k * tau_p));
elast_vHp_k = -k/ vHp * tau_p * (vHb + a0 + a1 + a2 + a3) * exp(-k * tau_p);
elast_vHp_a0 = - 1 + exp(-k * tau_p);
elast_vHp_a1 = - exp(-rB * tau_p) + exp(-k * tau_p);
elast_vHp_a2 = - exp(-2 * rB * tau_p) + exp(-k * tau_p);
elast_vHp_a3 = - exp(-3 * rB * tau_p) + exp(-k * tau_p);
Elast_vHp = elast_vHp_vHb * Elast_vHb + elast_vHp_taup * Elast_taup + elast_vHp_k * Elast_k ...
     + elast_vHp_a0 * Elast_a0 + elast_vHp_a1 * Elast_a1 + elast_vHp_a2 * Elast_a2 + elast_vHp_a3 * Elast_a3;

elast_kap = zeros(8,1);
elast_kap_Ri = -(1-kap)/ kap;   elast_kap(8) = elast_kap_Ri;
elast_kap_uE0 = -(1-kap)/ kap;
elast_kap_kM = (1-kap)/ kap;
elast_kap_k = -(1-kap)/ kap * k/ (1 - k * vHp);
elast_kap_vHp = -(1-kap)/ kap * vHp/ (1 - k * vHp);
Elast_kap = elast_kap + elast_kap_uE0 * Elast_uE0 + elast_kap_kM * Elast_kM + elast_kap_k * Elast_k + elast_kap_vHp * Elast_vHp;

elast_Em_EG = 1;
elast_Em_kap = -1;
elast_Em_g = -1;
Elast_Em = elast_Em_EG * Elast_EG + elast_Em_kap * Elast_kap + elast_Em_g * Elast_g;

elast_w = zeros(8,1);
elast_w_Em = 1;
elast_w_dV = -1;               elast_w(1) = elast_w_dV;
Elast_w = elast_w + elast_w_Em * Elast_Em;

elast_Lm = zeros(8,1);
elast_Lm_Wi = 1/3;             elast_Lm(7) = elast_Lm_Wi;
elast_Lm_w = -1/3 * w/ (1 + w);
Elast_Lm = elast_Lm + elast_Lm_w * Elast_w;

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

elast_EHp_vHp = 1;
elast_EHp_kap = -kap/ (1 - kap);
elast_EHp_g = 1;
elast_EHp_Em = 1;
elast_EHp_Lm = 3;
Elast_EHp = elast_EHp_vHp * Elast_vHp + elast_EHp_kap * Elast_kap + elast_EHp_g * Elast_g + elast_EHp_Em * Elast_Em + elast_EHp_Lm * Elast_Lm;

elast_ha = zeros(8,1);
elast_ha_am = -3;              elast_ha(4) = elast_ha_am;
elast_ha_kM = -1;
elast_ha_g = -1;
Elast_ha = elast_ha + elast_ha_kM * Elast_kM + elast_ha_g * Elast_g;


printpar(txt_par, par, Epar, 'name, pars, back-estimated pars')
fprintf('\n'); % insert blank line
printpar(txt_data, data, Edata, 'name, data, back-estimated data')

MRE_par = sum(abs(par - Epar) ./ par)/9;
MRE_data = sum(abs(data - Edata) ./ data)/9;
printpar({'mean relative error of par and data'}, MRE_par, MRE_data, '')

% [d_V; a_b; a_p; a_m; W_b; W_p; W_i; R_i];
% [p_Am; v; kap; p_M; E_G; E_Hb; E_Hp; h_a];

fprintf('[d_V; a_b; a_p; a_m; W_b; W_p; W_i; R_i]\n');
fprintf('p_Am\n')
fprintf('v\n')
fprintf('kap\n')
fprintf('p_M\n')
fprintf('E_G\n')
fprintf('E_Hb\n')
fprintf('E_Hp\n')
fprintf('h_a\n')

[Elast_pAm, Elast_v, Elast_kap, Elast_pM, Elast_EG, Elast_EHb, Elast_EHp, Elast_ha]'

