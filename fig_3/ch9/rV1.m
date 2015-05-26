function r = rV1(p, X)
  %% r = rV1(p, X)
  %% X: substrate concentration
  %% r: specific growth rate of V1-morphs; cf Fig 9_11 {329}
  
  %% unpack parameters
  K = p(1); % half saturation constant
  g = p(2); % investment ratio
  ld = p(3); % scaled length at division
  kM = p(4); % maintenance rate coefficient
  
  f = X(:,1) ./ (K + X(:,1)); % scaled functional response
  r = max(0, kM * (f/ ld - 1) ./ (f/ g + 1));
