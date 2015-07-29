%% pars_init_my_pet
% sets (initial values for) parameters

%%
function [par, metaPar, txtPar] = pars_init_my_pet(metaData)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/03/31
  % modified 2015/07/29 by Starrlight 
  
  %% Syntax
  % [par, metaPar, txtPar] = <../pars_init_my_pet.m *pars_init_my_pet*>(metaData)
  
  %% Description
  % sets (initial values for) parameters
  %
  % Input
  %
  % * metaData for names of phylum and class to get d_V
  %  
  % Output
  %
  % * par : structure with values of parameters
  % * metaPar: structure with information on metaparameters
  % * txtPar: structure with information on parameters

% parameters: initial values at reference temperature:
metaPar.T_ref = 215; %C2K(20); % K, reference temperature
metaPar.model = 'std'; % see online manual for explanation and alternatives

% edit the values below such that predictions are not too far off;
% the values must be set in the standard DEB units:
%   d for time; cm for length; J for energy; K for temperature

%% primary parameters
par.z = 1;          free.z     = 1;    units.z = '-';          label.z = 'zoom factor'; %for z = 1: L_m = 1 cm
par.F_m = 6.5;      free.F_m   = 0;    units.F_m = 'l/d.cm^2'; label.F_m = 'max spec searching rate';
par.kap_X = 0.8;    free.kap_X = 0;    units.kap_X = '-';      label.kap_X = 'digestion efficiency of food to reserve';
par.kap_P = 0.1;    free.kap_P = 0;    units.kap_P = '-';      label.kap_P = 'faecation efficiency of food to faeces';
par.v = 0.02;       free.v     = 1;    units.v = 'cm/d';       label.v = 'energy conductance';
par.kap = 0.8;      free.kap   = 1;    units.kap = '-';        label.kap = 'allocation fraction to soma';
par.kap_R = 0.95;   free.kap_R = 0;    units.kap_R = '-';      label.kap_R = 'reproduction efficiency';
par.p_M = 18;       free.p_M   = 1;    units.p_M = 'J/d.cm^3'; label.p_M = 'vol-spec somatic maint';
par.p_T =  0;       free.p_T   = 0;    units.p_T = 'J/d.cm^2'; label.p_T = 'surf-spec somatic maint';
par.k_J = 0.002;    free.k_J   = 1;    units.k_J = '1/d';      label.k_J = 'maturity maint rate coefficient';
par.E_G = 2800;     free.E_G   = 1;    units.E_G = 'J/cm^3';   label.E_G = 'spec cost for structure';
par.E_Hb = .275;    free.E_Hb  = 1;    units.E_Hb = 'J';       label.E_Hb = 'maturity at birth';
par.E_Hp = 50;      free.E_Hp  = 1;    units.E_Hp = 'J';       label.E_Hp = 'maturity at puberty';
par.h_a = 1e-6;     free.h_a   = 1;    units.h_a = '1/d^2';    label.h_a = 'Weibull aging acceleration';
par.s_G = 1e-4;     free.s_G   = 0;    units.s_G = '-';        label.s_G = 'Gompertz stress coefficient';

%% auxiliary parameters
par.T_A   = 8000;   free.T_A   = 0;    units.T_A = 'K';        label.T_A = 'Arrhenius temperature';
par.del_M = 0.16;   free.del_M = 1;    units.del_M = '-';      label.del_M = 'shape coefficient';

% environmental parameters (temperatures are in data)
par.f = 1.0;        free.f     = 0;    units.f = '-';          label.f    = 'scaled functional response for 0-var data';
par.f_tL = 0.8;     free.f_tL  = 1;    units.f_tL = '-';       label.f_tL = 'scaled functional response for 1-var data';


%% set chemical parameters from Kooy2010 
%  don't change these values, unless you have a good reason
[chem, freeChem, unitsChem, labelChem] = addchem(metaData.phylum, metaData.class);
[nm, nst] = fieldnmnst_st(chem);
for j = 1:nst
    eval(['par.',nm{j},' = chem.',nm{j}]);
    eval(['free.',nm{j},' = freeChem.',nm{j}]);
    eval(['units.',nm{j},' = unitsChem.',nm{j}]);
    eval(['label.',nm{j},' = labelChem.',nm{j}]);
end

% if you do have a good reason you may overwrite any of the values, but you must provide an explanations. 
% For example:
% chem.d_V = 0.33;     % g/cm^3, specific density of structure, see ref bibkey
% chem.d_E = chem.d_V; % g/cm^3, specific density of reserve
%   or add a product D like:
% chem.d_D = 0.1;     txt_chem.units.d_D  = 'g/cm^3';txt_chem.label.d_D  = 'specific density of product';
% chem.mu_D = 273210; txt_chem.units.mu.D = 'J/mol'; txt_chem.label.mu_D = 'chemical potential of product';
% chem.n_CD = 1;      txt_chem.units.n_CD = '-';     txt_chem.label.n_CD = 'chem. index of carbon in product';
% chem.HD = 1.2;      txt_chem.units.n_HD = '-';     txt_chem.label.n_HD = 'chem. index of hydrogen in product';
% chem.n_OD = 0.55;   txt_chem.units.n_OD = '-';     txt_chem.label.n_OD = 'chem. index of oxygen in product';
% chem.n_ND = 0.1;    txt_chem.units.n_ND = '-';     txt_chem.label.n_ND = 'chem. index of nitrogen in product';



%% Pack output:
txtPar.units = units; txtPar.label = label; par.free = free; % pack units, label, free in structure





