function  [cov, cor, sd, dev] = psurv2(func, p, t, y, N)
  %  created: 2002/02/08 by Bas Kooijman; corrected 2005/01/27
  %
  %% Description
  %  Calculates covariance matrix and standard deviations of parameters in survivor models, like psurv, but for 2 independent variables. 
  %
  %% Input
  %  func: string with name of user-defined function
  %     f = func (p, t, y) with p: np-vector; t: nt-vector; y: ny-vector
  %     f: (nt,ny)-matrix with model-predictions for surviving numbers
  %  p: (np,2) matrix with
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %  t: (nt,1)-vector with first independent variable (time)
  %  y: (ny,1)-vector with second independent variable
  %  N: (nt,ny)-matrix with surviving numbers
  %
  %% Output
  %  cov: (np,np) matrix with covariances
  %  cor: (np,np) matrix with correlation coefficients
  %  sd: (np,1) matrix with standard deviations
  %  dev: scalar with deviance
  %
  %% Remarks
  %  calls scdsurv2, and user-defined function 'func'
  %
  %% Example of use
  %  assuming that function_name, pars, tvalues, yvalues, numbers are defined properly: 
  %  [cov, cor, sd, ss] = pregr2('function_name', pars, tvalues, yvalues, numbers). 


  %% set independent variables to column vectors, 
  %% t = reshape(t, max(size(t)), 1);
  %% y = reshape(y, max(size(y)), 1);

  global nt ny l index;
  
  [np, k] = size(p); % np: number of parameters
  cov = zeros(np,np);
  cor = zeros(np,np);

  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of estimated parameters
  end
  l = max(size(index));  % l: number of estimated parameters
  if (l == 0)
    return; % no parameters to present statistics
  end

  [nt ny] = size(N); % nt,ny is number of values of surviving individuals
  nty = nt*ny;
  D = N - [N(2:nt,:); zeros(1,ny)]; D = reshape(D, nty, 1);
  n0 = ones(nt,1) * N(1,:); n0 = reshape(n0, nty, 1);
  likmax = D' * log(max(1e-10, D./ n0)); % max of log lik function

  %% eval([ 'f = ', func, '(p(:,1), t, y);']);
				% obtain survival probabilities
  %% prob = reshape(f - [f(2:nt,:);zeros(1,ny)], nty, 1);
 
  [prob, Dprob] = scdsurv2(func, p(:,1), t, y);
				% obtain death prob and derivatives
  dprob = zeros(nty,np);
  dprob(:,index) = Dprob;
 

  dev = 2 * (likmax - D' * log(max(1e-10,prob)));
				% deviance: 2* log lik minus its supremum
  cov(index, index) = inv((n0./prob * ones(1,l).*Dprob)'*Dprob);
				% inv of information matrix
  sd = sqrt(diag(cov)); % standard deviations
  cor = cov./(1e-10 + sd*sd'); % correlation matrix