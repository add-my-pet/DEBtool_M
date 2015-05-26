function X = gstate6 (X_t)
  %% created 2001/09/10 by Bas Kooijman
  %% Differential equations for the chemostat; obligate symbiosis
  %% Internal population of species 2 only (free endosymbionts)
  %% X_t: S1 S2 P1 P2 V1 m1 V2 m2 (initial estimates for X)
  %%   only S1 S2 V1 V2 are used; calls 'findsv6'
  %% test output by dstate6(X), but don't forget to set
  %%   J1_Sr = h*S1_r; J2_Sr = h*S2_r;
  %%   h1_S = h2_S = h1_P = h2_P = h1_V = h2_V = h;
  %% test: d = dstate6(X); (d'*d)< 1e-15 must hold

  global h Sr_1 Sr_2 ... % reactor controls
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P b1_S b2_S ... % uptake
      y1_EV y2_EV y1_es y2_es y12_PE y21_PE ... % costs for structure, reserves
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global r1 r2 j1_E j2_E j1_S j2_S;

  opt = optimset('display','off');
  
  %% help variables for species 1
  r1 = h; % spec growth rate
  m1 = y1_EV*(k1_M+r1)/(k1_E-r1); % res density
  j1_E = k1_E*m1; % spec assimilation rate of spec 1
  j1_S  = j1_E/y1_es; % spec consumption of substr 1 by spec 1
  j12_P = y12_PE*j1_E; % spec consumption of prod 2 by spec 1
  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*r1; % spec production of prod
  
  %% help variables for internal species 2
  r2 = h; % spec growth rate
  m2 = y2_EV*(k2_M+r2)/(k2_E-r2); % res density
  j2_E = k2_E*m2; % spec assimilation rate of spec 2
  j2_S  = j2_E/y2_es;  % spec consumption of substr 2 by spec 2
  j21_P = y21_PE*j2_E; % spec consumption of prod 1 by spec 2
  j2_P = y2_PE*j2_E + y2_PM*k2_M + y2_PG*r2; % spec production of prod

  X = zeros(8,1);
  [X([1 2 5 7]), val ,info] = fsolve('findsv6',X_t([1 2 5 7]),opt);
  P1 = (j1_P*X(5) - j21_P*X(7))/h; % product 1 conc
  P2 = (j2_P*X(7) - j12_P*X(5))/h; % product 2 conc 
  X([3 4 6 8]) = [P1 P2 m1 m2];