%% filter_hex
% filters for allowable parameters of holometabolous insect DEB model

%%
function [filter, flag] = filter_hex(p)
% created 2015/06/04 by Goncalo Marques; modified 2015/06/19, 2015/07/29 by Goncalo Marques
% modified 2015/08/03 by Starrlight Augustine, 2016/04/14 by Bas Kooijman

%% Syntax
% [filter flag] = <../filter_hex.m *filter_hex*> (par)

%% Description
% Checks if parameter values are in the allowable part of the parameter
%    space of standard DEB model without acceleration
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
%     4: birth cannot be reached
%     5: emergence cannot be reached

%% Remarks
% The theory behind boundaries is discussed in <http://www.bio.vu.nl/thb/research/bib/LikaAugu2013.html *LikaAugu2013*>.

  filter = 0; flag = 0; % default setting of filter and flag
  
  parvec = [p.z; p.v; p.kap; p.p_M; p.E_G; p.k_J; p.E_Hb; p.s_j; p.E_He; p.kap_R; p.kap_V; p.h_a; p.T_A];
  
  if sum(parvec <= 0) > 0 % all pars must be positive
    flag = 1;
    return;
  elseif p.p_T < 0
    flag = 1;
    return;
  end

  parvec = [p.kap; p.kap_R; p.kap_X; p.kap_P; p.kap_V];
  
  if sum(parvec >= 1) > 0 
    flag = 2;
    return;
  end

  % compute and unpack c (compound parameters)
  c = parscomp_st(p);

  if c.kap_G >= 1 % growth efficiency
    flag = 3;    
    return;
  end

  if ~reach_birth(c.g, c.k, c.v_Hb, p.f) % constraint required for reaching birth
    flag = 4;    
    return;
  end

  if p.s_j >= 1 % fraction of max [E_R] for pupation
    flag = 5;    
    return;
  end

  filter = 1;
