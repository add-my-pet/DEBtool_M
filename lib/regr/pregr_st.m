function [cov, cor, sd, ss] = pregr_st (func, p, st)
  % created: 2010/05/08 by Bas Kooijman; modified: 2013/05/02 by Gonçalo Marques
  %
  %% Description
  %  calculates covariance and correlation matrix of parameters
  %   standard deviation and sum of squared deviations
  %   of model predictions with respect to observations
  %
  %% Input
  %  func: character string with name of user-defined function
  %    see nrregr_st or nrregr
  %  p: (np,2) matrix with
  %    p(:,1) parameter values
  %    p(:,2) binaries with yes or no conditional values
  %    all conditional parameters have zero (co)variance
  %  st: (ni,3) structure with
  %    st.nm(:,1) independent variable
  %    st.nm(:,2) dependent variable
  %    st.nm(:,3) weight coefficients (optional)
  %    The number of data matrices in st fields is optional
  %    The first data matrix is assumed to be zero-variate, 
  %      the others uni-variate, which are first reduced to zero-variate data
  %      if all weight coefficients in a uni-variate data-set are zero,
  %      that relative error gets weight zero
  %  
  %% Output
  %  cov: (np,np) matrix with covariances
  %  cor: (np,np) matrix with correlation coefficients
  %  sd: (np,1) matrix with standard deviations
  %  ss: scalar with weighted sum of squared deviations
  
  %% Code    
  global index
  
  [nm nst] = fieldnmnst_st(st);
  
  i = 1; % initiate data set counter
  while (i <= nst) % loop across data sets
    eval(['[n(', num2str(i), '), k] = size(st.', nm{i}, ');']); % number of data points
    if i == 1
      eval(['Y = st.', nm{i}, '(:,2);']); % initiate dependent variables
      if k > 2
	    eval(['W = st.', nm{i}, '(:,3);']); % initiate weight coefficients
      else
	    W = ones(n(1),1);
      end
    else     
      eval(['Y = [Y;st.', nm{i}, '(:,2)];']); % append dependent variables
      if k > 2
	    eval(['W = [W;st.', nm{i}, '(:,3)];']); % append weight coefficients
      else
	    W = [W; ones(n(i), 1)]; % append weight coefficients
      end
    end
    i = i + 1;
  end

  W = W/ sum(W); % sum of weight coefficients set equal to 1

  [np, k] = size(p); % np: number of parameters
  index = 1:np;
  if k>1
    index = index(1 == p(:,2)); % indices of iterated parameters
  end
  n_pars = size(index, 2);  % number of parameters that must be iterated
  if (n_pars == 0)
    return; % no parameters to iterate
  end
     
  [f, df] = nrdregr_st(func, p(:,1), st);
  ss = W' * (f - Y) .^ 2;
  cov = zeros(np, np);
  cov(index, index) = inv(df' * (df .* W(:, ones(1, n_pars))));
  n = sum(df ~= 0); % number of data points that contributed to the parameter
  cov(index, index) = cov(index, index) * ss ./ sqrt(n' * n);
  sd = sqrt(diag(cov));
  cor = zeros(np, np);
  cor(index, index) = cov(index, index) ./ (sd(index) * sd(index)');
