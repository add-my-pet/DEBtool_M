function f = expon(p, tn)
  % example of function definition for nmsurv
  % p: (1) exponential decay
  f = exp(1).^(-p(1) * tn(:,1));
