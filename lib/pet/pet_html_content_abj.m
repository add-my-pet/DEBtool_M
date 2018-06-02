%% pet_html_content_abj
% prepares matrixes used as input for print_my_pet_html

%%
function [par_elt, chem_out, stat_html] = pet_html_content_abj(par, chem, stat, txt_stat, T_ref) 
% created 2009/07/11 by Dina Lika, modified by Bas Kooijman 2014/06/03
% modified by starrlight augustine 2014/13/04 

%% Syntax
% [par_elt, chem_out, stat_html] = <../pet_html_content.m *pet_html_content*> (par, 
% chem, stat, txt_stat, T_ref) 

%% Description
% This function might become obsolete in the future. But at the moment it
% prepares the input for print_my_pet_html assuming model 'abj'
%
% Input:
%
% * par  (structure with paramters)
% * chem  (structure with volume/energy converters and chemical indices)
% * stat (structure created with implied model properties created in
% statistics)
% * txt_stat (structure with units and labels of the implied properties,
% also created in statistics)
% * T_ref (scalar, reference temperature)
%
% Output:
% 
% * par_elt: n-4 matrix with symbol, value, units, description of parameters
% * chem_out: n-4 matrix with symbol, value, units, description of
% biochemical parameters
% * stat_html: n-4 matrix with symbol, value, units, description of implied
% model properties


%% Remarks
% This function is not yet finalised- we still need to add a lot of row to
% stat_html

%% Example of use
%   load('results_my_pet.mat');
%   v2struct(metadata); v2struct(metapar); f= 1; T = T_typical;
%   [stat, txt_stat] = statistics_std(par, chem, T, T_ref, f, model)
%   [par_elt, chem_out, stat_html] = pet_html_content(par, chem, stat, txt_stat, T_ref);

v2struct(par); 

v2struct(chem);

cp = parscomp_st(par, chem);
v2struct(cp); 

v2struct(stat); 

%% primary parameters in energy-length-time format:

par_elt = { ...
% temperature  #FFC6A5    
'#FFC6A5', 'T_ref', T_ref,     'K',        'Reference temp'    
'#FFC6A5', 'T_A', T_A  ,       'K',        'Arrhenius temp'   
% assimilation #CEEFBD
'#CEEFBD', '{F_m}',   F_m   ,  'l/d.cm^2', 'max spec searching rate'   
'#CEEFBD', 'kap_X',   kap_X ,  '-',        'digestion efficiency of food to reserve'   
'#CEEFBD', 'kap_P', kap_P, '-',        'faecation efficiency of food to faeces'   
'#CEEFBD', '{p_Am}',  p_Am,    'J/d.cm^2', 'max spec assimilation rate'
% mobilisation & allocation #DEF3BD
'#DEF3BD', 'v',       v,       'cm/d',     'energy conductance'   
'#DEF3BD', 'kap',     kap,     '-',        'allocation fraction to soma'   
'#DEF3BD', 'kap_R',   kap_R,   '-',        'reproduction efficiency' 
% maintenance #FFFF9C
'#FFFF9C', '[p_M]',   p_M,     'J/d.cm^3', 'vol-specific somatic maintenance'   
'#FFFF9C', '{p_T}',   p_T,     'J/d.cm^2', 'surface-specific som maintenance'   
'#FFFF9C', 'k_J',     k_J,     '1/d'     , 'maturity maint rate coefficient' 
% growth #FFFFC6
'#FFFFC6', '[E_G]',   E_G,     'J/cm^3',   'specific cost for structure'  
% life stages #94D6E7
'#94D6E7', 'E_H^b',   E_Hb,    'J',        'maturity at birth'   
'#94D6E7', 'E_H^p',   E_Hp,    'J',        'maturity at puberty'   
% aging #BDC6DE
'#BDC6DE', 'h_a',     h_a,     '1/d^2',    'Weibull aging acceleration'   
'#BDC6DE', 's_G',     s_G,     '-',        'Gompertz stress coefficient'    
};

%% biochemical parameters:

chem_out = { ...
% temperature  #FFC6A5    
'#FFC6A5', 'mu_X', mu_X,  'J/ mol', 'chemical potential of food'  
'#FFC6A5', 'mu_V', mu_V,  'J/ mol', 'chemical potential of structure'    
'#FFC6A5', 'mu_E', mu_E,  'J/ mol', 'chemical potential of reserve'    
'#FFC6A5', 'mu_P', mu_P,  'J/ mol', 'chemical potential of faeces'   
%
'#CEEFBD', 'd_X',   d_X,  'g/cm^3', 'specific density of food'   
'#CEEFBD', 'd_V',   d_V,  'g/cm^3', 'specific density of structure'   
'#CEEFBD', 'd_E',   d_E,  'g/cm^3', 'specific density of reserve'   
'#CEEFBD', 'd_P',   d_P,  'g/cm^3', 'specific density of faeces' 
% 
'#DEF3BD', 'n_HX',    n_O(2,1),  '-',     'chem. index of hydrogen in food'   
'#DEF3BD', 'n_OX',    n_O(3,1),  '-',     'chem. index of oxygen in food'     
'#DEF3BD', 'n_NX',    n_O(4,1),  '-',     'chem. index of nitrogen in food'   
% 
'#FFFF9C', 'n_HV',    n_O(2,2),  '-',     'chem. index of hydrogen in structure'     
'#FFFF9C', 'n_OV',    n_O(3,2),  '-',     'chem. index of oxygen in structure'    
'#FFFF9C', 'n_NV',    n_O(4,2),  '-',     'chem. index of nitrogen in structure'    
% 
'#FFFFC6', 'n_HE',    n_O(2,3),  '-',     'chem. index of hydrogen in reserve'  
'#FFFFC6', 'n_OE',    n_O(3,3),  '-',     'chem. index of oxygen in reserve'
'#FFFFC6', 'n_NE',    n_O(4,3),  '-',     'chem. index of nitrogen in reserve'
% 
'#94D6E7', 'n_HP',    n_O(2,4),  '-',     'chem. index of hydrogen in faeces' 
'#94D6E7', 'n_OP',    n_O(3,4),  '-',     'chem. index of oxygen in faeces' 
'#94D6E7', 'n_NP',    n_O(4,4),  '-',     'chem. index of nitrogen in faeces' 
};


%% statistics in energy time length framework
v2struct(stat);
units = txt_stat.units;
label = txt_stat.label;

stat_html = { ...
'#FFC6A5', 'f', f, units.f,    label.f 
'#FFC6A5', 'T', T, 'K',    'typical temp'     
%
'#FFFFFF', 'c_T', c_T, units.c_T,    label.c_T                            
'#FFFFFF', 'E_0', E_0, units.E_0, label.E_0                             
'#FFFFFF', 'W_d^0', W_0, units.W_0, label.W_0
'#FFFFFF', 'del_Ub', del_Ub, units.del_Ub, label.del_Ub
%
'#C6E7DE', 'a_b', a_b, units.a_b, label.a_b 
% '#C6E7DE', 'a_j', a_j, units.a_j, label.a_j
'#C6E7DE', 'a_p', a_p, units.a_p, label.a_p
'#C6E7DE', 'a_99', a_99, units.a_99, label.a_99
%
'#DEF3BD', 'W_b', W_b, units.W_b, label.W_b 
% '#DEF3BD', 'W_j', W_j, units.W_j, label.W_j 
'#DEF3BD', 'W_p', W_p, units.W_p, label.W_p 
'#DEF3BD', 'W_i', W_i, units.W_i, label.W_i
%
'#CEEFBD', 'L_b',L_b, units.L_b, label.L_b 
% '#CEEFBD', 'L_j',L_j, units.L_j, label.L_j 
'#CEEFBD', 'L_b',L_p, units.L_p, label.L_p 
'#CEEFBD', 'L_i',L_i, units.L_i, label.L_i 
};

% col_statistics = { ... % colours for statistics
%     '#FFC6A5'; '#FFFFFF'; '#C6E7DE'; '#CEEFBD'; '#CEEFBD';
%     '#DEF3BD'; '#FFFFC6'; '#BDC6DE'; '#C6B5DE'; '#DEBDDE';
%     '#F7BDDE'; '#C6E7DE'; '#FFFFC6'; '#FFC6A5'; '#FFFFC6'; 
%     '#F7BDDE'; '#BDC6DE'; '#FFFFC6'; '#FFFFFF'};
% 