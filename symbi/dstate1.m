function dX = dstate1 (t, X_t)
  %% Differential equations for generalized reactor
  %% Free living species 1 and 2
  %% Transition from facultative to obligate symbiosis

  global h1_V h2_V h1_S h2_S h1_P h2_P h J1_Sr J2_Sr S1_r S2_r...
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
  jSc = S1*b1_S; jPc = P2*b1_P; jScc = S1*b1_SP; jPcc = P2*b1_PS;
  jc = jSc + jPc;
  kt = k1 + ki1_S + ki1_P;
  Theta = jScc*jPcc*k1 + jScc*k1_S*(k1+ki1_P) + jPcc*k1_P*(k1+ki1_S) ...
      + k1_S*k1_P*kt;
  ThetaS = jScc*(jc*ki1_P + jSc*k1) + jSc*k1_P*kt;
  ThetaP = jPcc*(jc*ki1_S + jPc*k1) + jPc*k1_S*kt;
  ThetaSP = jScc*jPcc*jc + jScc*jPc*k1_S + jPcc*jSc*k1_P;
  Thetat = Theta + ThetaS + ThetaP +  ThetaSP;
  thetaS = ThetaS/Thetat; thetaP = ThetaP/Thetat; thetaSP = ThetaSP/Thetat;
 
  j1_E = y1_ES*k1_S*thetaS + y1_EP*k1_P*thetaP + ...
      (y1_ES*ki1_S+y1_EP*ki1_P+y1_Et*k1)*thetaSP;
  j1_S = k1_S*thetaS + (ki1_S+y1_St*k1)*thetaSP;
  j12_P = k1_P*thetaP + (ki1_P+y1_Pt*k1)*thetaSP;
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % spec growth rate
  j1_P = y1_PS*j1_S + y1_PP*j12_P + y1_PM*k1_M + y1_PG*r1;

  %% help variables for species 2; re-use kt, j's, Theta's, theta's
  jSc = S2*b2_S; jPc = P1*b2_P; jScc = S2*b2_SP; jPcc = P1*b2_PS;
  jc = jSc + jPc;
  kt = k2 + ki2_S + ki2_P;
  Theta = jScc*jPcc*k2 + jScc*k2_S*(k2+ki2_P) + jPcc*k2_P*(k2+ki2_S) ...
      + k2_S*k2_P*kt;
  ThetaS = jScc*(jc*ki2_P + jSc*k2) + jSc*k2_P*kt;
  ThetaP = jPcc*(jc*ki2_S + jPc*k2) + jPc*k2_S*kt;
  ThetaSP = jScc*jPcc*jc + jScc*jPc*k1_S + jPcc*jSc*k1_P;
  Thetat = Theta + ThetaS + ThetaP +  ThetaSP;
  thetaS = ThetaS/Thetat; thetaP = ThetaP/Thetat; thetaSP = ThetaSP/Thetat;

  j2_E = y2_ES*k2_S*thetaS + y2_EP*k2_P*thetaP + ...
      (y2_ES*ki2_S+y2_EP*ki2_P+y2_Et*k2)*thetaSP;
  j2_S = k2_S*thetaS + (ki2_S+y2_St*k2)*thetaSP;
  j21_P = k2_P*thetaP + (ki2_P+y2_Pt*k2)*thetaSP;
  r2 = (k2_E*m2 - k2_M*y2_EV)/(m2 + y2_EV); % spec growth rate
  j2_P = y2_PS*j2_S + y2_PP*j21_P + y2_PM*k2_M + y2_PG*r2;

  dX = zeros(8,1); % create 8-vector for output

  %% oscillating input
  %%  J1_Srt = J1_Sr*(0.5+sin(t/50)); J1_Srt = J2_Sr*(0.5+sin(t/50));
  
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