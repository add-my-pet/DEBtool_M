%% estim_options
% Sets options for estim.pars

%%
function estim_options (key, val)
  %  created at 2015/01/25 by Goncalo Marques; 
  %  modified 2015/03/26 by Goncalo Marques, 2018/05/21, 2018/08/21 by Bas Kooijman, 
  %    2019/12/20 by Nina Marn, 2021/06/07 by Bas Kooijman & Juan Robles,
  %    2021/10/20, 2022/04/24 by Juan Robles
  
  %% Syntax
  % <../estim_options.m *estim_options*> (key, val)
  
  %% Description
  % Sets options for estimation one by one, some apply to methods nm and mmea, others to mmea only
  %
  % Input
  %
  % * no input: print values to screen
  % * one input:
  %
  %    'default': sets options at default values
  %     any other key (see below): print value to screen
  %
  % * two inputs
  %
  %    'loss_function': 
  %      'sb': multiplicative symmetric bounded (default)
  %      'su': multiplicative symmetric unbounded
  %      're': relative error (not recommanded)
  %      'SMAE': symmetric mean absolute error
  %
  %    'filter': 
  %      0: do not use filters;
  %      1: use filters (default)
  %
  %    'pars_init_method':
  %      0: get initial estimates from automatized computation 
  %      1: read initial estimates from .mat file (for continuation)
  %      2: read initial estimates from pars_init file (default)
  %
  %    'results_output':
  %      0     - only saves data to .mat (no printing to html or screen and no figures) - use this for (automatic) continuations 
  %      1, -1 - no saving to .mat file, prints results to html (1) or screen (-1), shows figures but does not save them
  %      2, -2 - saves to .mat file, prints results to html (2) or screen (-2), shows figures but does not save them
  %      3, -3 - like 2 (or -2), but also prints graphs to .png files (default is 3)
  %      4, -4 - like 3 (or -3), but also prints html with implied traits
  %      5, -5 - like 4 (or -4), but includes related species in the implied traits
  %      6     - like 5, but also prints html with population traits
  %   
  %    'method': 
  %      'no': do not estimate
  %      'nm': Nelder-Mead simplex method (default)
  %      'mmea': multimodal evolutionary algorithm
  %
  %    'max_fun_evals': maximum number of function evaluations (default 10000)
  %
  %    'report': 
  %       0 - do not report
  %       1 - report steps to screen (default)
  %
  %    'max_step_number': maximum number of steps (default 500)
  %
  %    'tol_simplex': tolerance for how close the simplex points must be together to call them the same (default 1e-4)
  %
  %    'tol_fun': tolerance for how close the loss-function values must be together to call them the same (default 1e-4)
  %
  %    'simplex_size': fraction added (subtracted if negative) to the free parameters when building the simplex (default 0.05)
  %
  %    'search_method' (method mmea only): 
  %      'mm_shade' - use mm_shade method (default)
  %     
  %    'num_results' (method mmea only): The size for the multimodal algorithm's population. The author recommended
  %       50 for mm_shade ('search_method mm_shade', default) 
  %       18 * number of free parameters for L-mm_shade ('search method l-mm_shade')
  %
  %    'gen_factor' (method mmea only): percentage to build the ranges for initializing the first population of individuals (default 0.5)                  
  %
  %    'bounds_from_ind' (method mmea only): 
  %      0: use ranges from pseudodata if exist (these ranges not existing will be taken from data)         
  %      1: use ranges from data (default) 
  %
  %    'max_calibration_time' (method mmea only): maximum calibration time in minutes (default 30)
  %    'min_convergence_threshold' (method mmea only): the minimum improvement the mmea needs to reach 
  %                                                    to continue the calibration process (default 1e-4)
  %    'max_pop_dist': the maximum distance allowed between the solutions of the MMEA population to 
  %                     continue the calibration process (default 0.2). 
  %    'num_runs' (method mmea only): the number of independent runs to perform (default 1)
  %
  %    'add_initial' (method mmea only): if the initial individual is added in the first  population.
  %      1: activated
  %      0: not activated (default)
  %
  %     
  %    'refine_best'  (method mmea only): if the best individual found is refined using Nelder-Mead.
  %      0: not activated (default)
  %      1: activated
  %     
  %    'verbose_options' (method mmea only): The number of solutions to show from the set of optimal solutions found by the algorithm through the calibration process (default 10)                                           
  %
  %    'verbose' (method mmea only): prints some information while the calibration  process is running              
  %       0: not activated (default)
  %       1: activated
  %
  %    'seed_index' (method mmea only): index of vector with values for the seeds used to generate random values 
  %       each one is used in a single run of the algorithm (default 1, must be between 1 and 30)
  %
  %    'ranges' (method mmea only): Structure with ranges for the parameters to be calibrated (default empty)
  %       one value (factor between [0, 1], if not: 0.01 is set) to increase and decrease the original parameter values.
  %       two values (min, max) for the  minimum and maximum range values. Consider:               
  %         (1) Use min < max for each variable in ranges. If it is not, then the range will be not used
  %         (2) Do not take max/min too high, use the likely ranges of the problem
  %         (3) Only the free parameters (see 'pars_init_my_pet' file) are considered
  %       Set range with cell string of name of parameter and value for range, e.g. estim_options('ranges',{'kap', [0.3 1]}} 
  %       Remove range-specification with e.g. estim_options('ranges', {'kap'}} or estim_options('ranges', 'kap'}
  %
  %    'results_display (method mmea only)': 
  %       Basic - Does not show results in screen (default) 
  %       Best  - Plots the best solution results in DEBtool style
  %       Set   - Plots all the solutions remarking the best one 
  %               html with pars (best pars and a measure of the variance of each parameter in the solutions obtained for example)
  %       Complete - Joins all options with zero variate data with input and a measure of the variance of all the solutions considered
  %
  %    'results_filename (method mmea only)': The name for the results file (solutionSet_my_pet_time) 
  %
  %    'save_results' (method mmea only): If the results output images are going to be saved
  %       0: no saving (default)
  %       1: saving
  %
  %    'mat_file' (method mmea only): The name of the .mat-file with results from where to initialize the calibration parameters 
  %       (only useful if pars_init_method option is equal to 1 and if there is a result file)
  %       This file is outputted as results_my_pet.mat ("my pet" replaced by name of species) using method nm, results_output 0, 2-6.
  %
  %    'sigma_share': The value of the sigma share parameter (that is used
  %       into the fitness sharing niching method if it is activated)
  %
  % Output
  %
  % * no output, but globals are set to values or values are printed to screen
  %
  %% Remarks
  % See <estim_pars.html *estim_pars*> for application of the option settings.
  % Initial estimates are controlled by option 'pars_init_method', but the free-setting is always taken from the pars_init file.
  % A typical estimation procedure is
  % 
  % * first use estim_options('pars_init_method',2) with estim_options('max_step_number',500),
  % * then estim_options('pars_init_method',1), repeat till satiation or convergence (using arrow-up + enter)
  % * type mat2pars_init in the Matlab's command window to copy the results in the .mat file to the pars_init file
  %
  % If results_output equals 5 or higher, the comparison species can be
  % specified by declaring variable refPets as global and fill it with a
  % cell-string of AmP species names.
  %
  % The default setting for max_step_number on 500 in method nm is on purpose not enough to reach convergence.
  % Continuation (using arrow-up + 'enter' after 'pars_init_method' set on 1) is important to restore simplex size.
  %
  % Typical simplex options are also used in the evolutionary algorithm via local_search in mm_shade and lmm_shade
  %
  %% Example of use
  %  estim_options('default'); estim_options('filter', 0); estim_options('method', 'no')
  
  global method lossfunction filter pars_init_method results_output max_fun_evals 
  global report max_step_number tol_simplex tol_fun simplex_size 
  global search_method num_results gen_factor factor_type bounds_from_ind % method mmea only
  global max_calibration_time num_runs add_initial refine_best
  global verbose verbose_options
  global random_seeds seed_index ranges mat_file results_display
  global results_filename save_results sigma_share
  
  availableMethodOptions = {'no', 'nm', 'mmea', 'nr'};

  if exist('key','var') == 0
    key = 'inexistent';
  end
      
  switch key
	
    case 'default'
      lossfunction = 'sb';
      filter = 1;
      pars_init_method  = 2;
      results_output = 3;
      method = 'nm';
	  max_fun_evals = 1e4;
      report = 1;
	  max_step_number = 500;
	  tol_simplex = 1e-4;
	  tol_fun = 1e-4;
      simplex_size = 0.05;

      % for mmea method (taken from calibration_options)
      search_method = 'mm_shade'; % Use mm_shade: Success-History based Adaptive Differential Evolution 
      num_results = 50;   % The size for the multimodal algorithm's population.
                           % If not defined then sets the values recommended by the author, 
                           % which are 100 for mm_shade ('mm_shade') and 18 * problem size for L-mm_shade.
      gen_factor = 0.5;    % Percentage bounds for individual 
                           % initialization. (e.g. A value of 0.9 means that, for a parameter value of 1, 
                           % the range for generation is [(1 - 0.9) * 1, 1 * (1 + 0.9)] so
                           % the new parameter value will be a random between [0.1, 1.9]
      factor_type = 'mult'; % The kind of factor to be applied when generatin individuals 
                           %('mult' is multiplicative (Default) | 'add' if
                           % additive);
      bounds_from_ind = 1; % This options selects from where the parameters for the initial population of individuals are taken. 
                           % If the value is equal to 1 the parameters are generated from the data initial values 
                           % if is 0 then the parameters are generated from the pseudo data values. 
      add_initial = 0;     % If to add an invidivual taken from initial data into first population.                     % (only if it the 'add_initial' option is activated)
      refine_best = 0;     % If a local search is applied to the best individual found. 
      max_calibration_time = 30; % The maximum calibration time calibration process. 
      num_runs = 5; % The number of runs to perform. 
      verbose = 0;  % If to print some information while the calibration process is running. 
      verbose_options = 5; % The number of solutions to show from the  set of optimal solutions found by the  algorithm through the calibration process.
      random_seeds = [2147483647, 2874923758, 1284092845, ... % The values of the seed used to
                      2783758913, 3287594328, 2328947617, ... % generate random values (each one is used in a
                      1217489374, 1815931031, 3278479237, ... % single run of the algorithm).
                      3342427357, 223758927, 3891375891, ... 
                      1781589371, 1134872397, 2784732823, ... 
                      2183647447, 24923758, 122845, ...
                      2783784093, 394328, 2328757617, ...
                      12174974, 18593131, 3287237, ...
                      33442757, 2235827, 3837891, ... 
                      17159371, 34211397, 2842823]; 
      seed_index = 1; % index for seeds for random number generator
      rng(random_seeds(seed_index), 'twister'); % initialize the number generator is with a seed, to be updated for each run of the calibration method.
      ranges = struct(); % The range struct is empty by default. 
      results_display = 'Basic'; % The results output style.
      results_filename = 'Default';
      save_results = false; % If results output are saved.
      mat_file = '';
      sigma_share = 0.1;
    
      case 'loss_function'
      if exist('val','var') == 0
        if numel(lossfunction) ~= 0
          fprintf(['loss_function = ', lossfunction,' \n']);  
        else
          fprintf('loss_function = unknown \n');
        end
        fprintf('sb - multiplicative symmetric bounded \n');
        fprintf('su - multiplicative symmetric unbounded \n');
        fprintf('re - relative error \n');
        fprintf('SMAE - symmetric mean absolute error \n');
      else
        lossfunction = val;
      end
      
    case 'filter'
      if exist('val','var') == 0
        if numel(filter) ~= 0
          fprintf(['filter = ', num2str(filter),' \n']);  
        else
          fprintf('filter = unknown \n');
        end
        fprintf('0 - do not use filter \n');
        fprintf('1 - use filter \n');
      else
        filter = val;
      end
      
    case 'pars_init_method'
      if exist('val','var') == 0
        if numel(pars_init_method) ~= 0
          fprintf(['pars_init_method = ', num2str(pars_init_method),' \n']);  
        else
          fprintf('pars_init_method = unknown \n');
        end	      
        fprintf('0 - get initial estimates from automatized computation \n');
        fprintf('1 - read initial estimates from .mat file \n');
        fprintf('2 - read initial estimates from pars_init file \n');
      else
        pars_init_method = val;
      end

    case 'results_output'
      if exist('val','var') == 0
        if numel(results_output) ~= 0
          fprintf(['results_output = ', num2str(results_output),' \n']);
        else
          fprintf('results_output = unknown \n');
        end	 
        fprintf('0      only saves data results to .mat, no figures, no writing to html or screen\n');
        fprintf('1, -1  no saving to .mat file, prints results to html (1) or screen (-1)\n');
        fprintf('2, -2  saves to .mat file, prints results to html (2) or screen (-2) \n');
        fprintf('3, -3  like 2 (or -2), but also prints graphs to .png files (default is 3)\n');
        fprintf('4, -4  like 3 (or -3), but also prints html with implied traits \n');
        fprintf('5, -5  like 3 (or -3), but also prints html with implied traits including related species \n');
        fprintf('6,     like 5, but also prints html with population traits \n');         
      else
        results_output = val;
      end
            
    case 'method'
      if exist('val','var') == 0 || ~any(ismember(availableMethodOptions, val))
        if numel(method) ~= 0
          fprintf(['method = ', method,' \n']);  
        else
          fprintf('method = unknown \n');
        end	      
        fprintf('''no'' - do not estimate \n');
        fprintf('''nm'' - use Nelder-Mead method \n');
        fprintf('''mmea'' - use multimodal evolutionary algorithm method \n');
      else
        method = val;
      end

    case 'max_fun_evals'
      if exist('val','var') == 0 
        if numel(max_fun_evals) ~= 0
          fprintf(['max_fun_evals = ', num2str(max_fun_evals),' \n']);  
        else
          fprintf('max_fun_evals = unknown \n');
        end	      
      else
        max_fun_evals = val;
        max_calibration_time = Inf; % mmea method only
      end
      
    case 'report'
      if ~exist('val','var')
        if numel(report) ~= 0
          fprintf(['report = ', num2str(report),'\n']);  
        else
          fprintf('report = unknown \n');
        end	      
        fprintf('0 - do not report \n');
        fprintf('1 - do report \n');
      else
        report = val;
      end

    case 'max_step_number'
      if exist('val','var') == 0 
        if numel(max_step_number) ~= 0
          fprintf(['max_step_number = ', num2str(max_step_number),'\n']);  
        else
          fprintf('max_step_number = unknown \n');
        end	      
      else
        max_step_number = val;
      end

    case 'tol_simplex'
      if exist('val','var') == 0 
        if numel(tol_simplex) ~= 0
          fprintf(['tol_simplex = ', num2str(tol_simplex),'\n']);  
        else
          fprintf('tol_simplex = unknown \n');
        end	      
      else
        tol_simplex = val;
      end

    case 'simplex_size'
      if exist('val','var') == 0 
        if numel(simplex_size) ~= 0
          fprintf(['simplex_size = ', num2str(simplex_size),'\n']);  
        else
          fprintf('simplex_size = unknown \n');
        end	      
      else
        simplex_size = val;
      end
      
    % method mmea only, taken from calibatrion_options
    case 'search_method'
      if ~exist('val','var')
        search_method = 'mm_shade'; % Select mm_shade as the default method.
      else
        search_method = val;
      end 
      
    case 'num_results'
      if ~exist('val','var')
        if numel(num_results) ~= 0 
          fprintf(['num_results = ', num2str(num_results),' \n']);  
        else
          fprintf('num_results = unknown \n');
        end	      
      else
        if num_results < 1 
          num_results = 10;
        else
          num_results = val;
        end
      end
      
    case 'gen_factor'
      if ~exist('val','var')
        if numel(gen_factor) ~= 0.0
          fprintf(['gen_factor = ', num2str(gen_factor),' \n']);  
        else
          fprintf('gen_factor = unknown \n');
        end	      
      else
        gen_factor = val;
      end
      
    case 'factor_type'
      if ~exist('val','var')
        factor_type = 'mult';
        fprintf(['factor_type = ', factor_type,' \n']);  
      else
          factor_type = val;
      end	 
      
    case 'bounds_from_ind'
      if ~exist('val','var')
        if numel(bounds_from_ind) ~= 0
          fprintf(['bounds_from_ind = ', num2str(bounds_from_ind),' \n']);  
        else
          fprintf('bounds_from_ind = unknown \n');
        end	      
      else
        bounds_from_ind = val;
      end
      
    case 'add_initial'
      if ~exist('val','var')
        if numel(add_initial) ~= 0
          fprintf(['add_initial = ', num2str(add_initial),' \n']);  
        else
          fprintf('add_initial = unknown \n');
        end	      
      else
        add_initial = val;
      end
      
    case 'refine_best'
      if ~exist('val','var')
        if numel(refine_best) ~= 0
          fprintf(['refine_best = ', num2str(refine_best),' \n']);  
        else
          fprintf('refine_best = unknown \n');
        end	      
      else
        refine_best = val;
      end
      
    case 'max_calibration_time'
      if ~exist('val','var')
        if numel(max_calibration_time) ~= 0
          fprintf(['max_calibration_time = ', num2str(max_calibration_time),' \n']);
        else
          fprintf('max_calibration_time = unkown \n');
        end
      else
        max_calibration_time = val;
        max_fun_evals = Inf;
      end
      
    case 'num_runs'
      if ~exist('val','var')
        if numel(num_runs) ~= 0
          fprintf(['num_runs = ', num2str(num_runs),' \n']);
        else
          fprintf('num_runs = unkown \n');
        end
      else
        num_runs = val;
      end
      
    case 'verbose'
      if ~exist('val','var')
        if numel(verbose) ~= 0
          fprintf(['verbose = ', num2str(verbose),' \n']);
        else
          fprintf('verbose = unkown \n');
        end
      else
        verbose = val;
      end
      
    case 'verbose_options'
      if ~exist('val','var')
        if numel(verbose_options) ~= 0
          fprintf(['verbose_options = ', num2str(verbose_options),' \n']);
        else
          fprintf('verbose_options = unkown \n');
        end
      else
        verbose_options = val;
      end
      
    case 'seed_index'
      if ~exist('val','var')
        if numel(random_seeds) ~= 0
          fprintf(['seed_index = ', num2str(seed_index(1)),' \n']);
        else
          fprintf('seed_index = unkown \n');
        end
      else
        seed_index = val;
      end
      rng(random_seeds(seed_index), 'twister'); % initialize the random number generator
      
    case 'ranges'
      if ~exist('val','var')
        if numel(ranges) ~= 0
          fprintf('ranges = structure with fields: \n');
          disp(struct2table(ranges));
        else
          fprintf('ranges = unkown \n');
        end
      else
        if iscell(val) && length(val)>1
          ranges.(val{1}) = val{2};
        elseif iscell(val) && isfield(ranges, val)
          ranges = rmfield(ranges, val{1});
        elseif isfield(ranges, val)
          ranges = rmfield(ranges, val);
        end
      end
      
    case 'results_display'
      if ~exist('val','var')
        if strcmp(results_display, 'Basic')
          fprintf(['results_display = ', results_display,' \n']);
        elseif strcmp(results_display, 'Best')
          fprintf(['results_display = ', results_display,' \n']);
        elseif strcmp(results_display, 'Set')
          fprintf(['results_display = ', results_display,' \n']);
        elseif strcmp(results_display, 'Complete')
          fprintf(['results_display = ', results_display,' \n']);
        else
          fprintf('results_display = unkown \n');
        end
      else
        results_display = val;
      end
      
    case 'results_filename'
      if ~exist('val','var')
        results_filename = 'Default'; 
      else
        results_filename = val;
      end
      
    case 'save_results'
      if ~exist('val','var')
        if numel(save_results) ~= 0
          fprintf(['save_results = ', save_results,' \n']);
        else
          fprintf('save_results = unkown \n');
        end
      else
        save_results = val;
      end
      
    case 'mat_file'
      if ~exist('val','var')
        mat_file = ''; 
      else
        mat_file = val;
      end
         
      case 'sigma_share'
         if ~exist('val','var')
            if numel(sigma_share) ~= 0.0
               fprintf(['sigma_share = ', num2str(sigma_share),' \n']);  
            else
               fprintf('sigma_share = unknown \n');
            end	      
         else
            if val > 1.0
               val = 1.0;
            elseif val < 0.0
               val = .0;
            end
            sigma_share = val;
         end
         
    % only a single input
    case 'inexistent' 
      if numel(lossfunction) ~= 0
        fprintf(['loss_function = ', lossfunction,' \n']);
      else
        fprintf('loss_function = unknown \n');
      end
      
      if numel(filter) ~= 0
        fprintf(['filter = ', num2str(filter),' \n']);
      else
        fprintf('filter = unknown \n');
      end
      
      if numel(pars_init_method) ~= 0
        fprintf(['pars_init_method = ', num2str(pars_init_method),' \n']);
      else
        fprintf('pars_init_method = unknown \n');
      end
            
      if numel(results_output) ~= 0
        fprintf(['results_output = ', num2str(results_output),' \n']);
      else
        fprintf('results_output = unknown \n');
      end
      
      if numel(method) ~= 0
        fprintf(['method = ', method,' \n']);
        if strcmp(method, 'mmea')
          calibration_options;
        end
      else
        fprintf('method = unknown \n');
      end

      if numel(max_fun_evals) ~= 0
        fprintf(['max_fun_evals = ', num2str(max_fun_evals),' \n']);
      else
        fprintf('max_fun_evals = unknown \n');
      end
      
      if numel(report) ~= 0
        fprintf(['report = ', num2str(report),' (method nm)\n']);
      else
        fprintf('report = unknown \n');
      end

      if numel(max_step_number) ~= 0
        fprintf(['max_step_number = ', num2str(max_step_number),' (method nm)\n']);
      else
        fprintf('max_step_number = unknown \n');
      end
      
      if numel(tol_simplex) ~= 0
        fprintf(['tol_simplex = ', num2str(tol_simplex),' (method nm)\n']);
      else
        fprintf('tol_simplex = unknown \n');
      end
      
      if numel(simplex_size) ~= 0
        fprintf(['simplex_size = ', num2str(simplex_size),' (method nm)\n']);
      else
        fprintf('simplex_size = unknown \n');
      end
      
      % method mmea only
      if numel(search_method) ~= 0
        fprintf(['search_method = ', search_method,' (method mmea)\n']);
      else
        fprintf('search_method = unkown \n');
      end
      
      if numel(num_results) ~= 0.0
        fprintf(['num_results = ', num2str(num_results),' (method mmea)\n']);
      else
        fprintf('num_results = unknown \n');
      end
      
      if numel(gen_factor) ~= 0.0
        fprintf(['gen_factor = ', num2str(gen_factor),' (method mmea)\n']);
      else
        fprintf('gen_factor = unknown \n');
      end
      
      if numel(factor_type) ~= 0
        fprintf(['factor_type = ', factor_type,' \n']);
      else
        fprintf('factor_type = unkown \n');
      end
      
      if numel(bounds_from_ind) ~= 0.0
        fprintf(['bounds_from_ind = ', num2str(bounds_from_ind),' (method mmea)\n']);
      else
        fprintf('bounds_from_ind = unknown \n');
      end
      
      if numel(max_fun_evals) ~= 0
        fprintf(['max_fun_evals = ', num2str(max_fun_evals),' (method mmea)\n']);
      else
        fprintf('max_fun_evals = unkown \n');
      end
      
      if numel(max_calibration_time) ~= 0
        fprintf(['max_calibration_time = ', num2str(max_calibration_time),' (method mmea)\n']);
      else
        fprintf('max_calibration_time = unkown \n');
      end
      
      if numel(num_runs) ~= 0
        fprintf(['num_runs = ', num2str(num_runs),' (method mmea)\n']);
      else
        fprintf('num_runs = unkown \n');
      end
      
      if numel(add_initial) ~= 0
        fprintf(['add_initial = ', num2str(add_initial),' (method mmea)\n']);
      else
        fprintf('add_initial = unkown \n');
      end
      
      if numel(refine_best) ~= 0
        fprintf(['refine_best = ', num2str(refine_best),' (method mmea)\n']);
      else
        fprintf('refine_best = unkown \n');
      end
      
      if numel(verbose) ~= 0
        fprintf(['verbose = ', num2str(verbose),' (method mmea)\n']);
      else
        fprintf('verbose = unkown \n');
      end
      
      if numel(verbose_options) ~= 0
        fprintf(['verbose_options = ', num2str(verbose_options),' (method mmea)\n']);
      else
        fprintf('verbose_options = unkown \n');
      end
      
      if numel(random_seeds) ~= 0
        fprintf(['random_seeds = ', num2str(random_seeds(1)),' (method mmea)\n']);
      else
        fprintf('random_seeds = unkown \n');
      end
      
      if numel(ranges) ~= 0 
        fprintf('ranges = structure with fields (method mmea)\n');
        disp(struct2table(ranges));
      else
        fprintf('ranges = unkown \n');
      end
      
      if strcmp(results_display, '') ~= 0
        fprintf(['results_display = ', results_display,' (method mmea)\n']);
      else
        fprintf('results_display = unkown \n');
      end
      
      if strcmp(results_filename, '') ~= 0
        fprintf(['results_filename = ', results_filename,' (method mmea)\n']);
      else
        fprintf('results_filename = unkown \n');
      end
      
      if strcmp(mat_file, '') ~= 0
        fprintf(['mat_file = ', mat_file,' (method mmea)\n']);
      else
        fprintf('mat_file = unkown \n');
      end
      
      if strcmp(sigma_share, '') ~= 0
        fprintf(['sigma_share = ', sigma_share,' \n']);
      else
        fprintf('sigma_share = unkown \n');
      end
      
    otherwise
        fprintf(['key ', key, ' is unkown \n\n']);
        estim_options;
  end
  
  %% warnings
  if strcmp(method,'mmea') && filter==0
    fprintf('Warning from estim_options: method mmea without using filters amounts to asking for trouble\n');
  end
end