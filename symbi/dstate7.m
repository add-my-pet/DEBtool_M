function dX = dstate7 (t, X_t)
  %% Differential equations for generalized reactor; obligate symbiosis
  %% One structure, 2 reserves

  global h_V h1_S h2_S h1_P h2_P h1_E h2_E J1_Sr J2_Sr ...
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      b1_S b2_S kap1 kap2 ... % uptake rates, recovery fractions
      y1_EV y2_EV y1_es y2_es y12_PE y21_PE ... % costs for structure, reserves
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global m1 m2; % necessary for 'findr7'
  
  opt = optimset('display', 'off');

  %% unpack state vector for easy reference
  %% Si: substrate i in free space
  S1=X_t(1); S2=X_t(2); 
  %% Pi: product i in free space
  P1=X_t(3); P2=X_t(4);
  %% Ei: excreted reserve i in free space
  E1=X_t(5); E2=X_t(6);
  %% V,m1,m2: structure and reserve densities 1 and 2
  V=X_t(7); m1=X_t(8) ; m2=X_t(9);

  [r, val, info] = fsolve('findr7',findr7(0),opt); % spec growth rate
  if info <= 0
      fprintf('convergence problems in root finding \n')
  end

  %% help variables 
  j1_S = k1*S1/(S1+k1/b1_S);
  j1_E  = y1_es*j1_S;
  j12_P = y12_PE*j1_E;
  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*max(1e-4,r);

  j2_S = k2*S2/(S2+k2/b2_S);
  j2_E  = y2_es*j2_S;
  j21_P = y21_PE*j2_E;
  j2_P = y2_PE*j2_E + y2_PM*k2_M + y2_PG*max(1e-4,r);
  
  dX = zeros(9,1); % create 9-vector for output

  %% oscillating input
  %%  J1_Srt = J1_Sr*(0.5+sin(t/50)); J2_Srt = J2_Sr*(0.5+sin(t/50));

  %% conc substrate 
  dX(1) = J1_Sr - h1_S*S1 - j1_S*V; 
  dX(2) = J2_Sr - h2_S*S2 - j2_S*V;

  %% conc product 
  dX(3) = V*(j1_P - j21_P) - h1_P*P1;
  dX(4) = V*(j2_P - j12_P) - h2_P*P2;

  %% conc excreted reserves
  dX(5) = - h1_E*E1 + V*((k1_E-r)*m1 - (k1_M-r)*y1_EV)*(1-kap1);
  dX(6) = - h2_E*E2 + V*((k2_E-r)*m2 - (k2_M-r)*y2_EV)*(1-kap2);
  
  %% conc structure
  dX(7) = (r - h_V)*V; 

  %% conc res density 1 and 2
  dX(8) = j1_E - (1-kap1)*(k1_E-r)*m1 - kap1*y1_EV*(k1_M+r) - r*m1;
  dX(9) = j2_E - (1-kap2)*(k2_E-r)*m2 - kap2*y2_EV*(k2_M+r) - r*m2;