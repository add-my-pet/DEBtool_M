function f = findj_epi6a(j_E)

  global k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P ... % binding probabilities
      y1_EV y2_EV ... % costs for structure
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global m1 m2 V1 V2;

  j1_E = j_E(1); j2_E = j_E(2); % assimilation rates

  m1 = j1_E/k1_E; m2 = j2_E/k2_E; % reserve densities
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % spec growth rates
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV);

  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1; % product formations
  j2_P = y2_PE*j2_E + y2_PM*k2_M + y2_PG*r2;

  f = [1/(1/k1 + 1/(rho1_P*j2_P*V2/V1)) - j1_E, ...
       1/(1/k2 + 1/(rho2_P*j1_P*V1/V2)) - j2_E];