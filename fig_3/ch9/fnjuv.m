function f = fnjuv (rR)
  %% rR = r/R; apR = ap * R for
  %% R = reprod rate; ap = juv period; r = spec growth rate
  global ApR

  f = rR - exp(- ApR * rR);
