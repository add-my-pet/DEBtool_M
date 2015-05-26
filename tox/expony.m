function f = expony(p, t, y)
  % p: (1) exponential decay
  f = exp(1).^(-p(1) * t * y'.^p(2));