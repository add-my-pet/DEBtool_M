%% nmvcregr2
% Calculates ml estimates using Nelder Mead's simplex method for bivariate data and constant variation coefficient

%%
function [q, info] = nmvcregr2(func, p, x, y, Z, W)
  % created: 2004/04/05 by Bas Kooijman; corrected 2005/02/18, 2007/08/09
  
  %% Syntax
  % [q, info] = <../nmvcregr2.m *nmvcregr2*>(func, p, x, y, Z, W)
  
  %% Description
  % Calculates ml estimates using Nelder Mead's simplex method for bivariate data and constant variation coefficient
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, x, y) with p: np-vector; x: nx-vector; y: ny-vector
  %     f: (nx,ny)-matrix with model-predictions for dependent variable
  %
  % * p: (np,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * x: (nx,1)-vector with first independent variable
  % * y: (ny,1)-vector with second independent variable
  % * Z: (nx,ny)-matrix with dependent variable
  % * W: (nx,ny)-matrix with weight coefficients (optional)
  %
  % Output
  %
  % * q: matrix like p, but with least squares estimates
  % * info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % Salls nrdregr2, and user-defined function 'func'.
  % Set options with <nrregr_options.html *nrregr_options*>.
  % Similar to <nmregr2.html *nmregr2*>, but standard deviation proportional to mean

  global n;
  global report max_step_number max_fun_evals tol_simplex tol_fun; % option settings

  q = p; % copy input into output
  info = 1; % convergence has been successful
  
  [np k] = size(p); % np is number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  n = max(size(index)); % n is number of parameters that must be iterated
  if (n == 0)
    return; % no parameters to iterate
  end

  [nx ny] = size(Z); % nx,ny is number of values of dependent variables
  nxy = nx * ny; % total number of data points
  if exist('W') ~= 1
    W = ones(nx, ny);
  end

  size_x = size(x); size_y = size(y);
  if 2 ~= sum([nx ny]==size(W)) | nx ~= size_x(1) | ...
	ny ~= size_y(1)
    fprintf('sizes of arguments do not match \n');
    return;
  end

  W = W/sum(sum(W)); % scale weight coefficients

  options_exist; % make sure that options exist
  % set options if necessary
  if numel(max_step_number) == 0  
    nmregr_options('max_step_number', 200*n);
  end
  if numel(max_fun_evals) == 0 
    nmregr_options('max_fun_evals', 200*n);
  end
  if numel(tol_simplex) == 0 
    nmregr_options('tol_simplex', 1e-4);
  end
  if numel(tol_fun) == 0
    nmregr_options('tol_fun', 1e-4);
  end
  if  numel(report) == 0
    nmregr_options('report', 1);
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = ones(1,n);
  two2np1 = 2:n+1;
  one2n = 1:n;
  np1 = n+1;

  % Set up a simplex near the initial guess.
  v = zeros(n,np1); fv = zeros(1,np1);
  v(:,1) = xin = q(index,1);    % Place input guess in the simplex
  eval(['F = ', func, '(q(:,1), x, y);']);
  vc2 = sum(sum(W.*(Z./F-1).^2)); % squared variation coefficient
  fv(:,1) = sum(sum(W.* log(max(1e-8,F)))) + log(vc2)/2;
  
  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = 0.05;             % 5 percent deltas for non-zero terms
  zero_term_delta = 0.00025;      % Even smaller delta for zero elements of q
  for j = 1:n
    s = xin;
    if s(j) ~= 0
      s(j) = (1 + usual_delta)*s(j);
    else 
      s(j) = zero_term_delta;
    end  
    v(:,j+1) = s;
    q(index,1) = s;
    eval(['F = ', func, '(q(:,1), x, y);']);
    vc2 = sum(sum(W.*(Z./F-1).^2)); % squared variation coefficient
    fv(1,j+1) = sum(sum(W.* log(max(1e-8,F)))) + log(vc2)/2;

  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n+1;
  if report == 1
    fprintf(['step ', num2str(itercount), ' ssq ', num2str(min(fv)), '-', \
	    num2str(max(fv)), ' ', how,'\n']);
  end
  info = 1;
 
  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals & itercount < max_step_number
    if max(max(abs(v(:,two2np1)-v(:,onesn)))) <= tol_simplex & ...
       max(abs(fv(1)-fv(two2np1))) <= tol_fun
    break
  end
  how = '';
   
  % Compute the reflection point
   
  % xbar = average of the n (NOT n+1) best points
  xbar = sum(v(:,one2n), 2)/n;
  xr = (1 + rho)*xbar - rho*v(:,np1);
  q(index,1) = xr;
  eval(['F = ', func, '(q(:,1), x, y);']);
  vc2 = sum(sum(W.*(Z./F-1).^2)); % squared variation coefficient
  fxr = sum(sum(W.* log(max(1e-8,F)))) + log(vc2)/2;
  func_evals = func_evals+1;
   
   if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho*chi)*xbar - rho*chi*v(:,np1);
      q(index,1) = xe;
      eval(['F = ', func, '(q(:,1), x, y);']);
      vc2 = sum(sum(W.*(Z./F-1).^2)); % squared variation coefficient
      fxe = sum(sum(W.* log(max(1e-8,F)))) + log(vc2)/2;
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
	    eval(['F = ', func, '(q(:,1), x, y);']);
            vc2 = sum(sum(W.*(Z./F-1).^2)); % squared variation coefficient
            fxc = sum(sum(W.* log(max(1e-8,F)))) + log(vc2)/2;
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
	    eval(['F = ', func, '(q(:,1), x, y);']);
            vc2 = sum(sum(W.*(Z./F-1).^2)); % squared variation coefficient
            fxcc = sum(sum(W.* log(max(1e-8,F)))) + log(vc2)/2;
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
               eval(['F = ', func, '(q(:,1), x, y);']);
               vc2 = sum(sum(W.*(Z./F-1).^2)); % squared variation coefficient
               fv(:,j) = sum(sum(W.* log(max(1e-8,F)))) + log(vc2)/2;
            end
            func_evals = func_evals + n;
         end
      end
   end
   [fv,j] = sort(fv);
   v = v(:,j);
   itercount = itercount + 1;
   if report == 1
     fprintf(['step ', num2str(itercount), ' ln div ', num2str(min(fv)), '-', \
	     num2str(max(fv)), ' ', how, '\n']);
   end  
   end   % while


   q(index,1) = v(:,1);

   fval = min(fv); 
   if func_evals >= max_fun_evals
     if report > 0
       fprintf(['No convergences with ', \
		num2str(max_fun_evals), ' function evaluations\n']);
     end
     info = 0;
   elseif itercount >= max_step_number 
     if report > 0
       fprintf(['No convergences with ', num2str(max_step_number), ' steps\n']);
     end
     info = 0; 
   else
     if report > 0
       fprintf('Successful convergence \n');
     end
     info = 1;
   end
