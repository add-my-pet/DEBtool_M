%% surv_chi
% calculates the survivor probability of the Chi-square distribution

%%
function F = surv_chi (nu, x)
  % created 2002/04/09 by Bas Kooijman
  
  %% Syntax
  % F = <../surv_chi.m *surv_chi*> (nu, x)

  %% Description
  % Calculates the survivor probability of the Chi-square distribution
  %
  % Input:
  %
  % * nu: scalar with parameter (degrees of freedom)
  % * x: vector with argument values
  %
  % Output
  %
  % * F: vector with survivor probabilities
  
  %% Remarks
  % cf survi_chi the inverse survivor probability of the Chi-square distribution
  
  %% Example of use
  % surv_chi(2,[3 4 6.5])

  
  x = reshape(x, length(x), 1);
  F = 1 - gammainc(nu/2,x/2);

