%  Copyright (C) 2000 Bas Kooijman
%  Author: Bas Kooijman <bas@bio.vu.nl>
%  Created: 2002/03/03
%  Keywords: Growth and production by algae in a generalized reactor
% 
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
% 
%  This script has been coded and tested in Matlab version 5.3
%  This script can be obtained from http://www.bio.vu.nl/thb/deb/deblab/
%    new versions are indicated by the date of creation
% 
%  Requires:
%    pars, parcomp, shbatch, shbatch1, dbatch, dbatch1, shchem, shchem1,
%      dchem, dchem1, findr, findrm
% 
%  Usage: alga
%    Produces plots of state variables in batch reactors and chemostats.
%    The parameters in the routine 'pars' can be modified.
 
%  The theory for the model can be found in:
%    Kooijman, S. A. L. M. 2000 Dynamic Energy and Mass Budgets in
%    Biological Systems. Cambridge University Press.
%  You can download a concepts-paper from http://www.bio.vu.nl/thb/deb/
% 
%  This implementation accounts for:
%    effects of ammonia and phospate concentrations in the feed (X_Nr, X_Pr),
%    throughput rates (h) and temperature (T).
%    These environmental parameters are taken to be constant in the
%    present implementation, but it is not difficult to let them vary in
%    time. Limitations by light, carbon and other can be implemented as well
% 
%  Organic compounds (that make up the alga):
%    V = structure, EN = N-reserve, EP = P-reserve,
%  Mineral compounds:
%    C = carbon dioxide, H = water, O = dioxygen, N = ammonia, P = phosphate
%    NE = excreted N-reserve, NP = excreted P-reserve
%    
%  Uptake is proportional to surface area, which is taken to be
%    proportional to the structural volume: V1-morph. This removes the
%    distinction between the individual and the population level.
% 
%  The simplification k_J = k_M * (1 - kap)/ kap is implemented,
%    which makes this energy-structured model also size-structured
%  The alga divides when the structural mass exceeds a threshold value

% path(path,'../lib/misc/');

pars_alga;

%% batch reactor
shbatch;  % excreted reserves are NOT available for assimilation
fprintf('hit a key to proceed \n');
pause;

shbatch1; % excreted reserves are available for assimilation
fprintf('hit a key to proceed \n');
pause;

%% chemostat
shchem;   % excreted reserves are NOT available for assimilation
fprintf('hit a key to proceed \n');
pause;

shchem1;  % excreted reserves are available for assimilation
fprintf('hit a key to proceed \n');
pause;

shcycle;  % two nutrients concentrations cycle in time
%% parameters are specified in pars_cycle



