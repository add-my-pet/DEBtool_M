%% wblStat
% mean and variance of the Weibull distribution

function [mean, var] = wblStat(lambda,k)
  % created 2023/02/20 by Bas Kooijman
  
  %% Syntax
  % [mean, var] = <../wblStat.m *wblStat*> (lambda,k)

  %% Description
  % Calculates mean and variance of  the Weibull distribution:
  %    pdf(t)=k*lambda*(t*lambda)^(k-1)*exp(-(lambda*t)^k); 
  %    df(t)=1-exp(-(t/lambda)^k). 
  %
  % Input:
  %
  % * lambda: scalar with scale parameter
  % * k: scalar with shape parameter
  %
  % Output:
  %
  % * mean: scalar with mean
  % * var: scalar with variance
  
  %% Remarks
  % generate random trials from a Weibull distribution with wblrnd and ML estimates with wblML;
  
  %% Example of use
  % wblStat(2,3)

  mean = lambda * gamma(1 + 1/ k);
  var = lambda^2 * gamma(1 + 2/ k) - mean^2;

end