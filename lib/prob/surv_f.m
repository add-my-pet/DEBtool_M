function Q = surv_f(nu, F)
  %  created 2005/10/02 by Bas Kooijman; modified 2008/08/08
  %
  %% Description
  %  Calculates survivor function of F-distribution
  %
  %% Input
  %  nu: (2,1)-vector with degrees of freedom (integers)
  %  F: (n,1)-vector of argument values
  %% Output
  %  Q: (n,1)-vector with survivor probabilities
  %
  %% Remarks
  %  Abramowitz & Segun 1965, {946} 26.6.6-8
  %  warning: does not work properly for v1 and v2 odd while v1 > 1 !!!!!
  
  %% Code
  v1 = nu(1); v2 = nu(2); % degrees of freedom
  F = max(1e-8,F(:)); x = v2 ./ (v2 + v1 * F); nx = length(x); 
  if 0 == mod(v1, 2) % v1 even
    A = x .^ ((v1 + v2 - 2)/ 2);
    V = 1 ./ x - 1;
    M = cumprod([ones(nx,1), V(:,ones(1, v1/ 2 - 1))], 2);
    Z = 2 * (1: (v1/ 2 - 1));
    Y = v1 + v2 - Z;
    C = cumprod([1, Y ./ Z])';
    Q = A .* (M * C);
  elseif 0 == mod(v2, 2) % v2 even
    A = (1 - x) .^ ((v1 + v2 - 2)/ 2);
    V = x ./ (1 - x);
    M = cumprod([ones(nx,1), V(:,ones(1, v2/ 2 - 1))], 2);
    Z = 2 * (1: (v2/ 2 - 1));
    Y = v1 + v2 - Z;
    C = cumprod([1, Y ./ Z])';
    Q = 1 - A .* (M * C);
  else % v1 and v2 both odd
    th = atan(sqrt(F * v1/ v2));
    cth = cos(th); cth2 = cth .^ 2;
    sth = sin(th); sth2 = sth .^ 2;
    if v2 == 1
      A = 2 * th/ pi;
      B = 0;
    else
      Y = 2 : 2: v2 - 3;
      [cth, cth2 * (Y ./ (1 + Y))]
      V = sum(cumprod([cth, cth2 * (Y ./ (1 + Y))],2),2);
      A = (2/ pi) * (th + sth .* V);

      Y = (v2 + 1) : 2 : (v1 + v2 - 4); Z = 3 : 2 : (v1 - 2);
      V = sum(cumprod([ones(nx,1), sth2 * (Y ./ Z)],2),2);
      B = 2 * gamma((v2 - 1)/ 2) / (sqrt(pi) * gamma((v2 - 2)/ 2));
      B = B * V .* sth .* cth .^ v2;
    end
    if v1 == 1      
      B=0;
    end
    
    Q = 1 - A + B;
  end
