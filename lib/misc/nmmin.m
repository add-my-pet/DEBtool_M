%% nmmin
% Find min of a function using Nelder Mead's simplex method

%%
function [q, info] = nmmin(func, p,  varargin)
  %  created: 2001/08/20 by Bas Kooijman; modified 2009/09/29

  %% Syntax
  % [q, info] = <../nmmin.m *nmmin*> (func, p,  varargin)

  %% Description
  % Find min using Nelder Mead's simplex method
  %
  % Input:
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, xyw) with
  %       p: k-vector with parameters; xyw: (n,c)-matrix; f: n-vector
  %       [f1, f2, ...] = func (p, x1, x2, ...) with  p: k-vector  and
  %       xi: fixed parameters; fi: scalar function to be minimized
  %
  % * p: (k,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * xi (read as x1, x2, .. ): matrix with fixed parameters
  %
  % Output:
  %
  % * q: matrix like p, but parameters for which f's are minimal
  % * info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % Calls user-defined function 'func';
  % set options with 'nmregr_options'

  global n;
  global report max_step_nr max_fun_evals tol_simplex tol_fun;
  % option settings

  i = 1; % initiate data set counter
  ci = num2str(i); % character string with value of i
  ndat = nargin -1; % initial 'while' condition (will count down)
  nxyw = ndat -1; % number of data sets
  va_start (); % set pointer to first unnamed argument
  while (--ndat) % loop across data sets
    eval(['x', ci, ' = va_arg();']); % assing unnamed arguments to xi
    eval(['[N(', ci, ') k] = size(x', ci, ');']); % number of data points
    if i == 1
      listx = ['x', ci,',']; % initiate list x
      listf = ['f', ci,',']; % initiate list f
    else     
      listf = [listf, ' f', ci,',']; % append list f
      listx = [listx, ' xyw', ci,',']; % append list x
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end
  [i nl] = size(listx); listx = listx(1:(nl-1)); % remove last ','
  [i nl] = size(listf); listf = listf(1:(nl-1)); % remove last ','

  q = p; % copy input parameter matrix into output
  info = 1; % convergence has been successful

  [np k] = size(p); % k: number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  n = max(size(index));  % n: number of parameters that must be iterated
  if (n == 0)
    return; % no parameters to iterate
  end
  
  % set options if necessary
  if exist('max_step_nr','var')==0 
    nmregr_options('max_step_nr', 200*n);
  end
  if exist('max_fun_evals','var')==0 
    nmregr_options('max_fun_evals', 200*n);
  end
  if exist('tol_simplex','var')==0 
    nmregr_options('tol_simplex', 1e-4);
  end
  if exist('tol_fun','var')==0
    nmregr_options('tol_fun', 1e-4);
  end
  if exist('report','var')==0
    nmregr_options('report', 1);
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = ones(1,n);
  two2np1 = 2:n+1;
  one2n = 1:n;
  np1 = n+1;

  % Set up a simplex near the initial guess.
  v = zeros(n,np1); fv = zeros(1, np1);
  v(:,1) = q(index,1);    % Place input guess in the simplex
  xin = v(:,1);
  eval(['[',listf, '] = ', func, '(q(:,1),', listx, ');']);
  eval(['fv(:,1) = sum(', listf, ');']);

  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = 0.05;             % 5 percent deltas for non-zero terms
  zero_term_delta = 0.00025;      % Even smaller delta for zero elements of q
  for j = 1:n
    y = xin;
    if y(j) ~= 0
      y(j) = (1 + usual_delta)*y(j);
    else 
      y(j) = zero_term_delta;
    end  
    v(:,j+1) = y;
    q(index,1) = y;
    eval(['[', listf, '] = ', func, '(q(:,1), ', listx, ');']);
    eval(['fv(1,j+1) = sum(', listf, ');']);

  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n+1;
  if report == 1
    fprintf(['step ', num2str(itercount), ' value ', num2str(min(fv)), '-', ...
	    num2str(max(fv)), ' ', how, '\n']);
  end
  info = 1;

  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals && itercount < max_step_nr
    if max(max(abs(v(:,two2np1)-v(:,onesn)))) <= tol_simplex && ...
       max(abs(fv(1)-fv(two2np1))) <= tol_fun
    break
  end
  how = '';
   
  % Compute the reflection point
   
  % xbar = average of the n (NOT n+1) best points
  xbar = sum(v(:,one2n)')'/n;
  xr = (1 + rho)*xbar - rho*v(:,np1);
  q(index,1) = xr;
  eval(['[', listf, '] = ', func, '(q(:,1), ', listx, ');']);
  eval(['fxr = sum(', listf, ');']);
  func_evals = func_evals+1;
   
   if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho*chi)*xbar - rho*chi*v(:,np1);
      q(index,1) = xe;
      eval(['[', listf, '] = ', func, '(q(:,1), ', listx, ');']);
      eval(['fxe = sum(', listf, ');']);
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
            q(index,1) = xc;
	    eval(['[', listf, '] = ', func, '(q(:,1), ', listx, ');']);
	    eval(['fxc = sum(', listf, ');']);
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
            q(index,1) = xcc;
	    eval(['[', listf, '] = ', func, '(q(:,1), ', listx, ');']);
	    eval(['fxcc = sum(', listf, ');']);
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
               q(index,1) = v(:,j);
               eval(['[', listf, '] = ', func, '(q(:,1), ', listx, ');']);
               eval(['fv(:,j) = sum(', listf, ');']);
            end
            func_evals = func_evals + n;
         end
      end
   end
   [fv,j] = sort(fv);
   v = v(:,j);
   itercount = itercount + 1;
   if report == 1
     fprintf(['step ', num2str(itercount), ' value ', num2str(min(fv)), ...
	     '-', num2str(max(fv)), ' ', how, '\n']);
   end  
   end   % while


   q(index,1) = v(:,1);

   fval = min(fv); 
   if func_evals >= max_fun_evals
     if report > 0
       fprintf(['No convergences with ', ...
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
       fprintf('Successful convergence \n');              
     end
     info = 1;
   end
