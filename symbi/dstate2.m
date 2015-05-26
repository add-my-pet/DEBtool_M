function dX = dstate2 (t, X_t)
  %% Differential equations for generalized reactor; obligate symbiosis
  %% Free living species 1 and 2

  global h1_V h2_V h1_S h2_S h1_P h2_P h J1_Sr J2_Sr S1_r S2_r ...
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 k1_S k2_S ki1_S ki2_S k1_P k2_P ki1_P ki2_P ... % max assimilation
      b1_S b2_S b1_SP b2_SP b1_P b2_P b1_PS b2_PS ... % uptake
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ... % costs for structure, reserve
      y1_Et y2_Et y1_St y2_St y1_Pt y2_Pt ... % costs for reserve
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG ... % product yields
      istate; % initial values of state variables

  %% unpack state vector for easy reference
  S1=X_t(1); S2=X_t(2); P1=X_t(3); P2=X_t(4);
  V1=X_t(5); m1=X_t(6); V2=X_t(7); m2=X_t(8);

  %% help variables for species 1
  k = k1*y1_Et; a1 = S1*b1_S*y1_Et; a2 = P2*b1_P*y1_Et;
  j1_E = 1/(1/k + 1/a1 + 1/a2 - 1/(a1+a2));
  j1_S = j1_E*y1_St/y1_Et;
  j12_P = j1_E*y1_Pt/y1_Et;
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % spec growth rate
  j1_P = y1_PS*j1_S + y1_PP*j12_P + y1_PM*k1_M + y1_PG*max(1e-4,r1);

  %% help variables for species 2; re-use k, b_S, b_P
  k = k2*y2_Et; a1 = S2*b2_S*y2_Et; a2 = P1*b2_P*y2_Et;
  j2_E = 1/(1/k + 1/a1 + 1/a2 - 1/(a1+a2));
  j2_S = j2_E*y2_St/y2_Et;
  j21_P = j2_E*y2_Pt/y2_Et;
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % spec growth rate
  j2_P = y2_PS*j2_S + y2_PP*j21_P + y2_PM*k2_M + y2_PG*max(1e-4,r2);

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