% created 2015/01/23 by Bas Kooijman
% get_pars_2 till get_pars_8 and compares them with rusults of get_pars_9
% results of get_pars_9 are tested with mydata_get_pars_9

%first set data at level 9 and obtain pars

% set parameters according to generalised animal (see mydata_my_pet, but kap_G = 0.8)
%  assume T = T_ref; f = 1
d_V = 0.1; % g/cm^3, specific density of structure
a_b = 15;  % d, age at birth  
a_p = 130; % d, age at puberty  
a_m = 600; % d, age at death due to ageing  
W_b = 6e-4;% g, wet weight at birth
W_j = 6.01e-4;% g, wet weight at metamorphosis
W_p = 0.1; % g, wet weight at puberty
W_m = 14;  % g, maximum wet weight
R_m = 22;  % #/d, maximum reproduction rate  
% pack data
data_9 = [d_V; a_b; a_p; a_m; W_b; W_j; W_p; W_m; R_m];

% set fixed parameters
k_J = 0.002;  % 1/d, maturity maintenance rate coefficient (or 0 for kap)
s_G = 1e-4;   % -, Gopertz stress coefficient (= small; only required for filters)
kap_R = 0.95; % -, reproduction efficiency
kap_G = 0.80; % -, reproduction efficiency
fixed_par_9 = [k_J; s_G; kap_R; kap_G]; % pack fixed pars

% set chemical parameters
%  C:H:O:N = 1:1.8:0.5:0.15
w_V = 23.9;   % g/C-mol, molecular weight of structure
w_E = 23.9;   % g/C-mol, molecular weight of reserve
mu_V = 5E5;   % J/C-mol, chemical potential of structure
mu_E = 5.5E5; % J/C-mol, chemical potential of reserve
chem_par = [w_V; w_E; mu_V; mu_E]; % pack chem pars

txt_par_9 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 v, cm/d, energy conductance ';
 '3 kap, -, allocation fraction to soma ';
 '4 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance ';
 '5 E_G, J/cm^3, [E_G], spec cost for structure ';
 '6 E_Hb, J, E_H^b, maturity at birth ';
 '7 E_Hj, J, E_H^j, maturity at metamorphosis ';
 '8 E_Hp, J, E_H^p, maturity at puberty ';
 '9 h_a, 1/d^2, Weibull aging acceleration '};

par_9  = get_pars_9(data_9, fixed_par_9, chem_par);    % map 
v = par_9(2); kap = par_9(3); p_M = par_9(4);

%% now test the pars with lower levels

% 8: no acceleration
data_8 = [d_V; a_b; a_p; a_m; W_b; W_p; W_m; R_m];
fixed_par_8 = [k_J; s_G; kap_R; kap_G]; % pack fixed pars
par_8  = get_pars_8(data_8, fixed_par_8, chem_par);    % map 

txt_par_8 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 v, cm/d, energy conductance ';
 '3 kap, -, allocation fraction to soma ';
 '4 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance ';
 '5 E_G, J/cm^3, [E_G], spec cost for structure ';
 '6 E_Hb, J, E_H^b, maturity at birth ';
 '7 E_Hp, J, E_H^p, maturity at puberty ';
 '8 h_a, 1/d^2, Weibull aging acceleration '};

printpar(txt_par_8, par_8, par_9([1;2;3;4;5;6;8;9]), 'nm, par_8, par_9')
fprintf('\n'); % insert blank line

% 7: no ageing
data_7 = [d_V; a_b; a_p; W_b; W_p; W_m; R_m];
fixed_par_7 = [k_J; kap_R; kap_G]; % pack fixed pars
par_7  = get_pars_7(data_7, fixed_par_7, chem_par);    % map 

txt_par_7 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 v, cm/d, energy conductance ';
 '3 kap, -, allocation fraction to soma ';
 '4 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance ';
 '5 E_G, J/cm^3, [E_G], spec cost for structure ';
 '6 E_Hb, J, E_H^b, maturity at birth ';
 '7 E_Hp, J, E_H^p, maturity at puberty '};

printpar(txt_par_7, par_7, par_9([1;2;3;4;5;6;8]), 'nm, par_7, par_9')
fprintf('\n'); % insert blank line

% no age at birth
txt_par_6 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 kap, -, allocation fraction to soma ';
 '3 p_M, J/d.cm^3, [p_M], vol-specific somatic maintenance ';
 '4 E_G, J/cm^3, [E_G], spec cost for structure ';
 '5 E_Hb, J, E_H^b, maturity at birth ';
 '6 E_Hp, J, E_H^p, maturity at puberty '};

data_6 = [d_V; a_p - a_b; W_b; W_p; W_m; R_m];
fixed_par_6 = [v; k_J; kap_R; kap_G]; % pack fixed pars
par_6  = get_pars_6(data_6, fixed_par_6, chem_par);    % map 

printpar(txt_par_6, par_6, par_9([1;3;4;5;6;8]), 'nm, par_6, par_9')
fprintf('\n'); % insert blank line

% no age at puberty
txt_par_6a = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 v, cm/d, energy conductance ';
 '3 kap, -, allocation fraction to soma ';
 '4 E_G, J/cm^3, [E_G], spec cost for structure ';
 '5 E_Hb, J, E_H^b, maturity at birth ';
 '6 E_Hp, J, E_H^p, maturity at puberty '};

data_6a = [d_V; a_b; W_b; W_p; W_m; R_m];
fixed_par_6a = [p_M; k_J; kap_R; kap_G]; % pack fixed pars
par_6a  = get_pars_6a(data_6a, fixed_par_6a, chem_par); % map 
printpar(txt_par_6a, par_6a, par_9([1;2;3;5;6;8]), 'nm, par_6a, par_9')
fprintf('\n'); % insert blank line

% no ages at all
txt_par_5 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 kap, -, allocation fraction to soma ';
 '3 E_G, J/cm^3, [E_G], spec cost for structure ';
 '4 E_Hb, J, E_H^b, maturity at birth ';
 '5 E_Hp, J, E_H^p, maturity at puberty '};

data_5 = [d_V; W_b; W_p; W_m; R_m];
fixed_par_5 = [v; p_M; k_J; kap_R; kap_G]; % pack fixed pars
par_5  = get_pars_5(data_5, fixed_par_5, chem_par); % map 

printpar(txt_par_5, par_5, par_9([1;3;5;6;8]), 'nm, par_5, par_9')
fprintf('\n'); % insert blank line

% no reproduction
txt_par_4 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 E_G, J/cm^3, [E_G], spec cost for structure ';
 '3 E_Hb, J, E_H^b, maturity at birth ';
 '4 E_Hp, J, E_H^p, maturity at puberty '};

data_4 = [d_V; W_b; W_p; W_m];
fixed_par_4 = [v; kap; p_M; k_J; kap_G];            % pack fixed pars
par_4  = get_pars_4(data_4, fixed_par_4, chem_par); % map 

printpar(txt_par_4, par_4, par_9([1;5;6;8]), 'nm, par_4, par_9')
fprintf('\n'); % insert blank line

% no W_p
txt_par_3 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 E_G, J/cm^3, [E_G], spec cost for structure ';
 '3 E_Hb, J, E_H^b, maturity at birth '};

data_3 = [d_V; W_b; W_m];
fixed_par_3 = [v; kap; p_M; k_J; kap_G];            % pack fixed pars
par_3  = get_pars_3(data_3, fixed_par_3, chem_par); % map 

printpar(txt_par_3, par_3, par_9([1;5;6]), 'nm, par_3, par_9')
fprintf('\n'); % insert blank line

% only W_m
txt_par_2 = { ...
 '1 p_Am, J/d.cm^2, max specific assimilation rate ';
 '2 E_G, J/cm^3, [E_G], spec cost for structure '};

data_2 = [d_V; W_m];
fixed_par_2 = [v; kap; p_M; kap_G];                 % pack fixed pars
par_2  = get_pars_2(data_2, fixed_par_2, chem_par); % map 

printpar(txt_par_2, par_2, par_9([1;5]), 'nm, par_2, par_9')
fprintf('\n'); % insert blank line
