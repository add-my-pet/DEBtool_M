close all
global pets

% species names for the group
% pets = {'Dipodomys_deserti', 'Dipodomys_heermanni', 'Dipodomys_merriami'};
pets = {'Porcellio_scaber'};
% this example shows a case where 9 parameters are estimated per species,  but only 15 for 3 species
% the MRE's increase from [0.019 0.025 0.019] for 27 parameters to [0.088 0.102 0.102] for 15 parameters

% See estim_options for more options
estim_options('default');             % use Nead-Melder simplex method and filter

estim_options('max_step_number',5e3); % set options for parameter estimation
estim_options('max_fun_evals',10e3);   % set options for parameter estimation

estim_options('pars_init_method', 2);
estim_options('results_output', 3);
%estim_options('method', 'no');

estim_pars; % run estimation