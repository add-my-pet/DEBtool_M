%% scsurv3
%

%%
function [q, info] = scsurv3(func, p, t, x, y, N)
  %  created: 2006/03/07 by Bas Kooijman, modified 2008/30/12
  
  %% Syntax
  % [q, info] = <../scsurv3.m *scsurv3*>(func, p, t, x, y, N)
  
  %% Description
  % Finds maximum likelihood estimates from trivariate survivor data like using the method of scores
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, t, x, y) with
  %     p: np-vector; t: nt-vector; x: nx-vector; y: ny-vector
  %     f: (nt,nx*ny)-matrix with model-predictions for surviving numbers
  %
  % * p: (np,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * t: (nt,1)-vector with first independent variable (time)
  % * x: (nx,1)-vector with second independent variable
  % * y: (ny,1)-vector with third independent variable
  % * N: (nt,nx*ny)-matrix with surviving numbers
  %
  % Output
  %
  % * q: matrix like p, but with maximum likelihood estimates
  % * info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % Calls scdsurv3, and user-defined function 'func'.
  % Set options with <scsurv_options.html *scsurv_options*>.
  % See <<scsurv.html *scsurv*> and <scsurv2.html *scsurv2*>.
  %
  % The iteration is terminated if the norm, 
  %    i.e. the sum of squared derivetives of the deviance with respect to the iterated parameters, 
  %    is less than the maximum norm or if the number of iterations exceeds a maximum values (see scsurv_options).
  % If progression seems hopeful, but the number of iterations not large enough, 
  %    you can continue with pars = scsurv3('function_name', pars, tvalues, xvalues, yvalues, numbers). 
  % Alternatively you can increase the maximum number of iterations with scsurv_options. 

  %% Example of use
  % See <../mydata_surv3.m.m *mydata_surv3*>.

  global index nt nx ny l;
  global max_step_number max_step_size max_norm report;

  % t = t(:); x = x(:); y = y(:); % set independent vars to column vectors
  nt = length(t); % number of time points
  nx = length(x); % number of values for second independent vars
  ny = length(y); % number of values for third independent vars
  [nNt nNxy] = size(N); % number data points
  if nNt ~= nt & nNxy ~= nx * ny % test size data matrix
    fprintf('size of data matrix does not match specification of arguments \n');
    q = []; info = 0;
    return
  end
  nxy = nx * ny; ntxy = nt * nxy; 

  % set options, if necessary
  
  if prod(size(max_step_number)) == 0
    scsurv_options('max_step_number', 50);
  end
  if prod(size(max_step_size)) == 0
    scsurv_options('max_step_size', 1e20);
  end
  if prod(size(max_norm)) == 0
    scsurv_options('max_norm', 1e-8);
  end
  if prod(size(report)) == 0
    scsurv_options('report', 1);
  end

  q = p; % copy input into output
  info = 1; % convergence has been successful
  
  [np k] = size(p); % np is number of parameters
  index = 1:np;
  if k>1
    index = index(0 < p(:,2)); % indices of iterated parameters
  end
  l = max(size(index)); % l is number of parameters that must be iterated
  if (l == 0)
    return; % no parameters to iterate
  end

  D = N - [N(2:nt,:);zeros(1,nxy)]; D = reshape(D, ntxy, 1);
  n0 = ones(nt,1) * N(1,:); n0 = reshape(n0, ntxy, 1);
  likmax = D' * log(max(1e-10, D ./ n0)); % max of log lik function

  norm = 1 + max_norm; % make sure that we start with iteration
  step_number = 0; % initiate number of iterations
  	      
  while (norm > max_norm) & (step_number < max_step_number)
    step_number = step_number + 1; % increment step number
    [prob, dprob] = scdsurv3(func, q(:,1), t, x, y);
				% obtain death probabilities and derivatives
    dlik = dprob' * (D ./ prob); % deriv of log lik to pars
    norm = dlik' * dlik; % sum of squared derivatives

    if (report ~=0)
      dev = 2 * (likmax - D'*log(prob));
				% deviance: 2* log lik minus its supremum
      fprintf(['step ', num2str(step_number), ' norm ', num2str(norm), ...
	    ' dev ', num2str(dev), '\n']); % monitor progress
    end
    step = ((n0./prob * ones(1,l) .* dprob)' * dprob)\ dlik; % planned step
    step_size = step' * step;
    step = step*min(max_step_size, step_size)/ step_size;
				% reduce step if necessary
    q(index,1) = q(index,1) + step; % make step
  end  

  if (step_number == max_step_number)
    if (report ~= 0) % monitor result
      fprintf(['no convergence within ', num2str(max_step_number), ...
	      ' steps \n']);
    end
    info = 0; % convergence has not been successful
  end