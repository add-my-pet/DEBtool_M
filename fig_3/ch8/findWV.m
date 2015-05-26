function f = findWV(WV)
  %% w: total body wet weight in g
  %% WV: structural body weight in g
  %% p: w_E [M_Em] V_m^{-1/3} in g^-1/3
  global w p;
  f = w - WV - p*WV^(4/3);
