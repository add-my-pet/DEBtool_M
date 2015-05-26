%% pars_init_my_pet
% sets (initial values for) parameters

%%
function [par, metapar, txt_par, chem] = pars_init_my_pet(metadata)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2015/03/31
  
  %% Syntax
  % [par, txt_par, chem] = <../pars_init_my_pet.m *pars_init_my_pet*>(metadata)
  
  %% Description
  % sets (initial values for) parameters
  %
  % Input
  %
  % * metadata for names of phylum and class to get d_V
  %  
  % Output
  %
  % * par : structure with values of parameters
  % * txt_par: structure with information on parameters
  % * chem : structure with values of chemical parameters

% parameters: initial values at 
T_C = 273.15;     % K, temperature at 0 degrees C
T_ref = T_C + 20; % K, reference temperature
metapar.T_ref = T_ref;
metapar.model = 'std'; % see online manual for explanation and alternatives

% edit the values below such that predictions are not too far off;
% the values must be set in the standard DEB units:
%   d for time; cm for length; J for energy; K for temperature

%% primary parameters
par.z = 1;          free.z     = 1;    units.z = '-';          label.z = 'z';          % zoom factor; for z = 1: L_m = 1 cm
par.F_m = 6.5;      free.F_m   = 0;    units.F_m = 'l/d.cm^2'; label.F_m = '{F_M}';    % max spec searching rate
par.kap_X = 0.8;    free.kap_X = 0;    units.kap_X = '-';      label.kap_X = 'kap_X';  % digestion efficiency of food to reserve
par.kap_P = 0.1;    free.kap_P = 0;    units.kap_P = '-';      label.kap_P = 'kap_P';  % faecation efficiency of food to faeces
par.v = 0.02;       free.v     = 1;    units.v = 'cm/d';       label.v = 'v';          % energy conductance
par.kap = 0.8;      free.kap   = 1;    units.kap = '-';        label.kap = 'kap';      % allocation fraction to soma
par.kap_R = 0.95;   free.kap_R = 0;    units.kap_R = '-';      label.kap_R = 'kap_R';  % reproduction efficiency
par.p_M = 18;       free.p_M   = 1;    units.p_M = 'J/d.cm^3'; label.p_M = '[p_M]';    % vol-spec somatic maint
par.p_T =  0;       free.p_T   = 0;    units.p_T = 'J/d.cm^2'; label.p_T = '{p_T}';    % surf-spec somatic maint
par.k_J = 0.002;    free.k_J   = 1;    units.k_J = '1/d';      label.k_J = 'k_J';      % maturity maint rate coefficient
par.E_G = 2800;     free.E_G   = 1;    units.E_G = 'J/cm^3';   label.E_G = '[E_G]';    % spec cost for structure
par.E_Hb = .275;    free.E_Hb  = 1;    units.E_Hb = 'J';       label.E_Hb = 'E_Hb';    % maturity at birth
par.E_Hp = 50;      free.E_Hp  = 1;    units.E_Hp = 'J';       label.E_Hp = 'E_Hp';    % maturity at puberty
par.h_a = 1e-6;     free.h_a   = 1;    units.h_a = '1/d^2';    label.h_a = 'h_a';      % Weibull aging acceleration
par.s_G = 1e-4;     free.s_G   = 0;    units.s_G = '-';        label.s_G = 's_G';      % Gompertz stress coefficient

%% auxiliary parameters
par.T_A   = 8000;   free.T_A   = 0;    units.T_A = 'K';        label.T_A = 'T_A';      % Arrhenius temperature
par.del_M = 0.16;   free.del_M = 1;    units.del_M = '-';      label.del_M = 'del_M';  % shape coefficient

% environmental parameters (temperatures are in data)
par.f = 1.0;        free.f     = 0;    units.f = '-';          label.f = 'f';          % scaled functional response for 0-var data
par.f_tL = 0.8;     free.f_tL  = 1;    units.f_tL = '-';       label.f_tL = 'f_tL';    % scaled functional response for 1-var data

txt_par.units = units; txt_par.label = label; par.free = free; % pack units, label, free in structure

%% set chemical parameters from Kooy2010 
%  don't change these values, unless you have a good reason

% specific densities
%   set specific densites using the pet's taxonomy
d_V = get_d_V(metadata.phylum, metadata.class); d_E = d_V;
% For a specific density of wet mass of 1 g/cm^3,
%   a specific density of d_E = d_V = 0.1 g/cm^3 means a dry-over-wet weight ratio of 0.1
% Replace d_V and d_E to more appropriate values if you have them
% see comments on section 3.2.1 of DEB3 
%
%       X     V     E     P       food, structure, reserve, product (=faeces)
d_O = [0.1;  d_V;  d_E;  0.1];    % g/cm^3, specific densities for organics

% chemical potentials from Kooy2010 Tab 4.2
%        X     V     E     P
mu_O = [525; 500;  550;  480] * 1000; % J/mol, chemical potentials for organics
%       C  H  O  N     CO2, H2O, O2, NH3
mu_M = [0; 0; 0; 0]; % chemical potential of minerals

% chemical indices from Kooy2010 Fig 4.15
%       X     V     E     P
n_O = [1.00, 1.00, 1.00, 1.00;  % C/C, equals 1 by definition
       1.80, 1.80, 1.80, 1.80;  % H/C  these values show that we consider dry-mass
       0.50, 0.50, 0.50, 0.50;  % O/C
       0.15, 0.15, 0.15, 0.15]; % N/C
%       C     H     O     N
n_M = [ 1     0     0     0;    % C/C, equals 0 or 1
        0     2     0     3;    % H/C
        2     1     2     0;    % O/C
        0     0     0     1];   % N/C

% makes structure with chemical indices
% molar volume of gas at 1 bar and 20 C is 24.4 L/mol
T = T_C + 20;            % K, temp of measurement equipment
X_gas = T_ref/ T/ 24.4;  % M, mol of gas per litre at T_ref (= 20 C) and 1 bar 

% pack chem 
chem = struct(...
'mu_M', mu_M,  ...
'mu_X', mu_O(1),  ...
'mu_V', mu_O(2),  ...
'mu_E', mu_O(3),  ...
'mu_P', mu_O(4),  ...
'd_X',  d_O(1),   ...
'd_V',  d_O(2),   ...
'd_E',  d_O(3),   ...
'd_P',  d_O(4),   ...
'X_gas', X_gas, ...
'n_O',  n_O,   ...
'n_M',  n_M);

