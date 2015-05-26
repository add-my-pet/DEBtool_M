function f = findvh6(vh)

  global h S1_r S2_r ...
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P b1_S b2_S ... % uptake
      y1_EV y2_EV ... % structure yields
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields

  %% unpack vh
  v = vh(1); h = vh(2);
  
  r1 = h; r2 = h;
  m1 = y1_EV*(k1_M+h)/(k1_E-h);
  j1_E = k1_E*m1;
  m2 = y2_EV*(k2_M+h)/(k2_E-h);
  j2_E = k2_E*m2;
  a1 = b1_S*S1_r;
  b1 = rho1_P *(y2_PE*j2_E + y2_PM*k2_M + y2_PG*r2)*v;
  a2 = b2_S*S2_r;
  b2 = rho2_P *(y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1)/v;
  f = [1/(1/k1 + 1/a1 + 1/b1 - 1/(a1 + b1)) - j1_E, ...
       1/(1/k2 + 1/a2 + 1/b2 - 1/(a2 + b2)) - j2_E];