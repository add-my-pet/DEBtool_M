%% surv_skewNorm
% calculates the survivor probability of the skew normal distribution

%%
function p = surv_skewNorm (loc, scale, shape, x)
  % created 2026/03/20 by Bas Kooijman
  
  %% Syntax
  % p = <../surv_skewNorm.m *surv_skewNorm*> (loc, scale, shape, x)

  %% Description
  % Calculates the survivor probability of the skew normal distribution
  %
  % Input:
  %
  % * loc: scalar with location parameter 
  % * scale: scalar with scale parameter 
  % * shape: scalar with shape parameter
  % * x: (n,1)-vector with argument values
  %
  % Output
  %
  % * p: vector with survivor probabilities
  
  %% Remarks
  % see https://en.wikipedia.org/wiki/Skew_normal_distribution; cf surv_norm
  
  %% Example of use
  % surv_skewNorm(0,2,.3, [3 4 6.5])

  X = (x(:) - loc)/ scale; 
  p = (1 - erf(X/ sqrt(2)))/ 2 + 2 * owensT(X,shape);

