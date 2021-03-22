%% nrregr
% Calculates least squares estimates using Newton Raphson method multiple-sample case

%%
function [q, info] = nrregr(func, p, varargin)
  % created: 2001/09/07 by Bas Kooijman; modified 2013/10/04
  
  %% Syntax
  % [q, info] = <../nrregr.m *nrregr*> (func, p, varargin)
  
  %% Description
  % Calculates least squares estimates using Newton Raphson method multiple-sample case
  % Finds parameter values in (non-linear) weighted least-squares regression problems using the Newton Raphson method, 
  %    with numerically obtained values for the jacobian. 
  % It can deal with an arbitrary number of samples, which might share one or more parameters. 
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
  %     p(:,2) binaries with yes (1) or no (0) iteration (optional)
  %
  % * xyzi (read as xyw1, xyw2, .. ): (ni,3) matrix with
  %
  %     xywi(:,1) independent variable 
  %     xywi(:,2) dependent variable 
  %     xywi(:,3) weight coefficients (optional)
  %     xywi(:,>3) data-pont specific information data (optional)
  %     The number of data matrices xyw1, xyw2, ... is optional but > 0
  %
  % Output
  %
  % * q: matrix like p, but with least squares estimates
  % * info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % The convergence is usually fast, but the domain of attraction can be small, depending on data and model. 
  % See <nmregr.html *nmregr*> for simplex method, 
  %     <garegr.html *garegr*> for genetic algorithm, and 
  %     <nrregr2.html *nrregr2*>, <nmregr2.html *nmregr2*> and <garegr2.html *garegr2*> for 2 independent variables. 
  % See <nmvcregr.html *nmvcregr*> for standard deviations proportional to the mean.   
  % Calls nrdregr, and user-defined function 'func'.
  % Set options with <nrregr_options.html *nrregr_options*>
  % The iteration is terminated if the norm, i.e. the sum of squared derivetives of sum of squared deviations with respect to the iterated parameters, is less than the maximum norm or if the number of iterations exceeds a maximum values (see nrregr_options).
  
  %% Advices:
  % Fill data matrix, model definition and parameter values in a script-file. See mydata_regr.m for an example. 
  % If the data file is large, the parameter setting can best be done in a separate script file, 
  %    since you probably want to change them many times before the result satisfies. 
  % Optimization and plot options can best be set in the script file that contains the data.
  % Be aware of the fact that the result is not always what you expect it to be (for instance due to local minima). 
  % Check result graphically using routine shregr. 
  % Check logic of parameter values and check standard deviations, using routine pregr. 
  % If you do not trust the result, try other initial estimates. 
  % Use shregr to check that your initial parameter estimates make sense
  %  Since the output resembles the input for the parameters, continuation is easy. 
  %  Conversion is less easy for inceasing dimensionality. 
  %  It, therefore, helps to fixed parameters initially for which their approximate value is rather certain, 
  %     and only iterate those for which the values is less certain
  %  Use the default option report = 1. 
  %  The norm values can first increase and then decrease, but the sum of squared deviations should always decrease. 
  %  The approach to zero of the norm values should be rather fast, once in the neighbourhood of the proper minimum
  %  Far away from the proper minimum, it might help to restrict the maximum step size. 
  %  You can also to fix some rather well-known parameters first, the find appropriate values for less known parameters, 
  %    and then release all parameter values
  %  Use weight coefficient 0 if you want no effect of that data-point on the parameter estimates, 
  %    but still want to show that data-point in the plot (see shregr). 
  %  If the coefficient of variation is approximately constant, 
  %    weight coefficients inverse to the squared values of the dependent variable is an attractive alternative.
  %  There is no need to use the value of the independent variable in the user-defined function. 
  %  This allows the implementation of one or more sloppy constraints on the parameter values. 
  %  You define an extra dataset with one row, for instance xyw2 = [arbitrary_number value weight], 
  %    and a second output of a function of parameter values that should not differ too much from value. 
  %  If you give it a high weight, the resulting parameters will be such that the function of the parameters is close to value
  
  %% Remarks
  % See
  % <nmregr.html  *nmregr*> for simplex method, 
  % <garegr.html  *garegr*> for genetic algorithm,
  % <nrregr2.html *nrregr2*> for 2 independent variables, and 
  % <nmvcregr.html *nmvcregr*> for standard deviations proportional to the mean.
  % Set options via <nrregr_options.html *nrregr_options*>.

  %% Example of use
  % See <../mydata_regr.m *mydata_regr*>

  global index nxyw listx listxyw listf listg global_txt
  global max_step_number max_step_size max_norm report % option settings

  % set options if necessary
  if ~exist('max_step_number','var')
    nrregr_options('max_step_number', 10);
  end
  if ~exist('max_step_size','var')
    nrregr_options('max_step_size', 1e20);
  end
  if ~exist('max_norm','var')
    nrregr_options('max_norm', 1e-8);
  end
  if ~exist('report','var')
    nrregr_options('report', 1);
  end
  if isempty(max_step_number)
    nrregr_options('max_step_number', 10);
  end
  if isempty(max_step_size)
    nrregr_options('max_step_size', 1e20);
  end
  if isempty(max_norm)
    nrregr_options('max_norm', 1e-8);
  end
  if isempty(report)
    nrregr_options('report', 1);
  end

  i = 1; % initiate data set counter
  info = 1; % initiate info setting
  nxyw = nargin - 2; % number of data sets
  for i = 1:nxyw % loop across data sets
    ci = num2str(i); % character string with value of i
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
  end
  nl = size(listxyw,2); listxyw = listxyw(1:(nl - 1)); % remove last ','
  nl = size(listf,2); listf = listf(1:(nl - 1)); % remove last ','
  nl = size(listg,2); listg = listg(1:(nl - 1)); % remove last ','

  global_txt = strrep(['global ', listxyw], ',', ' ');
  eval(global_txt); % make data sets global

  n = zeros(nxyw, 1); % initiate data counter
  for i = 1:nxyw % loop across data sets
    ci = num2str(i); % character string with value of i
    eval(['xyw', ci, ' = varargin{',ci,'};']); % assign unnamed arguments to xywi
    eval(['[n(', ci, '), k] = size(xyw', ci, ');']); % number of data points
    if i == 1
      eval(['Y = xyw', ci, '(:,2);']); % initiate dependent variables
      if k > 2
	    eval(['W = xyw', ci, '(:,3);']); % initiate weight coefficients
      else
	    W = ones(n(1),1)/ n(1);
      end
    else     
      eval(['Y = [Y;xyw', ci, '(:,2)];']); % append dependent variables
      if k > 2
	    eval(['W = [W;xyw', ci, '(:,3)];']); % append weight coefficients
      else
	    W = [W; ones(n(i),1)/ n(i)]; % append weight coefficients
      end
    end
  end

  q = p; % copy input parameter matrix into output

  [np, k] = size(p); % k: number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  l = length(index);  % l: number of parameters that must be iterated
  if (l == 0)
    return; % no parameters to iterate
  end
  
  norm = 1 + max_norm; % make sure that we start with iteration
  step_number = 0; % initiate number of iterations
  
  % start of numerical minimization
  while (norm > max_norm) && (step_number < max_step_number)
    step_number = step_number + 1; % increment step number
    [fn, dfn] = nrdregr(func, q(:,1));
				% obtain function values and derivatives
    div = Y - fn;
    f = dfn' * (W .* div);   % weighted derivatives
    norm = f' * f;           % sum of squared derivatives
    step = (dfn' * (dfn .* W(:,ones(1,l))))\f;
    if report ~= 0           % monitor progress
      ssq = (W' * div .^ 2); % weighted sum of squared deviations
      fprintf(['step ', num2str(step_number), ' norm ', num2str(norm), ...
	    ' ssq ', num2str(ssq), '\n']); 
    end
    step_size = step' * step;
    step = step * min(max_step_size, step_size)/ step_size;
				% reduce step if necessary
    q(index,1) = q(index,1) + step; % make step
  end

  % trouble report
  if step_number == max_step_number || norm > max_norm
    if report ~= 0 % print warning  
      fprintf(['no convergence within ', num2str(max_step_number), ...
	      ' steps \n']);
    end    
    info = 0; % convergence has not been successful
  else
    info = 1; % convergence was successful
  end
  