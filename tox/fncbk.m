function f = fncbk (cbk,x)
  %  created 2002/02/05 by Bas Kooijman
  %  routine called by lc503
  %  f = 0 for cbk = [C0, Bk, Ke] given 3 lc50's
  
  global t c; %three exposure times and lc50's

  %% unpack cbk
  C0 = cbk(1); Bk = cbk(2); Ke = cbk(3);
  
  t0 = - log(1 - C0./ c)/ Ke;
  f = log(2) + c .* (exp(-Ke * t0) - exp(-Ke * t)) * Bk/ Ke - ...
      Bk * (c - C0) .* (t - t0);
