% created 2015/01/19 by Bas Kooijman
% runs get_pars_8 and its inverse iget_pars_8
% consider increase of numerical accuracy in the case of large relative errors

% set parameters according to generalised animal (see mydata_my_pet, but kap_G = 0.8)
%  assume T = T_ref; f = 1; no acceleration
d_V = 0.1;           % g/cm^3, specific density of structure
z = 1;               %  -, zoom factor
v = 0.02;            % 2 cm/d, energy conductance
kap = 0.8;           % 3 -, allocation fraction to soma = growth + somatic maintenance
p_M = 18;            % 4 J/d.cm^3, [p_M], vol-specific somatic maintenance
p_Am = z * p_M/ kap; % 1 J/d.cm^2, max specific assimilation rate
E_G = 2.6151e4 * d_V;% 5 J/cm^3, [E_G], spec cost for structure: d_V * mu_V/ kap_G/ w_V 
E_Hb = z^3 * .275;   % 6 J, E_H^b, maturity at birth
E_Hp = z^3 * 50;     % 7 J, E_H^p, maturity at puberty
h_a = 1e-6;          % 8 1/d^2, Weibull aging acceleration

% pack par
par = [p_Am; v; kap; p_M; E_G; E_Hb; E_Hp; h_a];

% set fixed parameters
k_J = 0.002;  % 1/d, maturity maintenance rate coefficient (or 0 for kap)
s_G = 1e-4;   % -, Gopertz stress coefficient (= small; only required for filters)
kap_R = 0.95; % -, reproduction efficiency
kap_G = 0.8;  % -, growth efficiency
fixed_par = [k_J; s_G; kap_R; kap_G]; % pack fixed pars

% set chemical parameters
w_V = 23.9;   % g/C-mol, molecular weight of structure
w_E = 23.9;   % g/C-mol, molecular weight of reserve
mu_V = 5E5;   % J/C-mol, chemical potential of structure
mu_E = 5.5E5; % J/C-mol, chemical potential of reserve
chem_par = [w_V; w_E; mu_V; mu_E]; % pack chem pars

[fil_p fl_p] = filter_pars_8(par, fixed_par, chem_par); % run data filter
if ~fil_p
  fprintf(['parameters do not pass filter with flag ', num2str(fl_d),'\n'])
end

% run iget_pars_8 and get_pars_8
data = iget_pars_8(par, fixed_par, chem_par);   % map par to data
Epar = get_pars_8(data, fixed_par, chem_par);   % map data to par
Edata = iget_pars_8(Epar, fixed_par, chem_par); % map par to data

[fil_d fl_d] = filter_data_8(data, fixed_par, chem_par); % run data filter
if ~fil_d
  fprintf(['data do not pass filter with flag ', num2str(fl_d),'\n'])
end

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
 '2 a_b, d, age at birth';
 '3 a_p, d, age at puberty';
 '4 a_m, d, age at death due to ageing';
 '5 W_b, g, wet weight at birth';
 '6 W_p, g, wet weight at puberty';
 '7 W_m, g, maximum wet weight';
 '8 R_m, #/d, maximum reproduction rate'};
   
printpar(txt_par, par, Epar, 'name, pars, back-estimated pars')
fprintf('\n'); % insert blank line
printpar(txt_data, data, Edata, 'name, data, back-estimated data')

MRE_par = sum(abs(par - Epar) ./ par)/8;
MRE_data = sum(abs(data - Edata) ./ data)/8;
fprintf('\n'); % insert blank line
printpar({'mean relative error of par and data'}, MRE_par, MRE_data, '')
