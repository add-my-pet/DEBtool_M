function S = weibull(p,a)
  S = exp(- (p(1) * a(:,1)) .^ p(2));
