%% surv_chi
% calculates the survivor probability of the Chi-square distribution

%%
function p = surv_chi (nu, x)
  % created 2002/04/09 by Bas Kooijman, modified 2021/02/10 by Dina Lika
  
  %% Syntax
  % p = <../surv_chi.m *surv_chi*> (nu, x)

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
  % * p: vector with survivor probabilities
  
  %% Remarks
  % cf survi_chi the inverse survivor probability of the Chi-square distribution
  
  %% Example of use
  % surv_chi(2,[3 4 6.5])

  p = 1 - gammainc(x(:)/2,nu/2);

