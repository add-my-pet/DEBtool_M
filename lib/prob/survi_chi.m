%% surv1_chi
% calculates the inverse of the survivor function of the Chi-square distribution

function x = survi_chi (nu, p)
% created 2021/02/09 by Bas Kooijman

  %% Syntax
  % x = <../survi_chi.m *survi_chi*> (nu, p, x0)

  %% Description
  % Calculates the inverse of the survivor function of the Chi-square distribution
  %
  % Input:
  %
  % * nu: scalar with parameter (degrees of freedom)
  % * p: n-vector with survivor probabilities
  %
  % Output
  %
  % * x: n-vector with argument values 
  
  %% Remarks
  % cf surv_chi for the survivor probability of the Chi-square distribution
  
  %% Example of use
  % survi_chi(2, [.99 .5 .1])
    
  survi = @(arg,nu,p) surv_chi(nu,arg) - p;
  n = length(p); x = zeros(n,1);
  for i = 1:n
    x(i) = fzero(@(arg) survi(arg, nu, p(i)), [0 1e4*nu]); 
  end
	     
end
