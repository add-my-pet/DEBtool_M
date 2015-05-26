%% parameters for 'microbe'
%% they are expressed on molar basis; this is convenient for balances,
%% not all parameters are required for any particular application

global T T_1 Tpars TC;
global n_O n_M n w_O d_O m_Em mu_T mu_O mu_M eta_O;
global jT_X_Am j_E_M j_E_J K y_E_X y_X_E y_V_E y_E_V kap;
global m_Em g kT_M kT_J kT_E hT_a l_d f;
global h h_X h_V h_P h_m r_m X_r zeta eta_O;

%% temperature parameters (in Kelvin)
%%   these pars are not relevant if T = T_1
T    =   293; % K, actual body temperature
T_1  =   293; % K, temp for which rate pars are given 
T_A  = 12000; % K, Arrhenius temp
T_L  =   277; % K, lower boundary tolerance range
T_H  =   318; % K, upper boundary tolerance range
T_AL = 20000; % K, Arrhenius temp for lower boundary
T_AH =190000; % K, Arrhenius temp for upper boundary
Tpars=[T_A T_L T_H T_AL T_AH];
%% chemical indices (relative elemental frequencies)
%% organic compounds
%%   columns: substrate X, structure V, reserve E, product P
%%     X     V     E     P
n_O = [1.00, 1.00, 1.00, 1.00;  % C/C, equals 1 by definition
       2.00, 1.80, 1.80, 1.80;  % H/C
       1.00, 0.50, 0.50, 1.00;  % O/C
       0.00, 0.15, 0.20, 0.00]; % N/C
%% minerals
%%   rows: elements carbon, hydrogen, oxygen, nitrogen
%%   columns: carbon dioxide, water, dioxygen, ammonia
%%     C  H  O  N
n_M = [1, 0, 0, 0;  % C
       0, 2, 0, 3;  % H
       2, 1, 2, 0;  % O
       0, 0, 0, 1]; % N
%% calorimetric parameters
mu_M = [0 0 0 0];         % kJ/mol, chemical potentials of minerals
mu_T = [ 60 0 -350 -590]; % kJ/mol, heat couplers to mineral fluxes

%% life stage parameter
M_Vd = 0.005; % mol, structural mass at division

%% feeding parameters
j_X_Am = 0.55;   % mol/mol.d, max mass-spec uptake of substrate
K = 0.00001;    % M, half-saturation concentration

%% yield coefficients
y_E_X = 0.3;   % mol/mol, from food to reserve
y_X_E = 1/y_E_X;
y_V_E = 0.85;   % mol/mol, from reserve to structure
y_E_V = 1/y_V_E;

%% partitioning parameter: dimensionless fraction
kap = 0.9;   % -, fraction of catabolic flux allocated to soma
 % the remaining fraction is allocated to development 

%% reserve parameter
k_E  = 0.45; % 1/d, reserve turnover rate

%% specific maintenancs costs in terms of reserve fluxes
%%   these costs are paid to maintain structural mass
k_M = 0.005; % 1/d, spec somatic  maint coeff

%% aging process
h_a = 0.01;   % 1/d, aging rate

%% product formation
zeta = [.05 .20 0]; % mol/mol, coupling to assim, dissipation, growth

%% control parameters
%% If h = h_X = h_V = h_P: chemostat throughput rate
%% If h_X = h_V = h_P = 0: fed-batch culture
%% If h = h_X = h_V = h_P = 0: batch culture
X_r = 0.001;   % M, substrate concentration in feed
h   = .1;   % 1/d, spec supply rate
h_X = .1;   % 1/d, spec drain rate for substrate
h_V = .1;   % 1/d, spec drain rate for structure
h_P = .1;   % 1/d, spec drain rate for product
 
parscomp_microbe;

