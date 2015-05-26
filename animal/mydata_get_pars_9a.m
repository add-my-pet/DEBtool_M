% created 2013/07/08 by Bas Kooijman; modified 2013/09/26
% runs get_pars_9 and its inverse iget_pars_9
% consider increase of numerical accuracy in the case of large relative errors

% set parameters according to generalised animal (see mydata_my_pet, but kap_G = 0.8)
%  assume T = T_ref; f = 1
d_V = 0.1; % g/cm^3, specific density of structure
a_b = 15;  % d, age at birth  
a_p = 130; % d, age at puberty  
a_m = 600; % d, age at death due to ageing  
W_b = 6e-4;% g, wet weight at birth
W_j = 6e-3;% g, wet weight at metamorphosis
W_p = 0.1; % g, wet weight at puberty
W_m = 14;  % g, maximum wet weight
R_m = 22;  % #/d, maximum reproduction rate  
% pack data
data = [d_V; a_b; a_p; a_m; W_b; W_j; W_p; W_m; R_m];

% set fixed parameters
k_J = 0.002;  % 1/d, maturity maintenance rate coefficient (or 0 for kap)
s_G = 1e-4;   % -, Gopertz stress coefficient (= small; only required for filters)
kap_R = 0.95; % -, reproduction efficiency
kap_G = 0.80; % -, growth efficiency
fixed_par = [k_J; s_G; kap_R; kap_G]; % pack fixed pars

% set chemical parameters
%  C:H:O:N = 1:1.8:0.5:0.15
w_V = 23.9;   % g/C-mol, molecular weight of structure
w_E = 23.9;   % g/C-mol, molecular weight of reserve
mu_V = 5E5;   % J/C-mol, chemical potential of structure
mu_E = 5.5E5; % J/C-mol, chemical potential of reserve
chem_par = [w_V; w_E; mu_V; mu_E]; % pack chem pars

[fil_d fl_d] = filter_data_9(data, fixed_par, chem_par); % run parameter filter
if fil_d == 0
  fprintf(['data does not pass filter with flag ', num2str(fl_d),'\n'])
  return
end

% run iget_pars_9 and iget_pars_9
par  = get_pars_9(data, fixed_par, chem_par);   % map data to pars
Edata = iget_pars_9(par, fixed_par, chem_par);  % map pars to data
Epar = get_pars_9(Edata, fixed_par, chem_par);  % map data to pars

[fil_p fl_p] = filter_pars_9(par, fixed_par, chem_par); % run data filter
if fil_p == 0
  fprintf(['pars do not pass filter with flag ', num2str(fl_d),'\n'])
end

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
   
printpar(txt_par, par, Epar, 'name, pars, back-estimated pars')
fprintf('\n'); % insert blank line
printpar(txt_data, data, Edata, 'name, data, back-estimated data')

MRE_par = sum(abs(par - Epar) ./ par)/9;
MRE_data = sum(abs(data - Edata) ./ data)/9;
fprintf('\n'); % insert blank line
printpar({'mean relative error of par and data'}, MRE_par, MRE_data, '')
