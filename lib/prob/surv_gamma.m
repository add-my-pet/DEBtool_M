%% surv_gamma
% calculates the survivor probability of the gamma distribution

%%
function p = surv_gamma (scale, shape, x)
  % created 2026/03/22 by Bas Kooijman
  
  %% Syntax
  % p = <../surv_gamma.m *surv_gamma*> (scale, shape, x)

  %% Description
  % Calculates the survivor probability of the gamma distribution
  %
  % Input:
  %
  % * scale: scalar with  parameter
  % * shape: scalar with shape parameter 
  % * x: vector with argument values
  %
  % Output
  %
  % * p: vector with survivor probabilities
  
  %% Remarks
  % cf gammaML and gammaStat
  
  %% Example of use
  % surv_gamma(2,3, [3 4 6.5])

  p = 1 - gammainc(x/scale, shape);

