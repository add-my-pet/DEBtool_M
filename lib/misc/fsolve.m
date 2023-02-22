%% fsolve
% find x for which 0 = func(x) using Nead-Melder simplex method

%%
function [x, fval, info] = fsolve(func, xin, opt, varargin)
% created by Bas Kooijman 2022/01/14

%% Syntax
% [x, fval, info] = <../fsolve.m *fsolve*> (func, x, varargin)

%% Description
% find the vector-valued x for which 0 = func(x), where func is a valid function name
%
% Input:
%
% * func: character string with name of function (without handle)
% * x: n-vector with initial values
% * opt: optional structure with iteration parameters (might be empty)
% * varargin: variables that are passed to function nm
%
% Output:
%
% * x: n-vector such that 0 = nm(x)
% * fval: n-vector of function values at x
% * info: boolean with success (1) or failure (0)
%
%% Remarks
% In case of failure, consider continuation: x = fsolve(nm, x0, vars); x = fsolve(nm, x, vars);
% For length(x)=1, fsolve resembles fzero, but uses another algorithm.
  
  n = length(xin); % number of variables to solve
    
  % set options if necessary
  if ~exist('opt','var') && ~isempty(opt);  vars_pull(opt); end
  if ~exist('max_step_number','var') || isempty(max_step_number)
    max_step_number = 1000 * n;
  end
  if ~exist('max_fun_evals','var') || isempty(max_fun_evals)
    max_fun_evals = 1000 * n;
  end
  if ~exist('tol_simplex','var') || isempty(tol_simplex)
    tol_simplex = 1e-10;
  end
  if ~exist('tol_fun','var') || isempty(tol_fun)
    tol_fun = 1e-10;
  end
  if ~exist('simplex_size','var') || isempty(simplex_size)
    simplex_size = 0.05;
  end
  if ~exist('report','var') || isempty(report)
    report = 0;
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = ones(1, n);
  n1 = n + 1;
  two2n1 = 2:n1;
  one2n = 1:n;

  % Set up a simplex near the initial guess.
  v(:,1) = xin;    % place input guess in the simplex
  fval(:,1) = feval(func, xin, varargin{:});
  fv(:,1) = sum(abs(fval(:,1)));
  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = simplex_size;         % 5 percent deltas for non-zero terms
  zero_term_delta = simplex_size/ 20; % Even smaller delta for zero elements
  for j = 1:n
    y = xin;
    if y(j) ~= 0
      y(j) = (1 + usual_delta) * y(j);
    else 
      y(j) = zero_term_delta;
    end  
    v(:,j+1) = y;
    fval(:,j+1) = feval(func, y, varargin{:});
    fv(1,j+1) = sum(abs(fval(:,j+1)));
  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j); fval = fval(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n + 1;
  if report == 1
    fprintf('step %0.4g lf %6.4g-%6.4g %s \n', itercount, min(fv), max(fv), how);
  end

  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals & itercount < max_step_number
    if max(max(abs(v(:,two2n1)-v(:,onesn)))) <= tol_simplex & ...
       max(abs(fv(1)-fv(two2n1))) <= tol_fun
      break
    end
    %how = '';
   
    % Compute the reflection point
   
    % xbar = average of the n (NOT n+1) best points
    xbar = sum(v(:,one2n), 2)/ n;
    xr = (1 + rho) * xbar - rho * v(:,n1);
    fvalr = feval(func, xr, varargin{:});
    fxr = sum(abs(fvalr));
    func_evals = func_evals + 1;
   
    if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho * chi) * xbar - rho * chi * v(:,n1);
      fvalxe = feval(func, xe, varargin{:});
      fxe = sum(abs(fvalxe));
      func_evals = func_evals + 1;
      
      if fxe < fxr
        v(:,n1) = xe;
        fv(:,n1) = fxe;
        how = 'expand';
      else
        v(:,n1) = xr; 
        fv(:,n1) = fxr;
        how = 'reflect';
      end
    else % fv(:,1) <= fxr
      if fxr < fv(:,n)
        v(:,n1) = xr; 
        fv(:,n1) = fxr;
        how = 'reflect';
      else % fxr >= fv(:,n) 
        % Perform contraction
        if fxr < fv(:,n1)
          % Perform an outside contraction
          xc = (1 + psi * rho) * xbar - psi * rho * v(:,n1);
          fvalxc = feval(func, xc, varargin{:});
          fxc = sum(abs(fvalxc));
          func_evals = func_evals + 1;
            
          if fxc <= fxr
            v(:,n1) = xc; 
            fv(:,n1) = fxc;
            fval(:,n1) = fvalxc;
            how = 'contract outside';
          else
            % perform a shrink
            how = 'shrink'; 
          end
        else
          % Perform an inside contraction
          xcc = (1 - psi) * xbar + psi * v(:,n1);
          fvalxcc = feval(func, xcc, varargin{:});
          fxcc = sum(abs(fvalxcc));
          func_evals = func_evals + 1;
            
          if fxcc < fv(:,n1)
            v(:,n1) = xcc;
            fv(:,n1) = fxcc;
            fval(:,n1) = fvalxcc;
            how = 'contract inside';
          else
            % perform a shrink
            how = 'shrink';
          end
        end
        if strcmp(how,'shrink')
          for j = two2n1
            v(:,j) = v(:,1) + sigma * (v(:,j) - v(:,1));
            fval(:,j) = feval(func, v(:,j), varargin{:});
            fv(:,j) = sum(abs(fval(:,j)));
          end
          func_evals = func_evals + n;
        end
      end
    end
    [fv,j] = sort(fv);
    v = v(:,j); fval = fval(:,j);
    itercount = itercount + 1;
    if report
      fprintf('step %0.4g lf %6.4g-%6.4g %s\n', itercount, min(fv), max(fv), how);
    end
  end   % while of main loop

  x = v(:,1); % copy best point to solution
  fval = fval(:,1); % output best function value
  fv = sum(abs(fval));
  
  if fv >=  tol_fun
    if report 
      fprintf('No convergence; function tolerance %6.4g exceeds limit %6.4g\n', fv, tol_n);
    end
    if func_evals >= max_fun_evals
      if report 
        fprintf('No convergence with %6.0g function evaluations\n', max_fun_evals);
      end
    elseif itercount >= max_step_number 
      if report 
        fprintf('No convergence with %6.0g steps\n', max_step_number);
      end
    end
    info = 0; 
  else
    if report 
      fprintf('Successful convergence\n');              
    end
    info = 1;
  end  
  