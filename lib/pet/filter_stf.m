%% filter_stf
% filters for allowable parameters of standard DEB model with fetus and without acceleration

%%
function [filter, flag] = filter_stf(p)
% created 2014/01/22 by Bas Kooijman; modified 2015/04/15, 2015/07/29 by Goncalo Marques
% modified 2015/08/03 by Starrlight, 2016/10/25 by Goncalo Marques

%% Syntax
% [filter, flag] = <../filter_std.m *filter_std*> (p)

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
  
  parvec = [p.z; p.v; p.kap; p.p_M; p.E_G; p.k_J; p.E_Hb; p.E_Hp; p.kap_R; p.h_a; p.T_A];
  
  if sum(parvec <= 0) > 0 % all pars must be positive
    flag = 1;
    return;
  elseif p.p_T < 0
    flag = 1;
    return;
  end

  if p.E_Hb >= p.E_Hp % maturity at birth, puberty
    flag = 4;
    return;
  end

  if p.kap > 1
    flag = 2;
    return;
  end

  parvec = [p.kap; p.kap_R; p.kap_X; p.kap_P];
  
  if sum(parvec >= 1) > 0 
    flag = 2;
    return;
  end

  % compute c (compound parameters)
  c = parscomp_st(p);

  if c.kap_G >= 1 % growth efficiency
    flag = 3;    
    return;
  end

  if c.k * c.v_Hp >= p.f * (p.f - c.l_T)^2 % constraint required for reaching puberty
    flag = 5;    
    return;
  end

  filter = 1;
