function f = fbert(p,a)
  %% feeding during von Bertalanffy growth
  f = (p(2) - (p(2) - p(1)) * exp( - p(3) * a(:,1))).^2;
