function f = findj1_ep6a(j1_E)

  global k1_M k2_M ... % maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P ... % binding probabilities
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global m1 m2 V1 V2 r1 r2;


  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1;
  j2_E = 1/(1/k2 + 1/(rho2_P*j1_P*V1/V2));
  j2_P = y2_PE*j2_E + y2_PM*k2_M + y2_PG*r2;

  f = 1/(1/k1 + 1/(rho1_P*j2_P*V2/V1)) - j1_E;