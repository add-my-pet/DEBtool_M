%% warning_lossfunc
% warns if parameter values are in the reasonable part of the parameter
% space of the toy model for the lossfunction study

%%
function warning_lossfunc(p)
% created 2016/06/29 by Goncalo Marques

%% Syntax
% <../warning_lossfunc.m *warning_lossfunc*> (par)

%% Description
% Checks if parameter values are in the reasonable part of the parameter
%    space of the toy model for lossfunction study.
% Meant to be run after the estimation procedure
%
% Input
%
% * p: structure with parameters (see below)
