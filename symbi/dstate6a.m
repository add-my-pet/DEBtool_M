function dX = dstate6a (t, X_t)
  %% Differential equations for the chemostat; obligate symbiosis
  %% Internal population of species 2 only; double product limitation

  global h1_V h2_V ...  % hazard rates
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P ... % binding probabilities
      y1_EV y2_EV ... % costs for structure
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global m1 m2 V1 V2 r1 r2;
  
  opt = optimset('display','off');

  %% unpack state vector for easy reference
  %% V1,m1: species 1; Vs,ms: internal species 2
  V1=X_t(1); m1=X_t(2) ; V2=X_t(3); m2=X_t(4);

  %% help variables 
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % spec growth rate
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % spec growth rate
  %% a1 = rho1_P*y2_PE; a2 = rho2_P*y1_PE;
  %% j1_E0 = (V2/V1)*k1*(a1 - 1/a2)/(a1*V2/V1 + k1/k2);
  [j1_E, val, info] = fsolve('findj1_ep6a',k1,opt);
  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1;
  j2_E = 1/(1/k2 + 1/(rho2_P*j1_P*V1/V2));

  dX = zeros(4,1); % create 4-vector for output
  
  %% conc structure, res density species 1
  dX(1) = (r1 - h1_V)*V1; 
  dX(2) = j1_E - k1_E*m1;

  %% conc structure, res density internal species 2
  dX(3) = (r2 - h2_V)*V2; 
  dX(4) = j2_E - k2_E*m2;