function f = fndjuv (rR)
  %% rR = r/R; apR = ap * R for
  %% R = reprod rate; ap = juv period; r = spec growth rate
  global ApR

  f = exp(rR) - 1 - exp(- ApR * rR); % Eq (9.36) {327}
