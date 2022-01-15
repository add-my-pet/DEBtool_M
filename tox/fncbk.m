function f = fncbk (x, t, c)
  %  created 2002/02/05 by Bas Kooijman
  %  routine called by lc503
  %  f = 0 for cbk = [C0, Bk, Ke] given 3 lc50's
  

  %% unpack x
  C0 = x(1); Bk = x(2); Ke = x(3);
  
  t0 = - log(1 - C0./ c)/ Ke;
  f = log(2) + c .* (exp(-Ke * t0) - exp(-Ke * t)) * Bk/ Ke - ...
      Bk * (c - C0) .* (t - t0);
