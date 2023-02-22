%% gammarnd
% generates random trials from a gamma distribution

function x = gammarnd(theta,alpha,r,c)
  % created 2023/02/20 by Bas Kooijman
  
  %% Syntax
  % x = <../gammarnd.m *gammarnd*> (theta,alpha,r,c)

  %% Description
  % generates random trials from the gamma distribution using the Ahrens-Dieter acceptance–rejection method:
  %    pdf(x)=theta^alpha/gamma(alpha)*x^(alpha-1)*exp(-theta*x); 
  %
  % Input:
  %
  % * theta: scalar with scale parameter;dim(theta)=dim(x)
  % * alpha: scalar with shape parameter; dim(alpha)=0
  % * r: optional scalar with number of rows of output (default 1)
  % * c: optional scalar with number of columns of output (default 1)
  %
  % Output:
  %
  % * x: (r,c)-matrix with random trials from a gamma distribution
  
  %% Example of use
  % gammarnd(2,4,5,6)

  if ~exist('r','var')
    r = 1;
  end
  if ~exist('c','var')
    c = 1;
  end
  
  del = mod(alpha,1); k = ceil(alpha) - 1; n = r * c; x = NaN(n,1); i = 0; j = 0;
  
  while i<n && j<100*n
    if rand <= exp(1)/ (exp(1) + del)
      xi = rand^(1/del); nu = rand*xi^(del-1);
    else
      xi = 1 - log(rand); nu = rand*exp(-xi);
    end
    if nu <= xi.^(del-1) * exp(-xi)
      i=i+1; x(i) = theta*(xi - sum(log(rand(k,1))));
    end
    j=j+1;
  end

  x = wrap(x,r,c);
  
  if j == 100*n
    fprintf('Warning from gammarnd: required number of random trials is not reached\n');
  end
end