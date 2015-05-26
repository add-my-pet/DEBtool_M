function f = findsv8(SV)

  global h S1_r S2_r ...
      k_E k_M ... % res turnover, maintenance
      k ... % max assimilation
      b1_S b2_S ... % uptake
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global j_E j1_S j2_S;

  %% unpack SV
  S1 = SV(1); S2 = SV(2); V = SV(3);
  
  r = h;
  a1 = b1_S*S1;
  a2 = b2_S*S2;
  f = [S1_r*h - j1_S*V - S1*h, ...
       S2_r*h - j2_S*V - S2*h, ...
       1/(1/k + 1/a1 + 1/a2 - 1/(a1 + a2)) - j_E];