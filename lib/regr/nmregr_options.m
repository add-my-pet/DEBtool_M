%% nmregr_options
% Sets options for function <nmregr.html *nmregr*>

%%
function nmregr_options (key, val)
  %  created at 2002/02/10 by Bas Kooijman; modified 2015/01/16, 2015/02/27 Goncalo Marques
  
  %% Syntax
  % <../nmregr_options .m *nmregr_options*> (key, val)
  
  %% Description
  % Sets options for function 'nmregr' one by one
  %
  % Input
  %
  % * no input: print values to screen
  % * one input: 
  %
  %    'default' sets options at default values
  %    other keys (see below) to print value to screen
  %
  % * two inputs
  %
  %    'report': 1 - to report steps to screen; 0 - not to;
  %    'max_step_number': maximum number of steps 
  %    'max_fun_evals': maximum number of function evaluations
  %    'tol_simplex': tolerance for how close the simplex points must be
  %       together to call them the same
  %    'tol_tun': tolerance for how close the loss-function values must be
  %       together to call them the same
  %
  % Output
  %
  % * no output, but globals are set to values or values printed to screen
  
  %% Example of use
  % nmregr_options('default'); nmregr_options('report', 0)

    global report max_step_number max_fun_evals tol_simplex tol_fun
 
    if ~exist('key','var')
      key = 'inexistent';
    end
 
    switch key
	
      case 'default'
	    report = 1;
	    max_step_number = 500;
	    max_fun_evals = 2000;
	    tol_simplex = 1e-4;
	    tol_fun = 1e-4;

      case 'report'
	    if exist('val','var') == 0
	      if numel(report) ~= 0
	        fprintf(['report = ', num2str(report),' \n']);  
	      else
            fprintf('report = unknown \n');
	      end	      
	    else
	      report = val;
	    end

      case 'max_step_number'
	    if ~exist('val','var')
	      if numel(max_step_number) ~= 0
	        fprintf(['max_step_number = ', num2str(max_step_number),' \n']);  
	      else
            fprintf('max_step_number = unknown \n');
	      end	      
	    else
	      max_step_number = val;
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
	    end

      case 'tol_simplex'
	    if ~exist('val','var')
	      if numel(tol_simplex) ~= 0
	        fprintf(['tol_simplex = ', num2str(tol_simplex),' \n']);
	      else
	        fprintf('tol_simplex = unknown \n');
	      end
	    else
	      tol_simplex = val;
	    end
	    
      case 'tol_fun'
	    if ~exist('val','var') 
	      if numel(tol_fun) ~= 0
	        fprintf(['tol_fun = ', num2str(tol_fun),' \n']);
	      else
	        fprintf('tol_fun = unknown \n');
	      end
	    else
	      tol_fun = val;
        end
        
      otherwise
        if ~strcmp(key, 'inexistent')   
            fprintf(['key ', key, ' is unkown \n\n']);
        end
	    if numel(report) ~= 0
          fprintf(['report = ', num2str(report),' \n']);
	    else
	      fprintf('report = unknown \n');
	    end	      
	    if numel(max_step_number) ~= 0
	      fprintf(['max_step_number = ', num2str(max_step_number),' \n']);
	    else
	      fprintf('max_step_number = unkown \n');
	    end
	    if numel(max_fun_evals) ~= 0
	      fprintf(['max_fun_evals = ', num2str(max_fun_evals),' \n']);
	    else
	      fprintf('max_fun_evals = unkown \n');
	    end
	    if numel(tol_simplex) ~= 0
	      fprintf(['tol_simplex = ', num2str(tol_simplex),' \n']);
	    else
	      fprintf('tol_simplex = unknown \n');
	    end
	    if numel(tol_fun) ~= 0
	      fprintf(['tol_fun = ', num2str(tol_fun),' \n']);
	    else
	      fprintf('tol_fun = unknown \n');
	    end
     end