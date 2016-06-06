%% pars_init_my_pet
% sets (initial values for) parameters

%%
function [par, metaPar, txtPar] = pars_init_my_pet_mytox(par, metaPar, txtPar)
  % created by Starrlight Augustine, Dina Lika, Bas Kooijman, Goncalo Marques and Laure Pecquerie 2016/02/16
  
  %% Syntax
  % [par, metaPar, txtPar] = <../pars_init_my_pet_mytox.m *pars_init_my_pet_mytox*>(par, txtPar)
  
  %% Description
  % sets (initial values for) parameters of mytox
  %
  % Input
  %
  % * par: structure with parameters of my_pet
  %  
  % Output
  %
  % * par : updated structure with values of parameters
  % * metaPar: structure with information on mytox
  % * txtPar: updated structure with information on parameters

vars_pull(txtPar);
  
metaPar.DEBMoA = 'haz'; % hazard per offspring 

%% toxico-kinetics parameters for scaled 1-compartment toxico kinetic model
% par.i_Q = 20;      free.i_Q = 1;     units.i_Q = 'cm^3 env/cm^3 biom/d';  label.i_Q  = 'i_Q, uptake rate';
par.k_e = 0.1498;      free.k_e = 1;     units.k_e = '1/d';                   label.k_e  = 'k_e, elimination rate';

%% MoA parameters
par.c0 = 0.001;  free.c0 = 1;   units.c0 = 'mMol/l';     label.c0  = 'no effect concentration (external)';
par.cA = 0.3991;  free.cA = 1;   units.cA = 'mMol/l';     label.cA  = 'no effect concentration (external)';

% par.b_p_M = 20;     free.b_p_M = 1;      units.b_p_M = 'J/d.cm^3/';       label.b_p_M = 'b, killing rate of vol-spec somatic maint';

%% parameters specific for the data sets
par.f_tN = 0.9;  free.f_tN = 1; units.f_tN = '-';  label.f_tN = 'scaled functional response for tN'; 


%% Pack output:
txtPar.units = units; txtPar.label = label; 
freeNm = fieldnames(free);
for i = 1:size(freeNm, 1)
    par.free.(freeNm{i}) = free.(freeNm{i});
end

