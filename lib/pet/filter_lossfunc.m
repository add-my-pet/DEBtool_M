%% filter_lossfunc
% filters for allowable parameters of the lossfunction toy model

%%
function [filter, flag] = filter_lossfunc(p)
% created 2016/06/29 by Goncalo Marques

%% Syntax
% [filter, flag] = <../filter_lossfunc.m *filter_lossfunc*> (p)

%% Description
% Checks if parameter values are in the allowable part of the parameter
%    space of the toy model for lossfunction study
% Meant to be run in the estimation procedure
%
% Input
%
% * p: structure with parameters (see below)
%  
% Output
%
% * filter: 0 for hold, 1 for pass
% * flag: indicator of reason for not passing the filter
%
%     0: parameters pass the filter
%     1: some parameter is negative

%% Remarks
% The theory behind boundaries is discussed in <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html *LikaAugu2013*>.

  filter = 0; flag = 0; % default setting of filter and flag
  
  parvec = [p.g; p.k_M; p.U; p.v];
  
  if sum(parvec <= 0) > 0 % all pars must be positive
    flag = 1;
    return;
  end
  
  filter = 1;
