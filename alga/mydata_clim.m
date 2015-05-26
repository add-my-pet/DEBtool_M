%% illustration of the use of clim
% created 2002/02/11 by Bas Kooijman

%% set parameter values
B0 = 1.895; %  1 mM background nutrient
C0 = 0.020; %  2 mM initial nutrient conc
X0 = 0.255; % 3 M, initial biomass
K = 15;   %  7 mM, half saturation constant
yEV = 1.2;%  8 mol/OD, yield of reserves on structure
kC = 120.7;  %  9 mol/(OD.h), max spec nutrient uptake rate
kE = 0.012;   % 10 1/h, reserve turnover rate
kCB = 79.50;   % 11 1/h, exchange from nutrient to background
kBC = 0.7288;  % 12 1/h, exchange from background to nutrient

%% collect parameters in a matrix
pars = [B0 C0 X0 K yEV kC kE kCB kBC; ...
	0  0  1  1 1   1  1  0   0]';

%% set data
%  Data from Prof. José Antonio Perales Vargas-Machuca
%    Área de Tecnologías del Medio Ambiente 
%    Escuela Politécnica Superior de Algeciras
%    Universidad de Cádiz 

%% Optical densities of Isochrysis aff. galbana (notice transpose)
%    in synthethic seawater (means of 3 replicas)
tOD = [0	24	48	72	96;
       0.285	0.318	0.461	0.634	0.807]';

%% p = nmregr('clim', pars, tOD) % estimate parameters
%  get statistics for parameter estimates
%  [cov, cor, sd, ss] = pregr('clim', p, tOD);
%  [p, sd] % show parameter values and standard deviations

%% set plot options
shregr_options('default');
shregr_options('xlabel', 1, 'time, h');
shregr_options('ylabel', 1, 'OD');

%% make plots
shregr('clim', pars, tOD); % show results
