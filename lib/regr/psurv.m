function [cov, cor, sd, dev] = psurv (func, p, ... )
  %  created: 2002/02/08 by Bas Kooijman
  %
  %% Description
  %  calculates covariance and correlation matrix of parameters standard deviation and sum of squared deviations 
  %    of model predictions with respect to observations
  %
  %% Input
  %  func: string with name of user-defined function
  %     f = func (p, tn) with
  %       p: k-vector with parameters; tn: (n,c)-matrix; f: n-vector
  %     [f1, f2, ...] = func (p, tn1, tn2, ...) with  p: k-vector  and
  %      tni: (ni,k)-matrix; fi: ni-vector with model predictions
  %     The dependent variable in the output f; For tn see below.
  %
  %% Output
  %  p: (k,2) matrix with
  %     p(:,1) initial guesses for parameter values
  %     p(:,2) binaries with yes or no iteration (optional)
  %  tni (read as tn1, tn2, .. ): (ni,2) matrix with
  %     tni(:,1) time: must be increasing with rows
  %     tni(:,2) number of survivors: must be non-increasing with rows
  %     tni(:,3, 4, ... ) data-pont specific information data (optional)
  %     The number of data matrices tn1, tn2, ... is optional but >0
  %  cov: (np,np) matrix with covariances
  %  cor: (np,np) matrix with correlation coefficients
  %  sd: (np,1) matrix with standard deviations
  %  dev: scalar with deviance
  %
  %% Example of use
  %  assuming that function_name, pars, and tn1 (and possibly more data matrices) are defined properly: 
  %  [cov, cor, sd, ss] = psurv('function_name', pars, tn1, tn2, ...). 
   
  %% Code
  global index l n ntn listt listtn listf listg

  i = 1; % initiate data set counter
  ci = num2str(i); % character string with value of i
  nntn = nargin -1; % initial 'while' condition (will count down)
  ntn = nntn -1; % number of data sets
  va_start (); % set pointer to first unnamed argument
  while (--nntn) % loop across data sets
    eval(['tn', ci, ' = va_arg();']); % assing unnamed arguments to tni
    eval(['[n(', ci, ') k] = size(tn', ci, ');']); % number of data points
    if i == 1
      %% obtain time intervals and numbers of death
      D = tn1(:,2) - [tn1(2:n(i),2);0]; % initiate death count
      n0 =  tn1(1,2)*ones(n(1),1); % initiate start number
      listtn = ['tn', ci,',']; % initiate list tn
      listt = ['tn', ci]; % initiate list tn for global declaration
      listf = ['f', ci,',']; % initiate list f
      listg = ['g', ci,',']; % initiate list g
    else     
      eval(['D = [D; tn', ci,'(:,2) - [tn', ci, '(2:n(i),2);0];']);
                                % append death counts
      eval(['n0 = [n0; tn', ci, '(1,2)*ones(n(', ci,'),1)];']);
				% append initial numbers
      listtn = [listtn, ' tn', ci,',']; % append list tn
      listt = [listt, ' tn', ci]; % append list tn for global declaration
      listf = [listf, ' f', ci,',']; % append list f
      listg = [listg, ' g', ci,',']; % append list g
    end
    i++;
    ci = num2str(i); % character string with value of i
  end

  [i nl] = size(listtn); listtn = listtn(1:(nl-1)); % remove last ','
  [i nl] = size(listf); listf = listf(1:(nl-1)); % remove last ','
  [i nl] = size(listg); listg = listg(1:(nl-1)); % remove last ','
  eval(['global ', listt,';']); % make data sets global

  likmax = D'*log(max(1e-10,D./ n0)); % max of log lik function

  [np, k] = size(p); % k: number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of estimated parameters
  end
  l = max(size(index));  % l: number of estimated parameters
  if (l == 0)
    return; % no parameters to present statistics
  end
  
  [prob, dprob] = scdsurv(func, p(:,1));
				% obtain death prob and derivatives

  dev = 2 * (likmax - D' * log(max(1e-10,prob)));
				% deviance: 2* log lik minus its supremum
  cov(index, index) = inv((n0./prob * ones(1,l).*dprob)'*dprob);
				% inv of information matrix
  sd = sqrt(diag(cov)); % standard deviations
  cor = cov./(sd*sd'); % correlation matrix