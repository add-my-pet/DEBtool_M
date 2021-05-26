%% calibration_options
% Sets options for calibration.pars

function calibration_options (key, val)
% Created at 2020/02/15 Juan Francisco Robles; 
% Modified 2020/02/22, 2020/02/24, 2020, 03, 11,
% 2020/03/12, 2020/06/02, 2021/03/23 by Juan Francisco Robles
%

%% Syntax
% <../calibration_options.m *calibration_options*> (key, val)

%% Description
% Sets options for calibration one by one
%
% Input
%
% * no input: print values to screen
% * one input:
%
%    'default': sets options by default
%
% * two inputs
%      
%    'method': 
%      'mm1' - use Nelder-Mead method; 
%      'mm2' - do not estimate;
%     
%    'num_results': The size for the multimodal algorithm's population.
%                   If it is not defined then sets the values recommended by 
%                   the author, which are 100 for SHADE ('mm1') and 
%                   18 * problem size for L-SHADE.
%    'gen_factor': percentage to build the ranges for initializing the 
%                  first population of individuals.
%
%    'bounds_from_ind': 
%      1: use ranges from data (default); 
%      0: use ranges from pseudodata if exist (these ranges not existing 
%         will be taken from data).
%
%    'max_fun_evals': maximum number of function evaluations (10000 by
%                     default).
%
%    'max_calibration_time': maximum calibration time in minutes (0 by default).
%
%    'num_runs': the number of independent runs to perform.
%
%    'add_initial': if the initial individual is added in the first
%                   population.
%
%    'refine_initial': if the initial individual is refined using Nelder
%                    Mead.
%     
%    'refine_best': if the best individual found is refined using Nelder
%                    Mead.
%     
%    'refine_running': If to apply local search to some individuals
%                       while simulation is running. 
%
%    'refine_run_prob': The probability to apply a local search to an 
%                        individual while algorithm is running. 
%
%    'refine_firsts': If to apply a local search to the first population 
%                      (this is recommended when the algorithm is not able
%                       to converge to good solutions till the end of its 
%                       execution). 
%                       Not activated (0) default. 
%
%    'verbose_options': The number of solutions to show from the set of 
%                        optimal solutions found by the algorithm through 
%                        the calibration process.  
%
%    'verbose': If to activate verbose options (1 yes, 0 no). 
%                This option prints some information while the calibration 
%                process is running.  
%
%    'random_seeds': The values for the seeds used to generate random
%                     values (each one is used in a single run of the
%                     algorithm). 
%    'ranges': Some ranges for the parameters to be calibrated. The range
%              struct has one (factor) to increase and decrease the 
%              original parameter values or two substructs (min and max)  
%              for the  minimum and maximum range values. 
%              The factor parameter could contain a value between [0, 1].
%              If the value is not between [0,1], a default value of 0.01
%              is set. 
%              Both min and max could contain values on any scale of values 
%              but is it important to consider the folowing: 
%              (1) The min value must be lower than the max value for each 
%                  variable in ranges. If it is not, then the variable will
%                  be not used to avoid problems into the calibration engine. 
%              (2) If the range between the min and max values is too high, 
%                  the calibration engine could experiment problems when 
%                  running. It is recomended to adapt the data to the real 
%                  ranges of the problem.
%               (3) Only the free parameters (see 'pars_init_my_pet' file)
%                   are considered.
%               The ranges structure is empty by default. 
%    'results_output': The type of results output to display after
%                      calibration execution. 
%                      Options: 
%                      (1) Basic - Does not show results in screen. 
%                      (2) Best - Plots the best solution results in
%                          DEBTools style.
%                      (3) Set - Plots all the solutions remarking the 
%                          best one. Html with pars (best pars and a 
%                          measure of the variance of each parameter in 
%                          the solutions obtained for example).
%                      (4) Complete - Joins options 1, 2 , and 3 together 
%                          with zero variate data with input and a measure 
%                          of the variance of all the solutions considered
%    'results_filename': The name for the results file. 
%    'save_results': If the results output images are going to be saved. 
%    'mat_file': A file with results from where to initialize the
%                calibration parameters (only useful if pars_init_method 
%                option is equal to 1 and if there is a result file)
% Output
%
% * no output, but globals are set to values or values are printed to screen
%
%% Remarks
% For other options see corresponding options file of the minimazation  algorithm, e.g. <../../regr/html/nmregr_options.html *nmregr_options*>.
% See <estim_pars.html *estim_pars*> for application of the option settings.
% Initial estimates are controlled by option 'pars_init_method', but the free-setting is always taken from the pars_init file
%
%% Example of use
%  calibration_options('default'); calibration_options('random_seed', 123543545); calibration_options('add_initial', 1)

   % Global varaibles
   global method num_results gen_factor bounds_from_ind max_fun_evals 
   global max_calibration_time  num_runs add_initial refine_initial  
   global refine_best  refine_running refine_run_prob refine_firsts 
   global verbose verbose_options random_seeds ranges mat_file
   global results_output results_filename save_results
   
   if exist('key','var') == 0
      key = 'inexistent';
   end

   switch key 
      case {'default', ''}
         method = 'mm1'; % Use SHADE for parameter estimation
         num_results = 100; % The size for the multimodal algorithm's population.
                          % If not defined then sets the values recommended by
                          % the author, which are 100 for SHADE ('mm1') and
                          % 18 * problem size for L-SHADE.
         gen_factor = 0.5; % Percentage bounds for individual 
                           % initialization. (e.g. A value of 0.9 means
                           % that, for a parameter value of 1, the range
                           % for generation is [(1 - 0.9) * 1, 1 * (1 + 0.9)] so
                           % the new parameter value will be a random
                           % between [0.1, 1.9]
         bounds_from_ind = 1; % This options selects from where the 
                              % parameters for the initial population of
                              % individuals are taken. If the value is
                              % equal to 1 the parameters are generated
                              % from the data initial values if is 0 then
                              % the parameters are generated from the
                              % pseudo data values. 
         add_initial = 0; % If to add an invidivual taken from initial 
                          % data into first population.
         refine_initial = 0; % If a refinement is applied to the initial 
                             % individual of the population (only if it the
                             % 'add_initial' option is activated)
         refine_best = 0; % If a local search is applied to the best 
                          % individual found. 
         refine_running = 0; % If to apply local search to some individuals
                             % while simulation is running. 
         refine_run_prob = 0.05; % The probability to apply a local search
                                 % to an individual while algorithm is
                                 % running. 
         refine_firsts = 0; % If to apply a local search to the first 
                            % population (this is recommended when the
                            % algorithm is not able to converge to good
                            % solutions till the end of its execution). 
         max_fun_evals = 10000; % The maximum number of function 
                                % evaluations to perform before to end the
                                % calibration process. 
         max_calibration_time = 30; % The maximum calibration time
         % calibration process. 
         num_runs = 1; % The number of runs to perform. 
         verbose = 0; % If to print some information while the calibration 
                      % process is running. 
         verbose_options = 10; % The number of solutions to show from the 
                               % set of optimal solutions found by the
                               % algorithm through the calibration process.
         random_seeds = [2147483647, 2874923758, 1284092845, ...
                         2783758913, 3287594328, 9328947617, ...
                         1217489374, 9815931031, 3278479237, ...
                         8342427357, 8923758927, 7891375891, ... 
                         8781589371, 8134872397, 2784732823]; % The values of the
                                                       % seed used to
                                                       % generate random
                                                       % values (each one
                                                       % is used in a
                                                       % single run of the
                                                       % algorithm). 
         rng(random_seeds(1), 'twister'); % By default, the random number 
                                          % generator is initialized with
                                          % the first seed. It will be
                                          % update for each run of the
                                          % calibration method. 
         ranges = struct(); % The range struct is empty by default. 
         results_output = 'Basic'; % The results output style.
         results_filename = 'Default';
         save_results = false; % If results output are saved.
         mat_file = '';
      case 'method'
         if ~exist('val','var')
            method = 'mm1'; % Select SHADE as the default method.
         else
            method = val;
         end 
      case 'num_results'
         if ~exist('val','var')
            if numel(num_results) ~= 0 
               fprintf(['num_results = ', num2str(num_results),' \n']);  
            else
               fprintf('num_results = unknown \n');
            end	      
         else
            if num_results < 100 
               num_results = 100;
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
            if val >= 1.0
               val = 0.99;
            elseif val <= 0.0
               val = .01;
            end
            gen_factor = val;
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
      case 'refine_running'
         if ~exist('val','var')
            if numel(refine_running) ~= 0
               fprintf(['refine_running = ', num2str(refine_running),' \n']);  
            else
               fprintf('refine_running = unknown \n');
            end	      
         else
           refine_running = val;
         end
      case 'refine_run_prob'
         if ~exist('val','var')
            if numel(refine_run_prob) ~= 0
               fprintf(['refine_run_prob = ', num2str(refine_run_prob),' \n']);  
            else
               fprintf('refine_run_prob = unknown \n');
            end	      
         else
            refine_run_prob = val;
         end
      case 'refine_firsts'
         if ~exist('val','var')
            if numel(refine_firsts) ~= 0
               fprintf(['refine_firsts = ', num2str(refine_firsts),' \n']);  
            else
               fprintf('refine_firsts = unknown \n');
            end	      
         else
            refine_firsts = val;
         end
      case 'refine_initial'
         if ~exist('val','var')
            if numel(refine_initial) ~= 0
               fprintf(['refine_initial = ', num2str(refine_initial),' \n']);  
            else
               fprintf('refine_initial = unknown \n');
            end	      
         else
            refine_initial = val;
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
      case 'max_fun_evals'
         if ~exist('val','var')
            if numel(max_fun_evals) ~= 0
               fprintf(['max_fun_evals = ', num2str(max_fun_evals),' \n']);
            else
               fprintf('max_fun_evals = unkown \n');
            end
         else
            max_fun_evals = val;
            max_calibration_time = Inf;
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
            if numel(max_fun_evals) ~= 0
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
      case 'random_seeds'
         if ~exist('val','var')
            if numel(random_seeds) ~= 0
               fprintf(['random_seeds = ', num2str(random_seeds),' \n']);
            else
               fprintf('random_seeds = unkown \n');
            end
         else
            random_seeds = val;
         end
      case 'ranges'
         if ~exist('val','var')
            if numel(ranges) ~= 0
               fprintf(['ranges = ', num2str(ranges),' \n']);
            else
               fprintf('ranges = unkown \n');
            end
         else
            ranges = val;
         end
      case 'results_output'
         if ~exist('val','var')
            if strcmp(results_output, 'Basic')
               fprintf(['results_output = ', results_output,' \n']);
            elseif strcmp(results_output, 'Best')
                fprintf(['results_output = ', results_output,' \n']);
            elseif strcmp(results_output, 'Set')
                fprintf(['results_output = ', results_output,' \n']);
            elseif strcmp(results_output, 'Complete')
                fprintf(['results_output = ', results_output,' \n']);
            else
               fprintf('results_output = unkown \n');
            end
         else
            results_output = val;
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
      otherwise
         if ~strcmp(key, 'inexistent')   
            fprintf(['key ', key, ' is unkown \n\n']);
         end
         if strcmp(method, '') ~= 0
            fprintf(['method = ', method,' \n']);
         else
            fprintf('method = unkown \n');
         end
         if numel(num_results) ~= 0.0
            fprintf(['num_results = ', num2str(num_results),' \n']);
         else
            fprintf('num_results = unknown \n');
         end
         if numel(gen_factor) ~= 0.0
            fprintf(['gen_factor = ', num2str(gen_factor),' \n']);
         else
            fprintf('gen_factor = unknown \n');
         end	  
         if numel(bounds_from_ind) ~= 0.0
            fprintf(['bounds_from_ind = ', num2str(bounds_from_ind),' \n']);
         else
            fprintf('bounds_from_ind = unknown \n');
         end
         if numel(max_fun_evals) ~= 0
            fprintf(['max_fun_evals = ', num2str(max_fun_evals),' \n']);
         else
            fprintf('max_fun_evals = unkown \n');
         end
         if numel(max_calibration_time) ~= 0
            fprintf(['max_calibration_time = ', num2str(max_calibration_time),' \n']);
         else
            fprintf('max_calibration_time = unkown \n');
         end
         if numel(num_runs) ~= 0
            fprintf(['num_runs = ', num2str(num_runs),' \n']);
         else
            fprintf('num_runs = unkown \n');
         end
         if numel(add_initial) ~= 0
            fprintf(['add_initial = ', num2str(add_initial),' \n']);
         else
            fprintf('add_initial = unkown \n');
         end
         if numel(refine_running) ~= 0
            fprintf(['refine_running = ', num2str(refine_running),' \n']);
         else
            fprintf('refine_running = unkown \n');
         end
         if numel(refine_run_prob) ~= 0
            fprintf(['refine_run_prob = ', num2str(refine_run_prob),' \n']);
         else
            fprintf('refine_run_prob = unkown \n');
         end
         if numel(refine_firsts) ~= 0
            fprintf(['refine_firsts = ', num2str(refine_firsts),' \n']);
         else
            fprintf('refine_firsts = unkown \n');
         end
         if numel('refine_initial') ~= 0
            fprintf(['refine_initial = ', num2str(refine_initial),' \n']);
         else
            fprintf('refine_initial = unkown \n');
         end
         if numel(refine_best) ~= 0
            fprintf(['refine_best = ', num2str(refine_best),' \n']);
         else
            fprintf('refine_best = unkown \n');
         end
         if numel(verbose) ~= 0
            fprintf(['verbose = ', num2str(verbose),' \n']);
         else
            fprintf('verbose = unkown \n');
         end
         if numel(verbose_options) ~= 0
            fprintf(['verbose_options = ', num2str(verbose_options),' \n']);
         else
            fprintf('verbose_options = unkown \n');
         end
         if numel(random_seed) ~= 0
            fprintf(['random_seeds = ', num2str(random_seeds),' \n']);
         else
            fprintf('random_seeds = unkown \n');
         end
         if numel(ranges) ~= 0
            fprintf(['ranges = ', num2str(ranges),' \n']);
         else
            fprintf('ranges = unkown \n');
         end
         if strcmp(results_output, '') ~= 0
            fprintf(['results_output = ', results_output,' \n']);
         else
            fprintf('results_output = unkown \n');
         end
         if strcmp(results_filename, '') ~= 0
            fprintf(['results_filename = ', results_filename,' \n']);
         else
            fprintf('results_filename = unkown \n');
         end
         if strcmp(mat_file, '') ~= 0
            fprintf(['mat_file = ', mat_file,' \n']);
         else
            fprintf('mat_file = unkown \n');
         end
   end
end
