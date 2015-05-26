%% scsurv2
%

%%
function [q, info] = scsurv2(func, p, t, y, N)
  %  created: 2002/02/08 by Bas Kooijman
   
  %% Syntax
  % [q, info] = <..scsurv2.m *scsurv2*>(func, p, t, y, N)
  
  %% Description
  %  Finds maximum likelihood estimates from survivor data like scsurv using the method of scores, 
  %    but for an additional independent variable, rather than time only. 
  %  So this routine fits a surface, no a curve. 
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, t, y) with p: np-vector; t: nt-vector; y: ny-vector
  %     f: (nt,ny)-matrix with model-predictions for surviving numbers
  %
  % * p: (np,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * t: (nt,1)-vector with first independent variable (time)
  % * y: (ny,1)-vector with second independent variable
  % * N: (nt,ny)-matrix with surviving numbers
  %
  % Output
  %
  % * q: matrix like p, but with maximum likelihood estimates
  % * info: 1 if convergence has been successful; 0 otherwise

  %% Remarks
  % Calls scdsurv2, and user-defined function 'func'.
  % Set options with <scsurv_options.html *scsurv_options*>.
  %
  % The iteration is terminated if the norm, 
  %   i.e. the sum of squared derivetives of the deviance with respect to the iterated parameters, 
  %   is less than the maximum norm or if the number of iterations exceeds a maximum values (see scsurv_options).
  
  %% Example of use
  % Assuming that 'tvalues', 'yvalues', 'numbers', function 'function_name' and initial paramer estimates 'ipars' are properly defined: 
  % pars = scsurv2('function_name', ipars, tvalues, yvalues, numbers). See sample file 'mydata_surv2.m' for an example of specification. If progression seems hopeful, but the number of iterations not large enough, you can continue with pars = scsurv2('function_name', pars, tvalues, yvalues, numbers). 
  % Alternatively you can increase the maximum number of iterations with scsurv_options. 

  %% Code
  global index nt ny l;
  global max_step_number max_step_size max_norm report;

  %% set options, if necessary
  
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

  %  set independent variables to column vectors, 
  %  t = reshape(t, max(size(t)), 1);
  %  y = reshape(y, max(size(y)), 1);

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

  [nt ny] = size(N); % nt,ny is number of values of surviving individuals
  nty = nt*ny;
  D = N - [N(2:nt,:);zeros(1,ny)]; D = reshape(D, nty, 1);
  n0 = ones(nt,1)*N(1,:); n0 = reshape(n0, nty, 1);
  likmax = D'*log(max(1e-10,D./ n0)); % max of log lik function

  norm = 1 + max_norm; % make sure that we start with iteration
  step_number = 0; % initiate number of iterations
  	      
  while (norm > max_norm) & (step_number < max_step_number)
    step_number = step_number + 1; % increment step number
    [prob, dprob] = scdsurv2(func, q(:,1), t, y);
				% obtain death probabilities and derivatives
    dlik = dprob'*(D./prob); % deriv of log lik to pars
    norm = dlik'*dlik; % sum of squared derivatives

    if (report ~=0)
      dev = 2 * (likmax - D'*log(prob));
				% deviance: 2* log lik minus its supremum
      fprintf(['step ', num2str(step_number), ' norm ', num2str(norm), ...
	    ' dev ', num2str(dev), '\n']); % monitor progress
    end
    step = ((n0./prob * ones(1,l).*dprob)'*dprob)\dlik; % planned step
    step_size = step'*step;
    step = step*min(max_step_size, step_size)/step_size;
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