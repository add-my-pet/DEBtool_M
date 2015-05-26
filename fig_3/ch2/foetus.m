function f = foetus (p, aWw)
  f = (p(1) * max(0,aWw(:,1) - p(2))/ 3) .^ 3;

