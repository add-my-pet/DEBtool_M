%% estim_options
% Sets options for estim.pars

%%
function estim_options (key, val)
  %  created at 2015/01/25 by Goncalo Marques; modified 2015/03/26 by Goncalo Marques
  
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
  %   'default': sets options at default values
  %   any other key (see below): print value to screen
  %
  % * two inputs
  %
  %   'filter': 1 - use filter (default); 0 - do not;
  %   'pars_init_method':
  %     0 - get initial estimates from automatized computation (default)
  %     1 - read initial estimates from .mat file (for continuation)
  %     2 - read initial estimates from pars_init file
  %   'pseudodata_pets': 
  %     0 - put pseudodata together with data (default) 
  %     1 - put it apart (only for multispecies estimation)
  %   'results_output':
  %     0 - prints results to screen (default)
  %     1 - prints results to screen, saves to .mat file
  %     2 - saves data to .mat file and graphs to .png files
  %     (prints results to screen using a customized results file when it exists)
  %   'method': 'nm' - use Nelder-Mead method; 'no' - do not estimate;
  %   for other options see corresponding options file of the method (e.g. nmregr_options)
  %
  % Output
  %
  % * no output, but globals are set to values or values are printed to screen
  
  %% Remarks
  % See <estim_pars.html *estim_pars*> for application of the option settings
  
  %% Example of use
  %  estim_options('default'); estim_options('filter', 0)
 
  global method filter pars_init_method pseudodata_pets results_output
 
  if exist('key','var') == 0
    key = 'inexistent';
  end
    
  switch key
	
    case 'default'
      filter = 1;
      pars_init_method  = 0;
      pseudodata_pets = 0;
      results_output = 0;
      method = 'nm';
      nmregr_options('default');

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
        fprintf('3 - prints results using a customized results file \n');
      else
        pars_init_method = val;
      end

    case 'pseudodata_pets'
      if exist('val','var') == 0
        if numel(pseudodata_pets) ~= 0
          fprintf(['pseudodata_pets = ', num2str(pseudodata_pets),' \n']);  
        else
          fprintf('pseudodata_pets = unknown \n');
        end
        fprintf('0 - put pseudodata together with data \n');
        fprintf('1 - put it apart (for multispecies estimation) \n');
     else
        pseudodata_pets = val;
      end

    case 'results_output'
      if exist('val','var') == 0
        if numel(results_output) ~= 0
          fprintf(['results_output = ', num2str(results_output),' \n']);
        else
          fprintf('results_output = unknown \n');
        end	      
        fprintf('0 - prints results to screen \n');
        fprintf('1 - prints results, saves to matlab file and produces html \n');
        fprintf('2 - saves to matlab file and produces html \n');
      else
        results_output = val;
      end
            
    case 'method'
      if exist('val','var') == 0
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
      if numel(pseudodata_pets) ~= 0
        fprintf(['pseudodata_pets = ', num2str(pseudodata_pets),' \n']);
      else
        fprintf('pseudodata_pets = unknown \n');
      end
      if numel(results_output) ~= 0
        fprintf(['results_output = ', num2str(results_output),' \n']);
      else
        fprintf('results_output = unknown \n');
      end
      if numel(method) ~= 0
        fprintf(['method = ', method,' \n']);
        eval([method, 'regr_options;']);
      else
        fprintf('method = unknown \n');
      end
        
    otherwise % option 'other'
      if numel(method) ~= 0
        if exist('val','var') == 0
          eval([method, 'regr_options(key);']);
        else
          eval([method, 'regr_options(key, val);']);
        end
      else
        fprintf(['key ', key, ' is unkown \n\n']);
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
        if numel(pseudodata_pets) ~= 0
          fprintf(['pseudodata_pets = ', num2str(pseudodata_pets),' \n']);
        else
          fprintf('pseudodata_pets = unknown \n');
        end
        if numel(results_output) ~= 0
          fprintf(['results_output = ', num2str(results_output),' \n']);
        else
          fprintf('results_output = unknown \n');
        end
        fprintf('method = unknown \n');
      end

   end