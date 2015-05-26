function r = riso(p, X)
  %% r = riso(p, X)
  %% X: substrate concentration
  %% r: specific growth rate of dividing isomorphs; cf Fig 9_11 {329}
  
  %% unpack parameters
  K = p(1); % half saturation constant
  g = p(2); % investment ratio
  ld = p(3); % scaled length at division
  kM = p(4); % maintenance rate coefficient
  
  f = X(:,1) ./ (K + X(:,1)); % scaled functional response
  r = kM ./ (f/ g + 1);
  r = r * (log(2)/ 3) ./ log(max(1e-8,(f - ld * 2^(-1/3)) ./ (f - ld)));
  r = max(0,r);
