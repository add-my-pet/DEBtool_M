%% calibrate_clarias_gariepinus_shade

close all; 
global pets


pets = {'Clarias_gariepinus'}; % The pet to calibrate
check_my_pet(pets); % Check pet consistence

%species = ["Clarias_gariepinus", "Heterobranchus_longifilis", "Cyclops_vicinus", "Dipodomys_deserti"];
%species = [species, "Dipodomys_heermanni", "Dipodomys_merriami", "Homo_sapiens", "Lepus_timidus", ];
%species = ["Pleurobrachia_bachei", "Porcellio_scaber"];
%species = [species, "Venturia_canescens"];

%for specie = 1 : length(species)
   %fprintf('Calibrating %s \n', species(specie));
   %pets = {char(species(specie))}; % The pet to calibrate
   %check_my_pet(pets); % Check pet consistence

   % Setting estimation options such as: 
   estim_options('default');
   estim_options('method','mmea');
   estim_options('results_output',5);

   estim_options('num_runs', 7);
   estim_options('num_results', 50);
   estim_options('gen_factor', 0.8);
   estim_options('factor_type', 'mult');
   estim_options('sigma_share', 0.1);
   estim_options('bounds_from_ind', 1);
   estim_options('max_fun_evals', 50000);
   estim_options('refine_best', 1);
   estim_options('verbose', 1);
   estim_options('verbose_options', 5);
   estim_options('save_results',1)

   [nsteps, info, fval] = estim_pars;
%end

% Setting estimation options such as: 
%estim_options('default');
%estim_options('method','mmea');
%estim_options('results_output',5);

%estim_options('num_runs', 20);
%estim_options('num_results', 50);
%estim_options('gen_factor', 1.5);
%estim_options('factor_type', 'mult');
%estim_options('activate_niching', 1); 
%estim_options('sigma_share', 0.4);
%estim_options('bounds_from_ind', 1);
%estim_options('max_pop_dist', 0.14);
%estim_options('verbose', 1);
%estim_options('verbose_options', 5);
%estim_options('save_results',1)

%[nsteps, info, fval] = estim_pars;