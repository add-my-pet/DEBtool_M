%% Calibrates the Clarias Gariepinus pet using SHADE multimodal algorithm
%% 

close all; 
global pets

% The pet to calibrate
pets = {'Clarias_gariepinus'};
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
calibration_options('max_fun_evals', 20000);
% Set the maximum number of solutions
calibration_options('num_results', 200);
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
% Set calibration ranges
ranges.z = 0.25; % For a factor to the original parameter value. 
ranges.('f_tW') = [0.1, 0.4]; % For a desired range values. 
calibration_options('ranges', ranges);
% Calibrate
[best, info, out, best_favl] = calibrate;