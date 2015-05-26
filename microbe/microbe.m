%% Copyright (C) 2000 Bas Kooijman
%% Author: Bas Kooijman <bas@bio.vu.nl>
%% Created: 2000/10/20, modified 2009/08/01
%% Keywords: Growth and production by microbes in a generalized reactor
%%
%% This program is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%
%% This script has been coded and tested in Matlab version 5.3
%% This script can be obtained from http://www.bio.vu.nl/thb/deb/deblab/
%%   new versions are indicated by the date of creation
%%
%% Requires:
%%   pars, statistics, functions, time_plots
%%
%% Usage: microbe
%%   Calculates statistics and produces plots of state variables and fluxes.
%%   The parameters in the routine 'pars' can be modified.
 
%% The theory for the model can be found in:
%%   Kooijman, S. A. L. M. 2000 Dynamic Energy and Mass Budgets in
%%   Biological Systems. Cambridge University Press.
%% You can download a concepts-paper from http://www.bio.vu.nl/thb/deb/
%%
%% The model accounts for:
%%   effects of substrate concentration in the feed (X_r), supply and
%%   draining rates and temperature (T).
%%   These environmental parameters are taken to be constant in the
%%   present implementation, but it is not difficult to let them vary in
%%   time.
%%
%% The microbe is decomposed in:
%%   structure (V) and general reserves (E)
%% Organic compounds:
%%   X = substrate, V = structure, E = reserve, P = product(s)
%% Mineral compounds:
%%   C = carbon dioxide, H = water, O = dioxygen, N = ammonia
%%
%% Uptake is proportional to surface area, which is taken to be
%%   proportional to the structural volume: V1-morph. This removes the
%%   distinction between the individual and the population level.
%%
%% The simplification k_J = k_M*(1 - kap)/kap is implemented,
%%   which makes this energy-structured model also size-structured
%% The microbe divides when the structural mass exceeds a threshold value
%%
%% In a generalized reactor, the specific supply and draining rates can
%%   be set independently for all compounds. If they are chosen to be
%%   equal, we have a chemostat. If the specific draining rates are set to
%%   zero, we have a fed-batch reactor; if the specific supply rate set to
%%   zero as well, we have a batch-reactor.

pars_microbe;


shbatch;
fprintf('hit a key to proceed \n');
pause;

shchemostat;
fprintf('hit a key to proceed \n');
pause;

shflux_microbe;
fprintf('hit a key to proceed \n');
pause;

shratio;
