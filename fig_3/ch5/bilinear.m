function f = bilinear(p, x)
  f = p(1) + p(2) * min(x(:,1), p(3)) + p(4) * max(0, x(:,1) - p(3));

