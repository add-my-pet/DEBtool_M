%% Parameters for mixotrophs with 3 reserves

global j_L_F Ctot Ntot j_EV_AHVm j_EE_AHEm j_EC_Am j_EN_Am j_L_FK ...
K_C K_N K_NE K_NV K_DV K_DE rho_EH rho_EA rho_EV rho_EE ...
k_EV k_EE z_C z_N y_DVE y_DEE y_EV y_ECV y_ENV y_NEN ...
k_E k_M kap_EC kap_EN h n_NV n_NE n_NEN L_h;

global istate upmix dwnmix;

%% control parameters
j_L_F = -5;   % mol/d, incoming light per cell
Ctot = 1200;  % muM, total carbon
Ntot = 150;   % muM, total nitrogen

%% max assimilation
j_EV_AHVm = 1.5;% mol/mol.d max assim of DV detritus
j_EE_AHEm = 2;  % mol/mol.d max assim of DE detritus
j_EC_Am = 1.75;   % mol/mol.d max assim of EC-reserve
j_EN_Am = 1.75;    % mol/mol.d max assim of EN-reserve

%% half saturation
j_L_FK = 5;     % mol/d, photon flux per cell
K_C = 500;       % muM, DIC for autotrophic route
K_N = 1;       % muM, DIN for autotrophic route
K_NV = 0.001;    % muM, DIN for digestion of V-detritus
K_NE = 0.001;    % muM, DIN for digestion of E-detritus
K_DV = 2500;     % muM, V-detritus
K_DE = 1000;     % muM, E-detritus

%% binding probabilities
rho_EV = 0.7;    % -, merging metabolites V-detritus with those of E-detr
rho_EE = 0.9;    % -, merging metabolites E-detritus with those of V-detr

%% max process rates
k_EV = 5;        % 1/d, max synth rate of V-detritus metabolites
k_EE = 5;        % 1/d, max synth rate of E-detritus metabolites 

%% scaling parameters
z_C = 10;        % -, scaling of DIC assimilation
z_N = 10;        % -, scaling of DIN assimilation

%% yield coefficients
y_DVE = 4;       % mol/mol, yield of DV on E
y_DEE = 2.5;     % mol/mol, yield of DE on E
y_EV = 1.5;      % mol/mol, yield of E on V
y_ECV = 1.2;     % mol/mol, yield of EC on V
y_ENV = 0.3;     % mol/mol, yield of EN on V
y_NEN = 1;       % mol/mol, yield of N on EN

%% internal physiology
k_E = 0.6;       % 1/d, reserve turnover rate
k_M = 0.1;       % 1/d, maintenance rate coefficient
kap_EC = 0;      % -, fraction of rejected EC reserve that is returned
kap_EN = 0;      % -, fraction of rejected EN reserve that is returned
h = 0.10;        % 1/d, hazard rate

%% composition
n_NV = 0.1;      % -, N/C ratio in V
n_NE = 0.2;      % -, N/C ratio in E
n_NEN = 1;       % -, N/C ratio in EN

%% extinction L(i) = L(i - 1) * exp(-1/Lh)
Lh = 1000;       % m, vertical light extinction 

%% initial state (at time 0)
V0 = 0.01*Ctot;
m_E0 = max([k_EE k_EV])/k_E; m_EC0 = j_EC_Am/k_E; m_EN0 = j_EN_Am/k_E;
E0 = V0*m_E0; EC0 = m_EC0*V0; EN0 = m_EN0*V0;
C0 = Ctot - V0 - E0 - EC0; N0 = Ntot - n_NV*V0 - n_NE*E0 - n_NEN*EN0; 
istate = [C0, N0, 1e-8, 1e-8, V0, E0, EC0, EN0]';

%% vertical mixing
upmix = 0.01*ones(8,1); % 1/d, upward transport rates
dwnmix = upmix;         % 1/d, downward transport rates
