function dX = dstate6 (t, X_t)
  %% Differential equations for generalized reactor; obligate symbiosis
  %% Internal population of species 2 only; no mantle space

  global h1_V h2_V h1_S h2_S h1_P h2_P J1_Sr J2_Sr ...
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P b1_S b2_S ... % uptake
      y1_EV y2_EV y1_es y2_es y12_PE y21_PE ... % costs for structure, reserves
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global S1 S2 r1 r2 V1 V2;
  
  opt = optimset('display', 'off');

  %% unpack state vector for easy reference
  %% Si: substrate i in free space
  S1=X_t(1); S2=X_t(2); 
  %% Pi: product i in free space
  P1=X_t(3); P2=X_t(4);
  %% V1,m1: species 1; Vs,ms: internal species 2
  V1=X_t(5); m1=X_t(6) ; V2=X_t(7); m2=X_t(8);

  %% help variables
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % spec growth rate
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % spec growth rate

  [j_E, val, info] = fsolve('findj_e6',[k1 k2], opt);
  j1_E = j_E(1); j2_E = j_E(2);
  
  j1_S  = j1_E/y1_es;
  j12_P = y12_PE*j1_E;
  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1;

  j2_S  = j2_E/y2_es;
  j21_P = y21_PE*j2_E;
  j2_P = y2_PE*j2_E + y2_PM*k2_M + y2_PG*r2;

  dX = zeros(8,1); % create 8-vector for output

  %% oscillating input
  %%  J1_Srt = J1_Sr*(0.5+sin(t/50)); J2_Srt = J2_Sr*(0.5+sin(t/50));
  
  %% conc substrate 
  dX(1) = J1_Sr - h1_S*S1 - j1_S*V1; 
  dX(2) = J2_Sr - h2_S*S2 - j2_S*V2;

  %% conc product 
  dX(3) = - h1_P*P1 - j21_P*V2 + j1_P*V1;
  dX(4) = - h2_P*P2 - j12_P*V1 + j2_P*V2;

  %% conc structure, res density species 1
  dX(5) = (r1 - h1_V)*V1; 
  dX(6) = j1_E - k1_E*m1;

  %% conc structure, res density internal species 2
  dX(7) = (r2 - h2_V)*V2; 
  dX(8) = j2_E - k2_E*m2;