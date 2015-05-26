function f = fnrod(p, aVw)
  %% Eq (3.42) {109}: volume at age in rods
  f = p(2) - (p(2) - p(1)/2) * exp( - p(3) * aVw(:,1));
