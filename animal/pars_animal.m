%% parameters for 'animal'
% created 2000/11/02 by Bas Kooijman, modified 2009/09/29
% not all parameters are required for any particular application
% warning: length units refer to volumetric lengths
% multiply by the shape coefficient for physical length
% suggestion: copy pars_animal first to pars_mydata before changing values
%   then run pars_mydata

mydata = 0; foetus = 0; % for compatibility with pars_my_pet in add_my_pet

global T T_ref pars_T TC pT_Am pT_M k
global n_O n_M w_O d_O mu_T mu_M mu_O mu_E eta_O M_Vb M_Vp M_Vm M_E0 M_Em m_Em p_ref M_V
global f K eb_min ep_min y_E_X y_X_E y_V_E y_E_V y_P_X y_X_P kap kap_R
global jT_X_Am jT_E_Am JT_X_Am JT_E_Am jT_E_M jT_E_J 
global vT g kT_M kT_J E_G R_m hT_a s_G a_m
global L_d L_b L_p L_m L_T l_b l_p l_T V_Hb v_Hb v_Hp u_Hb u_Hp U_Hb U_Hp 

%% temperature parameters (in Kelvin)
%   these pars are not relevant if T = T_1
T    =   293; % K, actual body temperature
T_ref  = 293; % K, temp for which rate pars are given 

T_A  =  8000; % K, Arrhenius temp
T_L  =   277; % K, lower boundary tolerance range
T_H  =   318; % K, upper boundary tolerance range
T_AL = 20000; % K, Arrhenius temp for lower boundary
T_AH =190000; % K, Arrhenius temp for upper boundary
pars_T = [T_A T_L T_H T_AL T_AH];    

%% food abundance
% values computed in routine statistics depend on this

f = 1.0; % scaled functional response
% this is the food intake relative to the max for individuals of that size

%% chemical indices (relative elemental frequencies)
% notice that these values relate to dry mass
% wet mass has ten times more H and O, relative to C
% organic compounds
%   columns: food, structure, reserve, faeces
%      X     V     E     P
n_O = [1.00, 1.00, 1.00, 1.00;  % C/C, equals 1 by definition
       1.80, 1.80, 2.00, 1.80;  % H/C
       0.50, 0.50, 0.75, 0.50;  % O/C
       0.20, 0.15, 0.20, 0.15]; % N/C
   
% minerals
%   rows: elements carbon, hydrogen, oxygen, nitrogen
%   columns: carbon dioxide (C), water (H), dioxygen (O), ammonia (N)
%     CO2 H2O O2 NH3
n_M = [1,  0, 0,  0;  % C
       0,  2, 0,  3;  % H
       2,  1, 2,  0;  % O
       0,  0, 0,  1]; % N

%% parameters that link moles to grams (wet weight), volumes and energy

%   given in vector form for food, structure, reserve, feaces
%   these parameters do not affect the dynamics; just output mapping 
d_O = [.1; .1; .1; .1];     % g/cm^3, specific densities for organics
% dry mass per wet volume
mu_X = 525000;                    % J/mol, chemical potential of food
mu_V = 500000;                    % J/mol, chemical potential of structure
mu_E = 550000;                    % J/mol, chemical potential of reserve
mu_P = 480000;                    % J/mol, chemical potential of faeces
mu_O = [mu_X; mu_V; mu_E; mu_P];  %J/mol, chemical potentials of organics

mu_M = [0; 0; 0; 0];           % kJ/mol, chemical potentials of minerals
% C: CO2, H: H2O, O: O2, N: NH3

% molar volume of gas at 1 bar and 20 C is 24.4 L/mol
X_gas = T_ref/ T/ 24.4;     % M, mol of gas per litre at 20 C and 1 bar 


%% conversion parameters

z = 1;       % zoom factor rel to reference L_m = 1 cm to compare species
del_M = .16; % -, shape coefficient to convert vol-length to physical length

%% primary parameters of the standard DEB model in energy
% only p_Am, E_Hb, E_Hp, h_a depend on zoom factor z (interspecifically)

F_m = 6.5;       % l/d.cm^2, {F_m} max spec searching rate
kap_X = 0.8;     % -, digestion efficiency of food to reserve
kap_X_P = 0.1;   % -, faecation efficiency of food to faeces
% kap_X_P does not affect state varables, only mineral and faeces fluxes
v = 0.02;        % cm/d, energy conductance
kap = 0.8;       % -, alloaction fraction to soma = growth + somatic maintenance
kap_R = 0.95;    % -, reproduction efficiency
p_M = 18;        % J/d.cm^3, [p_M] vol-specific somatic maintenance
p_T =  0;        % J/d.cm^2, {p_T} surface-specific som maintenance
k_J = 0.002;     % 1/d, < k_M = p_M/E_G, maturity maint rate coefficient
E_G = 2800;      % J/cm^3, [E_G], spec cost for structure

% life stage parameters: b = birth; i = metamorphosis; p = puberty
% E_H is the cumulated energy from reserve invested in maturation
E_Hb = 1e-3 * 275 * z^3; % J, E_H^b
E_Hj = E_Hb;             % J, E_H^j, no metamorphosis
E_Hp = 50 * z^3;         % J, E_H^p 

% aging process
h_a = z * 1e-6;   % 1/d^2, Weibull aging acceleration
s_G = 1e-4;       % -, Gompertz stress coefficient

parscomp          % compound parameters
statistics        % food-dependend quantities
%report_animal    % writes statistics and par-values and