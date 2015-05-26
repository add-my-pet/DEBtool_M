function r = rrod(p, X)
  %% r = rrod(p, X)
  %% X: substrate concentration
  %% r: specific growth rate of rods; cf Fig 9_11 {329}
  
  %% unpack parameters
  K = p(1); % half saturation constant
  g = p(2); % investment ratio
  ld = p(3); % scaled length at division
  kM = p(4); % maintenance rate coefficient
  delta3 = p(5)/ 3; % aspet ratio
  
  f = X(:,1) ./ (K + X(:,1)); % scaled functional response
  r = kM * ((1 - delta3) * f/ ld - 1) ./ (f/ g + 1);
  r = r .* log(2) ./ (log(max(1e-8,(2 * (1 - ld ./ f)) ./ (1 + delta3 - ld ./ f))));
  r = max(0,r);