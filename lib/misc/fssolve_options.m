function fssolve_options (key, val)
  %  created at 2001/08/20 by Bas Kooijman
  %  sets options for function 'fssolve' one by one
  %  type 'fssolve_options' to see values or
  %  type 'fssolve_options('default') to set options at default values

  global report max_step_nr max_fun_evals tol_simplex tol_fun;
  global n;

    if exist('key') == 0
      key = 'unkown';
    end

    options = {'default'; 'report'; 'max_step_nr'; ...
	       'max_fun_evals'; 'tol_simplex'; 'tol_fun'; 'unkown'; key};
    [nr nc ] = size(options); [nc, nk] = size(key);
    for i = 1:(nc-2) % determine the option number 
      opt = options{i}; [nc, ns] = size(opt);
      if nk == sum(key == opt(min(ns,1:nk)));
	opt_nr = i;
	break;   
      end		   
    end
    if exist('opt_nr') == 0 % option is 'other'
      opt_nr = nc-1;
    end
    
    switch opt_nr
	
      case 1 % option 'default'
	report = 1;
	max_step_nr = 200*n;
	max_fun_evals = 200*n;
	tol_simplex = 1e-4;
	tol_fun = 1e-4;
	nmregr_options;

      case 2 % option 'report'
	if exist('val') == 0
	  if exist('report') == 1
	    fprintf(['report = ', num2str(max_step_nr),' \n']);  
	  else
            fprintf('report = unknown \n');
	  end	      
	else
	  report = val;
	end

      case 3 % option 'max_step_nr'
	if exist('val') == 0
	  if exist('max_step_nr') == 1
	    fprintf(['max_step_nr = ', num2str(max_step_nr),' \n']);  
	  else
            fprintf('max_step_nr = unknown \n');
	  end	      
	else
	  max_step_nr = val;
	end

      case 4 % option 'max_fun_evals'
	if exist('val') == 0
	  if exist('max_fun_evals') == 1
	    fprintf(['max_fun_evals = ', num2str(max_step_size),' \n']);
	  else
	    fprintf('max_fun_evals = unkown \n');
	  end
	else
	  max_fun_evals = val;
	end

      case 5 % option 'tol_simplex'
	if exist('val') == 0
	  if exist('tol_simplex') == 1
	    fprintf(['tol_simplex = ', num2str(max_norm),' \n']);
	  else
	    fprintf('tol_simplex = unknown \n');
	  end
	else
	  tol_simplex = val;
	end
	    
      case 6 % option 'tol_fun'
	if exist('val') == 0
	  if exist('tol_fun') == 1
	    fprintf(['tol_fun = ', num2str(report),' \n']);
	  else
	    fprintf('tol_fun = unknown \n');
	  end
	else
	  tol_fun = val;
	end
	    
      otherwise % option 'other'
	if exist('report') == 1
          fprintf(['report = ', num2str(report),' \n']);
	else
	  fprintf('report = unknown \n');
	end	      
	if exist('max_step_nr') == 1
	  fprintf(['max_step_nr = ', num2str(max_step_nr),' \n']);
	else
	  fprintf('max_step_nr = unkown \n');
	end
	if exist('max_fun_evals') == 1
	  fprintf(['max_fun_evals = ', num2str(max_fun_evals),' \n']);
	else
	  fprintf('max_fun_evals = unkown \n');
	end
	if exist('tol_simplex') == 1
	  fprintf(['tol_simplex = ', num2str(tol_simplex),' \n']);
	else
	  fprintf('tol_simplex = unknown \n');
	end
	if exist('tol_fun') == 1
	  fprintf(['tol_fun = ', num2str(tol_fun),' \n']);
	else
	  fprintf('tol_fun = unknown \n');
	end
     end	
