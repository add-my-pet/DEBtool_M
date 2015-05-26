% parameters for 'shcycle'
% they are expressed on molar basis
% simultaneous growth limitation by nutrients N and P
% time-dependent nutrient concentrations are parameterized 

global y_EN_V y_EP_V y_N_EN y_P_EP ...
    j_EN_M j_EP_M j_EN_Am j_EP_Am K_P K_N ...
    k_E kap_EN kap_EP h h_X h_V;
global X0_N X1_N t0_N t1_N X0_P X1_P t0_P t1_P power;
 
%% saturation parameters
%   water affects nutrient uptake via the saturation parameters
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
k_E  = [0.5 0.75 1 1.25 1.5]; % 1/d, N-reserve turnover rate

%% the first is plotted blue, the last red, the rest green 

%% specific maintenancs costs in terms of reserve fluxes
%   these costs are paid to maintain structural mass

k_MN = 0.135; % 1/d, spec somatic  maint coeff for N-reserve
k_MP = 0.008; % 1/d, spec somatic  maint coeff for P-reserve
j_EN_M = k_MN*y_EN_V; % 1/d, som maint costs for N-reserve
j_EP_M = k_MP*y_EP_V; % 1/d, som maint costs for P-reserve

h   = 0.1;     % 1/d, hazard rate for structure

%% nutrient profile parameters
%   chosen time function: X = X0 + X1 * (1 + sin((t-t0)/t1))^power

X0_N = 0.0; X1_N = 0.004; t1_N = 10; t0_N = 0;       % for nutrient N
X0_P = 0.0; X1_P = 0.002; t1_P = 10; t0_P = t1_P*pi; % for nutrient P
power = 5;
