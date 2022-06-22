%% calibrate_clarias_gariepinus_shade

close all; 
global pets


pets = {'Clarias_gariepinus'}; % The pet to calibrate
check_my_pet(pets); % Check pet consistence

% Setting estimation options such as: 
estim_options('default');
estim_options('method','mmea');
estim_options('results_output',5);

estim_options('num_runs', 1);
estim_options('num_results', 100);
estim_options('gen_factor', 1.5);
estim_options('factor_type', 'mult');
estim_options('sigma_share', 0.05);
estim_options('bounds_from_ind', 1);
estim_options('max_calibration_time', 10);
estim_options('refine_best', 0);
estim_options('verbose', 1);
estim_options('verbose_options', 5);
estim_options('save_results',1)

[nsteps, info, fval] = estim_pars;