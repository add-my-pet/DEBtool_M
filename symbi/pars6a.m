%% Parameters for 'endosym'
%%   2 interacting species each having 1 structure (V) and 1 reserve (E)
%%   each species eats one product (P);
%% Autonomous sytem: No control-parameters

global h1_V h2_V ...  % hazard rates
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P ... % binding probabilities
      y1_EV y2_EV ... % costs for structure
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG; % product yields

h1_V = 0.25; h2_V=0.5; % hazard rates for structures

k1_E = 0.25;  k2_E = 1;  % reserve-turnover rate
k1_M = 0.04; k2_M = 0.01; % maintenance rate coeff
k1 = 2; k2 = 0.2;       % max assimilation rate

rho1_P  = .4; rho2_P  = .8; % binding probabilities

y1_EV = 1.5; y2_EV = 1.2; % yield of E on V (>1 since E -> V)

y1_PE = 4; y2_PE = 2; % yield of P on assimilation
y1_PM = 2.0; y2_PM = 0.0; % yield of P on maintenance
y1_PG = 2.0; y2_PG = 4.0; % yield of P on growth