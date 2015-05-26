function f = findj_e6(j_E)

  global k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P b1_S b2_S ... % uptake
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global S1 S2 r1 r2 V1 V2;

    j1_E = j_E(1); j2_E = j_E(2);
    a1 = b1_S*S1;
    b1 = rho1_P *(y2_PE*j2_E + y2_PM*k2_M + y2_PG*r2)*V2/V1;
    a2 = b2_S*S2;
    b2 = rho2_P *(y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1)*V1/V2;
    f = [1/(1/k1 + 1/a1 + 1/b1 - 1/(a1 + b1)) - j1_E, ...
	 1/(1/k2 + 1/a2 + 1/b2 - 1/(a2 + b2)) - j2_E];