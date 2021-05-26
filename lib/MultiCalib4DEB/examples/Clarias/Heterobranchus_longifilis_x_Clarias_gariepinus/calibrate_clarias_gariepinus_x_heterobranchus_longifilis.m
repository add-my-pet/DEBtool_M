%% Calibrates the Clarias_gariepinus_x_Heterobranchus_longifilis pet using L-SHADE multimodal algorithm
%% 

close all; 
global pets

% The pet to calibrate
pets = {'Clarias_gariepinus_x_Heterobranchus_longifilis'};
% Check pet consistence
check_my_pet(pets); 

% Setting estimation options such as: 
% Loss function, method to use, filter, etc
estim_options('default');
% Setting 'mm' (mmultimodal) for calibration 
estim_options('method', 'mm1');
% Setting calibration options (number of runs, maximum function
% evaluations, ...) 
calibration_options('default'); 
% Set number of evaluations
calibration_options('max_fun_evals', 20000);
% Set value for individual generation ranges
calibration_options('gen_factor', 0.9); 
% Set if the initial guest from data is introduced into initial population
calibration_options('add_initial', 1); 
% Set if the best individual found will be refined with a local search
% method
calibration_options('refine_best', 1);
% Set if the bounds for the algorithm's first individuals population is
% taken from the data values or from pseudodata (1 -> data | 0 ->
% pseudodata average values)
calibration_options('bounds_from_ind', 1); 
% Verbose options
% Activate verbose
calibration_options('verbose', 1); 
calibration_options('verbose_options', 8); 
% Calibrate
estim_pars