%% calibrate_clarias_gariepinus_shade

close all; 
global pets


pets = {'Arctocephalus_gazella'}; % The pet to calibrate
check_my_pet(pets); % Check pet consistence

% Setting estimation options such as: 
estim_options('default');
estim_options('method','mmea');
%estim_options('results_output',5);

estim_options('num_results', 100);
estim_options('gen_factor', 0.5); 
estim_options('factor_type', 'mult');
estim_options('activate_niching', 1); 
estim_options('sigma_share', 0.15);
estim_options('bounds_from_ind', 1); 
%estim_options('min_convergence_threshold', 1e-4);
%estim_options('norm_pop_dist', 0.15);
%estim_options('max_calibration_time', 5);
estim_options('max_fun_evals', 1);
estim_options('verbose', 1); 
estim_options('verbose_options', 5);
estim_options('results_display', 'Complete');
%estim_options('ranges', {'z', 0.25}); % For a factor to the original parameter value. 
%estim_options('ranges', {'f_tW', [0.1, 0.4]}); % For a desired range values. 
%estim_options('results_filename', 'results_Clarias_II.mat');
estim_options('save_results',1)

[nsteps, info, fval] = estim_pars;