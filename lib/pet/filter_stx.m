%% filter_stx
% filters for allowable parameters of standard DEB model for mammals (with fetus and delay in start of embryo development) 

%%
function [filter, flag] = filter_stx(p)
% created 2015/08/24 by Goncalo Marques, modified 2016/10/25 by Goncalo Marques

%% Syntax
% [filter, flag] = <../filter_stx.m *filter_stx*> (p)

%% Description
% Checks if parameter values are in the allowable part of the parameter
%    space of standard DEB model with fetus without acceleration
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
%     2: some kappa is larger than 1
%     3: growth efficiency is larger than 1
%     4: maturity levels do not increase during life cycle
%     5: puberty cannot be reached

%% Remarks
% The theory behind boundaries is discussed in <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html *LikaAugu2013*>.

  filter = 0; flag = 0; % default setting of filter and flag

  if p.t_0 < 0 % all pars must be positive
    flag = 1;
    return;
  end

  % compute and unpack cpar (compound parameters)
  c = parscomp_st(p);

  if c.kap_G >= 1 % growth efficiency
    flag = 3;    
    return;
  end

  if p.E_Hb >= p.E_Hx || p.E_Hx >= p.E_Hp % maturity at birth, puberty
    flag = 4;
    return;
  end

  [filter, flag] = filter_stf(p);
  
