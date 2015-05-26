%% parameters for 'alga'
% they are expressed on molar basis; this is convenient for balances,
% not all parameters are required for any particular application
% simultaneous growth limitation by two nutrients is moddelled here,
%   called ammonia and phosphate. We ignore that nitrate is usually more
%   abundant, while ammonia is excreted, but hardly stored as such.

global T T_1 Tpars TC ...
    n_O n_M n w_O d_O m_Em mu_T mu_O mu_M eta_O h h_X h_V;

global y_EN_V y_EP_V y_N_EN y_P_EP ...
       jT_EN_M jT_EP_M jT_EN_Am jT_EP_Am K_P K_N ...
       kT_E kap_EN kap_EP X_Nr X_Pr X_N X_P h h_X h_V;
 
%% temperature parameters (in Kelvin)
%   these pars are not relevant if T = T_1
T    =   293; % K, actual body temperature
T_1  =   293; % K, temp for which rate pars are given 
T_A  = 12000; % K, Arrhenius temp
T_L  =   277; % K, lower boundary tolerance range
T_H  =   318; % K, upper boundary tolerance range
T_AL = 20000; % K, Arrhenius temp for lower boundary
T_AH =190000; % K, Arrhenius temp for upper boundary
Tpars = [T_A T_L T_H T_AL T_AH];

%% chemical indices (relative elemental frequencies)
% organic compounds
%   columns: structure V, reserve EC, reserve EN
%       V     EN    EP    
n_O = [1.00, 0.00, 0.00;  % C/C, equals 1 by definition
       1.80, 3.00, 0.00;  % H/C
       0.50, 0.00, 4.00;  % O/C
       0.15, 1.00, 0.00;  % N/C
       0.03, 0.00, 1.00]; % P/C
%% minerals
%    rows: elements carbon, hydrogen, oxygen, nitrogen, phosphorous
%    columns: carbon dioxide, water, dioxygen, ammonia, phosphate
%      C  H  O  N  P
n_M = [1, 0, 0, 0, 0;  % C
       0, 2, 0, 3, 0;  % H
       2, 1, 2, 0, 4;  % O
       0, 0, 0, 1, 0;  % N
       0, 0, 0, 0, 1]; % P
%% calorimetric parameters
mu_M = [0 0 0 0];         % kJ/mol, chemical potentials of minerals
mu_T = [ 60 0 -350 -590]; % kJ/mol, heat couplers to mineral fluxes

%% life stage parameter
M_Vd = 5; % mol, structural mass at division

%% saturation parameters
%    water affects nutrient uptake via the saturation parameters
K_N = 0.120;   % M, half-saturation concentration for uptake of ammonia
K_P = 0.017;   % M, half-saturation concentration for uptake of phosphate

%% max specific uptake parameters that relate uptake to active surface area
j_EN_Am = 76.6;   % mol/mol.d, max spec N-res assimilation
j_EP_Am =  4.9;   % mol/mol.d, max spec P-res assimilation

%% yield coefficients
y_N_EN = 1;      % mol/mol, from ammonia to N-reserve
y_P_EP = 1;      % mol/mol, from phosphate to P_reserve       
y_EN_V = 2.35;   % mol/mol, from N-reserve to structure
y_EP_V = 0.39;   % mol/mol, from P-reserve to structure

%% partitioning parameter: dimensionless fraction
kap_EN = 0.96; % -, non-processed N-reserve returned to N-reserve
kap_EP = 0.69; % -, non-processed P-reserve returned to P-reserve

%% reserve parameters
k_E  = 1.20; % 1/d, N-reserve turnover rate

%% specific maintenancs costs in terms of reserve fluxes
%    these costs are paid to maintain structural mass
k_MN = 0.135; % 1/d, spec somatic  maint coeff for N-reserve
k_MP = 0.008; % 1/d, spec somatic  maint coeff for P-reserve

%% control parameters
X_Nr = 50;    % M, ammonia concentration in feed
X_Pr = 1;     % M, phosphate concentration in feed
h   = .1;     % 1/d, spec supply rate
h_X = .1;     % 1/d, spec compound draining rate
h_V = .1;     % 1/d, spec biomass draining rate       

parscomp_alga;

