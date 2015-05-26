function f = findsvm7 (X)
  %% Steady state equations for the chemostat; obligate symbiosis
  %% One structure, 2 reserves
  %% routine called by gstate7

  global h S1_r S2_r ...
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      b1_S b2_S kap1 kap2 ... % uptake rates, recovery fractions
      y1_EV y2_EV y1_ES y2_ES y12_PE y21_PE ... % costs for structure, reserves
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields

  %% unpack state vector for easy reference
  %% Si: substrate i in free space
  S1=X(1); S2=X(2); 
  %% V,m1,m2: structure and reserve densities 1 and 2
  V=X(3); m1=X(4); m2=X(5); r = h;

  %% help variables 
  j1_S = k1*S1/(S1+k1/b1_S);
  j1_E = y1_ES*j1_S;
  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*r;

  j2_S = k2*S2/(S2+k2/b2_S);
  j2_E = y2_ES*j2_S;
  j2_P = y2_PE*j2_E + y2_PM*k2_M + y2_PG*r;

  a1 = (k1_E - r)*m1/y1_EV - k1_M;
  a2 = (k2_E - r)*m2/y2_EV - k2_M;
  
  f = [h*S1_r - h*S1 - j1_S*V, ...
       h*S2_r - h*S2 - j2_S*V, ...
       j1_E - (1-kap1)*(k1_E-r)*m1 - kap1*y1_EV*(k1_M+r) - r*m1, ...
       j2_E - (1-kap2)*(k2_E-r)*m2 - kap2*y2_EV*(k2_M+r) - r*m2, ...
       1/(1/a1 + 1/a2 - 1/(a1+a2)) - h];