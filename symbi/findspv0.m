function f = findSPV0 (SPV)
  global h S1_r S2_r ... % reactor controls
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance rate coeff
      k1_S k2_S k1_P k2_P ... % dissociation rates
      b1_S b2_S b1_P b2_P ... % association rates
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ... % res, substr, prod costs
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG; % produc yields
  global r1 r2 m1 m2;

  %% unpack SPV for easy reference
  S1 = SPV(1); S2 = SPV(2); P1 = SPV(3); P2 = SPV(4);
  V1 = SPV(5); V2 = SPV(6);

  %% help variables for species 1
  j1_E = k1_E*m1;
  a1 = 1 + S1*b1_S/k1_S + P2*b1_P/k1_P;
  j1_S = b1_S*S1/a1;
  j12_P = b1_P*P2/a1;
  j1_P = y1_PS*j1_S + y1_PP*j12_P + y1_PM*k1_M + y1_PG*r1;

  %% help variables for species 2
  j2_E = k2_E*m1;
  a2 = 1 + S2*b2_S/k2_S + P1*b2_P/k2_P;
  j2_S = b2_S*S2/a2;
  j21_P = b2_P*P1/a2;
  j2_P = y2_PS*j2_S + y2_PP*j21_P + y2_PM*k2_M + y2_PG*r2;

  f = [h*S1_r - h*S1 - j1_S*V1, ...
       h*S2_r - h*S2 - j2_S*V2, ...
       j1_P*V1 - h*P1 - j21_P*V2, ...
       j2_P*V2 - h*P2 - j12_P*V1, ...
       (y1_ES*b1_S*S1 + y1_EP*b1_P*P2)/a1 - j1_E, ...
       (y2_ES*b2_S*S2 + y2_EP*b2_P*P1)/a2 - j2_E];