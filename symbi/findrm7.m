function f = findrm7 (rm)
  %% created: 2001/09/10 by Bas Kooijman
  %% called from shstate7 to find max throughput, res densities
  global S1_r S2_r k1 k2 b1_S b2_S y1_ES y2_ES kap1 kap2 ...
      k1_E k2_E y1_EV y2_EV k1_M k2_M;

  r = rm(1); m1 = rm(2); m2 = rm(3);
  
  j1_S = k1*S1_r/(S1_r+k1/b1_S);
  j1_E  = y1_ES*j1_S;

  j2_S = k2*S2_r/(S2_r+k2/b2_S);
  j2_E  = y2_ES*j2_S;

  a1 = (k1_E - r)*m1/y1_EV - k1_M;
  a2 = (k2_E - r)*m2/y2_EV - k2_M;
  
  f = [1/(1/a1 + 1/a2 - 1/(a1+a2)) - r, ...
       j1_E - (1-kap1)*(k1_E-r)*m1 - kap1*y1_EV*(k1_M+r) - r*m1, ...
       j2_E - (1-kap2)*(k2_E-r)*m2 - kap2*y2_EV*(k2_M+r) - r*m2];