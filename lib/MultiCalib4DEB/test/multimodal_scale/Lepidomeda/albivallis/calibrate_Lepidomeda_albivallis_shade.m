%% Calibrates the Clarias Gariepinus pet using SHADE multimodal algorithm
%% 

close all; 
global pets

% The pet to calibrate
pets = {'Lepidomeda_albivallis'};
% Check pet consistence
check_my_pet(pets); 

% Setting estimation options such as: 
estim_options('default');
estim_options('method','mmea');
estim_options('results_output',5);

estim_options('gen_factor', 0.7);
estim_options('factor_type', 'mult');
estim_options('bounds_from_ind', 1); 
estim_options('max_pop_dist', 0.2);
estim_options('verbose', 1); 
estim_options('verbose_options', 5);
estim_options('results_display', 'Complete');
estim_options('save_results',1)

[nsteps, info, fval] = estim_pars;