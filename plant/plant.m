%% Copyright (C) 2000 Bas Kooijman
%% Author: Bas Kooijman <bas@bio.vu.nl>
%% Created: 2000/10/18
%% Keywords: Growth of an individual plant
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
%%   pars_plant, flux, findr, time_plots
%%
%% Usage: plant
%%   Produces plots of state variables as functions of time.
%%   The parameters in the routine "pars" can be modified.
 
%% The theory for the model can be found in:
%%   Kooijman, S. A. L. M. 2000 Dynamic Energy and Mass Budgets in
%%   Biological Systems. Cambridge University Press.
%% You can download a concepts-paper from http://www.bio.vu.nl/thb/deb/
%%
%% The model accounts for:
%%   effects of light (J_L.F), oxygen (X_O) and carbon dioxide (X_C)
%%   concentrations in the air, ammonium (X_NH), nitrate (X_NO) and
%%   water (X_H) concentrations in the soil, and temperature (T).
%%   These environmental parameters are taken to be constant in the
%%   present implementation, but it is not difficult to let them vary in
%%   time.
%% Control vector:
%%   X = [J_L.F, X_C, X_O, X_NH, X_NO, X_H, T]
%%
%% The plant is decomposed in:
%%   shoot product (PS, e.g. wood), structure (VS), general reserves (ES),
%%     nitrogen-reserves (ENS) and carbon-reserves (ECS)
%%   root  product (PR, e.g. wood), structure (VR), general reserves (ER),
%%     nitrogen-reserves (ENR) and carbon-reserves (ECR)
%% State vector:
%%   M = [M_PS, M_VS, M_ECS, M_ENS, M_ES, M_PR, M_VR, M_ECR, M_ENR, M_ER]
%%
%% It developes through an embryonic, juvenile and adult phase.
%%   No assimilation occurs during the embryonic phase
%%   No reproduction allocation occurs during the juvenile phase
%%
%% The interaction between root and shoot resembles that between host and symbiont
%%   It differs by translocation of general reserves, and the occurence
%%   of the ratio of shoot and root surface area's in the saturation
%%   constants for nutrients and water. 
%%
%% Uptake is proportional to surface area of root or shoot. The area's
%%   are take to be functions of the structure, and specified in routine
%%   'flux'; many plants develop from a V1-morph, via a isomorph, to a V0-morph.
%% Maintenance is proportional to structure.

pars_plant;
shtime_plant;