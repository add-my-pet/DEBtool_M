%% garegr_options
% Sets options for function garegr 

%%
function garegr_options (key, val)
  %  created at 2006/05/28 by Bas Kooijman
  
  %% Syntax
  % <..garegr_options.m *garegr_options*> (key, val)
  
  %% Description
  % Sets options for function 'garegr' one by one;
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
  %   'max_step_number', default: 500
  %   'max_evol', default:50;
  %   'tol_fun', default: 1e-6;
  %   'popSize', default: 50;
  %   'startPop', default: [];
  %   'report', default: 1
  %
  % Output
  %
  % * no output, but globals are set to values or values are printed to screen
  
  %% Example of use
  % garegr_options('default'); garegr_options('report', 0)

  global popSize startPop tol_fun report max_step_number max_evol

  if ~exist('key', 'var')
    key = 'unkown';
  end
    
  switch key
	
   case 'default'
     report = 1;
     max_step_number = 500;
     max_evol = 50;
     tol_fun = 1e-6;
     popSize = 50;
     startPop = [];
     garegr_options

   case 'report'
     if ~exist('val', 'var')
       if numel(report) == 1
	 fprintf(['report = ', num2str(report),' \n']);  
       else
         fprintf('report = unknown \n');
       end	      
     else
       report = val;
     end

   case 'max_step_number'
     if ~exist('val', 'var')
       if numel(max_step_number) == 1
	 fprintf(['max_step_number = ', num2str(max_step_number),' \n']);  
       else
         fprintf('max_step_number = unknown \n');
       end	      
     else
       max_step_number = val;
     end

   case 'max_evol'
     if ~exist('val', 'var')
       if numel(max_evol) == 1
	 fprintf(['max_evol = ', num2str(max_evol),' \n']);
       else
	 fprintf('max_evol = unkown \n');
       end
     else
       max_evol = val;
     end

   case 'tol_fun'
     if ~exist('val', 'var')
       if numel(tol_fun) == 1
	 fprintf(['tol_fun = ', num2str(tol_fun),' \n']);
       else
	 fprintf('tol_fun = unknown \n');
       end
     else
       tol_fun = val;
     end
     
   case 'popSize'
     if ~exist('val', 'var')
       if  numel(popSize) == 1
	 fprintf(['popSize = ', num2str(popSize),' \n']);
       else
	 fprintf('popSize = unknown \n');
       end
     else
       popSize = val;
     end

   case 'startPop'
     if ~exist('val', 'var')
       if numel(startPop) == 1
	 fprintf(['startPop = ', num2str(startPop),' \n']);
       else
	 fprintf('startPop = unknown \n');
       end
     else
       popSize = val;
     end
	    
   otherwise 
     if numel(report) == 1
       fprintf(['report = ', num2str(report),' \n']);
     else
       fprintf('report = unknown \n');
     end	      
     if numel(max_step_number) == 1
       fprintf(['max_step_number = ', num2str(max_step_number),' \n']);
     else
       fprintf('max_step_number = unkown \n');
     end
     if numel(max_evol) == 1
       fprintf(['max_evol = ', num2str(max_evol),' \n']);
     else
       fprintf('max_evol = unkown \n');
     end
     if numel(tol_fun) == 1
       fprintf(['tol_fun = ', num2str(tol_fun),' \n']);
     else
       fprintf('tol_fun = unknown \n');
     end
     if numel(popSize) == 1
       fprintf(['popSize = ', num2str(popSize),' \n']);
     else
       fprintf('popSize = unknown \n');
     end
     if numel(startPop) == 1
       fprintf(['startPop = ', num2str(startPop),' \n']);
     else
       fprintf('startPop = unknown \n');
     end
   end
