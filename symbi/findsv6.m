function f = findsv6(SV)

  global h S1_r S2_r ...
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P b1_S b2_S ... % uptake
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global j1_E j2_E j1_S j2_S;

  %% unpack SV
  S1 = SV(1); S2 = SV(2); V1 = SV(3); V2 = SV(4);
  
  r1 = h; r2 = h;
  a1 = b1_S*S1;
  b1 = rho1_P *(y2_PE*j2_E + y2_PM*k2_M + y2_PG*r2)*V2/V1;
  a2 = b2_S*S2;
  b2 = rho2_P *(y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1)*V1/V2;
  f = [S1_r*h - j1_S*V1 - S1*h, ...
       S2_r*h - j2_S*V2 - S2*h, ...
       1/(1/k1 + 1/a1 + 1/b1 - 1/(a1 + b1)) - j1_E, ...
       1/(1/k2 + 1/a2 + 1/b2 - 1/(a2 + b2)) - j2_E];