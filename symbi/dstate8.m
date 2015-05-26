function dX = dstate8 (t, X_t)
  %% Differential equations for generalized reactor
  %% Single species, 1 structure, 1 reserve, 2 substrates, 2 products

  global h_V h1_S h2_S h1_P h2_P J1_Sr J2_Sr ...% feeding, removal pars
      k_E k_M ... % res turnover, maintenance
      k ... % max assimilation
      b1_S b2_S ... % uptake rates
      y_EV y1_es y2_es y12_PE y21_PE ...
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
 
  %% unpack state vector for easy reference
  S1=X_t(1); S2=X_t(2); P1=X_t(3); P2=X_t(4); V=X_t(5); m=X_t(6);

  %% help variables
  j_E = 1/(1/k + 1/(S1*b1_S) + 1/(S2*b2_S) - 1/(S1*b1_S + S2*b2_S));
  j1_S = j_E/y1_es; j2_S = j_E/y2_es;

  r = (k_E*m - k_M*y_EV)/(m + y_EV); % spec growth rate

  j12_P = y12_PE*j_E;
  j1_P = y1_PE*j_E + y1_PM*k_M + y1_PG*r;

  j21_P = y21_PE*j_E;
  j2_P = y2_PE*j_E + y2_PM*k_M + y2_PG*r;

  dX = zeros(6,1); % create 4-vector for output

  %% oscillating input
  %%  J1_Srt = J1_Sr*(0.5+sin(t/50)); J2_Srt = J2_Sr*(0.5+sin(t/50)); 
  
  %% conc substrates
  dX(1) = J1_Sr - h1_S*S1 - j1_S*V; 
  dX(2) = J2_Sr - h2_S*S2 - j2_S*V; 

  %% conc products
  dX(3) = (j1_P - j21_P)*V - h1_P*P1; 
  dX(4) = (j2_P - j12_P)*V - h2_P*P2; 

  %% conc structure
  dX(5) = (r - h_V)*V; 

  %% reserve density
  dX(6) = j_E - k_E*m;