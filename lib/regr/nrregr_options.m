%% nrregr_options
% Sets options for function 'nrregr' one by one.
%% nrregr_options
% Sets options for function nrregr

%%
function nrregr_options (key, val)
  %  created at 2001/08/11 by Bas Kooijman
  
  %% Syntax
  % <../nrregr_options.m *nrregr_options*> (key, val)
  
  %% Description
  % Sets options for function <nrregr.html *nrregr*> one by one.
  % Type 'nrregr_options' to see values or
  %  type 'nrregr_options('default') to set options at default values
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
  %   'max_step_number', default: 10
  %   'max_step_size', default : 1e20
  %   'max_norm', default: 1e-8 
  %   'report', default: 1
  %
  % Output
  %
  % * no output, but globals are set to values or values are printed to screen

  %% Example of use
  % nrregr_options('default'); nrregr_options('report', 0)

    global max_step_number max_step_size max_norm report;

    if ~exist('key', 'var')
      key = 'unkown';
    end
     
    switch key
	
      case 'default'
	    max_step_number = 10;
	    max_step_size = 1e20;
	    max_norm = 1e-8;
	    report = 1;

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

      case 'max_step_size'
	    if ~exist('val','var')
	      if numel(max_step_size) ~= 0
	        fprintf(['max_step_size = ', num2str(max_step_size),' \n']);
	      else
	        printf('max_step_size = unkown \n');
	      end
	    else
	      max_step_size = val;
	    end

      case 'max_norm'
	    if ~exist('val','var')
	      if numel(max_norm) ~= 0
	        fprintf(['max_norm = ', num2str(max_norm),' \n']);
	      else
	        fprintf('max_norm = unknown \n');
	      end
	    else
	      max_norm = val;
	    end
	    
      case 'report'
	    if ~exist('val','var')
	      if numel(report) ~= 0
	        fprintf(['report = ', num2str(report),' \n']);
	      else
	        fprintf('report = unknown \n');
	      end
	    else
	      report = val;
	    end
	    
      otherwise 
	    if numel(max_step_number) ~= 0
          fprintf(['max_step_number = ', num2str(max_step_number),' \n']);
	    else
	      fprintf('max_step_number = unknown \n');
	    end	      
	    if numel(max_step_size) ~= 0
	      fprintf(['max_step_size = ', num2str(max_step_size),' \n']);
	    else
	      fprintf('max_step_size = unkown \n');
	    end
	    if numel(max_norm) ~= 0
	      fprintf(['max_norm = ', num2str(max_norm),' \n']);
	    else
	      fprintf('max_norm = unknown \n');
	    end
	    if numel(report) ~= 0
	      fprintf(['report = ', num2str(report),' \n']);
	    else
	      fprintf('report = unknown \n');
	    end
     end