%% filter_ntm
% void filter file for non-typified model  

%%
function [filter, flag] = filter_ntm(p)
% created 2016/03/16 by Goncalo Marques

%% Syntax
% [filter, flag] = <../filter_ntm.m *filter_ntm*> (p)

%% Description
% Checks if parameter values are in the allowable part of the parameter
%    space 
% Meant to be run in the estimation procedure
%
% Input
%
% * p: structure with parameters (see below)
%  
% Output
%
% * filter: 0 for hold, 1 for pass
% * flag: indicator of reason for not passing the filter (0)
%

%% Remarks
%  The theory behind boundaries is discussed in 
%    <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html LikaAugu2013>.

  filter = 1; flag = 0; % default setting of filter and flag
