function f = hyp(p, xyw)
  % p: (1) maximum (2) saturation coefficient
  
  f = p(1) * xyw(:,1)./ (p(2) + xyw(:,1));