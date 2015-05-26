%% Parameters for 'endosym'
%%   2 interacting species each having 1 structure (V) and 1 reserve (E)
%%   each species eats one substrate (S) and one product (P)
%%
%% Control-parameters:
%%   hazard rates h1_V, h2_V, h1_S, h2_S, h1_P, h2_P or h
%%   supply fluxes J1_Sr, J2_Sr or supply concentrations S1_r, S2_r

global h1_V h2_V h1_S h2_S h1_P h2_P h ... % reactor drains
    J1_Sr J2_Sr S1_r S2_r ... % reactor feeding
    k1_E k2_E k1_M k2_M ...
    k1 k2 k1_S k2_S ki1_S ki2_S k1_P k2_P ki1_P ki2_P ...
    b1_S b2_S b1_SP b2_SP b1_P b2_P b1_PS b2_PS ...
    y1_EV y2_EV y1_ES y2_ES y1_EP y2_EP ...
    y1_Et y2_Et y1_St y2_St y1_Pt y2_Pt ...
    y1_PS y2_PS y1_PP y2_PP y1_PM y2_PM y1_PG y2_PG ...
    istate;

h = 0.1;                         % spec throughput rate of the chemostat
S1_r = 100; S2_r = 100;          % conc substrate in feed 
h1_V=h; h2_V=h; h1_S=h; h2_S=h; h1_P=h; h2_P=h; % hazard rates equal to throughput rate  
J1_Sr = h*S1_r; J2_Sr = h*S2_r;  % supply fluxes from supply concentrations

k1_E = 0.3;  k2_E = 0.3;  % reserve-turnover rate
k1_M = 0.01; k2_M = 0.01; % maintenance rate coeff
k1 = 0.1; k2 = 0.1;       % dissociation rate
k1_S  = 0.1;  k2_S = 0.1; % dissociation rate
ki1_S = 0.1; ki2_S = 0.1; % dissociation rate
k1_P  = 0.1;  k2_P = 0.1; % dissociation rate
ki1_P = 0.1; ki2_P = 0.1; % dissociation rate

b1_S  = 0.05; b2_S  = 0.05; % uptake of substrate
b1_SP = 0.01; b2_SP = 0.01; % uptake of substrate 
b1_P  = 0.05; b2_P  = 0.05; % uptake of product
b1_PS = 0.00; b2_PS = 0.00; % uptake of product

y1_EV = 1.2; y2_EV = 1.2; % yield of E on V (>1 since E -> V)
y1_ES = 0.8; y2_ES = 0.8; % yield of E on S 
y1_EP = 0.2; y2_EP = 0.2; % yield of E on P
y1_Et = 0.8; y2_Et = 0.8; % yield of E on S+P -> E (production)
y1_St = 0.2; y2_St = 0.2; % yield of S on S+P -> E (consumption)
y1_Pt = 0.2; y2_Pt = 0.2; % yield of P on S+P -> E (consumption)

y1_PS = 0.1; y2_PS = 0.1; % yield of P on S-assimilation
y1_PP = 0.1; y2_PP = 0.1; % yield of P on P-assimilation
y1_PM = 0.1; y2_PM = 0.1; % yield of P on maintenance
y1_PG = 0.2; y2_PG = 0.2; % yield of P on growth

istate = [S1_r S2_r 0.1 0.1 .1 1 .1 1]; % initial state values
%% substrates, products, structure, reserve density, structure, res density