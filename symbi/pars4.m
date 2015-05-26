%% Parameters for 'endosym'
%%   2 interacting species each having 1 structure (V) and 1 reserve (E)
%%   each species eats one substrate (S) and one product (P)
%%
%% Control-parameters:
%%   hazard rates h1_V, h2_V, h1_S, h2_S, h1_P, h2_P or h
%%   supply fluxes J1_Sr, J2_Sr or supply concentrations S1_r, S2_r

global h1_V h2_V h1_S h2_S h1_P h2_P h ... % reactor drains
    J1_Sr J2_Sr S1_r S2_r ... % reactor feeding
      k1_E k2_E k1_M k2_M ... % res turnover, maintenance
      k1 k2 ... % max assimilation
      b1_S b2_S b1_P b2_P rho1_P rho2_P ... % uptake
      b2_Sm b2_mS b2_Ss b2_sS ... % substrate transport
      b1_Pm b1_mP b2_Pm b2_mP b1_Ps b1_sP b2_Ps b2_sP ... % product transport 
      y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ... % y_ES = y_Et/y_St; y_EP = y_Et/y_Pt
      y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG ...
      istate; % initial values of state variables

h = 0.1;                         % spec throughput rate of the chemostat
S1_r = 100; S2_r = 100;          % conc substrate in feed 
h1_V=h; h2_V=h; h1_S=h; h2_S=h; h1_P=h; h2_P=h; % hazard rates equal to throughput rate  
J1_Sr = h*S1_r; J2_Sr = h*S2_r;  % supply fluxes from supply concentrations

k1_E = 0.3;  k2_E = 0.3;  % reserve-turnover rate
k1_M = 0.01; k2_M = 0.01; % maintenance rate coeff
k1 = 0.1; k2 = 0.2;       % max assimilation rate

b1_S  = 0.06; b2_S  = 0.05; % uptake of substrate
b1_P  = 0.04; b2_P  = 0.06; % uptake of product
rho1_P = 0.8; rho2_P = 0.7; % binding probabilities for product

b2_Sm = 0.1; b2_mS = 0.1; % substrate 2 transport to mantle <-> free
b2_Ss = 0.1; b2_sS = 0.1; % substrate 2 transport to internal <-> mantle
b1_Pm = 0.1; b1_mP = 0.1; % product 1 transport to mantle <-> free
b2_Pm = 0.1; b2_mP = 0.1; % product 2 transport to mantle <-> free
b1_Ps = 0.1; b1_sP = 0.1; % product 1 transport to inernal <-> mantle
b2_Ps = 0.1; b2_sP = 0.1; % product 2 transport to inernal <-> mantle

y1_EV = 1.2; y2_EV = 1.2; % yield of E on V (>1 since E -> V)
y1_ES = 0.8; y2_ES = 0.8; % yield of E on S
y1_EP = 0.2; y2_EP = 0.2; % yield of E on P

y1_PS = 0.1; y2_PS = 0.1; % yield of P on S-assimilation
y1_PP = 0.1; y2_PP = 0.1; % yield of P on P-assimilation
y1_PM = 0.1; y2_PM = 0.1; % yield of P on maintenance
y1_PG = 0.2; y2_PG = 0.2; % yield of P on growth

istate = [S1_r S2_r S2_r S2_r 0.1 0.1 0.1 0.1 0.1 0.1 ...
	  .1 1 .1 1]; % initial state values (18) 
%% substrates, products, V,m-spec-1, V,m-spec-2, V,m-spec-m, V,m-spec-s
%% S1 S2 S2m S2s P1 P1m P1s P2 P2m P2s V1 m1 Vs ms