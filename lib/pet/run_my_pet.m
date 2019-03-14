%% <../run_my_pet.m *run_my_pet*>
% script that calls DEBtool_M functions, for parameter estimation and ploting predictions
%%
% created by Starrlight Augustine, Bas Kooijman, Dina Lika, Goncalo Marques and Laure Pecquerie 2015/01/22
% modified 2015/07/08
% modified 2019/03/13 by Nina Marn

close all 
global pets

% species names
pets = {'my_pet'};
check_my_pet(pets); % check pet-files for required fields

% Read about how to set estimation and output options (estim_options) on the online
% manual: http://www.debtheory.org/wiki/index.php?title=Run_file

estim_options('default'); 

estim_options('max_step_number',5e2); % set options for parameter estimation
estim_options('max_fun_evals',5e2);   % set options for parameter estimation
%estim_options('report',0);           % save time during the estimation 

estim_options('pars_init_method', 2);
estim_options('results_output', 0);
estim_options('method', 'nm');

estim_pars; % run estimation