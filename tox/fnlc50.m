function f = fnlc50 (c)
  %  created 2002/02/05 by Bas Kooijman
  %  routine called by shlc50
  %  f = 0 for c = lc50
  
  global t C0 Bk Ke;
  
  t0 = - log(1 - C0/ c)/ Ke;
  f = log(2) + c * (exp(-Ke * t0) - exp(-Ke * t)) * Bk/ Ke - ...
      Bk * (c - C0) * (t - t0);

