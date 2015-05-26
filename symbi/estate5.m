function dX = estate5 (X_t)
  %% Differential equations for generalized reactor; obligate symbiosis
  %%   the same as dstate5, but with a single argument only
  %% Internal population of species 2 only; no mantle space
  %% Substrate 2, and product 1 and 2 in species 1 and in environment (free)

  global h1_V h2_V h1_S h2_S h1_P h2_P ... % reactor drain controls
      J1_Sr J2_Sr ... % reactor feeding controls
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      b1_S b2_S b1_P b2_P rho1_P rho2_P ... % uptake
      b2_Ss b2_sS ... % substrate transport
      b1_Ps b1_sP b2_Ps b2_sP ... % product transport 
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ... % costs for structure, reserves
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG; % product yields
  global h S1_r S2_r; % for calls from 'shstate5'

  %% unpack state vector for easy reference
  %% Si, Sis: substrate i in free space, internal
  S1=X_t(1);  S2=X_t(2); S2s=X_t(3);
  %% Pi, Pis: product i in free space, internal
  P1=X_t(4); P1s=X_t(5); P2=X_t(6); P2s=X_t(7);
  %% V1,m1: species 1; Vs,ms: internal species 2
  V1=X_t(8); m1=X_t(9) ; Vs=X_t(10); ms=X_t(11);

  %% help variables for internal species 2
  a1 = b2_S*S2s; a2 = b2_P*P1s; % just for j2_Es
  j2_Es = 1/(1/k2 + 1/a1 + 1/a2 - 1/(a1+a2)); % spec assim spec 2 internal
  j2_Ss = j2_Es/y2_ES; % spec substr 2 consumption
  j21_Ps = j2_Es/y2_EP; % spec prod 1 consumpton
  rs = (k2_E*ms - k2_M*y2_EV)/(ms + y2_EV); % spec growth rate
  j2_Ps = y2_PS*j2_Ss + y2_PP*j21_Ps + y2_PM*k2_M + y2_PG*rs; % spec production

  %% help variables for species 1
  a1 = b1_S*S1; a2 = b1_P*P2 + rho1_P*j2_Ps*Vs/V1; % just for j1_E
  j1_E = 1/(1/k1 + 1/a1 + 1/a2 - 1/(a1+a2)); % spec assim spec 1
  j1_S = j1_E/y1_ES; % spec substr 1 consumption
  j12_P = j1_E/y1_EP; % spec prod 2 consumption
  j12_Pm = j12_P*b1_P*P2/(b1_P*P2+j2_Ps*Vs/V1); % consump from mantle space
  j12_Ps = j12_P - j12_Pm; % consump from internal 
  r1 = (k1_E*m1 - k1_M*y1_EV)/(m1 + y1_EV); % spec growth rate
  j1_Ps = y1_PS*j1_S + y1_PP*j12_P + y1_PM*k1_M + y1_PG*r1; % spec production

  dX = zeros(11,1); % create 11-vector for output

  %% oscillating input
  %%  J1_Srt = J1_Sr*(0.5+sin(t/50)); J2_Srt = J2_Sr*(0.5+sin(t/50));
  
  %% conc substrate 
  dX(1) = J1_Sr - h1_S*S1 - j1_S*V1;  % substr 1
  dX(2) = J2_Sr - h2_S*S2 - b2_Ss*S2*V1 + b2_sS*S2s*V1;
				      % free substr 2
  dX(3) = - h2_S*S2s - j2_Ss*Vs + b2_Ss*S2*V1 - b2_sS*S2s*V1;
				      % internal substr 2

  %% conc product 
  dX(4) = - h1_P*P1 - b1_Ps*P1*V1 + b1_sP*P1s*V1;
				      % free product 1
  dX(5) = j1_Ps*V1 - j21_Ps*Vs - h1_P*P1s + b1_Ps*P1*V1 - b1_sP*P1s*V1;
				      % internal product 1
  dX(6) = - j12_Pm*V1 - h2_P*P2 - b2_Ps*P2*V1 + b2_sP*P2s*V1;
				      % free product 2
  dX(7) = j2_Ps*Vs - j12_Ps*V1 - h2_P*P2s + b2_Ps*P2*V1 - b2_sP*P2s*V1;
				      % internal product 2

  %% conc structure, res density species 1
  dX(8) = (r1 - h1_V)*V1; 
  dX(9) = j1_E - k2_E*m1;

  %% conc structure, res density internal species 2
  dX(10) = (rs - h2_V)*Vs; 
  dX(11) = j2_Es - k2_E*ms;