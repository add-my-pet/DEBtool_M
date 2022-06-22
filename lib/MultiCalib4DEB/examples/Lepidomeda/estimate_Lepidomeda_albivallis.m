close all
global pets

% species names for the group
pets = {'Lepidomeda_albivallis'};

% See estim_options for more options
estim_options('default');             % use Nead-Melder simplex method and filter

estim_options('max_step_number',10e2); % set options for parameter estimation
estim_options('max_fun_evals',10e2);   % set options for parameter estimation

estim_options('pars_init_method', 2);
estim_options('results_output', 3);
%estim_options('method', 'no');

estim_pars; % run estimation