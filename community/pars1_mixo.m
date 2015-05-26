%% Parameters for mixotrophs with 1 reserve

global j_L_F Ctot Ntot j_EV_AHVm j_EE_AHEm j_EA_Am j_L_FK ...
  K_C K_N K_NE K_NV K_DV K_DE rho_EH rho_EA rho_EV rho_EE ...
  k_EA k_EH k_EV k_EE z_C z_N z_CH y_DVE y_DEE y_EV ...
  k_E k_M h n_NV n_NE L_h

global istate upmix dwnmix

%% control parameters
j_L_F = -5;      % mol/d, incoming light per cell
Ctot = 1200;     % muM, total carbon
Ntot = 150;      % muM, total nitrogen

%% max assimilation
j_EV_AHVm = 1.5; % mol/mol.d max assim of V-detritus
j_EE_AHEm = 2;   % mol/mol.d max assim of E-detritus
j_EA_Am = 2.5;   % mol/mol.d max assim (total)

%% half saturation
j_L_FK = 25;     % mol/d, photon flux per cell
K_C = 500;       % muM, DIC for autotrophic route
K_N = 0.1;       % muM, DIN for autotrophic route
K_NV = 0.001;    % muM, DIN for digestion of V-detritus
K_NE = 0.001;    % muM, DIN for digestion of E-detritus
K_DV = 2500;     % muM, V-detritus
K_DE = 1000;     % muM, E-detritus

%% binding probabilities
rho_EA = 0.9;    % -, merging metabolites of autotrophic route with hetero
rho_EH = 0.8;    % -, merging metabolites of heterotrophic route with auto
rho_EV = 0.7;    % -, merging metabolites V-detritus with those of E-detr
rho_EE = 0.9;    % -, merging metabolites E-detritus with those of V-detr

%% max process rates
k_EA = 10;       % 1/d, max synth rate of autotrophic route 
k_EH = 10;       % 1/d, max synth rate of heterotrophic route
k_EV = 5;        % 1/d, max synth rate of V-detritus metabolites
k_EE = 5;        % 1/d, max synth rate of E-detritus metabolites 

%% scaling parameters
z_C = 10;        % -, scaling of DIC assimilation
z_N = 10;        % -, scaling of DIN assimilation
z_CH = 10;       % -, scaling of carbohydrate assimilation

%% yield coefficients
y_DVE = 4;       % mol/mol, yield of DV on E
y_DEE = 2.5;     % mol/mol, yield of DE on E
y_EV = 1.5;      % mol/mol, yield of E on V

%% internal physiology
k_E = 0.6;       % 1/d, reserve turnover rate
k_M = 0.1;       % 1/d, maintenance rate coefficient
h = 0.45;        % 1/d, hazard rate

%% composition
n_NV = 0.1;      % -, N/C ratio in V
n_NE = 0.2;      % -, N/C ratio in E

%% extinction L(i) = L(i - 1) * exp(-1/Lh)
Lh = 1000;         % m, vertical light extinction 

%% initial state (at time 0)
V0 = 0.01*Ctot; m_E0 = j_EA_Am/k_E; E0 = m_E0*V0;
istate = [(Ctot-V0 - E0), (Ntot- n_NV*V0 - n_NE*E0), 1e-8, 1e-8, V0, E0]';

%% vertical mixing
upmix = 0.01*ones(6,1); % 1/d, upward transport rates
dwnmix = upmix;         % 1/d, downward transport rates
