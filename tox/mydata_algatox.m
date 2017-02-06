% illustration of the use of algatox
% created 2002/02/05 by Bas Kooijman

%% set parameter values
B0 = 1.895;    %  1 mM background nutrient
N0 = 0.020;    %  2 mM initial nutrient conc
X0 = 0.261;    %  3 M, initial biomass
w = 1;         %  4 OD/M, weight of living in optical density (redundant par)
wd = 1;        %  5 OD/M, weight of dead in optical density
w0 = 0.322;    %  6 OD,M, weight of ghosts in optical density
K = 15.1;      %  7 mM, half saturation constant
yEV = 321;     %  8 mol/OD, yield of reserves on structure
kN = 143.0;    %  9 mol/(OD.h), max spec nutrient uptake rate
kE = 0.01246;  % 10 1/h, reserve turnover rate
kNB = 79.50;   % 11 1/h, exchange from nutrient to background
kBN = 0.7288;  % 12 1/h, exchange from background to nutrient
k0 = 0.1; % 13 1/h, dead biomass decay rate to ghost
c0 = 0;   % 14 mg/L, no-effect concentration
cH = 21;  % 15 mg/L, tolerance conc for initial mortality
cy = 1e8; % 16 mg/L, tolerance concentration for costs of growth
b = 0;    % 17 L/(h.mg), spec killing rate

% collect parameters in a matrix
pars = [B0 N0 X0 w wd w0 K yEV kN kE kNB kBN k0 c0 cH cy b; ...
	0  0  1  0 0  1  1 1   1  1  0   0   1  0  1  0  0]';
% set exposure times
time = linspace(0, 100, 100)';

% set concentrations of toxic compound
conc = linspace(0, 10, 5)';

% show OD versus time only
shregr2_options('default');
shregr2_options('plotnr', 1);

% set plot labels
shregr2_options('xlabel', 'time, h');
shregr2_options('zlabel', 'OD');

%%
% make plots
% shregr2('algatox', pars, time, conc);

% set observations
% Data from Prof. José Antonio Perales Vargas-Machuca
%   Área de Tecnologías del Medio Ambiente 
%   Escuela Politécnica Superior de Algeciras
%   Universidad de Cádiz 

% Incubation times of the batch cultures (h)
time = [0	24	48	72	96]';

% Commercial Sodium Linear Alkylbenzene Sulphonate (LAS, mg/L)
conc = (0:10)';

% Optical densities of Isochrysis aff. galbana (notice transpose)
%   in synthethic seawater (means of 3 replicas)
OD = [0.285	0.318	0.461	0.634	0.807;
0.287	0.310	0.439	0.623	0.786;
0.285	0.305	0.424	0.610	0.777;
0.284	0.301	0.415	0.582	0.749;
0.283	0.300	0.410	0.572	0.708;
0.285	0.296	0.391	0.543	0.683;
0.287	0.295	0.373	0.521	0.650;
0.284	0.291	0.363	0.483	0.616
0.284	0.292	0.345	0.456	0.588;
0.284	0.283	0.334	0.440	0.570;
0.285	0.288	0.317	0.414	0.548]';

p = nmregr2('algatox', pars, time, conc, OD); % estimate parameters
% get statistics for parameter estimates
[cov, cor, sd, ss] = pregr2('algatox', p, time, conc, OD);
[p, sd] % show parameter values and standard deviations

shregr2_options('Range', 1, [0.2 0.85]);
shregr2_options('Range', 2, [0.2 0.55]);
shregr2('algatox', p, time, conc, OD); % show results