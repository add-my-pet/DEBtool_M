%% ch4troph calculates fluxes of compounds for methanotrophs
%% created at 2001/10/04 by Bas Kooijman

%% methanothrophs are treated as V1-morphs
%%   with 1 reserve E, 1 structure V
%% 4 elements, 7 compounds, 5 processes
%%   compounds C, H and O ad libitum;  X, N (potentially) limiting

global jEAm KX KN kM kE yVE yEX Y

%% Parameters
KX = 0.1;   % mM, saturation constant for X
KN = 0.02;  % mM, saturation constant for N
jEAm = 1.2; % mol/(h.mol), max spec assim rate (of E)
yEX = 0.8; % mol/mol, yield of E on X (total of assimilation)
yVE = 0.8; % mol/mol, yield of V on E
kM = 0.01;  % 1/h, maintenance rate constant
kE = 2.00;  % 1/h, reserve turnover rate

%% chemical indices: 4 elements, 7 compounds; 6 new parameters
nHE = 1.8; nOE = 0.3; nNE = 0.3; % reserve
nHV = 1.8; nOV = 0.5; nNV = 0.1; % structure
%%   C  H    O    N   elements
n = [1, 4,   0,   0  ; ... % X: methane
     1, 0,   2,   0  ; ... % C: carbon dioxide
     0, 2,   1,   0  ; ... % H: water
     0, 0,   2,   0  ; ... % O: dioxygen
     0, 3,   0,   1  ; ... % N: ammonia
     1, nHE, nOE, nNE; ... % E: reserve
     1, nHV, nOV, nNV]';   % V: structure

%% yield coefficients: 7 compounds, 5 processes; no new parameters
ANX = - nNE; AHX = 2 - ANX*3/2 - nHE/2;
AOX = -AHX/2 - nOE/2;  % assimilation
MHE = -nNE*3/2 + nHE/2; MOE = -1 + nOE/2 - MHE/2; % maintenance
GNE = nNE - nNV; GHE = nHE/2 - nHV/2 -GNE*3/2;
GOE = nOE/2 - nOV/2 - GHE/2; % growth (anabolic part)
%%   X   C  H     O   N    E     V  compounds
Y = [-1, 1, 2,   -2,  0,   0,  0; ... % AC: assimilation (catabolic part)
     -1, 0, AHX, AOX, ANX, 1,  0; ... % AA: assimilation (anabolic part)
     0,  1, MHE, MOE, nNE, -1, 0; ... % M : maintenance
     0,  1, MHE, MOE, nNE, -1, 0; ... % GC: growth (catabolic part)
     0,  0, GHE, GOE, GNE, -1, 1]';   % GA: growth (anabolic part)

%% mass balance: (4, 5)-null matrix: (%elements,%processes)
%% n*Y % check only

shchem (1)
%% shchem (2)
