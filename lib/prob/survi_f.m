function [x info] = survi_f (nu, F)
  %  created 2005/10/02 by Bas Kooijman; modified 2008/08/08
  %
  %% Description
  %  calculates the inverse survivor probability of the F distribution
  %
  %% Input
  %  nu: (2,1)-vector with parameters (degrees of freedom; integers)
  %  F: vector with survivor probabilities
  %
  %% Output
  %  x: vector with argument values for which the survivor function
  %     equals F
  %  info: indicator for success (1); 0 otherwise
    
  global NU f;
  F = reshape(F, max(size(F)), 1);
  NU=nu; f = F;
  
  [x flag info] = fsolve('findf', - log(f)/5);
	     
