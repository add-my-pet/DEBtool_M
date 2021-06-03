%% Calibrates the Heterobranchus longifilis pet using SHADE multimodal algorithm
%% 

close all; 
global pets

% The pet to calibrate
pets = {'Heterobranchus_longifilis'};
% Check pet consistence
check_my_pet(pets); 

% Setting estimation options such as: 
% Loss function, method to use, filter, etc
estim_options('default');
% Setting calibration options (number of runs, maximum function
% evaluations, ...) 
calibration_options('default'); 
% Setting 'mm' (mmultimodal) for calibration 
calibration_options('method', 'mm1');
% Set number of evaluations
calibration_options('max_fun_evals', 30000);
% Set the total time in minutes
%calibration_options('max_calibration_time', 180);
% Set value for individual generation ranges
calibration_options('gen_factor', 0.3); 
% Set if the initial guest from data is introduced into initial population
calibration_options('add_initial', 0); 
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
calibration_options('results_output', 'Basic')
% Calibrate
[best, info, out, best_favl] = calibrate;