%% Script animal
%  Created by Bas Kooijman at 2000/10/18; modified 2011/02/03

%% Description
% Calculates statistics and produces plots of state variables and fluxes.
% The parameters in the function <pars_animal.html *pars_animal*> can be modified.
%
% The theory for the standard DEB model can be found in:
%    Kooijman, S. A. L. M. 2010 Dynamic Energy Budgets theory
%    for metabolic organisation. Cambridge University Press.
% 
%  The standard DEB model accounts for:
%    effects of food availability (X) and temperature (T).
%    These environmental parameters are taken to be constant in pars_animal
%    but other routines let them vary in time.
%
%  The animal is decomposed in structure (V) and general reserve (E),
%    and metabolic switching is linked to maturity (H)
%  The animal developes through an embryonic, juvenile and adult phase.
%    Assimilation is switched on at birth
%    Investment in maturity is redirected to reproduction at puberty
%  Organic compounds:
%    X = food, V = structure, E = reserve, P = faeces
%  Mineral compounds:
%    C = carbon dioxide, H = water, O = dioxygen, N = nitrogen waste
% 
%  Uptake is proportional to surface area, which is taken to be
%    proportional to the structural volume^(2/3): isomorph

%% Example of use
% animal
 
pars_animal % set parameters and compute quantities

%lsode_options('relative tolerance', 1e-3)

clf; shmics;
fprintf('hit a key to proceed \n');
pause;

clf; shtime_animal;
fprintf('hit a key to proceed \n');
pause;

clf; shphase;
fprintf('hit a key to proceed \n');
pause;

clf; shflux;
fprintf('hit a key to proceed \n');
pause;

clf; shflux_struc;
fprintf('hit a key to proceed \n');
pause;

clf; shflux_weight;
fprintf('hit a key to proceed \n');
pause;

clf; shratio;
fprintf('hit a key to proceed \n');
pause;

clf; shpower;
fprintf('hit a key to proceed \n');
pause;

clf; shscale;