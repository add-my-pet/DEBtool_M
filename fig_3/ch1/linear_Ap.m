function f = linear_Ap(p, x)
  %% Arrhenius plot: Eq (2.20) {53} with transformed axes
  f = p(1) + p(2) * x(:,1);
