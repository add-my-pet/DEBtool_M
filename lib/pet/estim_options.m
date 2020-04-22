%% estim_options
% Sets options for estim.pars

%%
function estim_options (key, val)
  %  created at 2015/01/25 by Goncalo Marques; modified 2015/03/26 by Goncalo Marques, 2018/05/21, 2018/08/21 by Bas Kooijman
  % 2019/12/20 by Nina Marn
  
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
  %      'nm': use Nelder-Mead method; 
  %      'no': do not estimate;
  %
  % Output
  %
  % * no output, but globals are set to values or values are printed to screen
  %
  %% Remarks
  % For other options see corresponding options file of the minimazation  algorithm, e.g. <../../regr/html/nmregr_options.html *nmregr_options*>.
  % See <estim_pars.html *estim_pars*> for application of the option settings.
  % Initial estimates are controlled by option 'pars_init_method', but the free-setting is always taken from the pars_init file
  % A typical estimation procedure is
  % 
  % * first use estim_options('pars_init_method',2) with estim_options('max_step_number',500),
  % * then estim_options('pars_init_method',1), repeat till satiation or convergence (using arrow-up + enter)
  % * type mat2pars_init in the Matlab's command window to copy the results in the .mat file to the pars_init file
  
  %% Example of use
  %  estim_options('default'); estim_options('filter', 0); estim_options('method', 'no')
 
  global method lossfunction 
  global filter pars_init_method results_output
 
  if exist('key','var') == 0
    key = 'inexistent';
  end
  
  availableMethodOptions = {'no', 'nm'};
    
  switch key
	
    case 'default'
      lossfunction = 'sb';
      filter = 1;
      pars_init_method  = 2;
      results_output = 3;
      method = 'nm';
      nmregr_options('default');

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
        fprintf(' 0      only saves data results to .mat, no figures, no writing to html or screen\n');
        fprintf('1, -1  no saving to .mat file, prints results to html (1) or screen (-1)\n');
        fprintf('2, -2  saves to .mat file, prints results to html (2) or screen (-2) \n');
        fprintf('3, -3  like 2 (or -2), but also prints graphs to .png files (default is 3)\n');
        fprintf('4, -4  like 3 (or -3), but also prints html with implied traits \n');
        fprintf('5, -5  like 3 (or -3), but also prints html with implied traits including related species \n');
        fprintf('6, -6  like 5, but also prints html with population traits \n');         
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
        if ~strcmp(method, 'no')
          eval([method, 'regr_options;']);
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