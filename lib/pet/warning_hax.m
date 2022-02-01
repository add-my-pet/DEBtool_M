%% warning_hax
% warns if parameter values are in the reasonable part of the parameter space of hax DEB model 

%%
function warning_hax(p)
% created 2022/01/21 by Bas Kooijman
%% Syntax
% <../warning_hax.m *warning_hax*> (p)

%% Description
% Checks if parameter values are in the reasonable part of the parameter
%    space of the hax DEB model.
% Meant to be run after the estimation procedure
%
% Input
%
% * p: structure with parameters (see below)


warning_hep(p)