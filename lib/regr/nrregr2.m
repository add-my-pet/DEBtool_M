%% nrregr2
% Calculates least squares estimates using Newton Raphson method for bivariate data

%%
function [q, info] = nrregr2(func, p, x, y, Z, W)
  % created: 2001/09/07 by Bas Kooijman
  
  %% Syntax
  % [q, info] = <../nrregr2.m *nrregr2*>(func, p, x, y, Z, W)
  
  %% Description
  % Calculates least squares estimates using Newton Raphson method for bivariate data
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
  % Calls nrdregr2, and user-defined function 'func'.
  % Set options with <nrregr_options.htmml *nrregr_options*>
  
  %% Example of use
  % See <../mydata_regr2.m *mydata_regr2*>

  global index nxy l n_pars
  global max_step_number max_step_size max_norm report

  % set options, if necessary
  if numel(max_step_number) == 0 
    nrregr_options('max_step_number', 10);
  end
  if numel(max_step_size) == 0 
    nrregr_options('max_step_size', 1e20);
  end
  if numel(max_norm) == 0
    nrregr_options('max_norm', 1e-8);
  end
  if numel(report) == 0
    nrregr_options('report', 1);
  end

  % set independent variables to column vectors, 
  x = reshape(x, max(size(x)), 1);
  y = reshape(y, max(size(y)), 1);
  q = p; % copy input into output
  info = 1; % convergence has been successful
  
  [np, k] = size(p); % np is number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  l = max(size(index)); % l is number of parameters that must be iterated
  if (l == 0)
    return; % no parameters to iterate
  end
  n_pars = l;

  [nx, ny] = size(Z); % nx,ny is number of values of dependent variables
  nxy = nx * ny; % total number of data points
  if exist('W', 'var') ~= 1
    W = ones(nx, ny);
  end
  
  norm = 1 + max_norm; % make sure that we start with iteration
  step_number = 0; % initiate number of iterations


  if 2 ~= sum([nx ny]==size(W)) | 2 ~= sum([nx 1]==size(x)) | ...
	2 ~= sum([ny 1]==size(y))
    fprintf('sizes of arguments do not match \n');
    return;
  end
  
  WW = reshape(W, nxy, 1); % wrap matrix of weight coefficients into vector
  sw = sum(WW); % sum of weight coefficients
	      
  while (norm > max_norm) & (step_number < max_step_number)
    step_number = step_number + 1; % increment step number
    [fn, dfn] = nrdregr2(func, q(:,1), x, y);
				% obtain function values and derivatives
    div = Z-fn; 
    f = dfn'*reshape(W.*div, nxy, 1); % weighted derivatives
    norm = f'*f; % sum of squared derivatives
    if report ~=0
      ssq = sum(sum(W.*div.^2))/sw;
      fprintf(['step ', num2str(step_number), ' norm ', num2str(norm), ...
	    ' ssq ', num2str(ssq), '\n']); % monitor progress
    end 
    step = (dfn'*(dfn.*WW(:,ones(1,l))))\f;
    step_size = step'*step;
    step = step*min(max_step_size, step_size)/step_size;
				% reduce step if necessary
    q(index,1) = q(index,1) + step; % make step
  end  

  if step_number == max_step_number
    if report ~= 0 % monitor result
      fprintf(['no convergence within ', num2str(max_step_number), ...
	      ' steps \n']);
    end
    info = 0; % convergence has not been successful
  end