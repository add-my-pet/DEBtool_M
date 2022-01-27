close all; 
global pets

pets = {'no_pet'};

estim_options('default'); 
estim_options('max_step_number',5e2); 
estim_options('max_fun_evals',5e3);  

estim_options('pars_init_method', 2);
estim_options('results_output', 3);
%estim_options('method', 'no');

estim_pars; 
prt_elas