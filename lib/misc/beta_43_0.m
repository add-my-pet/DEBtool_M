function B = beta_43_0(x)
  % created 2000/08/16 by Bas Kooijman, modified 2013/10/02
  %
  %% Description
  %  particular incomplete beta function 
  %    B_x(4/3,0) = \int_0^x t^(4/3-1) (1-t)^(-1) dt

  %
  %% Input
  %  x: scalar with argument
  %
  %% Output
  %  incomplete beta function with parameters 4/3, 0
  %
  %% Remarks
  %  n = 0:100;
  %  B = .75 * x^(4/3) * (gamma(7/3)/ gamma(4/3)) * ...
  %     sum(gamma(n + 4/3) .* x.^n ./ gamma(n + 7/3));
  %  beta_43_0(x1) - beta_43_0(x0) = beta0(x0,x1)
  %    where beta0 is in DEBtool_M/animal, which is much faster and more accurate
  %    beta_43_0 is just meant for testing beta0
  %
  %% Example of use
  %  beta_43_0(.2)

  %% Code
  B = quad(@(y)y .^ (1/3) ./ (1 - y), 0, x);
  