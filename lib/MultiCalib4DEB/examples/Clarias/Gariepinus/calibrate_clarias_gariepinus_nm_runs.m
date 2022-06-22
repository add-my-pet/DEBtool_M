%% calibrate_clarias_gariepinus_lshade


close all; 
global pets

% The pet to calibrate
pets = {'Clarias_gariepinus'};
% Check pet consistence
check_my_pet(pets); 

% Setting estimation options such as: 
% Loss function, method to use, filter, etc
estim_options('default');

estim_options();
% Setting calibration options (number of runs, maximum function
% evaluations, ...) 
calibration_options('default'); 
% Setting 'mm' (mmultimodal) for calibration 
calibration_options('search_method', 'nm_runs');
% Set number of runs
calibration_options('num_runs', 1);
% Set number of evaluations
calibration_options('max_fun_evals', 10000);
% Set value for individual generation ranges
calibration_options('gen_factor', 0.3); 
% Set if the initial guest from data is introduced into initial population
calibration_options('add_initial', 1); 
% If refine the indivuduals of the first population using local search
calibration_options('refine_firsts', 0);
% Set if the best individual found will be refined with a local search
% method
calibration_options('refine_best', 1);
% Define local search options
calibration_options('refine_running', 1);
% Define local search application probability
calibration_options('refine_run_prob', 0.1);
% Set if the bounds for the algorithm's first individuals population is
% taken from the data values or from pseudodata (1 -> data | 0 ->
% pseudodata average values)
calibration_options('bounds_from_ind', 1); 
% Verbose options
% Activate verbose
calibration_options('verbose', 1); 
calibration_options('verbose_options', 8); 
calibration_options('num_runs', 2);
% Calibrate
[best, out, best_favl] = calibrate;