%% Copyright (C) 2001 Bas Kooijman
%% Author: Bas Kooijman <bas@bio.vu.nl>
%% Created: 25 aug 2001; modofied 2007/08/08
%% Keywords: cummunity of mixotrophs
%%
%% This program is distributed in the hope that it will be useful, but
%% WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
%%
%% Usage: mixo
%%   Produces plots of state variables as functions of time and their
%%   equilibrium values as functions of parameters.
%%   The parameters in the routines pars0, pars1 and pars3 can be modified.

%% The theory for the models can be found in: S. A. L. M. Kooijman, 
%%   Dijkstra, H. A. and Kooi, B. W. 2001 Light-induced mass turnover 
%%   in a mono-species community of mixotrophs. J. Theor. Biol., to appear
%%
%% This paper is based on the DEB theory, described in Kooijman, S. A.
%% L. M. 2000 Dynamic Energy and Mass Budgets in Biological Systems.
%% Cambridge University Press. You can download a concepts-paper from
%% http://www.bio.vu.nl/thb/deb/
%%
%% The paper describes the nutrient and organic matter turnover in a 
%% homogeneous system that is closed for mass and open for energy. 
%% It also considers an one-dimensional spatial structure, with a light 
%% gradient. The rules for uptake and use of resources imply the 
%% development of particular profiles for systems's components.

  shtime0_mixo;
  fprintf('time plots for 0 reserves; hit a key to proceed \n');
  pause

  clf
  shstate0_mixo;
  fprintf('state plots for 0 reserves; hit a key to proceed \n');
  pause

  clf
  shtime1_mixo;
  fprintf('time plots for 1 reserve; hit a key to proceed \n');
  pause

  clf
  shstate1_mixo;
  fprintf('state plots for 1 reserve; hit a key to proceed \n');
  pause

  clf
  shtime3_mixo;
  fprintf('time plots for 3 reserves; hit a key to proceed \n');
  pause

  clf
  shstate3_mixo;


  