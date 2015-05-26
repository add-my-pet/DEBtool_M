function f = hyp_shift(p,X)
  f = p(2) * (X(:,1) + p(3)) ./ (p(1) + p(3) + X(:,1));
