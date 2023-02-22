%% wblrnd
% generates random trials from a Weibull distribution

function t = wblrnd(lambda,k,r,c)
  % created 2023/02/20 by Bas Kooijman
  
  %% Syntax
  % t = <../wblrnd.m *wblrnd*> (lambda,k,r,c)

  %% Description
  % generates random trials from the Weibull distribution:
  %    pdf(t)=k/lambda*(t/lambda)^(k-1)*exp(-(t/lambda)^k)
  %
  % Input:
  %
  % * lambda: scalar with scale parameter, dim(lambda) = dim(t)
  % * k: scalar with shape parameter, dim(k) = 0
  % * r: optional scalar with number of rows of output (default 1)
  % * c: optional scalar with number of columns of output (default 1)
  %
  % Output:
  %
  % * t: (r,c)-matrix with random trials from a Weibull distribution
  
  %% Remarks
  % estimate parameters of the Weibull distribution with wblML;
  
  %% Example of use
  % wblrnd(2,4,5,6)

  if ~exist('r','var')
    r = 1;
  end
  if ~exist('c','var')
    c = 1;
  end

  % Generate uniform random values, and apply the Weibull inverse CDF.
  t = lambda * (-log(rand(r,c))) .^ (1/k); 

end