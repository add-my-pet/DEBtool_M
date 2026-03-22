%% surv_norm
% calculates the survivor probability of the normal distribution

%%
function p = surv_norm (mean, std, x)
  % created 2026/03/20 by Bas Kooijman
  
  %% Syntax
  % p = <../surv_norm.m *surv_norm*> (mean, std, x)

  %% Description
  % Calculates the survivor probability of the normal distribution
  %
  % Input:
  %
  % * mean: scalar with mean 
  % * std: scalar with standard deviation
  % * x: vector with argument values
  %
  % Output
  %
  % * p: vector with survivor probabilities
  
  %% Remarks
  % cf surv_skewNorm
  
  %% Example of use
  % surv_norm(0,2, [3 4 6.5])

  p = (1 - erf((x-mean) / std/ sqrt(2)))/ 2;

