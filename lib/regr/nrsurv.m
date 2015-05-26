%% nrsurv
% Calculates maximum likelihood estimates using Newton Raphson method

%%
function [q, info] = nrsurv(func, p, varargin)
  %  created: 2002/02/08 by Bas Kooijman; modified 2013/03/13
  
  %% Sybtax
  % [q, info] = <../nrsurv.m *nrsurv*> (func, p, varargin)
  
  %% Description
  % Calculates maximum likelihood estimates using Newton Raphson method
  %
  % Input
  %
  % * func: string with name of user-defined function
  %
  %     f = func (p, tn) with
  %       p: k-vector with parameters; tn: (n,c)-matrix; f: n-vector
  %     [f1, f2, ...] = func (p, tn1, tn2, ...) with  p: k-vector  and
  %      tni: (ni,k)-matrix; fi: ni-vector with model predictions
  %     The dependent variable in the output f; For tn see below.
  %
  % * p: (k,2) matrix with
  %
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %
  % * tni (read as tn1, tn2, .. ): (ni,2) matrix with
  %
  %     tni(:,1) time: must be increasing with rows
  %     tni(:,2) number of survivors: must be non-increasing with rows
  %     tni(:,3, 4, ... ) data-pont specific information data (optional)
  %     The number of data matrices tn1, tn2, ... is optional but >0
  %
  % Output
  %
  % * q: matrix like p, but with ml-estimates
  % * info: 1 if convergence has been successful; 0 otherwise
  
  %% Remarks
  % Calls nrdsurv, and user-defined function 'func'
  % Set options with <nrregr_options.html *nrregr_options*>
  
  %% Example of use
  % See <../mydata_surv.m *mydata_surv*>
 
  global index l n ntn listt listtn listf listg;
  global max_step_number max_step_size max_norm report; % option settings

  % set options if necessary
  if ~exist('max_step_number', 'var')
    nrregr_options('max_step_number', 20);
  end
  if ~exist('max_step_size', 'var')
    nrregr_options('max_step_size', 1e20);
  end
  if ~exist('max_norm', 'var')
    nrregr_options('max_norm', 1e-8);
  end
  if ~exist('report', 'var')
    nrregr_options('report', 1);
  end

  i = 1; % initiate data set counter
  ci = num2str(i); % character string with value of i
  nntn = nargin -1; % initial 'while' condition (will count down)
  ntn = nntn -1; % number of data sets
  ntn = nargin - 2; % number of data sets
  while (i <= ntn) % loop across data sets
    eval(['tn', ci, ' = varargin{i};']); % assing unnamed arguments to xywi
    eval(['[n(', ci, '), k] = size(tn', ci, ');']); % number of data points
    if i == 1
      % obtain time intervals and numbers of death
      D = tn1(:,2) - [tn1(2:n(i),2);0]; % initiate death count
      n0 =  tn1(1,2)*ones(n(1),1); % initiate start number
      listtn = ['tn', ci,',']; % initiate list tn
      listt = ['tn', ci]; % initiate list tn for global declaration
      listf = ['f', ci,',']; % initiate list f
      listg = ['g', ci,',']; % initiate list g
    else     
      eval(['D = [D; tn', ci,'(:,2) - [tn', ci, '(2:n(i),2);0]];']);
                                % append death counts
      eval(['n0 = [n0; tn', ci, '(1,2)*ones(n(', ci,'),1)];']);
				% append initial numbers
      listtn = [listtn, ' tn', ci,',']; % append list tn
      listt = [listt, ' tn', ci]; % append list tn for global declaration
      listf = [listf, ' f', ci,',']; % append list f
      listg = [listg, ' g', ci,',']; % append list g
    end
    i = i + 1;
    ci = num2str(i); % character string with value of i
  end
  listtn(end) = []; listf(end) = []; listg(end) = [];

  q = p; % copy input parameter matrix into output
  info = 1; % convergence has been successful
  likmax = D'*log(max(1e-10,D./ n0)); % max of log lik function

  [np, k] = size(p); % k: number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  l = max(size(index));  % l: number of parameters that must be iterated
  if (l == 0)
    return; % no parameters to iterate
  end
  
  norm = 1 + max_norm; % make sure that we start with iteration
  step_number = 0; % initiate number of iterations

  % start of numerical minimization
  while (norm > max_norm) & (step_number < max_step_number)
    ++ step_number; % increment step number
    [prob, dprob] = nrdsurv(func, q(:,1));
				% obtain death prob and derivatives
    dlik = dprob' * (D ./ prob); % deriv of log lik to pars
    norm = dlik' * dlik; % sum of squared derivatives

    if report ~= 0 % monitor progress
      dev = 2 * (likmax - D'*log(prob));
				% deviance: 2* log lik minus its supremum
      fprintf(['step ', num2str(step_number), ' norm ', num2str(norm), ...
	      ' dev ', num2str(dev), '\n']); 
    end

    step = ((n0 ./ prob * ones(1,l) .* dprob)' * dprob)\ dlik; % planned step
    step_size = step' * step;
    step = step * min(max_step_size, step_size)/ step_size;
				% reduce step if necessary
    q(index,1) = q(index,1) + step; % make step

  end

  % trouble report
  if step_number == max_step_number
    if report ~= 0 % print warning
      fprintf(['no convergence within ', num2str(max_step_number), ...
	      ' steps \n']);
    end    
    info = 0; % convergence has not been successful
  end