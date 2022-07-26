%% nmregr
% Calculates least squares estimates using Nelder Mead's simplex method
% with the "symmetric bounded" loss function 

%%
function [q, info, fval] = nmregr(func, p, varargin)
  % created 2001/09/07 by Bas Kooijman; modified 2013/10/04; modified
  % 2021/03/21 by Dina Lika
  
  %% Syntax
  % [q, info] = <../nmregr.m *nmregr*> (func, p, varargin)
  
  %% Description
  % Calculates least squares estimates using Nelder Mead's simplex method
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
  % * p: (k,2)-matrix with
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
  %     Default for xywi(:,3) is (number of data points in the set i)^-1
  %
  % Output
  %
  % * q: matrix like p, but with F_sb estimates
  % * info: 1 if convergence has been successful; 0 otherwise
  % * fval: scalar with value of loss function at estimates
  
  %% Remarks
  % Calls user-defined function 'func'
  % Set options with <nmregr_options.html *nmregr_options*>
  % See
  % <nrregr.html  *nrregr*> for Newton-Raphson method, 
  % <garegr.html  *garegr*> for genetic algorithm,
  % <nrregr2.html *nrregr2*> for 2 independent variables, and 
  % <nmvcregr.html *nmvcregr*> for standard deviations proportional to the mean.
  % It is usually a good idea to run <nrregr.html *nrregr*> on the result of nmregr.

  %% Example of use
  % See <../mydata_regr.m *mydata_regr*>

  global report max_step_number max_fun_evals tol_simplex tol_fun
  
  i = 1; % initiate data set counter
  info = 1; % initiate info setting
  ci = num2str(i); % character string with value of i
  nxyw = nargin - 2; % number of data sets
  while (i <= nxyw) % loop across data sets
    if i == 1
      listxyw = ['xyw', ci,',']; % initiate list xyw
      listf = ['f', ci,',']; % initiate list f
    else     
      listxyw = [listxyw, ' xyw', ci,',']; % append list xyw
      listf = [listf, ' f', ci,',']; % append list f
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end
  nl = size(listxyw,2); listxyw = listxyw(1:(nl - 1)); % remove last ','
  nl = size(listf,2); listf = listf(1:(nl - 1)); % remove last ','
  
  global_txt = strrep(['global ', listxyw], ',', ' ');
  eval(global_txt); % make data sets global
  
  N = zeros(nxyw, 1); % initiate data counter
  Y = []; meanY = []; W = [];  % initiate observations, mean of observations and weight coefficients
  for i = 1:nxyw % loop across data sets
    ci = num2str(i); % character string with value of i
    % assing unnamed arguments to xyw1, xyw2, etc
    eval(['xyw', ci, ' = varargin{',ci,'};']);
    eval(['[N(', ci, '), k] = size(xyw', ci, ');']); % number of data points
    eval(['Y = [Y;xyw', ci, '(:,2)];']); % append dependent variables
    eval(['meanY = [meanY; ones(length(xyw',ci,'(:,2)),1) * mean(xyw',ci,'(:,2))];']);  % append mean of data
    if k > 2
	  eval(['W = [W;xyw', ci, '(:,3)];']); % append weight coefficients
    else
	  W = [W; ones(N(i),1)/ N(i)]; % append weight coefficients
    end
  end

  q = p; % copy input parameter matrix to output
  info = 1; % convergence has been successful

  [np, k] = size(p); % k: number of parameters
  index = 1:np;
  if k > 1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  n_par = max(size(index));  % number of parameters that must be iterated
  if (n_par == 0)
    fval = []; info = 1;
    return; % no parameters to iterate
  end
  
  % set options if necessary
  if ~exist('max_step_number','var')
    nmregr_options('max_step_number', 200 * n_par);
  end
  if ~exist('max_fun_evals','var')
    nmregr_options('max_fun_evals', 200 * n_par);
  end
  if ~exist('tol_simplex','var')
    nmregr_options('tol_simplex', 1e-4);
  end
  if ~exist('tol_fun','var')
    nmregr_options('tol_fun', 1e-4);
  end
  if ~exist('report','var')
    nmregr_options('report', 1);
  end
  if isempty(max_step_number)
    nmregr_options('max_step_number', 200 * n_par);
  end
  if isempty(max_fun_evals)
    nmregr_options('max_fun_evals', 200 * n_par);
  end
  if isempty(tol_simplex)
    nmregr_options('tol_simplex', 1e-4);
  end
  if isempty(tol_fun)
    nmregr_options('tol_fun', 1e-4);
  end
  if isempty(report)
    nmregr_options('report', 1);
  end

  % Initialize parameters
  rho = 1; chi = 2; psi = 0.5; sigma = 0.5;
  onesn = ones(1, n_par);
  two2np1 = 2:n_par + 1;
  one2n = 1:n_par;
  np1 = n_par + 1;

  % Set up a simplex near the initial guess.
  v = zeros(n_par, np1); fv = zeros(1, np1);
  xin = q(index, 1);    % Place input guess in the simplex
  v(:,1) = xin;
  eval(['[',listf, '] = ', func, '(q(:,1),', listxyw, ');']);
  meanf = f1;   
  for i = 2:nxyw % loop across data sets
    ci = num2str(i); % character string with value of i
    eval(['meanf = [meanf; ones(length(f',ci,'),1) * mean(f',ci,')];']);  % append mean of data
  end
  if nxyw == 1
    fv(:,1) = W' * ((f1 - Y).^2 / max(1e-6,mean(f1)^2 + mean(Y)^2));
  else
    eval(['fv_aux = (cat(1, ', listf, ')-Y).^2 ./ max(1e-6,meanf.^2 + meanY.^2);']);
    fv(:,1) = W' * fv_aux;
  end
  % Following improvement suggested by L.Pfeffer at Stanford
  usual_delta = 0.05;             % 5 percent deltas for non-zero terms
  zero_term_delta = 0.00025;      % Even smaller delta for zero elements of q
  for j = 1:n_par
    y = xin;
    if y(j) ~= 0
      y(j) = (1 + usual_delta) * y(j);
    else 
      y(j) = zero_term_delta;
    end  
    v(:,j+1) = y;
    q(index,1) = y;
    eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
    meanf = f1;   
    for i = 2:nxyw % loop across data sets
      ci = num2str(i); % character string with value of i
      eval(['meanf = [meanf; ones(length(f',ci,'),1) * mean(f',ci,')];']);  % append mean of data
    end
    if nxyw == 1
      fv(1, j + 1) = W' * ((f1 - Y).^2 / max(1e-6, mean(f1)^2 + mean(Y)^2));
    else
    eval(['fv_aux = (cat(1, ', listf, ')-Y).^2 ./ max(1e-6,meanf.^2 + meanY.^2);']);
    fv(1, j + 1) = W' * fv_aux;
    end
  end     

  % sort so v(1,:) has the lowest function value 
  [fv,j] = sort(fv);
  v = v(:,j);

  how = 'initial';
  itercount = 1;
  func_evals = n_par + 1;
  if report == 1
    fprintf(['step ', num2str(itercount), ' ssq ', num2str(min(fv)), '-', ...
	    num2str(max(fv)), ' ', how, '\n']);
  end
  info = 1;

  % Main algorithm
  % Iterate until the diameter of the simplex is less than tol_simplex
  %   AND the function values differ from the min by less than tol_fun,
  %   or the max function evaluations are exceeded. (Cannot use OR instead of AND.)
  while func_evals < max_fun_evals && itercount < max_step_number
    if max(max(abs(v(:,two2np1) - v(:,onesn)))) <= tol_simplex && ...
      max(abs(fv(1) - fv(two2np1))) <= tol_fun
      break
    end
    how = '';
   
    % Compute the reflection point
   
    % xbar = average of the n (NOT n+1) best points
    xbar = sum(v(:,one2n), 2)/ n_par;
    xr = (1 + rho) * xbar - rho * v(:,np1);
    q(index,1) = xr;
    eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
    meanf = f1;   
    for i = 2:nxyw % loop across data sets
      ci = num2str(i); % character string with value of i
      eval(['meanf = [meanf; ones(length(f',ci,'),1) * mean(f',ci,')];']);  % append mean of data
    end
    if nxyw == 1
      fxr = W' * ((f1 - Y).^2 / (mean(f1)^2 + mean(Y)^2));
    else
    eval(['fv_aux = (cat(1, ', listf, ')-Y).^2 ./ max(1e-6,meanf.^2 + meanY.^2);']);
    fxr = W' * fv_aux;
    end
    func_evals = func_evals + 1;
   
    if fxr < fv(:,1)
      % Calculate the expansion point
      xe = (1 + rho * chi) * xbar - rho * chi * v(:, np1);
      q(index,1) = xe;
      eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
      meanf = f1;   
      for i = 2:nxyw % loop across data sets
        ci = num2str(i); % character string with value of i
        eval(['meanf = [meanf; ones(length(f',ci,'),1) * mean(f',ci,')];']);  % append mean of data
      end
      if nxyw == 1
        fxe = W' * ((f1 - Y).^2 / (mean(f1)^2 + mean(Y)^2));
      else
         eval(['fv_aux = (cat(1, ', listf, ')-Y).^2 ./ max(1e-6,meanf.^2 + meanY.^2);']);
         fxe = W' * fv_aux;
      end
      func_evals = func_evals + 1;
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
      if fxr < fv(:,n_par)
        v(:,np1) = xr; 
        fv(:,np1) = fxr;
        how = 'reflect';
      else % fxr >= fv(:,n_par) 
        % Perform contraction
        if fxr < fv(:,np1)
          % Perform an outside contraction
          xc = (1 + psi * rho) * xbar - psi * rho * v(:,np1);
          q(index,1) = xc;
	      eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
          meanf = f1;   
          for i = 2:nxyw % loop across data sets
            ci = num2str(i); % character string with value of i
            eval(['meanf = [meanf; ones(length(f',ci,'),1) * mean(f',ci,')];']);  % append mean of data
          end
          if nxyw == 1
            fxc = W' * ((f1 - Y).^2 / (mean(f1)^2 + mean(Y)^2));
          else              
            eval(['fv_aux = (cat(1, ', listf, ')-Y).^2 ./ max(1e-6,meanf.^2 + meanY.^2);']);    
            fxc = W' * fv_aux;
          end
          func_evals = func_evals + 1;
            
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
          xcc = (1 - psi) * xbar + psi * v(:,np1);
          q(index,1) = xcc;
	      eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
          meanf = f1;   
          for i = 2:nxyw % loop across data sets
            ci = num2str(i); % character string with value of i
            eval(['meanf = [meanf; ones(length(f',ci,'),1) * mean(f',ci,')];']);  % append mean of data
          end
          if nxyw == 1
            fxcc = W' * ((f1 - Y).^2 / (mean(f1)^2 + mean(Y)^2));
          else
            eval(['fv_aux = (cat(1, ', listf, ')-Y).^2 ./ max(1e-6,meanf.^2 + meanY.^2);']);
            fxcc = W' * fv_aux;
          end
          func_evals = func_evals + 1;
            
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
          for j = two2np1
            v(:,j) = v(:,1) + sigma * (v(:,j) - v(:,1));
            q(index,1) = v(:,j);
            eval(['[', listf, '] = ', func, '(q(:,1), ', listxyw, ');']);
            meanf = f1;   
            for i = 2:nxyw % loop across data sets
              ci = num2str(i); % character string with value of i
              eval(['meanf = [meanf; ones(length(f',ci,'),1) * mean(f',ci,')];']);  % append mean of data
            end
            if nxyw == 1
              fv(:,j) = W' * ((f1 - Y).^2 / (mean(f1)^2 + mean(Y)^2));
            else
              eval(['fv_aux = (cat(1, ', listf, ')-Y).^2 ./ max(1e-6,meanf.^2 + meanY.^2);']);
              fv(:,j) = W' * fv_aux;
            end
          end
          func_evals = func_evals + n_par;
        end
      end
    end
    [fv,j] = sort(fv);
    v = v(:,j);
    itercount = itercount + 1;
    if report == 1
      fprintf(['step ', num2str(itercount), ' ssq ', num2str(min(fv)), ...
	    '-', num2str(max(fv)), ' ', how, '\n']);
    end  
  end   % while of main loop


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