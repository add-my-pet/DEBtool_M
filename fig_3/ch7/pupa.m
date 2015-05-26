function f = pupa(p, t)
  f = p(1) - ((p(2) + t(:,1))/  p(3)).^3;
