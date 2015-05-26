% parameters of the biochem model
% Martina Vijver
% 2002/02/05

global l0 C_Ms0 C_Mp0 C_Ma0 C_Mi0\
    k_pi k_si k_ai k_as k_sa k_pa k_ap k_ps k_sp k_0 k_V k_e\
    W_d l V_p M_s;

%% Inititial state variables
l0 = 0.8;  % -, initital scaled length of annelid
C_Ms0 = 1000; % mol/g, metal conc in solids
C_Mp0 = 100;  % mol/l, total metal conc in pore water
C_Ma0 = 1;    % mol/l, conc of active metal in pore water
C_Mi0 = 0;    % mol/g, internal metal conc

%% kinetic parameters
k_pi = 0.2; % dm^3/(mol.t), rate from total pool in pore water to organism
k_si = 0.1; % mg/(mol.t), rate from solid to organism
k_ai = 0.5; % dm^3/(mol.t), rate from active pool in pore water to organism
k_as = 0.2; % dm^3/d, rate from active pool to solid
k_sa = 0.25;% dm^3/d, rate from solid to active pool
k_pa = 0.1; % dm^3/d, rate from total to active pool
k_ap = 0.01;% dm^3/d, rate from active to tatal pool
k_ps = 0.1; % dm^3/d, rate from total pore to solid pool
k_sp = 0.01;% dm^3/d, rate from solid to total pore pool
k_0 = 0.01; % 1/d, decay rate from total pool
k_V = 0.01; % 1/d, reduction rate of length of annelid
k_e = 0.02; % 1/d, elimination rate

%% size parameters
W_d = 70; % mg, dry weight of annelid
V_p = 1;  % l, volume of pore water
M_s = 10; % kg, weight of solids
