%% Demonstrates the use og get_pars_m
% get parameters for Balaenoptera musculus
% get_pars_m is adapted for placentalia data (foetal development)


global dwm % pass d_O, w_O, mu_O directly to get_pars_m

% first initial estimators of the parameter values
% copy-paste from pars_animal


T    =   273 + 37; % K, actual body temperature ADAPT THIS FOR B.musculus
T_ref  = 293;      % K, temp for which rate pars are given 
T_A  =  1.6*8000;  % K, Arrhenius temp ADAT THIS FOR B.musculus
f = 1.0;           % scaled functional response
z = 128;           % zoom factor ADAPT THIS FOR B.musculus
del_M =.16/ 4;     % -, shape coefficient ADAPT THIS FOR B.musculus
F_m = 6.5;         % l/d.cm^2, {F_m} max spec searching rate
kap_X = 0.8;       % -, digestion efficiency of food to reserve
v = 0.02;          % cm/d, energy conductance
kap = 0.8;         % -, alloaction fraction to soma = growth + somatic maintenance
kap_R = 0.95;      % -, reproduction efficiency
p_M = 18;          % J/d.cm^3, [p_M] vol-specific somatic maintenance
p_T =  0;          % J/d.cm^2, {p_T} surface-specific som maintenance
k_J = 0.002;       % 1/d, < k_M = p_M/E_G, maturity maint rate coefficient
E_G = 2800;        % J/cm^3, [E_G], spec cost for structure
E_Hb = 20 * 1e-3 * 275 * z^3; % J, E_H^b ADAPT THIS FOR B.musculus
E_Hp = 3 * 50 * z^3;  % J, E_H^p ADAPT THIS FOR B.musculus
h_a = z * 1e-9;    % 1/d^2, Weibull aging acceleration
s_G = 0.5;         % -, Gompertz stress coefficient ADAPT THIS FOR B.musculus

% pack 18 parameters and fix T, T_ref, f, F_m, kap_X, kap_R, p_T, h_a, s_G
pars_Bm = [T 0; T_ref 0; T_A 1; f 0; z 1; del_M 1; 
    F_m 0; kap_X 0; v 1; kap 1; kap_R 0; p_M 1; p_T 0; k_J 1; E_G 1; E_Hb 1; E_Hp 1; h_a 1; s_G 0];

% 10 data for B.musculus
ab = 336;       %   1 ab    % d, age at birth
ap = 2555;      %   2 ap    % d, age at puberty
Lb = 700;       %   3 Lb    % cm, length at birth
Lp = 2050;      %   4 Lp    % cm, length at puberty
Li = 2700;      %   5 Li    % cm, ultimate length
Wb = 275000;    %   6 Wb    % g, weight at birth
Wp = 6900000;   %   7 Wp    % g, weight at puberty
Wi = 16000000;  %   8 Wi    % g, ultimate weight
rB = 5.9178e-4; %   9 rB    % 1/d, von Bertalanffy growth rate
Ri = .0011;     %  10 Ri    % #/d, maximum reproduction rate
tm = 29200;     %  11 tm    % d, life span

% pack data for B.musculus
%  append parameters for generalised animal as data
%   to make sure that those of B.musculus are near, except for z
data_Bm = [ab; ap; Lb; Lp; Li; Wb; Wp; Wi; rB; Ri; tm; pars_Bm(:,1)];
% nmregr wants to have 3 columns: indpendent var, dependent var, weight coeff
%   prepend independent variable (not used) and append weight coefficients
%   weight coeff inverse to squared data
Data_Bm = [zeros(30,1), data_Bm, 1 ./ max(1e-6, data_Bm) .^ 2];
Data_Bm(1:11,3) = 10 * Data_Bm(1:11,3); % give Bm data more weight
Data_Bm(11,3) = 0; % no weight to a_m; small value gives numerical problems
% we should turn to years, rather than days as unit of time to solve this problem
Data_Bm(26,3) = 20 * Data_Bm(26,3); % more weight to E_G
Data_Bm([14 20],3) = 10 * Data_Bm([14 20],3); % more weight to v, T_A
Data_Bm([12 13 16 27 28],3) = 0; % set weight for T, T_ref, z, E_Hb, E_Hp to zero

%% conversion coefficients (selected copy-paste from pars_animal)

n_O = [1.00, 1.00, 1.00, 1.00;  % C/C, equals 1 by definition
       1.80, 1.80, 2.00, 1.80;  % H/C
       0.50, 0.50, 0.75, 0.50;  % O/C
       0.20, 0.15, 0.20, 0.15]; % N/C
   
d_O = [.1; .1; .1; .1];     % g/cm^3, specific densities for organics
mu_X = 525000;                    % J/mol, chemical potential of food
mu_V = 500000;                    % J/mol, chemical potential of structure
mu_E = 550000;                    % J/mol, chemical potential of reserve
mu_P = 480000;                    % J/mol, chemical potential of faeces
mu_O = [mu_X; mu_V; mu_E; mu_P];  % J/mol, chemical potentials of organics
w_O = n_O' * [12; 1; 16; 14];     % g/mol, mol-weights for org. compounds
dwm = [d_O, w_O, mu_O]; % g/cm^3, g/mol, kJ/mol spec density, mol weight, chem pot

%% tune parameters
nmregr_options('max_step_number',2e4)
nmregr_options('max_fun_evals',2e4)
pars_Bm = nmregr('get_pars_m', pars_Bm, Data_Bm);
Edata_Bm = get_pars_m(pars_Bm(:,1), Data_Bm);
format short eng

txt_Bm = {...
    '1 ab, d, age at birth ';
    '2 ap, d, age at puberty ';
    '3 Lb, cm, length at birth ';
    '4 Lp, cm, length at puberty ';
    '5 Li, cm, ultimate length ';
    '6 Wb, g, weight at birth ';
    '7 Wp, g, weight at puberty ';
    '8 Wi, g, ultimate weight ';
    '9 rB, 1/d, von Bert growth rate ';
   '10 Ri, #/d, maximum reprod rate ';
   '11 am, d, life span ';
   '12 T,  K, actual body temp ';
   '13 T_ref, K, reference temp ';
   '14 T_A,   K, Arrhenius temp ';
   '15 f, scaled functional response ';
   '16 z, zoom factor ';
   '17 del_M,  -, shape coefficient ';
   '18 F_m, l/d.cm^2, {F_m} max spec search r ';
   '19 kap_X, -, digestion efficiency ';
   '20 v, cm/d, energy conductance ';
   '21 kap, -, allocation fraction to soma ';
   '22 kap_R, -, reproduction efficiency ';
   '23 [p_M], J/d.cm^3, vol-spec som maint ';
   '24 {p_T}, J/d.cm^2, sur-spec som maint ';
   '25 k_J, 1/d, maturity maint rate coefficient ';
   '26 [E_G], J/cm^3, spec cost for structure'; 
   '27 E_H^b, J, maturity investm at birth ';
   '28 E_H^p, J, maturity investm at puberty ';
   '29 h_a, 1/d^2, Weibull aging acceleration ';
   '30 s_G, -, Gompertz stress coefficient'};

printpar(txt_Bm, data_Bm, Edata_Bm)