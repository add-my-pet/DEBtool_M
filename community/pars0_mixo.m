%% Parameters for mixotrophs without reserves

global j_L_F Ctot Ntot j_V_Am j_L_FK K_C K_N K_NV K_D rho_A rho_H ...
  k_A k_H z_C z_CH z_N y_DV k_M h n_NV L_h

global istate upmix dwnmix

%% control parameters
j_L_F = -5;   % mol/d, incoming light
Ctot = 1200;  % muM, total carbon
Ntot = 150;   % muM, total nitrogen

%% max assimilation
j_V_Am = 2.5;    % mol/mol.d max assim of V-Detritus

%% half saturation
j_L_FK = 25;     % mol/d photon flux
K_C = 500;       % muM, DIC
K_N = 0.1;       % muM, DIN
K_NV = 0.001;    % muM, DIN for V-Detritus
K_D = 2500;      % muM, V-Detritus

%% binding probabilities
rho_A = 0.9;     % -, E for autotrophic route
rho_H = 0.8;     % -, E for heterotrophic route

%% max process rates
k_A = 1e4;        % mol/mol.d, for autotrophic route
k_H = 1e4;        % mol/mol.d, for heterotrophic route

%% scaling parameters
z_C = 10;        % -, DIC
z_N = 10;        % -, DIN
z_CH = 10;       % -, Carbohydrates

%% yield coefficients
y_DV = 1.2;      % mol/mol, yield of Detritus on structure

%% internal physiology
k_M = 0.1;        % 1/d, maintenance rate coefficient
h = 0.45;        % 1/d, hazard rate (aging)

%% composition
n_NV = 0.15;     % -, nitrogen/carbon in structure

%% extinction L(i) = L(i - 1) * exp(-1/Lh)
Lh = 1000;       % m, vertical light extinction 

%% initial state (at time 0)
V0 = 0.01*Ctot;
istate = [(Ctot-V0), (Ntot-n_NV*V0), 1e-8, V0]';

%% vertical mixing
upmix = 0.01*ones(4,1); % 1/d, upward transport rates
dwnmix = upmix;         % 1/d, downward transport rates
