%% nmfzero
% Solves a uni-variate function using Nelder Mead's simplex method

%%
function [q, info] = nmfzero(hfunc, p, varargin)
  % created 2019/07/25 by Bas Kooijman
  
  %% Syntax
  % [q, info] = <../nmfzero.m *nmfzero*> (hfunc, p, varargin)
  
  %% Description
  % Solves a uni-variate function using Nelder Mead's simplex method
  %
  % Input
  %
  % * hfunc: function handle of user-defined function
  %
  %     f = func (p, varargin) with
  %     p: initial value for variable that is to be solved
  %     value = func (p, varargin)
  %
  % * p: scalar
  % * varargin: optional parameters
  %
  % Output
  %
  % * q: scalar: with solution
  % * info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % Calls user-defined function 'func'
  % Set options with <nmregr_options.html *nmregr_options*>
  % Similar to fzero, but here using simplex method

  %% Example of use
  % See <../mydata_nmfzero.m *mydata_nmfzero*>

  global report max_step_number max_fun_evals tol_simplex tol_fun
  
  q = p; % copy input parameter to output
  info = 1; % convergence has been successful
  
  % set options if necessary
  if ~exist('max_step_number','var') || isempty(max_step_number)
    nmregr_options('max_step_number', 200);
  end
  if ~exist('max_fun_evals','var') || isempty(max_fun_evals)
    nmregr_options('max_fun_evals', 200);
  end
  if ~exist('tol_simplex','var') || isempty(tol_simplex)
    nmregr_options('tol_simplex', 1e-4);
  end
  if ~exist('tol_fun','var') || isempty(tol_fun)
    nmregr_options('tol_fun', 1e-4);
  end
  if ~exist('report','var') || isempty(report)
    nmregr_options('report', 1);
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;

  % Set up a simplex near the initial guess.
  v = zeros(1, 2); fv = zeros(1, 2); 
  v(1,1) = q; fv(1,1) = hfunc(q, varargin{:})^2;
  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = 0.05;             % 5 percent deltas for non-zero terms
  zero_term_delta = 0.00025;      % Even smaller delta for zero element of q
  p = q;
  if p ~= 0
    p = (1 + usual_delta) * p;
  else 
    p = zero_term_delta;
  end  
  v(1,2) = p; fv(1,2) =  hfunc(p, varargin{:})^2;

  % sort so v(1,1) has the lowest function value 
  [fv, j] = sort(fv); v = v(:,j); q = v(1);


  how = 'initial';
  itercount = 1;
  func_evals = 2;
  if report == 1
    fprintf(['step ', num2str(itercount), ' var ', num2str(q), ...
        ' val^2 ', num2str(fv(1)), '-', num2str(fv(2)), ' ', how, '\n']);
  end

  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals && itercount < max_step_number
    if abs(v(1,1) - v(1,2)) <= tol_simplex && abs(fv(1)) <= tol_fun
      break
    end
    how = '';
   
    % Compute the reflection point
   
    xr = (1 + rho) * v(1) - rho * v(2);
    q = xr;
    fxr = hfunc(q, varargin{:})^ 2;
    func_evals = func_evals + 1;
   
    if fxr < fv(1)
      % Calculate the expansion point
      xe = (1 + rho * chi) * v(1) - rho * chi * v(2);
      q = xe;
      fxe = hfunc(q, varargin{:})^2;
      func_evals = func_evals + 1;
      if fxe < fxr
        v(2) = xe;
        fv(2) = fxe;
        how = 'expand';
      else
        v(2) = xr; 
        fv(2) = fxr;
        how = 'reflect';
      end
    else % fv(1) <= fxr
      if fxr < fv(1)
        v(2) = xr; 
        fv(2) = fxr;
        how = 'reflect';
      else % fxr >= fv(1) 
        % Perform contraction
        if fxr < fv(2)
          % Perform an outside contraction
          xc = (1 + psi * rho) * v(1) - psi * rho * v(2);
          q = xc;
          fxc = hfunc(q, varargin{:})^2;
          func_evals = func_evals + 1;
            
          if fxc <= fxr
            v(2) = xc; 
            fv(2) = fxc;
            how = 'contract outside';
          else
            % perform a shrink
            how = 'shrink'; 
          end
        else
          % Perform an inside contraction
          xcc = (1 - psi) * v(1) + psi * v(2);
          q = xcc;
          fxcc = hfunc(q, varargin{:})^2;
          func_evals = func_evals + 1;
            
          if fxcc < fv(2)
            v(2) = xcc;
            fv(2) = fxcc;
            how = 'contract inside';
          else
            % perform a shrink
            how = 'shrink';
          end
        end
        if strcmp(how,'shrink')
          v(2) = v(1) + sigma * (v(2) - v(1));
          q = v(2);
          fv(2) = hfunc(q, varargin{:})^2;
          func_evals = func_evals + 1;
        end
      end
    end
    [fv,j] = sort(fv); v = v(:,j); 
    itercount = itercount + 1;
    if report == 1
      fprintf(['step ', num2str(itercount), ' var ', num2str(q), ...
         ' val^2 ', num2str(fv(1)), '-', num2str(fv(2)), ' ', how, '\n']);
    end  
  end   % while of main loop

  q = v(1); fval = fv(1); 
  if func_evals >= max_fun_evals
    if report > 0
      fprintf(['No convergence with ', ...
      num2str(max_fun_evals), ' function evaluations\n']);
    end
    info = 0;
  elseif itercount >= max_step_number 
    if report > 0
      fprintf(['No convergence with ', num2str(max_step_number), ' steps\n']);
    end
    info = 0; 
  elseif  abs(v(1,1) - v(1,2)) > tol_simplex 
    if report > 0
      fprintf(['No convergence with tol_simplex ', num2str(abs(v(1,1) - v(1,2))), '\n']);
    end
    info = 0; 
  elseif abs(fv(1)) > tol_fun
    if report > 0
      fprintf(['No convergence with tol_fun ', num2str(abs(fv(1) - fv(2))), '\n']);
    end
    info = 0; 
  else
    if report > 0
      fprintf('Successful convergence \n');              
    end
    info = 1;
  end
