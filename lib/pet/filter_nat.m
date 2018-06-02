%% filter_nat
% filters for allowable parameters in case of not-a-typified model

%%
function [filter, flag] = filter_nat(p)
% created 2017/02/03 by Bas Kooijman

%% Syntax
% [filter, flag] = <../filter_nat.m *filter_nat*> (p)

%% Description
% Always pass the filter
% Meant to be run in the estim_pars
%
% Input
%
% * p: structure with parameters (see below)
%  
% Output
%
% * filter: 1 for pass
% * flag: 0: parameters pass the filter

%% Remarks
% No checks if model "nat" or estim_options "no-filter" is specified.
% In/output is similar to other filters. 
% It still allows the user to specify a user-defined filter in the predict-file.

  filter = 1; flag = 0; % default setting of filter and flag
  
