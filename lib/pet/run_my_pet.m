%% <../run_my_pet.m *run_my_pet*>
% created by Starrlight Augustine, Bas Kooijman, Dina Lika, Goncalo Marques and Laure Pecquerie 2015/01/22
% modified 2015/07/08

close all 
global pets

% species names
pets = {'my_pet'};
check_my_pet(pets); % check pet-files for required fields

% See estim_options for more options
estim_options('default'); % runs estimation, uses nmregr method and filter
                          % prints results, does not write file, does not produce html
% 'method':           'nm' - use Nelder-Mead method (default); 'no' - do not estimate;
% 'pars_init_method': 0 - get initial estimates from automatized computation (default)
%                     1 - read initial estimates from .mat file 
%                     2 - read initial estimates from pars_init file 
% 'results_output':   0 - prints results to screen; (default)
%                     1 - prints results to screen, saves to .mat file
%                     2 - saves data to .mat file and graphs to .png files
%                     (prints results to screen using a customized results file when there is one)
% 'report'        :   0 - does not print to screen the step numbers and the corresponding simplex ssq values 

estim_options('max_step_number',5e2); % set options for parameter estimation
estim_options('max_fun_evals',5e2);   % set options for parameter estimation
%estim_options('report',0);           % save time during the estimation 

estim_options('pars_init_method', 2);
estim_options('results_output', 0);
estim_options('method', 'nm');

estim_pars; % run estimation