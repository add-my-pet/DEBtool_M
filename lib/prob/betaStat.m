%% betaStat
% mean and variance of the beta distribution

function [mean, var] = betaStat(alpha,beta)
  % created 2023/02/22 by Bas Kooijman
  
  %% Syntax
  % [mean, var] = <../betaStat.m *betaStat*> (alpha,beta)

  %% Description
  % Calculates mean and variance of  the beta distribution:
  %    pdf(x)=x^(alpha-1)(1-x)^(beta-1)/ B(alpha, beta); 
  %
  % Input:
  %
  % * alpha: scalar with scale parameter
  % * beta: scalar with scale parameter
  %
  % Output:
  %
  % * mean: scalar with mean
  % * var: scalar with variance
  
  %% Remarks
  % generate random trials from a beta distribution with betarnd and ML estimates with betaML;
  
  %% Example of use
  % betaStat(0.2,0.3)

  mean = alpha/ (alpha + beta);
  var = alpha * beta/ (alpha + beta)^2/ (alpha + beta + 1);

end