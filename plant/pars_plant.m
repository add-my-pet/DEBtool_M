%% parameters for 'plant'
% The values of these parameters are very provisional

global X T_1 Tpars n_N_ENR n_N_ER;
global M_VSd M_VSm M_VRd M_VRm M_VSb M_VRb M_VSp M_ER0;
global k_C k_O k_ECS k_ENS k_ES k_ECR k_ENR k_ER rho_NO;
global J_L_K K_C K_O K_NH K_NO K_H;
global j_L_Am j_C_Am j_O_Am j_NH_Am j_NO_Am;
global y_ES_CH_NO y_CH_ES_NO y_ER_CH_NO y_CH_ER_NO y_ER_CH_NH;
global y_VS_ES y_ES_VS y_VR_ER y_ER_VR y_ES_ER y_ER_ES;
global y_ES_ENS y_ENS_ES y_ER_ENR y_ENR_ER y_ENS_ENR y_ECR_ECS;
global kap_ECS kap_ECR kap_ENS kap_ENR kap_SS;
global kap_SR kap_RS kap_TS kap_TR;
global j_ES_MS j_ER_MR j_ES_JS j_PS_MS j_PR_MR y_PS_VS y_PR_VR;
    
% control parameters (environmental conditions)
J_L_F = 5; % mol/s, flux of useful photons
X_C = 10;  % M, concentration of carbon dioxide
X_O = 100; % M, concentration of oxygen
X_NH = 5;  % M, concentration of ammonia
X_NO = 10; % M, concentration of nitrate
X_H = 10;  % M, concentration of water
T = 310;   % K, temperature

% pack control parameters into vector
X = [J_L_F, X_C, X_O, X_NH, X_NO, X_H, T];

% temperature parameters (in Kelvin)
%   these pars are not relevant if T = T_1
T_1  =   310; % K, temp for which rate pars are given 
T_A  = 12000; % K, Arrhenius temp
T_L  =   293; % K, lower boundary tolerance range
T_H  =   318; % K, upper boundary tolerance range
T_AL = 20000; % K, Arrhenius temp for lower boundary
T_AH = 70000; % K, Arrhenius temp for upper boundary
Tpars=[T_A T_L T_H T_AL T_AH];

% parameters that link moles to grams (wet weight)
%   these parameters do not affect the dynamics; just output mapping 
w_PS  = 25; % g/mol, mol-weight of shoot product (wood)
w_VS  = 25; % g/mol, mol-weight of shoot structure
w_ECS = 25; % g/mol, mol-weight of shoot C-reserve
w_ENS = 25; % g/mol, mol-weight of shoot N-reserve
w_ES  = 25; % g/mol, mol-weight of shoot reserve
w_PR  = 25; % g/mol, mol-weight of root product (wood)
w_VR  = 25; % g/mol, mol-weight of root structure
w_ECR = 25; % g/mol, mol-weight of root C-reserve
w_ENR = 25; % g/mol, mol-weight of root N-reserve
w_ER  = 25; % g/mol, mol-weight of root reserve

% chemical indices: elemental_nitrogen/elemental_carbon
%   only n_N_ENR and n_N_ER play a dynamic role
%   the others are only used to evaluate the nitrogen balance
n_N_PS = 0;     % -, N/C in shoot product (wood)
n_N_VS = 0.15;  % -, N/C in shoot structure
n_N_ECS = 0;    % -, N/C in shoot C-reserve
n_N_ENS = 10;   % -, N/C in shoot N-reserve
n_N_ES = 0.2;   % -, N/C in shoot reserve
n_N_PR = 0;     % -, N/C in root product (wood)
n_N_VR = 0.15;  % -, N/C in root structure
n_N_ECR = 0;    % -, N/C in root C-reserve
n_N_ENR = 10;   % -, N/C in root N-reserve
n_N_ER = 0.2;   % -, N/C in root reserve

% parameters that link active surface area to structural mass
%  they describe the development through V1-, iso- and V0-morphs
M_VSd = 1;      % mol, shoot's reference mass
M_VSm = 100;    % mol, shoot's scaling mass
M_VRd = 1;      % mol, root's  reference mass
M_VRm = 100;    % mol, root's  scaling mass

% life stage parameters
M_VSb =.5; % mol, shoot's structural mass at germination
M_VRb =.3; % mol, root's  structural mass at germination
M_VSp =10; % mol, shoot's structural mass at start reproduction
M_ER0 = 8; % mol, root's initial general reserves (this is the total seed mass)

% saturation parameters
%   water affects nutrient uptake via the saturation parameters
J_L_K = 1;  % mol/s, half-saturation flux of useful photons
K_C = 1;    % M, half-saturation concentration of carbon dioxide
K_O = 1;    % M, half-saturation concentration of oxygen
K_NH = 10;   % M, half-saturation concentration of ammonia
K_NO = 10;   % M, half-saturation concentration of nitrate
K_H = 1;    % M, half-saturation concentration of water

% max specific uptake parameters that relate uptake to active surface area
j_L_Am = 50;     % mol/mol.s, max spec uptake of useful photons
j_C_Am = 50;     % mol/mol.s, max spec uptake of carbon dioxide
j_O_Am = 0.0001; % mol/mol.s, max spec uptake of oxygen
j_NH_Am = 0.5;   % mol/mol.s, max spec uptake of ammonia
j_NO_Am = 0.5;   % mol/mol.s, max spec uptake of nitrate

% nitrogen preference parameter
rho_NO = 0.7; %-, weights preference for nitrate relative to ammonia

% binding rates of gases to quantify photo-respiration
k_C = 1; % 1/s, scaling rate for carbon dioxide
k_O = 1; % 1/s, scaling rate for oxygen

%% reserve turnover rates
k_ECS = 0.2; % 1/d, shoots' C-reserve turnover rate
k_ENS = 0.2; % 1/d, shoots' N-reserve turnover rate
k_ES  = 0.2; % 1/d, shoots'   reserve turnover rate
k_ECR = 0.2; % 1/d, roots'  C-reserve turnover rate
k_ENR = 0.2; % 1/d, roots'  N-reserve turnover rate
k_ER  = 0.2; % 1/d, roots'    reserve turnover rate

% yield coefficients (see also production parameters)
y_ES_CH_NO = 1.5;   % mol/mol, from shoot's C-reserve to reserve, using nitrate
y_CH_ES_NO = 1/y_ES_CH_NO;
y_ER_CH_NO = 1.5;   % mol/mol, from root's C-reserve to reserve, using nitrate
y_CH_ER_NO = 1/y_ER_CH_NO;
y_ER_CH_NH = 1.25;  % mol/mol, from root's C-reserve to reserve, using ammonia
y_VS_ES = 0.7;      % mol/mol, from shoot's reserve to structure
y_ES_VS = 1/y_VS_ES;
y_VR_ER = 0.7;      % mol/mol, from root's  reserve to structure
y_ER_VR = 1/y_VR_ER;
y_ES_ER = 0.8;      % mol/mol, from shoot's reserve to root's reserve
y_ER_ES = 0.8;      % mol/mol, from root's  reserve to shoot's reserve
y_ES_ENS = 0.5;     % mol/mol, from shoot's N-reserve to reserve
y_ENS_ES = 1/y_ES_ENS;
y_ER_ENR = 0.3;     % mol/mol, from root's N-reserve to reserve
y_ENR_ER = 1/y_ER_ENR;
y_ENS_ENR = 1;      % mol/mol, from root's N-reserve to shoot's N-reserve
y_ECR_ECS = 1;      % mol/mol, from shoot's C-reserve to root's C-reserve

% partitioning parameters: dimensionless fractions
kap_ECS = 0.2; % -, shoot's non-processed C-reserve returned to C-reserve
               %   the remaining fraction is translocated to the root 
kap_ECR = 0.5; % -, root's  non-processed C-reserve returned to C-reserve
               %   the remaining fraction is translocated to the shoot 
kap_ENS = 0.5; % -, shoot's non-processed N-reserve returned to N-reserve
kap_ENR = 0.2; % -, root's  non-processed N-reserve returned to N-reserve
kap_SS = 0.6;  % -, shoots' reserve flux allocated to development/reprod.
kap_SR = 0.5;  % -, shoots' reserve flux allocated to soma
kap_RS = 0.05; % -, roots'  reserve flux allocated to soma
kap_TS = 1 - kap_SS - kap_RS;   % -, shoots' reserve flux translocated to root
kap_TR = 1 - kap_SR;            % -, roots' reserve flux translocated to shoot
kap_R = 0.8;   % -, fraction of flux allocated to reproduction that is
               % fixed in embryonic reserves; the remaining fraction is lost

% specific maintenancs costs in terms of reserve fluxes
%   these costs are paid to maintain structural mass
j_ES_MS = 0.001; % mol/mol.s, shoots' spec somatic maint costs 
j_ER_MR = 0.003; % mol/mol.s, roots' spec somatic maint costs
j_ES_JS = 0.001; % mol/mol.s, shoors' spec maturity maint costs 

% production parameters
%   these parameters play no dynamic role, but can dominate weights
j_PS_MS = 0.01; % mol/mol.s, shoot product formation linked to maintenance
j_PR_MR = 0.01; % mol/mol.s, root  product formation linked to maintenance
y_PS_VS = 0.02; % mol/mol, shoot product formation linked to growth
y_PR_VR = 0.02; % mol/mol, root  product formation linked to growth



