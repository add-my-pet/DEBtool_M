%% warning_stx
% warns if parameter values are in the reasonable part of the parameter space of standard DEB model for mammals (with fetus and delay of start of development for embryo)

%%
function warning_stx(p)
% created 2015/08/24 by Goncalo Marques

%% Syntax
% <../warning_stx.m *warning_stx*> (p)

%% Description
% Checks if parameter values are in the reasonable part of the parameter
%    space of standard DEB model for mammals (with fetus and delay of start of development for embryo).
% Meant to be run after the estimation procedure
%
% Input
%
% * p: structure with parameters (see below)

  warning_stf(p);
