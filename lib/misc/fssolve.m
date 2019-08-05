function [x, info] = fssolve(func, xin)
  %  created: 2001/08/20 by Bas Kooijman; modified 2007/08/08
  %
  %% Description
  %  sets a vector-valued function to zero
  %     using Nelder Mead's simplex method based on fminsearch of MatLab
  %
  %% Input
  %  func: string with name of user-defined function
  %     f = func (x) with
  %     x: k-vector with arguments; f: k-vector with function values
  %  xin: k-vector with intial estimates 
  %
  %% Output
  %  x:  k-vector with final estimates
  %  info: 1 if convergence has been successful; 0 otherwise
  %
  %% Remarks
  %  calls user-defined function 'func'
  %  set options with 'fssolve_options'

  global n
  global report max_step_nr max_fun_evals tol_simplex tol_fun

  n = max(size(xin));
  x = xin; % copy input to output
  
  %% set options if necessary
  if ~exist('max_step_nr','var')
    fssolve_options('max_step_nr', 200*n);
  end
  if ~exist('max_fun_evals','var')
    fssolve_options('max_fun_evals', 200*n);
  end
  if ~exist('tol_simplex','var')
    fssolve_options('tol_simplex', 1e-4);
  end
  if ~exist('tol_fun','var')
    fssolve_options('tol_fun', 1e-4);
  end
  if ~exist('report','var')
    fssolve_options('report', 1);
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = ones(1,n);
  two2np1 = 2:n+1;
  one2n = 1:n;
  np1 = n+1;

  % Set up a simplex near the initial guess.
  v = zeros(n,np1); fv = zeros(1, np1);
  v(:,1) = xin;    % Place input guess in the simplex
  eval(['f = ', func, '(x);']);
  fv(:,1) = f'*f;

  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = 0.05;             % 5 percent deltas for non-zero terms
  zero_term_delta = 0.00025;      % Even smaller delta for zero elements of x
  for j = 1:n
    y = xin;
    if y(j) ~= 0
      y(j) = (1 + usual_delta)*y(j);
    else 
      y(j) = zero_term_delta;
    end  
    v(:,j+1) = y;
    x = y;
    eval(['f = ', func, '(x);']);
    fv(1, j+1) = f'*f;
    
  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n+1;
  if report == 1
    fprintf(['step ', num2str(itercount), ' function ', num2str(min(fv)), '-', ...
	    num2str(max(fv)), ' ', how, '\n']);
  end
  info = 1;

  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals & itercount < max_step_nr
    if max(max(abs(v(:,two2np1)-v(:,onesn)))) <= tol_simplex & ...
       max(abs(fv(1)-fv(two2np1))) <= tol_fun
    break
  end
  how = '';
   
  % Compute the reflection point
   
  % xbar = average of the n (NOT n+1) best points
  xbar = sum(v(:,one2n), 2)/n;
  xr = (1 + rho)*xbar - rho*v(:,np1);
  x = xr;
  eval(['f = ', func, '(x);']);
  fxr = f'*f;
  func_evals = func_evals+1;
   
   if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho*chi)*xbar - rho*chi*v(:,np1);
      x = xe;
      eval(['f = ', func, '(x);']);
      fxe = f'*f;
      func_evals = func_evals+1;
      if fxe < fxr
         v(:,np1) = xe;
         fv(:,np1) = fxe;
         how = 'expand';
      else
         v(:,np1) = xr; 
         fv(:,np1) = fxr;
         how = 'reflect';
      end
   else % fv(:,1) <= fxr
      if fxr < fv(:,n)
         v(:,np1) = xr; 
         fv(:,np1) = fxr;
         how = 'reflect';
      else % fxr >= fv(:,n) 
         % Perform contraction
         if fxr < fv(:,np1)
            % Perform an outside contraction
            xc = (1 + psi*rho)*xbar - psi*rho*v(:,np1);
            x = xc;
	    eval(['f = ', func, '(x);']);
	    fxc = f'*f;
            func_evals = func_evals+1;
            
            if fxc <= fxr
               v(:,np1) = xc; 
               fv(:,np1) = fxc;
               how = 'contract outside';
            else
               % perform a shrink
               how = 'shrink'; 
            end
         else
            % Perform an inside contraction
            xcc = (1-psi)*xbar + psi*v(:,np1);
            x = xcc;
	    eval(['f = ', func, '(x);']);
	    fxcc = f'*f;
            func_evals = func_evals+1;
            
            if fxcc < fv(:,np1)
               v(:,np1) = xcc;
               fv(:,np1) = fxcc;
               how = 'contract inside';
            else
               % perform a shrink
               how = 'shrink';
            end
         end
         if strcmp(how,'shrink')
            for j=two2np1
               v(:,j)=v(:,1)+sigma*(v(:,j) - v(:,1));
               x = v(:,j);
               eval(['f = ', func, '(x);']);
	       fv(:,j) = f'*f;
            end
            func_evals = func_evals + n;
         end
      end
   end
   [fv,j] = sort(fv);
   v = v(:,j);
   itercount = itercount + 1;
   if report == 1
     fprintf(['step ', num2str(itercount), ' function ', num2str(min(fv)), ...
	     '-', num2str(max(fv)), ' ', how, '\n']);
   end  
   end   % while


   x = v(:,1);

   fval = min(fv); 
   if func_evals >= max_fun_evals
     if report > 0
       fprintf(['No convergences with ', \
		num2str(max_fun_evals), ' function evaluations\n']);
     end
     info = 0;
   elseif itercount >= max_step_nr 
     if report > 0
       fprintf(['No convergences with ', num2str(max_step_nr), ' steps\n']);
     end
     info = 0; 
   else
     if report > 0
       fprintf(['Successful convergence \n']);              
     end
     info = 1;
   end
