function X = gstate8 (X_t)
  %% Steady state values for the chemostat; obligate symbiosis
  %% One structure, 1 reserve
  %% X_t: state vector with initial estimates
  %%   only S1, S2, V are used
  %% X: state vector with steady state values
  %%   S1, S2, P1, P2, V, m

  global h S1_r S2_r ...
      k_E k_M ... % res turnover, maintenance
      k ... % max assimilation
      b1_S b2_S ... % uptake rates
      y_EV y1_es y2_es y12_PE y21_PE ... % costs for structure, reserves
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields
  global j_E j1_S j2_S; % necessary for 'findsv8'
  
  opt = optimset('display','off');

  r = h; % spec growth rate equal to throughput rate
  m = y_EV*(k_M+r)/(k_E-r); % res density

  %% help variables 
  j_E = k_E*m; % spec assimilation rate
  j1_S = j_E/y1_es; % spec substrate 1 consumption
  j2_S = j_E/y2_es; % spec sunstrate 2 consumption

  j12_P = y12_PE*j_E; % spec consumption of prod 2
  j1_P = y1_PE*j_E + y1_PM*k_M + y1_PG*r; % spec prod of prod 1

  j21_P = y21_PE*j_E;
  j2_P = y2_PE*j_E + y2_PM*k_M + y2_PG*r;

  X = zeros(6,1); % create 6-vector for output
  %% find S1, S2, V numerically; unpack for easy reference
  [X([1 2 5]), val ,info] = fsolve('findsv8', X_t([1 2 5]),opt);
  if info <= 0
      fprintf('convergence problems in root finding \n')
  end
  
  S1 = X(1); S2 = X(2); V = X(5);

  P1 = V*(j1_P - j21_P)/h; % prod 1
  P2 = V*(j2_P - j12_P)/h; % prod 2
  X([3 4 6]) = [P1 P2 m]; % copy to output