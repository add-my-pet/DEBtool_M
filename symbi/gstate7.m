function X = gstate7 (X_t)
  %% Steady state values for the chemostat; obligate symbiosis
  %% One structure, 2 reserves
  %% X_t: state vector with initial estimates
  %%   only S1, S2, V, m1, m2 are used
  %% X: state vector with steady state values
  %%   S1, S2, P1, P2, E1, E2, V, m1, m2

  global h S1_r S2_r ...
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      b1_S b2_S kap1 kap2 ... % uptake rates, recovery fractions
      y1_EV y2_EV y1_ES y2_ES y12_PE y21_PE ... % costs for structure, reserves
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
      
  opt = optimset('display','off');

  r = h; % spec growth rate equal to throughput rate

  X = zeros(9,1); % create 9-vector for output
  %% find S1, S2, V, m1, m2 numerically; unpack for easy reference
  [X([1 2 7 8 9]), val, info] = fsolve('findsvm7', X_t([1 2 7 8 9]),opt);
  S1 = X(1); S2 = X(2); V = X(7); m1 = X(8); m2 = X(9);

  %% help variables 
  j1_S = k1*S1/(S1+k1/b1_S); % spec substr 1 consumption
  j1_E = y1_ES*j1_S; % spec synthesis of reserve 1
  j12_P = y12_PE*j1_E; % spec consumption of prod 2
  j1_P = y1_PE*j1_E + y1_PM*k1_M + y1_PG*r; % spec prod of prod 1

  j2_S = k2*S2/(S2+k2/b2_S);
  j2_E = y2_ES*j2_S;
  j21_P = y21_PE*j2_E;
  j2_P = y2_PE*j2_E + y2_PM*k2_M + y2_PG*r;

  P1 = V*(j1_P - j21_P)/h; % prod 1
  P2 = V*(j2_P - j12_P)/h; % prod 2
  E1 = V*((k1_E-r)*m1 - (k1_M-r)*y1_EV)*(1-kap1)/h; % excreted res 1
  E2 = V*((k2_E-r)*m2 - (k2_M-r)*y2_EV)*(1-kap2)/h; % excreted res 2
  X([3 4 5 6]) = [P1 P2 E1 E2]; % copy to output