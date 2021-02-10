%% surv_chi
% calculates the survivor probability of the Chi-square distribution

%%
function p = surv_chi (nu, x)
<<<<<<< HEAD
  % created 2002/04/09 by Bas Kooijman; modified 2021/02/10
=======
  % created 2002/04/09 by Bas Kooijman, modified 2021/02/10 by Dina Lika
>>>>>>> 810cab6e5e6e9cd9f6e9615e0f50a31850a0e72d
  
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

<<<<<<< HEAD
  p = 1 - gammainc(x(:)/2,nu/2);
=======
  x = reshape(x, length(x), 1);
  p = 1 - gammainc(x/2,nu/2);
>>>>>>> 810cab6e5e6e9cd9f6e9615e0f50a31850a0e72d

