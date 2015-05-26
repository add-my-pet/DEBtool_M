function p = frac(z,x)
  %  Created 2002/04/21 by Bas Kooijman
  %
  %% Description
  %  Calculates the empirical survivor probabilities from a number of random trials
  
  %% Input
  %  z: n-vector of trials from some p.d.f. or prob distr.
  %  x: m-vector of argument values
  %
  %% Output
  %  p: m-vector of fractions of z-values that exceed x
  %
  %% Example of use
  %  p = frac(randn(100,1), [-1; -0.5; 0; 0.5; 1])

  %% Code
  nx = length(x);
  nz = length(z);
  p=x;
  for i=1:nx
    p(i)=sum(x(i)<z);
  end
  p = p/nz;
