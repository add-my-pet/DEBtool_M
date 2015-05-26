%% nmvcregr
% Calculates ml estimates using Nelder Mead's simplex method with constant variation coefficient

%%
function [q, info] = nmvcregr(func, p, varargin)
  %  created: 2004/04/05 by Bas Kooijman; corrected 2005/02/18; 2005/03/09
  %
  %% Syntax
  % [q, info] = <..nmvcregr.m *nmvcregr*>(func, p, varargin)
  
  %% Description
  % Calculates ml estimates using Nelder Mead's simplex method with constant variation coefficient
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, xyw) with
  %       p: k-vector with parameters; xyw: (n,c)-matrix; f: n-vector
  %     [f1, f2, ...] = func (p, xyw1, xyw2, ...) with  p: k-vector  and
  %      xywi: (ni,k)-matrix; fi: ni-vector with model predictions
  %     The dependent variable in the output f; For xyw see below.
  %
  % * p: (k,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * xyzi (read as xyw1, xyw2, .. ): (ni,3) matrix with
  %
  %     xywi(:,1) independent variable i
  %     xywi(:,2) dependent variable i
  %     xywi(:,3) weight coefficients i (optional)
  %     xywi(:,>3) data-pont specific information data (optional)
  %     The number of data matrices xyw1, xyw2, ... is optional but >0
  %
  % Output
  %
  %  q: matrix like p, but with ml estimates
  %  info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % Calls user-defined function 'func'.
  % Set options with <nmregr_options.html *nmregr_options*>.
  % Similar to <nmregr.html *nmregr*>, but standard deviation proportional to mean
  
  global n;
  global report max_step_number max_fun_evals tol_simplex tol_fun; % option settings

  i = 1; % initiate data set counter
  ci = num2str(i); % character string with value of i
  nxyw = nargin - 2; % number of data sets
  while (i <= nxyw) % loop across data sets
    if i == 1
      listxyw = ['xyw', ci,',']; % initiate list xyw
      listx = ['xyw', ci]; % initiate list xyw for global declaration
      listf = ['f', ci,',']; % initiate list f
      listg = ['g', ci,',']; % initiate list g
    else     
      listxyw = [listxyw, ' xyw', ci,',']; % append list xyw
      listx = [listx, ' xyw', ci]; % append list xyw for global declaration
      listf = [listf, ' f', ci,',']; % append list f
      listg = [listg, ' g', ci,',']; % append list g
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end
  [i, nl] = size(listxyw); listxyw = listxyw(1:(nl-1)); % remove last ','
  [i, nl] = size(listf); listf = listf(1:(nl-1)); % remove last ','
  [i, nl] = size(listg); listg = listg(1:(nl-1)); % remove last ','

  global_txt = strrep(['global ', listxyw], ',', ' ');
  eval(global_txt); % make data sets global

  i = 1; N = zeros(nxyw, 1); % initiate data counter
  ci = num2str(i); % character string with value of i
  while (i <= nxyw) % loop across data sets
    eval(['xyw', ci, ' = varargin{',ci,'};']); % assing unnamed arguments to xywi
    eval(['[N(', ci, '), k] = size(xyw', ci, ');']); % number of data points
    if i == 1
      eval(['Y = xyw',ci,'(:,2);']); % initiate dependent variables
      if k > 2
	    eval(['W = xyw',ci,'(:,3);']); % initiate weight coefficients
      else
	    W = ones(N(1),1);
      end
    else     
      eval(['Y = [Y;xyw', ci, '(:,2)];']); % append dependent variables
      if k > 2
	    eval(['W = [W;xyw', ci, '(:,3)];']); % append weight coefficients
      else
	    W = [W; ones(N(i),1)]; % append weight coefficients
      end
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end

  q = p;         % copy input parameter matrix into output
  info = 1;      % convergence has been successful
  N = sum(N);    % total number of data points in all samples
  W = W/ sum(W); % sum of weight coefficients set equal to 1

  [np k] = size(p); % k: number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  n = max(size(index));  % n: number of parameters that must be iterated
  if (n == 0)
    return; % no parameters to iterate
  end

  % options_exist; % make sure that options exist
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
  if numel(report) == 0
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
  v(:,1) = q(index,1); xin = q(index,1); % Place input guess in the simplex
  eval(['[',listf, '] = ', func, '(q(:,1),', listxyw, ');']);
  eval(['F = max(1e-8, cat(1, ', listf,'));']);
  vc2 = max(1e-8,W'*(Y./F-1).^2); % squared variation coefficient
  fv(:,1) = W'* log(F) + log(vc2)/2;
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
    eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
    eval(['F = max(1e-8,cat(1, ', listf,'));']);
    vc2 = max(1e-8,W'*(Y./F-1).^2); % squared variation coefficient
    fv(1,j+1) = W'* log(F) + log(vc2)/2;
  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n+1;
  if report == 1
    fprintf(['step ', num2str(itercount), ' ln div ', num2str(min(fv)), '-', ...
	    num2str(max(fv)), ' ', how, '\n']);
  end
  info = 1;

  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals && itercount < max_step_number
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
  eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
  eval(['F = max(1e-8, cat(1, ', listf,'));']);
  vc2 = max(1e-8, W'*(Y./F-1).^2); % squared variation coefficient
  fxr = W'* log(F) + log(vc2)/2;
  func_evals = func_evals+1;
   
   if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho*chi)*xbar - rho*chi*v(:,np1);
      q(index,1) = xe;
      eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
      eval(['F = max(1e-8, cat(1, ', listf,'));']);
      vc2 = max(1e-8, W' * (Y./ F - 1) .^ 2); % squared variation coefficient
      fxe = W'* log(F) + log(vc2)/ 2;
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
	    eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
            eval(['F = max(1e-8, cat(1, ', listf,'));']);
            vc2 = max(1e-8, W' * (Y ./ F - 1) .^ 2); % squared variation coefficient
            fxc = W' * log(F) + log(vc2)/ 2;
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
	    eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
            eval(['F = max(1e-8, cat(1, ', listf,'));']);
            vc2 = max(1e-8, W' * (Y ./ F-1) .^ 2); % squared variation coefficient
            fxcc = W' * log(F) + log(vc2)/ 2;
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
               eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
               eval(['F = max(1e-8, cat(1, ', listf,'));']);
               vc2 = max(1e-8, W'*(Y./F-1).^2); % squared variation coefficient
               fv(:,j) = W'* log(F) + log(vc2)/2;
            end
            func_evals = func_evals + n;
         end
      end
   end
   [fv,j] = sort(fv);
   v = v(:,j);
   itercount = itercount + 1;
   if report == 1
     fprintf(['step ', num2str(itercount), ' ln div ', num2str(min(fv)), ...
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
