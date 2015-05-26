%% Parameters for 'endosym'
%%   modified 2009/09/29
%%   2 interacting species each having 1 structure (V) and 1 reserve (E)
%%   each species eats one substrate (S) and one product (P)
%% Internal population of species 2 only; no mantle space
%% Substrates and products in environment (free) only
%%
%% Control-parameters:
%%   hazard rates h1_V, h2_V, h1_S, h2_S, h1_P, h2_P or h
%%   supply fluxes J1_Sr, J2_Sr or supply concentrations S1_r, S2_r

global h h1_V h2_V h1_S h2_S h1_P h2_P ... % reactor drains
    J1_Sr J2_Sr S1_r S2_r ... % reactor feeding
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      rho1_P rho2_P b1_S b2_S ... % uptake
      y1_EV y2_EV y1_ES y2_ES y12_PE y21_PE ... % costs for structure, reserves
      y1_PE y2_PE y1_PM y2_PM y1_PG y2_PG ... % product yields
      istate; % initial values of state variables

h = 0.16;                        % spec throughput rate of the chemostat
S1_r = 100; S2_r = 200;          % conc substrate in feed 
h1_V=h; h2_V=h; h1_S=h; h2_S=h; h1_P=h; h2_P=h; % hazard rates equal to throughput rate  
J1_Sr = h*S1_r; J2_Sr = h*S2_r;  % supply fluxes from supply concentrations

k1_E = 5.5;  k2_E = 3.5;    % reserve-turnover rate
k1_M = 0.02; k2_M = 0.04;  % maintenance rate coeff
k1 = 2; k2 = 1;           % max assimilation rate

rho1_P  = 0.8; rho2_P  = 0.9; % binding probabilities
b1_S  = 0.6; b2_S  = 0.2;     % uptake of substrate

y1_EV = 1.5; y2_EV = 1.2;   % yield of E on V (>1 since E -> V)
y1_ES = 1.2; y2_ES = 1.5;   % yield of E on S 
y12_PE = 0.2; y21_PE = 0.2; % yield of P on E

y1_PE = 2; y2_PE = 2; % yield of P on assimilation
y1_PM = 6; y2_PM = 3; % yield of P on maintenance
y1_PG = 0; y2_PG = 2; % yield of P on growth

%% constant ratio of structures for y1_PE, y2_PE > 0; k2_M > k1_M
%% k_E = k1_E = k2_E; k1 = k2 = 1e50; y1_PG = y2_PG = 0; y2_ES = 500;
%% y1_PM = y1_PE*y1_EV*(k_E/k1_M)*(k2_M - k1_M)/(k_E + k2_M);
 
istate = [S1_r S2_r 0 0 0.1 .5 .1 0.5]; % initial state values (8) 
%% substrates, products, V,m-spec-1, V,m-spec-2
%% S1 S2 P1 P2 V1 m1 V2 m2