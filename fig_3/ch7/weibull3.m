function f = weibull3(p, t)
  f = p(1) * exp(- (p(2) * t(:,1)) .^ 3);
