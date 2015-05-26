function dX = dstate0 (t, X_t)
  %% Differential equations for generalized reactor; facultative symbiosis

  global h1_V h2_V h1_S h2_S h1_P h2_P ...
      J1_Sr J2_Sr ...
      k1_E k2_E k1_M k2_M ...
      k1_S k2_S k1_P k2_P ...
      b1_S b2_S b1_P b2_P ...
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ...
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG;

  %% unpack state vector for easy reference
  S1=X_t(1); S2=X_t(2); P1=X_t(3); P2=X_t(4); 
  V1=X_t(5); m1=X_t(6); V2=X_t(7); m2=X_t(8);

  %% help variables for species 1
  a = 1 + S1*b1_S/k1_S + P2*b1_P/k1_P;
  j1_E = (y1_ES*b1_S*S1 + y1_EP*b1_P*P2)/a;
  j1_S = b1_S*S1/a;
  j12_P = b1_P*P2/a;
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % spec growth rate
  j1_P = y1_PS*j1_S + y1_PP*j12_P + y1_PM*k1_M + y1_PG*r1;

  %% help variables for species 2
  a = 1 + S2*b2_S/k2_S + P1*b2_P/k2_P;
  j2_E = (y2_ES*b2_S*S2 + y2_EP*b2_P*P1)/a;
  j2_S = b2_S*S2/a;
  j21_P = b2_P*P1/a;
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % spec growth rate
  j2_P = y2_PS*j2_S + y2_PP*j21_P + y2_PM*k2_M + y2_PG*r2;

  dX = zeros(8,1); % create 8-vector for output

  %% oscillating input
  %%  J1_Srt = J1_Sr*(0.5+sin(t/50)); J2_Srt = J2_Sr*(0.5+sin(t/50));
  
  %% conc substrate 
  dX(1) = J1_Sr - h1_S*S1 - j1_S*V1; 
  dX(2) = J2_Sr - h2_S*S2 - j2_S*V2; 

  %% conc product 
  dX(3) = j1_P*V1 - j21_P*V2 - h1_P*P1; 
  dX(4) = j2_P*V2 - j12_P*V1 - h2_P*P2; 

  %% conc structure
  dX(5) = (r1 - h1_V)*V1; 
  dX(7) = (r2 - h2_V)*V2;

  %% reserve density
  dX(6) = j1_E - k1_E*m1;
  dX(8) = j2_E - k2_E*m2;