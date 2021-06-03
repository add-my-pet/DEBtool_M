%% estim_options
% Sets options for estim.pars

%%
function estim_options (key, val)
  %  created at 2015/01/25 by Goncalo Marques; 
  %  modified 2015/03/26 by Goncalo Marques, 2018/05/21, 2018/08/21 by Bas Kooijman, 2019/12/20 by Nina Marn, 2021/06/02 by Bas Kooijman
  
  %% Syntax
  % <../estim_options.m *estim_options*> (key, val)
  
  %% Description
  % Sets options for estimation one by one
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
  %      're': relative error (symmetric by addition);
  %      'sb': multiplicative symmetric bounded (default);
  %      'su': multiplicative symmetric unbounded;
  %
  %    'filter': 
  %      1: use filter (default); 
  %      0: do not;
  %
  %    'pars_init_method':
  %      0:  get initial estimates from automatized computation 
  %      1:  read initial estimates from .mat file (for continuation)
  %      2:  read initial estimates from pars_init file (default)
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
  %      'nm': Nelder-Mead method; 
  %      'ga': genetic algorithm;
  %      'no': do not estimate;
  %
  %    'report': 
  %       1 - to report steps to screen (default); 
  %       0 - do not report;
  %
  %    'max_step_number': maximum number of steps (default 500)
  %
  %    'max_fun_evals': maximum number of function evaluations (default 2000)
  %
  %    'tol_simplex': tolerance for how close the simplex points must be together to call them the same (default 1e-4)
  %
  %    'tol_fun': tolerance for how close the loss-function values must be together to call them the same (default 1e-4)
  %
  %    'simplex_size': fraction added (subtracted if negative) to the free parameters when building the simplex (default 0.05)

  %
  % Output
  %
  % * no output, but globals are set to values or values are printed to screen
  %
  %% Remarks
  % Options for the nm method 'report', 'max_step_number', 'max_fun_evals', 'tol_simplex', 'tol_tun', 'simplex_size' are set in <../../regr/html/nmregr_options.html *nmregr_options*>.
  % Options for the ga method are set in <../../lib/html/calibration_options.html *calibration_options*>;
  % See <estim_pars.html *estim_pars*> for application of the option settings.
  % Initial estimates are controlled by option 'pars_init_method', but the free-setting is always taken from the pars_init file
  % A typical estimation procedure is
  % 
  % * first use estim_options('pars_init_method',2) with estim_options('max_step_number',500),
  % * then estim_options('pars_init_method',1), repeat till satiation or convergence (using arrow-up + enter)
  % * type mat2pars_init in the Matlab's command window to copy the results in the .mat file to the pars_init file
  %
  % The default setting for max_step_number on 500 in method nm is on purpose not enough to reach convergence.
  % Continuation (using arrow-up + 'enter' after 'pars_init_method' set on 1) is important to restore simplex size.
  %
  %% Example of use
  %  estim_options('default'); estim_options('filter', 0); estim_options('method', 'no')
 
  global method lossfunction 
  global filter pars_init_method results_output
 
  if exist('key','var') == 0
    key = 'inexistent';
  end
  
  availableMethodOptions = {'no', 'nm', 'ga'};
    
  switch key
	
    case 'default'
      calibration_options('default');
      nmregr_options('default');
      lossfunction = 'sb';
      filter = 1;
      pars_init_method  = 2;
      results_output = 3;
      method = 'nm';

    case 'loss_function'
      if exist('val','var') == 0
        if numel(lossfunction) ~= 0
          fprintf(['loss_function = ', lossfunction,' \n']);  
        else
          fprintf('loss_function = unknown \n');
        end
        fprintf('sb - multiplicative symmetric bounded \n');
        fprintf('su - multiplicative symmetric unbounded \n');
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
        fprintf('''ga'' - use genetic algorithm method \n');
      else
        method = val;
      end

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
        if strcmp(method, 'nm')
          nmregr_options;
        elseif strcmp(method, 'ga')
          calibration_options;
        end
      else
        fprintf('method = unknown \n');
      end
        
    otherwise % option 'other'
      if numel(method) ~= 0
        if exist('val','var') == 0 && ~strcmp(method, 'no') 
          eval([method, 'regr_options(key);']);
        else
          eval([method, 'regr_options(key, val);']);
        end
      else
        fprintf(['key ', key, ' is unkown \n\n']);
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
        fprintf('method = unknown \n');
      end

   end