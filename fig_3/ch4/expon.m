function f = expon(p,x)
  f = p(1) * exp(-p(2) * x(:,1));
