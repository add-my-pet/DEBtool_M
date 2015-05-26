%% Copyright (C) 2000 Bas Kooijman
%% Author: Bas Kooijman <bas@bio.vu.nl>
%% Created: 2000/10/18
%% Keywords: Enzyme kinetics for the transformation
%%                    n_A A + n_B B -> n_C C
%%
%% This program is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%
%% This script has been coded and tested in Matlab vesion 5.3.1
%% This script can be obtained from http://www.bio.vu.nl/thb/deb/deblab/
%%   new versions are indicated by the date of creation
%%
%% Usage: enzyme
%%   Produces plots of fluxes.
%%   The parameters in the routine 'pars' can be modified.
 
%% The theory for the model can be found in:
%%   Kooijman, S. A. L. M. 2000 Dynamic Energy and Mass Budgets in
%%   Biological Systems. Cambridge University Press.
%% You can download a concepts-paper from http://www.bio.vu.nl/thb/deb/
%%

pars_enzyme;


%% pipe_gnuplot;

shcontsu;
fprintf('hit a key to proceed \n');
pause;

shbatch;
fprintf('hit a key to proceed \n');
pause;

