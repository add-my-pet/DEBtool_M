%% Copyright (C) 2001 Bas Kooijman
%% Author: Bas Kooijman <bas@bio.vu.nl>
%% Created: 10 sept 2001
%% Keywords: free-living -> endosymbiosis
%%
%% This program is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%
%% Usage: endosym
%%   Produces plots of state variables as functions of time and their
%%   equilibrium values as functions of parameters.
%%   The parameters in the routine pars1 till pars8 can be modified.

%% The theory for the models can be found in: S. A. L. M. Kooijman, P.
%% Auger, J. C. Poggiale and B. W.  Kooi 2001 Eight quantitative steps
%% in the evolution of endosymbiosis and homeostasis. submitted
%%
%% This paper is based on the DEB theory, described in Kooijman, S. A.
%% L. M. 2000 Dynamic Energy and Mass Budgets in Biological Systems.
%% Cambridge University Press. You can download a concepts-paper from
%% http://www.bio.vu.nl/thb/deb/
%%
%% The paper describes the trophic relationships between two species
%% that become fully interlocked in an endosymbiontic relationship in 8
%% steps starting from complete independence. Each species feeds on a
%% single substrate and produces a single product, which is taken up by
%% the other species. The substrate and product for each species are
%% initially substitutable, and then become complementary. The species
%% initially live freely in a homogeneous reactor; later the future
%% endosymbiont has three populations: free-living, inside the mantle
%% space of the future host, and inside the host. Each species initially
%% has a single reserve and single structure. First the structures
%% merge, then the reserves. Eventually a single species with one
%% structure and one reserve emerges.
%%
%% see DEBtools' manual for a description of the levels of integration.

  shtime0;
  fprintf('level 0 time plots; hit a key to proceed \n');
  pause

  %% shstate0;
  %% fprintf('level 0 state plots; hit a key to proceed \n');
  %% pause

  shtime1;
  fprintf('level 1 time plots; hit a key to proceed \n');
  pause

  %% shstate1;
  %% fprintf('level 1 state plots; hit a key to proceed \n');
  %% pause

  shtime2;
  fprintf('level 2 time plots; hit a key to proceed \n');
  pause

  %% shstate2;
  %% fprintf('level 2 state plots; hit a key to proceed \n');
  %% pause

  shtime3;
  fprintf('level 3 time plots; hit a key to proceed \n');
  pause

  %% shstate3;
  %% fprintf('level 3 state plots; hit a key to proceed \n');
  %% pause

  shtime4;
  fprintf('level 4 time plots; hit a key to proceed \n');
  pause

  %% shstate4;
  %% fprintf('level 4 state plots; hit a key to proceed \n');
  %% pause

  shtime5;
  fprintf('level 5 time plots; hit a key to proceed \n');
  pause

  shstate5;
  fprintf('level 5 state plots; hit a key to proceed \n');
  pause

  shtime6;
  fprintf('level 6 time plots; hit a key to proceed \n');
  pause

  shstate6;
  fprintf('level 6 state plots; hit a key to proceed \n');
  pause

  shtime7;
  fprintf('level 7 time plots; hit a key to proceed \n');
  pause

  shstate7;
  fprintf('level 7 state plots; hit a key to proceed \n');
  pause

  shtime8;
  fprintf('level 8 time plots; hit a key to proceed \n');
  pause

  shstate8;
  fprintf('level 8 state plots; hit a key to proceed \n');
  pause
