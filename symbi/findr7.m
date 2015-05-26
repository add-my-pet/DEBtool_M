function f = findr7 (r)
  %% created: 2001/09/10 by Bas Kooijman
  %% called from dstate7 to find growth rate; see p169 of DEB-book
  global m1 m2 k1_E k2_E y1_EV y2_EV k1_M k2_M;

  a1 = (k1_E - r)*m1/y1_EV - k1_M;
  a2 = (k2_E - r)*m2/y2_EV - k2_M;
  
  f = 1/(1/a1 + 1/a2 - 1/(a1+a2)) - r;