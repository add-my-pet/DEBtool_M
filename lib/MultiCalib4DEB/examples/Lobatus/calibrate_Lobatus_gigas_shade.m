%% Calibrates the Lobatus gigas pet using SHADE multimodal algorithm
%% 

close all; 
global pets

% The pet to calibrate
pets = {'Lobatus_gigas'};
% Check pet consistence
check_my_pet(pets); 

% Setting estimation options such as: 
estim_options('default');
estim_options('method','mmea');
estim_options('results_output',5);

estim_options('num_runs', 20);
estim_options('num_results', 100);
estim_options('gen_factor', 0.8);
estim_options('factor_type', 'mult');
estim_options('activate_niching', 1); 
estim_options('sigma_share', 0.05);
estim_options('bounds_from_ind', 1); 
estim_options('max_calibration_time', 10);
estim_options('verbose', 1); 
estim_options('verbose_options', 5);
estim_options('results_display', 'Complete');
estim_options('save_results',1)

[nsteps, info, fval] = estim_pars;